@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Response Entity contains data related to the responses
  # within a given Survey.

  # currentResponses
  # "responses:init" initializes a ResponseCollection that persists in memory.
  # This collection is removed with "responses:destroy"
  currentResponses = false

  class Entities.Response extends Entities.Model
    defaults: # default values for all Responses:
      response: "NOT_DISPLAYED" # All submitted responses are not_displayed

  class Entities.ResponseCollection extends Entities.Collection
    model: Entities.Response

  API = 
    init: ($surveyXML) ->
      throw new Error "responses already initialized, use 'responses:destroy' to remove existing responses" unless currentResponses is false
      currentResponses = new Entities.ResponseCollection
      myResponses = @createResponses App.request("survey:xml:content", $surveyXML)
      currentResponses.add myResponses
      console.log 'currentResponses', currentResponses.toJSON()
    createResponses: ($contentXML) ->
      # Loop through all responses.
      # Only want to create a Response for a contentItem that actually
      # can accept responses, so we check its type. Currently a "message"
      # is the only item that does not have a response.
      # The .map() creates a new array, each key is object or false.
      # The .filter() removes the false keys.

      _.chain($contentXML.children()).map((child) ->
        $child = $(child)

        isResponseType = $child.tagText('promptType') isnt 'message'

        if isResponseType then {id: $child.tagText('id') } else false
      ).filter((result) -> !!result).value()


  App.commands.setHandler "responses:init", ($surveyXML) ->
    API.init $surveyXML

  App.reqres.setHandler "responses:current", ->
    throw new Error "responses not initialized, use 'responses:init' to create new Responses" unless currentResponses isnt false
    currentResponses