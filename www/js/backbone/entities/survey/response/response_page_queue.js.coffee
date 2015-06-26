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

      currentDeferred = queue.map( (item, key) ->
        currentIndices.push(item.get 'id')
        return new $.Deferred()
      )

      # tracking indices in a separate array.
      # Required if using Coffeescript splats to pass
      # arguments to Deferred (which map to .apply())
      # can't use an "associative" array
      $.when( currentDeferred... ).done =>
        @whenComplete surveyId, successCallback, errorCallback

      # Fire a validation event for ALL of the responses in the queue.
      queue.each( (item) =>
        App.vent.trigger "survey:response:get", surveyId, item.get('id')
      )

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
