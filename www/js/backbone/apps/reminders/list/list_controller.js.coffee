@Ohmage.module "RemindersApp.List", (List, App, Backbone, Marionette, $, _) ->

  # RemindersApp renders the Reminders page.

  class List.Controller extends App.Controllers.Application
    initialize: ->
      @layout = @getLayoutView()

      reminders = App.request 'reminders:current'

      @listenTo @layout, "show", =>
        console.log "showing layout"
        @listRegion reminders

      @show @layout

    listRegion: (reminders) ->
      listView = @getListView reminders

      @show listView, region: @layout.listRegion

    getListView: (reminders) ->
      new List.Reminders
        collection: reminders

    getLayoutView: ->
      new List.Layout
