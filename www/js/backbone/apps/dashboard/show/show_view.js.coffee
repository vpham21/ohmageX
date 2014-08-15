@Ohmage.module "DashboardApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: "dashboard/show/show_layout"

    regions:
        fooRegion: "#foo-region"