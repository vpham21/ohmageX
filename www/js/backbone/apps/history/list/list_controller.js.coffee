@Ohmage.module "HistoryApp.List", (List, App, Backbone, Marionette, $, _) ->

  # History List renders the history List view.

  class List.Controller extends App.Controllers.Application
    initialize: ->
      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        console.log "showing history layout"

      @show @layout


    getLayoutView: ->
      new List.Layout
