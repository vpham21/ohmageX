
@Ohmage.module "RemindersApp.List", (List, App, Backbone, Marionette, $, _) ->

  # RemindersApp renders the Reminders page.

  class List.Controller extends App.Controllers.Application
    initialize: (options) ->

      _.defaults options,
        forceRefresh: false
        surveyId: false

      permissions = App.request 'permissions:current'

      reminders = App.request 'reminders:current'
      surveys = App.request 'surveys:saved'

      @layout = @getLayoutView permissions

      @listenTo permissions, "localnotification:checked", =>
        App.execute "reminders:force:refresh"

      if !options.forceRefresh
        @listenTo permissions, "localnotification:registered", =>
          App.execute "reminders:force:refresh"

      # @surveyId is used to populate the reminders list with a new reminder,
      # with a specific survey selected. Currently used from the survey
      # completion page to encourage users to create a new reminder.
      @surveyId = options.surveyId

      @listenTo @layout, "show", =>
        console.log "showing layout"
        if permissions.get('localNotification') is true

          if surveys.length is 0
            @noticeRegion 'No saved surveys! You must have saved surveys in order to create reminders.'
          else
            @addRegion reminders
            @listRegion reminders
            if @surveyId then App.execute("reminders:add:new")

        else
          # attempt to register permissions here if it's false.
          App.execute "permissions:register:localnotifications"


      @show @layout

    noticeRegion: (message) ->
      notice = new Backbone.Model message: message
      noticeView = @getNoticeView notice

      @show noticeView, region: @layout.noticeRegion

    initBlockerView: ->
      @blockerView = @getBlockerView()

      @listenTo @blockerView, "render", (blockerView) =>
        console.log 'blockerView render'
        surveysView = @getReminderSurveysView App.request("reminders:surveys", blockerView.model.get('surveyId'))
        blockerView.surveysRegion.show surveysView

        @listenTo surveysView, "survey:selected", (model) ->
          console.log 'survey:selected model', model
          blockerView.model.trigger "survey:selected", model

      @listenTo @blockerView, "reminder:submit", (model, response) =>
        console.log 'reminder:submit model', model
        App.vent.trigger "reminders:reminder:submit", model, response

      @listenTo @blockerView, "delete:reminder", (view) =>
        console.log 'reminder:delete view', view
        App.vent.trigger "reminders:reminder:delete", view.model

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
          selectedSurvey = if @surveyId then reminderSurveys.findWhere(id: @surveyId) else reminderSurveys.at(0)
          childView.model.trigger "survey:selected", selectedSurvey

      @listenTo listView, "childview:active:complete", (options) ->
        console.log 'active:complete model' , options.model
        App.vent.trigger "reminder:toggle", options.model


      @listenTo reminders, "invalid", (reminderModel) =>
        # reminder submit validation failed
        console.log "reminder invalid, errors are", reminderModel.validationError
        App.vent.trigger "reminder:validate:fail", reminderModel.validationError


      @listenTo reminders, "validated:success", (model) =>
        # reminder validation succeeded
        App.vent.trigger "reminder:set:success", model


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
