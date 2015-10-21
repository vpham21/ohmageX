@Ohmage.module "GoalsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # GoalsApp renders the Goals page.

  class Show.Controller extends App.Controllers.Application
    initialize: ->
      @layout = @getLayoutView()

      goals = App.request 'goals:current'

      @listenTo @layout, "show", =>
        console.log "showing layout"
        @goalsRegion goals

      @show @layout

    goalsRegion: (goals) ->
      goalsView = @getInfoView goals

      @show goalsView, region: @layout.goalsRegion

    getInfoView: (goals) ->
      new Show.Goals
        model: goals

    getLayoutView: ->
      new Show.Layout
