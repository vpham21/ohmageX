@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

    clearOldPage: (flow, oldPage) ->
      flow.each (step) =>
        if step.get('page') is oldPage
          step.set 'page', false
          App.vent.trigger "flow:step:reset", step.get('id')

  App.vent.on "surveytracker:page:old", (oldPage) ->
    API.clearOldPage App.request('flow:current'), oldPage
