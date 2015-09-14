@Ohmage.module "HelpApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # HelpApp renders the Help page.

  class Show.Controller extends App.Controllers.Application
    initialize: ->
      @layout = @getLayoutView()

      help = App.request 'help:current'

      @listenTo @layout, "show", =>
        console.log "showing layout"
        @helpRegion help

      @show @layout

    helpRegion: (help) ->
      helpView = @getInfoView help

      @show helpView, region: @layout.helpRegion

    getInfoView: (help) ->
      new Show.Help
        model: help

    getLayoutView: ->
      new Show.Layout
