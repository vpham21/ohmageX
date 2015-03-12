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

      # this is only needed on iOS, since currently the notification does not appear
      # in the iOS notification banner while the app is open.
      window.plugin.notification.local.on "trigger", (notification) =>
        # this seems to only activate when the app is in the foreground.
        console.log 'trigger event'
        console.log 'JSON', notification.data
        result = JSON.parse notification.data
        if device.platform is "iOS"
          App.execute "dialog:confirm", "Reminder to take the survey #{result.surveyTitle}. Go to the survey?", (=>
            App.navigate "survey/#{result.surveyId}", trigger: true

            # Suppress this reminder now that it's been activated.
            App.execute "reminders:suppress", [result.id]
          ), (=>
            console.log 'dialog canceled'
          )


    generateId: ->
      # generate a numeric id (not a guid). Local notifications plugin
      # fails if the id is not an Android-valid integer (Max for 32 bits is 2147483647)

      myId = "9xxxxxxxx".replace /[xy]/g, (c) ->
        r = Math.random() * 9 | 0
        v = (if c is "x" then r else (r & 0x3 | 0x8))
        v.toString 10
      myId

    nextDayofWeek: (myMoment, weekday) ->
      # myMoment is a JS moment
      # weekday is the zero indexed day of week (0 - 6)
      myInput = moment(myMoment)
      myOutput = myInput.clone().startOf('week').day(weekday).hour(myInput.hour()).minute(myInput.minute()).second(myInput.second())

      if myOutput > myInput then myOutput else myOutput.add(1, 'weeks')

    nextHourMinuteSecond: (myMoment, interval) ->
      # gets the next occurrence of a moment's hours, minutes, and seconds.
      # Ignores the month, day and year.
      # it jumps ahead by the given 'interval' for the next occurrence.
      # expected - Moment.js intervals like 'days' or 'weeks'

      input = moment(myMoment)

      hour = input.hour()
      minute = input.minute()
      second = input.second()
      output = moment().startOf('day').hour(hour).minute(minute).second(second)

      if output > moment() then output else output.add(1, interval)

    addNotifications: (reminder) ->
      if App.device.isNative
        # Delete any of the reminder's system notifications
        API.deleteNotifications reminder

      myIds = []
      if !reminder.get('repeat')
        # reminder is non-repeating.
        myId = @generateId()
        @createReminderNotification 
          notificationId: myId
          reminder: reminder
          frequency: ''
          activationDate: reminder.get('activationDate').toDate()

        App.vent.trigger "notifications:update:complete"
        myIds.push myId
      else
        if reminder.get('repeatDays').length is 7
          # create one daily notification since it's repeating every day.
          myId = @generateId()

          activationDate = @nextHourMinuteSecond reminder.get('activationDate'), 'days'

          @createReminderNotification
            notificationId: myId
            reminder: reminder
            frequency: 'daily'
            activationDate: activationDate.toDate()

          App.vent.trigger "notifications:update:complete"
          myIds.push myId
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


    createReminderNotification: (options) ->
      _.defaults options,
        callback: (=>
          console.log 'notification creation default callback'
        )

      { notificationId, reminder, frequency, activationDate, callback } = options

      metadata = JSON.stringify reminder.toJSON()

      if App.device.isNative
        window.plugin.notification.local.schedule
          id: notificationId
          title: "#{reminder.get('surveyTitle')}"
          message: "Take survey #{reminder.get('surveyTitle')}"
          repeat: frequency
          date: activationDate
          autoCancel: !reminder.get('repeat') # autoCancel NON-repeating reminders
          json: metadata
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
