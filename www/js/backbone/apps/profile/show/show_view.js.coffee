@Ohmage.module "ProfileApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Info extends App.Views.ItemView
    className: "text-container"
    template: "profile/show/info"

  class Show.Layout extends App.Views.Layout
    template: "profile/show/show_layout"
    regions:
      infoRegion: "#info-region"
