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
        # get the first step in the survey with an unassigned page

        myIndex = -1
        result = flow.find (step) =>
          myIndex++
          step.get('page') is false
        return myIndex

    assignNewPage: (flow, currentPage) ->
      loopThroughSteps = true
      myStepIndex = @getStartingStepIndex flow, currentPage

      while loopThroughSteps and myStepIndex < flow.length
        currentStep = flow.at myStepIndex

        if currentStep.get('page') is false
          # a page hasn't been assigned to this step yet.

          switch currentStep.get('type')
            when "intro"
              if currentStep.get('status') is "displayed"
                currentStep.set 'page', 1
                # the intro step gets a page all to itself, if displayed
                loopThroughSteps = false
            when "beforeSurveySubmit"
              currentStep.set 'page', currentPage+1
            when "afterSurveySubmit"
              currentStep.set 'page', currentPage+2
              loopThroughSteps = false
            else
              # it's a prompt

              if App.request("flow:condition:invalid:future:reference", currentStep.get('condition'))
                # stop, we've hit something that has an invalid reference.
                loopThroughSteps = false
              else
                # Condition check also sets the status of the prompt to either "displaying"
                # or "not_displayed"
                isPassed = App.request "flow:condition:check", currentStep.get('id')
                if isPassed 
                  currentStep.set 'page', currentPage

        myStepIndex++

    clearOldPage: (flow, oldPage) ->
      flow.each (step) =>
        if step.get('page') >= oldPage
          step.set 'page', false
          App.vent.trigger "flow:step:reset", step.get('id')

    getPageFirstStep: (flow, page) ->
      console.log 'getPageFirstStep'
      result = flow.findWhere(page: "#{page}")
      if result is undefined then throw new Error "Page #{page} does not exist in flow"
      result

    getPageSteps: (flow, page) ->
      console.log 'getPageSteps'
      resultArr = flow.where(page: "#{page}")
      new Entities.Collection resultArr

  App.vent.on "surveytracker:page:new", (page) ->
    API.assignNewPage App.request('flow:current'), page

  App.vent.on "surveytracker:page:old", (oldPage) ->
    API.clearOldPage App.request('flow:current'), oldPage

  App.reqres.setHandler "flow:page:steps", (page) ->
    API.getPageSteps App.request('flow:current'), page

  App.reqres.setHandler "flow:page:step:first", (page) ->
    API.getPageFirstStep App.request('flow:current'), page
