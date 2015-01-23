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
        if permissions.get('localNotification') is true
          if surveys.length is 0
            @noticeRegion 'No saved surveys! You must have saved surveys in order to create reminders.'
          else
            @addRegion reminders
            @listRegion reminders
        else
          # attempt to register permissions here if it's false.
          App.execute "permissions:register:localnotifications"

      @show @layout

    noticeRegion: (message) ->
      notice = new Backbone.Model message: message
      noticeView = @getNoticeView notice

      @show noticeView, region: @layout.noticeRegion
    listRegion: (reminders) ->
      listView = @getListView reminders

      @show listView, region: @layout.listRegion

    getNoticeView: (notice) ->
      new List.Notice
        model: notice

    getListView: (reminders) ->
      new List.Reminders
        collection: reminders

    getLayoutView: (permissions) ->
      console.log 'permissions', permissions
      new List.Layout
        model: permissions
