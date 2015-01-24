@Ohmage.module "RemindersApp.List", (List, App, Backbone, Marionette, $, _) ->

  # RemindersApp renders the Reminders page.

  class List.Controller extends App.Controllers.Application
    initialize: (options) ->

      _.defaults options,
        forceRefresh: false

      permissions = App.request 'permissions:current'
      # permissions = new Backbone.Model(localNotification: true)
      reminders = App.request 'reminders:current'
      surveys = App.request 'surveys:saved'

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

    addRegion: (reminders) ->
      addView = @getAddView()

      @listenTo addView, "add:clicked", ->
        App.execute "reminders:add:new"

      @show addView, region: @layout.addRegion

    listRegion: (reminders) ->
      listView = @getListView reminders

      @listenTo listView, "childview:before:render", (childView) =>
        # set the surveyId and surveyTitle if they're not set yet.
        # (they default to `false`)
        console.log 'childView model surveyId', childView.model.get('surveyId')
        if childView.model.get('surveyId') is false
          # this should only execute once per Reminder view.
          # this always happens before rendering.
          # declare a new reminderSurveys object.
          childView.model.reminderSurveys = App.request("reminders:surveys")
          childView.model.set('surveyId', childView.model.reminderSurveys.at(0).get('id'))
          childView.model.set('surveyTitle', childView.model.reminderSurveys.at(0).get('title'))
          @listenTo childView.model.reminderSurveys, "change:chosen", (model) =>
            if model.isChosen()
              # this binds reminderSurveys with the Reminders collection.
              childView.model.set('surveyId', model.get('id'))
              childView.model.set('surveyTitle', model.get('title'))

      @listenTo listView, "childview:render", (childView) =>
        console.log 'childview:render'
        console.log 'reminders', reminders
        if reminders.length > 0
          # This event always fires after childview:before:render,
          # these events are assumed to be synchronous.
          # Hence the childView.model.reminderSurveys here is assumed to exist.
          surveysView = @getReminderSurveysView childView.model.reminderSurveys
          childView.model.reminderSurveys.chooseById childView.model.get('surveyId')
          childView.surveysRegion.show surveysView
      @show listView, region: @layout.listRegion

    getReminderSurveysView: (surveys) ->
      new List.ReminderSurveys
        collection: surveys

    getNoticeView: (notice) ->
      new List.Notice
        model: notice

    getAddView: ->
      new List.Add

    getListView: (reminders) ->
      new List.Reminders
        collection: reminders

    getLayoutView: (permissions) ->
      console.log 'permissions', permissions
      new List.Layout
        model: permissions
