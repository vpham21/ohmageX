@Ohmage.module "SettingsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Settings extends App.Views.ItemView
    className: "text-container"
    template: "settings/show/info"

    serializeData: ->

    onRender: ->

  class Show.Layout extends App.Views.Layout
    template: "settings/show/show_layout"
    regions:
      settingsRegion: "#settings-region"
