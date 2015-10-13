@Ohmage.module "SettingsDateApp", (SettingsDateApp, App, Backbone, Marionette, $, _) ->

  class SettingsDateApp.Router extends Marionette.AppRouter
    before: ->
      if !App.request("credentials:isloggedin")
        App.navigate Routes.default_route(), trigger: true
        return false
    appRoutes:
      "settings_date": "show"

  API =
    show: (id) ->
      App.vent.trigger "nav:choose", "settings_date"
      console.log 'SettingsDateApp show'
      new SettingsDateApp.Show.Controller

    saveDate: (dateStart) ->
      console.log "save settings date"
      App.vent.trigger 'user:preferences:start_date:set', dateStart
      @addNotifications dateStart

    addNotifications: (dateStart) ->
      console.log "add notifications" + dateStart

      currentReminders = App.request 'reminders:current'

      right_now = moment()

      start_date = moment(dateStart).hour(10).minute(0) 
      start_date_monday = moment(start_date).day(1).hour(10).minute(0)
      start_date_next_monday = moment(start_date).day(1 + 7).hour(10).minute(0)

      if start_date_monday <= start_date
        next_monday = start_date_next_monday
      else 
        next_monday = start_date_monday

      settings_dates = App.request "settings_dates:get:all"

      for settings_date in settings_dates
        for reminder in settings_date.reminders
          reminder = 
            id: _.guid()
            activationDate: next_monday.day(reminder.day).hour(reminder.hour).minute(reminder.minute)
            active: true
            notificationIds: []
            repeat: false
            repeatDays: []
            renderVisible: false
            surveyId: settings_date.campaign + ':' + reminder.survey_id
            surveyTitle: reminder.survey_title
            campaign: settings_date.campaign
            message: reminder.message
          currentReminders.add(reminder, { validate: false })

      App.execute "storage:save", 'reminders', currentReminders, =>
        console.log "reminders storage save success"
        @setNotifications currentReminders

    setNotifications: (currentReminders) ->
      console.log "setNotifications"

      right_now = moment();
      two_weeks_from_now = moment().endOf('day').add(2,'weeks')
      max = 64 - 4 # max ios local notifications - buffer

      assigned = 0 # local notifications already assigned
      currentReminders.each( (item) ->
        if item.get('notificationIds').length > 0
          assigned += 1
      )

      currentReminders.each( (item) ->
        activation_date = moment(item.get('activationDate'))
        
        # schedule local notifications to go off from now until 2 weeks from now up to 60 max
        if activation_date.diff(right_now) > 0 and two_weeks_from_now.diff(activation_date) > 0
          if item.get('notificationIds').length == 0 and assigned < max
            assigned += 1
            App.vent.trigger "reminder:set:success", item
      )

      console.log "added " + assigned + " local notifications"
    
    keepNotificationsUpdated: ->
      currentReminders = App.request 'reminders:current'
      @setNotifications currentReminders

  App.addInitializer ->
    new SettingsDateApp.Router
      controller: API

  App.vent.on "settings_date:save:clicked", (dateStart) ->
    console.log 'settings_app.settings_date:save:clicked'
    API.saveDate(dateStart)

  App.vent.on "settings_date:local_notifications:keep_up_to_date", (dateStart) ->
    console.log 'settings_date:local_notifications:keep_up_to_date'
    API.keepNotificationsUpdated()