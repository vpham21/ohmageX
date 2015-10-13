@Ohmage.module "SettingsDateApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # SettingsDateApp renders the Help page.

  class Show.Controller extends App.Controllers.Application
    initialize: ->
      @layout = @getLayoutView()

      settings_date = App.request 'settings_date:current'

      @listenTo @layout, "show", =>
        console.log "showing layout"
        @settingsDateRegion settings_date

      @show @layout

    settingsDateRegion: (settings_date) ->
      settingsDateView = @getInfoView settings_date

      @show settingsDateView, region: @layout.settingsDateRegion

      @listenTo settingsDateView, "settings_date:save:clicked", (dateString)->
        console.log 'show_controller.listenTo.navigate:settings_date:clicked'
        App.vent.trigger "settings_date:save:clicked", moment(dateString)

    getInfoView: (settings_date) ->
      new Show.SettingsDate
        model: settings_date

    getLayoutView: ->
      new Show.Layout
