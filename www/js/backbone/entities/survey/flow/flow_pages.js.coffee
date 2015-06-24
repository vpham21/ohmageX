@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Flow Entity contains data related to the flow
  # of the Steps within a Survey.
  # This module contains the Page handlers for Flow for survey multi-prompt display.

  # References the current Flow StepCollection object, defined in flow_init.js.coffee
  # via the interface "flow:current"

  API =
    getStartingStepIndex: (flow, currentPage) ->
      if currentPage is 1
        # a fresh survey with NO assigned pages
        return 0
      else
        # we start checking the first step after the previous page-assigned step.
        # For example, if we're starting to assign page number 2, we get the index of
        # the first step after the latest step with a page number of 1.
        flowArr = flow.toJSON()
        myIndex = 0
        # because the array is flipped, to get the next item after the found item,
        # you must use length - index
        _.find(flowArr.reverse(), (item, index) => if (item.page is currentPage-1) then myIndex = flowArr.length - index)
        return myIndex

    assignNewPage: (flow, currentPage) ->
      loopThroughSteps = true
      myStepIndex = @getStartingStepIndex flow, currentPage

      while loopThroughSteps and myStepIndex <= flow.length
        currentStep = flow.at myStepIndex
        myStepIndex++

    clearOldPage: (flow, oldPage) ->
      flow.each (step) =>
        if step.get('page') is oldPage
          step.set 'page', false
          App.vent.trigger "flow:step:reset", step.get('id')

  App.vent.on "surveytracker:page:old", (oldPage) ->
    API.clearOldPage App.request('flow:current'), oldPage
