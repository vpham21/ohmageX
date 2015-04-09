@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Systems Notifications entity.

  # This provides the interface between the app's Reminders and the
  # device notifications created on the OS.

  API =
    init: ->
      @initNotificationEvents()

    initNotificationEvents: ->
      window.plugin.notification.local.on "click", (notification) =>
        console.log "notification onclick event"
        result = JSON.parse notification.data
        console.log "survey/#{result.surveyId}"
        App.navigate "survey/#{result.surveyId}", trigger: true

        # Suppress this reminder now that it's been activated.
        App.execute "reminders:suppress", [result.id]

      window.plugin.notification.local.on "trigger", (notification) =>
        # in the old version of the plugin, this seems to only activate when the app is in the foreground.
        console.log 'trigger event'
        console.log 'JSON', notification.data
        result = JSON.parse notification.data
        App.execute "surveys:local:triggered:add", result.surveyId

    generateId: ->
      # generate a numeric id (not a guid). Local notifications plugin
      # fails if the id is not an Android-valid integer (Max for 32 bits is 2147483647)

      myId = "9xxxxxxxx".replace /[xy]/g, (c) ->
        r = Math.random() * 9 | 0
        v = (if c is "x" then r else (r & 0x3 | 0x8))
        v.toString 10
      myId

    newBumpedWeekdayHourMinuteDate: (options) ->
      # retuns a new date base on the provided weekday, hour and minute,
      # with any past dates bumped to the future by the provided pastBumpInterval.

      { weekday, hour, minute, pastBumpInterval } = options

      newDate = moment().startOf('week').day(weekday).hour(hour).minute(minute)

      if weekday < moment().day()
        # in this week, the provided day comes before today's 
        # day of the week. Bump it
        # (watch for type conversion here)
        newDate.add(1, interval)

      else if weekday is moment().day()
        # the provided weekday matches today's day of the week

        # use a buffer of 2 minutes for setting notifications.
        bufferedNow = moment().add(2, 'minutes')

        if hour < bufferedNow.hour() and minute < bufferedNow.minute()
          # the hour and minute are in the past, bump it
          newDate.add(1, interval)

      newDate

    turnOn: (reminder) ->
      myIds = []
      if !reminder.get('repeat')
        # schedule a one-time notification using the full activationDate.
        myId = @generateId()
        myIds.push myId

        @scheduleNotification
          notificationId: myId
          surveyId: reminder.get('surveyId')
          every: 0 # 0 means that the system triggers the local notification once
          firstAt: reminder.get('activationDate').toDate()

      else

        if reminder.get('repeatDays').length is 7
          # schedule a daily notification using the activation date's hour:minute
          myId = @generateId()
          myIds.push myId

          targetHour = reminder.get('activationDate').hour()
          targetMinute = reminder.get('activationDate').minute()

          newDate = @newBumpedWeekdayHourMinuteDate
            weekday: moment().day()
            hour: targetHour
            minute: targetMinute
            pastBumpInterval: 'days'

          @scheduleNotification
            notificationId: myId
            surveyId: reminder.get('surveyId')
            every: 'day' # 0 means that the system triggers the local notification once
            firstAt: newDate.toDate()

        else
          # send a copy of repeatDays to recursive @generateMultipleNotifications
          # so the original isn't sliced to nothing.
          repeatDays = reminder.get('repeatDays').slice(0)

          @generateMultipleNotifications repeatDays, reminder, myIds

      App.execute "reminder:notifications:set", reminder, myIds


    generateMultipleNotifications: (repeatDays, reminder, myIds) ->
      # Generates multiple notifications recursively, each iteration
      # completes when the plugin notification creation callback fires.
      # Required because creating multiple system notifications in rapid
      # succession may fail.

      myId = @generateId()
      myIds.push myId

      activationDayofWeek = moment().day()
      repeatDay = repeatDays[0]

      if "#{activationDayofWeek}" is repeatDay

        # if the day of week is the same as the current day,
        # we get the NEXT occurrence of that hour:minute:second
        activationDate = @nextHourMinuteSecond reminder.get('activationDate'), 'weeks'
      else
        activationDate = @nextDayofWeek(reminder.get('activationDate'), repeatDay)

      if repeatDays.length is 1
        # base condition
        callback = (=>
          console.log 'final of many notification created, activationDate', activationDate.format("dddd, MMMM Do YYYY, h:mm:ss a")
          App.vent.trigger "notifications:update:complete"
        )
      else
        callback = (=>
          console.log 'one of many notifications created, activationDate', activationDate.format("dddd, MMMM Do YYYY, h:mm:ss a")
          # shrink repeatDays from the front, ensuring that repeatDays[0]
          # will always be a valid value for repeatDay in the recursive loop
          repeatDays.shift()
          @generateMultipleNotifications repeatDays, reminder, myIds
        )

      @createReminderNotification
        notificationId: myId
        reminder: reminder
        frequency: 'weekly'
        activationDate: activationDate.toDate()
        callback: callback


    scheduleNotification: (options) ->
      _.defaults options,
        callback: (=>
          # trigger the callback when notification updates complete.
          App.vent.trigger "notifications:update:complete"
          console.log 'notification creation default callback'
        )

      { notificationId, surveyId, every, firstAt, callback } = options

      if App.device.isNative
        cordova.plugins.notification.local.schedule
          id: notificationId
          title: "#{reminder.get('surveyTitle')}"
          message: "Take survey #{reminder.get('surveyTitle')}"
          every: every
          firstAt: firstAt
          data:
            surveyId: surveyId
        , callback, @
      else
        callback.call(@)

    deleteNotifications: (reminder) ->
      ids = reminder.get('notificationIds')
      if ids.length > 0
        # ensure this is only executed when ids are present.
        if App.device.isNative
          window.plugin.notification.local.getScheduledIds((scheduledIds) ->
            console.log 'Ids to delete', JSON.stringify ids
            console.log 'scheduled Ids', JSON.stringify scheduledIds
            _.each ids, (id) =>
              # ensures we only attempt to remove a scheduled notification.
              if id in scheduledIds then window.plugin.notification.local.cancel(id)
          )
        # clear out the reminder's notification IDs immediately, they now reference nothing
        App.execute "reminder:notifications:set", reminder, []
        App.vent.trigger "notifications:update:complete"

    suppressNotifications: (reminder) ->
      if reminder.get('repeat')
        newDate = moment(reminder.get('activationDate'))

        # shift the activation date for the reminder's notifications 24 hours in the future.
        App.execute "reminder:date:set", reminder, newDate.add(1, 'days')

        # Generate new notifications (and IDs) for the repeating reminder.
        # Whether the reminders repeat daily or weekly, `addNotifications` will set
        # the activation dates appropriately.
        API.addNotifications reminder
      else
        # non-repeating reminder, just delete it
        App.execute "reminder:delete", reminder

    clear: ->
      window.plugin.notification.local.cancelAll ->
        console.log 'All system notifications canceled'

  App.vent.on "surveys:saved:load:complete", ->
    if App.device.isNative
      API.init()

  App.commands.setHandler "system:notifications:delete", (reminderId) ->
    API.deleteNotifications App.request('reminders:current').get(reminderId)

  App.commands.setHandler "system:notifications:add", (reminder) ->
    console.log "system:notifications:add", reminder
    API.addNotifications reminder

  App.commands.setHandler "system:notifications:suppress", (reminder) ->
    API.suppressNotifications reminder

  App.vent.on "credentials:cleared", ->
    if App.device.isNative
      API.clear()
