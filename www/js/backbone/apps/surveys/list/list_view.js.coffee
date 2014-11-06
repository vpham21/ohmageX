@Ohmage.module "SurveysApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Logout extends App.Views.ItemView
    template: "surveys/list/logout"
    triggers:
      "click button": "logout:clicked"

  class List.Survey extends App.Views.ItemView
    initialize: ->
      @listenTo @model, 'change', @render
    tagName: 'li'
    getTemplate: ->
      if @model.get('status') is 'running' then "surveys/list/_item_running" else "surveys/list/_item_stopped"
    triggers:
      "click .stopped-survey": "stopped:clicked"
      "click .running-survey": "running:clicked"

  class List.Surveys extends App.Views.CompositeView
    template: "surveys/list/surveys"
    childView: List.Survey
    childViewContainer: ".surveys"

  class List.Layout extends App.Views.Layout
    template: "surveys/list/list_layout"
    regions:
      listRegion: "#list-region"
      logoutRegion: "#logout-region"
