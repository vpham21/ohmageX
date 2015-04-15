@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Systems Notifications entity.

  # This provides the interface between the app's Reminders and the
  # device notifications created on the OS.

  API =
    init: ->
      @initNotificationEvents()

    initNotificationEvents: ->
      document.addEventListener 'pause', (=>
        App.vent.trigger "notification:blocker:close"
      )

      document.addEventListener 'resume', (=>
        cordova.plugins.notification.local.clearAll =>
          console.log 'any triggered notifications cleared from notification center'
      )

      cordova.plugins.notification.local.on "click", (notification) =>
        console.log "notification onclick event"
        result = JSON.parse notification.data
        console.log "survey/#{result.surveyId}"
        App.navigate "survey/#{result.surveyId}", trigger: true

        # clear the notification from the notification center now
        # that it has been activated.
        cordova.plugins.notification.local.clear notification.id, ->
          console.log 'Notification cleared'

      cordova.plugins.notification.local.on "cancel", (notification) =>
        console.log 'canceled notification', notification.id

      cordova.plugins.notification.local.on "schedule", (notification) =>
        console.log 'scheduled notification', notification.id

      cordova.plugins.notification.local.on "trigger", (notification, state) =>
        console.log 'trigger event'
        console.log 'JSON', notification.data
        result = JSON.parse notification.data

        if device.platform is "iOS" and state is "foreground"
          # The notification doesn't show up in the banner on iOS if the app is in the foreground.
          cordova.plugins.notification.local.clear notification.id, ->
            console.log 'Notification cleared'

          App.request 'reminders:current' # request current reminders to cleanup any expired reminders

          App.execute "dialog:confirm", "Reminder to take the survey #{result.surveyTitle}. Go to the survey?", (=>
            App.navigate "survey/#{result.surveyId}", trigger: true

          ), (=>
           console.log 'dialog canceled'
          )

        App.execute "surveys:local:triggered:add", result.surveyId

    turnOn: (reminder) ->
      # turn the reminder off before you turn it on, in case a currently active (or ON)
      # reminder was saved, meaning two turnOn events would happen in sequence.
      @turnOff reminder
      myIds = []
      if !reminder.get('repeat')
        # schedule a one-time notification using the full activationDate.
        myId = App.request "system:notifications:id:generate", reminder.get('repeat')
        myIds.push myId


        @scheduleNotification
          notificationId: myId
          surveyId: reminder.get('surveyId')
          reminderId: reminder.get('id')
          firstAt: reminder.get('activationDate').toDate()
          surveyTitle: reminder.get('surveyTitle')

      else

        if reminder.get('repeatDays').length is 7
          # schedule a daily notification using the activation date's hour:minute
          myId = App.request "system:notifications:id:generate", reminder.get('repeat')
          myIds.push myId

          targetHour = reminder.get('activationDate').hour()
          targetMinute = reminder.get('activationDate').minute()


          newDate = reminder.newBumpedWeekdayHourMinuteDate
            weekday: moment().day()
            hour: targetHour
            minute: targetMinute
            pastBumpInterval: 'days'

          # set the new activationDate to the next occurrence of the daily reminder
          App.execute "reminder:date:set", reminder, newDate

          @scheduleNotification
            notificationId: myId
            surveyId: reminder.get('surveyId')
            every: 'day'
            firstAt: newDate.toDate()
            surveyTitle: reminder.get('surveyTitle')

        else
          # schedule multiple non-consecutive weekly notifications
          # using the activation date's hour:minute
          @scheduleNotifications reminder, myIds

      App.execute "reminder:notifications:set", reminder, myIds


    scheduleNotification: (options) ->

      { notificationId, surveyId, every, firstAt, surveyTitle } = options
      console.log 'scheduleNotification'
      console.log JSON.stringify(options)
      if App.device.isNative
        result =
          id: notificationId
          title: "#{surveyTitle}"
          text: "Take survey #{surveyTitle}"
          firstAt: firstAt
          data:
            surveyId: surveyId
            surveyTitle: surveyTitle

        # In the plugin schedule method:
        # `every` property must either be NOT included at all or set to a pre-defined interval string.
        # Even though the plugin documentation says the default value is 0, setting
        # it to `0` or `false` crashes the app.

        result = if every isnt false then _.extend(result, every: every) else result

        cordova.plugins.notification.local.schedule result

      App.vent.trigger "notifications:update:complete"

    scheduleNotifications: (reminder, myIds) ->

      result = []

      repeatDays = reminder.get('repeatDays')
      targetHour = reminder.get('activationDate').hour()
      targetMinute = reminder.get('activationDate').minute()

      _.each repeatDays, (repeatDay) =>
        myId = App.request "system:notifications:id:generate", reminder.get('repeat'), repeatDay
        myIds.push myId

        newDate = reminder.newBumpedWeekdayHourMinuteDate
          weekday: parseInt(repeatDay) # type conversion required for day comparison
          hour: targetHour
          minute: targetMinute
          pastBumpInterval: 'weeks'

        result.push
          id: myId
          title: "#{reminder.get('surveyTitle')}"
          text: "Take survey #{reminder.get('surveyTitle')}"
          every: 'week'
          at: newDate.toDate()
          data:
            surveyId: reminder.get('surveyId')
            surveyTitle: reminder.get('surveyTitle')

      if App.device.isNative
        # Multiple notifications can be sent to the plugin `schedule` method
        # as an array of JSON objects and be scheduled simultaneously.

        cordova.plugins.notification.local.schedule result

      App.vent.trigger "notifications:update:complete"


    turnOff: (reminder) ->
      ids = reminder.get('notificationIds')
      if ids.length > 0
        # ensure this is only executed when ids are present.
        if App.device.isNative
          cordova.plugins.notification.local.cancel ids
        # clear out the reminder's notification IDs immediately, they now reference nothing
        App.execute "reminder:notifications:set", reminder, []
        App.vent.trigger "notifications:update:complete"


    clear: ->
      cordova.plugins.notification.local.cancelAll ->
        console.log 'All system notifications canceled'

  App.vent.on "surveys:saved:load:complete", ->
    if App.device.isNative
      API.init()

  App.commands.setHandler "system:notifications:turn:off", (reminder) ->
    API.turnOff reminder

  App.commands.setHandler "system:notifications:turn:on", (reminder) ->
    console.log "system:notifications:turn:on", reminder
    API.turnOn reminder

  App.vent.on "credentials:cleared", ->
    if App.device.isNative
      API.clear()
