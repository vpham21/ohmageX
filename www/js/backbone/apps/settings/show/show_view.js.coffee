@Ohmage.module "SettingsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Settings extends App.Views.ItemView
    className: "text-container"
    template: "settings/show/info"
    triggers:
      "click .navigate-goals": "navigate:goals:clicked"
      "click .navigate-profile": "navigate:profile:clicked"
      "click .navigate-settings-date": "navigate:settings_date:clicked"


  class Show.Layout extends App.Views.Layout
    template: "settings/show/show_layout"
    regions:
      settingsRegion: "#settings-region"