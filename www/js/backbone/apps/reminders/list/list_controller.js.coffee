@Ohmage.module "RemindersApp.List", (List, App, Backbone, Marionette, $, _) ->

  # RemindersApp renders the Reminders page.

  class List.Controller extends App.Controllers.Application
    initialize: (options) ->

      _.defaults options,
        forceRefresh: false

      permissions = App.request 'permissions:current'
      # permissions = new Backbone.Model(localNotification: true)
      reminders = App.request 'reminders:current'
      @layout = @getLayoutView permissions

      @listenTo permissions, "localnotification:checked", =>
        App.execute "reminders:force:refresh"

      if !options.forceRefresh
        @listenTo permissions, "localnotification:registered", =>
          App.execute "reminders:force:refresh"

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

    getLayoutView: (permissions) ->
      console.log 'permissions', permissions
      new List.Layout
        model: permissions
