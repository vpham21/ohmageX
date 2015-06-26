@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # This queue handles all responses on a given page.

  currentDeferred = []
  currentIndices = []
  errorCount = 0

  API =
    validateAll: (queue, surveyId, successCallback, errorCallback) ->
      console.log 'response page queue validateAll'

      currentDeferred = []
      currentIndices = []
      errorCount = 0


    itemError: (itemId) ->
      errorCount++
      myIndex = currentIndices.indexOf(itemId)
      currentDeferred[myIndex].resolve()

    itemSuccess: (itemId) ->
      myIndex = currentIndices.indexOf(itemId)
      currentDeferred[myIndex].resolve()

  App.vent.on "survey:page:responses:get", (surveyId, page, successCallback, errorCallback) ->
    API.validateAll App.request('flow:page:steps', page), surveyId, successCallback, errorCallback

  App.on "before:start", ->

    if App.custom.functionality.multi_question_survey_flow is true
      App.vent.on "response:set:error", (error, surveyId, stepId) ->
        API.itemError stepId

      App.vent.on "response:set:success", (response, surveyId, stepId) ->
        API.itemSuccess stepId
