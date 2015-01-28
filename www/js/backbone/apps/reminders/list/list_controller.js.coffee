
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
        if childView.model.get('surveyId') is false
          # set the surveyId and surveyTitle if they're not set yet.
          # (they default to `false`)
          reminderSurveys = App.request("reminders:surveys")
          childView.model.trigger "survey:selected", reminderSurveys.at(0)

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

          labelView = @getReminderLabelView childView.model
          childView.labelRegion.show labelView

      @listenTo listView, "childview:reminder:submit", (view, response) =>
        console.log 'childview:reminder:submit model', view.model
        # close any notices
        @noticeRegion ''
        App.vent.trigger "reminders:reminder:submit", view.model, response

      @listenTo reminders, "invalid", (reminderModel) =>
        # reminder submit validation failed
        console.log "reminder invalid, errors are", reminderModel.validationError
        App.vent.trigger "reminder:validate:fail", reminderModel.validationError
        @noticeRegion reminderModel.validationError

      @listenTo reminders, "change:activationDate change:repeat change:active change:surveyId", (model) =>
        # reminder validation succeeded
        App.vent.trigger "reminder:set:success", model


      @show listView, region: @layout.listRegion


    getReminderLabelView: (reminder) ->
      new List.ReminderLabel
        model: reminder

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
