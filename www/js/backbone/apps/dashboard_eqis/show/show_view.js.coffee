@Ohmage.module "DashboardeQISApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: "dashboard_eqis/show/show_layout"
    regions:
      artifactsRegion: "#artifacts-region"
