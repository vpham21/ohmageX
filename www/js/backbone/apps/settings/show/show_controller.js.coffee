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

      @show settingsView, region: @layout.settingsRegion

    getInfoView: (settings) ->
      new Show.Settings
        model: settings

    getLayoutView: ->
      new Show.Layout
