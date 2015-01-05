@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Custom Choice Entity saves and restores custom choices for a user.

  currentChoices = false

  class Entities.CustomChoice extends Entities.Model

  class Entities.CustomChoices extends Entities.Collection
    model: Entities.CustomChoice


  API =
    init: ->
      App.request "storage:get", 'custom_choices', ((result) =>
        # customChoice is retrieved from raw JSON.
        console.log 'custom choices retrieved from storage'
        currentChoices = new Entities.CustomChoices result
      ), =>
        console.log 'custom choices not retrieved from storage'
        currentChoices = false

    addChoice: (surveyId, stepId, value) ->
      # expects campaign to be a Model or JSON format.

      if !currentChoices then currentChoices = new Entities.CustomChoices

      currentChoices.add
        campaign_urn: App.request "survey:saved:urn", surveyId
        surveyId: surveyId
        stepId: stepId
        value: value

      @updateLocal( =>
        console.log "custom_choices entity saved in localStorage"
        App.vent.trigger "prompt:customchoice:new:success", surveyId, stepId, value
      )

    removeChoice: (surveyId, stepId, value) ->
      removed = currentChoices.where
        surveyId: surveyId
        stepId: stepId
        value: value

      currentChoices.remove removed
      @updateLocal( =>
        console.log "custom_choices entity removed from localStorage"
        App.vent.trigger "prompt:customchoice:remove:success", surveyId, stepId, value
      )

    removeCampaignChoices: (campaign_urn) ->
      removed = currentChoices.where
        campaign_urn: campaign_urn

      currentChoices.remove removed
      @updateLocal( =>
        console.log "campaign custom choices removed from localStorage"
        App.vent.trigger "prompt:customchoice:campaign:remove:success", campaign_urn
      )


    getMergedChoices: (surveyId, stepId, original) ->
      
      # map currentChoices to an array that matches the format of ChoiceCollection Models.
      customArr = currentChoices.chain().filter( (choice) ->
        return choice.get('surveyId') is surveyId and choice.get('stepId') is stepId
      ).map( (choice) ->
        key: _.guid()
        label: choice.get 'value'
        parentId: stepId
        custom: true
      ).value()
      console.log 'getMergedChoices surveyId, stepId, customArr', surveyId, stepId, customArr

      # merge the currentChoices formatted array with the original ChoiceCollection
      # into a new collection for output. 
      result = new Entities.ChoiceCollection _.union(original.toJSON(), customArr)

      # saving the merged collection to a variable before returning it prevents the 
      # "duplicate custom choice" error that may happen when re-displaying a custom choice
      result

    updateLocal: (callback) ->
      # update localStorage index custom_choices with the current version of campaignsSaved entity
      App.execute "storage:save", 'custom_choices', currentChoices.toJSON(), callback

    clear: ->
      currentChoices = false
      App.execute "storage:clear", 'custom_choices', ->
        console.log 'custom choices erased'
        App.vent.trigger "prompt:customchoice:cleared"

  App.reqres.setHandler "prompt:customchoices:entity", ->
    currentChoices

  App.reqres.setHandler "prompt:customchoices:merged", (surveyId, stepId, choiceCollection) ->
    if !currentChoices then return choiceCollection
    API.getMergedChoices surveyId, stepId, choiceCollection

  App.commands.setHandler "prompt:customchoice:add", (surveyId, stepId, value) ->
    API.addChoice surveyId, stepId, value

  App.commands.setHandler "prompt:customchoice:remove", (surveyId, stepId, value) ->
    API.removeChoice surveyId, stepId, value

  App.vent.on "campaign:saved:remove", (campaign_urn) ->
    API.removeCampaignChoices campaign_urn

  App.vent.on "credentials:cleared", ->
    API.clear()

  Entities.on "start", ->
    API.init()
