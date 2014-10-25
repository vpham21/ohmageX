@Ohmage.module "SurveysApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Logout extends App.Views.ItemView
    template: "surveys/list/logout"
    triggers:
      "click button": "logout:clicked"

  class List.Survey extends App.Views.ItemView
    tagName: 'li'
    template: "surveys/list/survey_item"
    triggers:
      "click": "survey:clicked"

  class List.Surveys extends App.Views.CompositeView
    template: "surveys/list/surveys"
    childView: List.Survey
    childViewContainer: ".surveys"

  class List.Layout extends App.Views.Layout
    template: "surveys/list/list_layout"
    regions:
      listRegion: "#list-region"
      logoutRegion: "#logout-region"