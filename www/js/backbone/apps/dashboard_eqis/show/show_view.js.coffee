@Ohmage.module "DashboardeQISApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Notice extends App.Views.ItemView
    template: "dashboard_eqis/show/notice"
    className: "notice-nopop"

  class Show.Artifact extends App.Views.ItemView
    tagName: "li"
    template: "dashboard_eqis/show/artifact"
    triggers:
      "click button.first-survey": "newsurvey:first:clicked"
      "click button.second-survey": "newsurvey:second:clicked"
      "click button.response-count": "responsecount:clicked"

  class Show.Artifacts extends App.Views.CompositeView
    childView: Show.Artifact
    childViewContainer: ".list ul"
    template: "dashboard_eqis/show/artifacts"
    initialize: ->
      @listenTo @collection, 'reset', @render

  class Show.Layout extends App.Views.Layout
    template: "dashboard_eqis/show/show_layout"
    regions:
      artifactsRegion: "#artifacts-region"
