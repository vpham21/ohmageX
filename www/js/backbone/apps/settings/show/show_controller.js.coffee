@Ohmage.module "SettingsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # SettingsApp renders the Settings page.

  class Show.Controller extends App.Controllers.Application
    initialize: ->
      @layout = @getLayoutView()

      settings = App.request 'settings:current'

      @listenTo @layout, "show", =>
        console.log "showing layout"
        @settingsRegion settings

      @show @layout

    settingsRegion: (settings) ->
      settingsView = @getInfoView settings

      @listenTo settingsView, "navigate:profile:clicked", ->
        console.log 'show_controller.listenTo.navigate:profile:clicked'
        App.vent.trigger "settings:navigate:profile"

      @listenTo settingsView, "navigate:settings_date:clicked", ->
        console.log 'show_controller.listenTo.navigate:settings_date:clicked'
        App.vent.trigger "settings:navigate:settings_date"

      @show settingsView, region: @layout.settingsRegion

    getInfoView: (settings) ->
      new Show.Settings
        model: settings

    getLayoutView: ->
      new Show.Layout
