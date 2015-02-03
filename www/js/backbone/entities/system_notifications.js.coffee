@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Systems Notifications entity.

  # This provides the interface between the app's Reminders and the
  # device notifications created on the OS.

  API =
    init: ->
      @initNotificationEvents()

    initNotificationEvents: ->
      window.plugin.notification.local.onclick = (id, state, json) ->
        console.log 'onclick event!'
        console.log 'id', id
        result = JSON.parse json
        # delete our local Reminder, if it's non-repeating.
        if !result.repeat then App.execute('reminder:delete:json', result)
        console.log "survey/#{result.surveyId}"
        App.navigate "survey/#{result.surveyId}", trigger: true

    generateId: ->
      myId = "9xxxxxxxxxx".replace /[xy]/g, (c) ->
        r = Math.random() * 9 | 0
        v = (if c is "x" then r else (r & 0x3 | 0x8))
        v.toString 10
      myId

    addNotifications: (reminder) ->

      if App.device.isNative and reminder.get('notificationIds').length > 0
        # Delete any of the reminder's system notifications, if they exist
        API.deleteNotifications reminder.get('notificationIds')

        # clear out the reminder's notification IDs, they now reference nothing
        reminder.set('notificationIds', [])

      myIds = []
      if !reminder.get('repeat')
        # reminder is non-repeating.
        myId = @generateId()
        @createReminderNotification 
          notificationId: myId
          reminder: reminder
          frequency: ''
          activationDate: reminder.get('activationDate').toDate()
        myIds.push myId
      else
        if reminder.get('repeatDays').length is 7
          myId = @generateId()
          @createReminderNotification
            notificationId: myId
            reminder: reminder
            frequency: 'daily'
            activationDate: reminder.get('activationDate').toDate()

          myIds.push myId
        else
          _.each reminder.get('repeatDays'), (day) =>
            # create a new notification for all of the IDS in the reminder.
            myId = @generateId()
            myIds.push myId

      reminder.set 'notificationIds', myIds


    createReminderNotification: (options) ->
      { notificationId, reminder, frequency, activationDate } = options

      metadata = JSON.stringify reminder.toJSON()

      window.plugin.notification.local.add
        id: notificationId
        title: "#{reminder.get('surveyTitle')}"
        message: "Take survey #{reminder.get('surveyTitle')}"
        repeat: frequency
        date: activationDate
        autoCancel: !reminder.get('repeat') # autoCancel NON-repeating reminders
        json: metadata
      , (=>
        console.log "reminder set callback"

        # add listener here for the reminder action.
        # use the same ID as this generated ID.
        # Save the generated ID.
        # App.execute "dialog:alert", "reminder set"
      ), @


    deleteNotifications: (ids) ->
      window.plugin.notification.local.getScheduledIds((scheduledIds) ->
        console.log 'Ids to delete', JSON.stringify ids
        console.log 'scheduled Ids', JSON.stringify scheduledIds
        _.each ids, (id) =>
          # ensures we only attempt to remove a scheduled notification.
          if id in scheduledIds then window.plugin.notification.local.cancel(id)
      )


  App.vent.on "surveys:saved:load:complete", ->
    if App.device.isNative
      API.init()

  App.commands.setHandler "system:notifications:delete", (ids) ->
    console.log "system:notifications:delete", ids
    if App.device.isNative
      API.deleteNotifications ids

  App.commands.setHandler "system:notifications:add", (reminder) ->
    console.log "system:notifications:add", reminder
    if App.device.isNative
      API.addNotifications reminder
