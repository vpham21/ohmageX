@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->



  class Entities.SuppressionNotification extends Entities.Model

  class Entities.SuppressionNotifications extends Entities.Collection
    model: Entities.SuppressionNotification
    initialize: ->
      @listenTo @, "suppress", @suppress

    cancelNotificationsDeleteReminders: (onceIds) ->
      # cancel all notifications passed in and delete their reminders.

      # verify that all notifications passed in are non-repeating.
      _.each onceIds, (onceId) =>
        repeat = App.request "system:notifications:id:repeat", onceId
        throw new Error "suppression: repeating notification id #{onceId} being canceled" if repeat.type isnt false

      if onceIds.length > 0
        console.log 'canceling notifications'

        if App.device.isNative
          cordova.plugins.notification.local.cancel onceIds, =>
            # after the cancel has finished, delete all corresponding reminders
            _.each onceIds, (onceId) =>
              suppressNotification = @get onceId
              console.log 'deleting reminders'
              App.execute "reminder:delete:byid", suppressNotification.get 'reminderId'

    updateRepeatingNotifications: (repeatIds, onceIds) ->
      # this method takes in the onceIds so the onceIds
      # can be passed to this update's callback for subsequent canceling.
      updateObjs = []
      _.each repeatIds, (repeatId) =>
        repeat = App.request "system:notifications:id:repeat", repeatId
        throw new Error "suppression: one-time notification id #{repeatId} being updated" if repeat.type is false
        activationDate = @get(repeatId).get('activationDate')
        hour = activationDate.hour()
        minute = activationDate.minute()
        interval = if repeat.type is 'daily' then 'days' else 'weeks'

        # setting the new date:
        # - get 12am today.
        # - if it's daily, add 1 day to it so it's tomorrow 12am.
        # - if it's weekly, add 1 week so it's 1 week from today 12am.
        # - add the activationDate's hour and minute.

        updateObjs.push
          id: repeatId
          at: moment().startOf('day').add(1, interval).hour(hour).minute(minute).toDate()

      console.log 'update objects', updateObjs
      if App.device.isNative
        cordova.plugins.notification.local.update updateObjs, =>
          console.log 'update complete'
          @cancelNotificationsDeleteReminders onceIds

    suppress: (ids) ->
      # suppression is triggered with an event that includes
      # an array of notification IDs to suppress.
      console.log 'suppress ids', ids 

      onceIds = []
      repeatIds = []

      _.each ids, (id) =>
        repeat = App.request "system:notifications:id:repeat", id
        if !repeat.type
          onceIds.push id
        else
          repeatIds.push id

      if repeatIds.length > 0
        @updateRepeatingNotifications repeatIds, onceIds
      else
        console.log 'no repeating ids to update, remove all one-time ids'
        @cancelNotificationsDeleteReminders onceIds

  API =

    getLaterToday: (reminders) ->

      todaysNotifications = []

      reminders.each (reminder) =>
        reminderNotifications = reminder.get('notificationIds')

        if reminderNotifications.length is 1
          # one-time notifications
          # daily repeating notifications
          idToAdd = reminderNotifications[0]
        else
          # weekly notifications that match the current weekday
          idToAdd = _.find reminderNotifications, (id) =>
            # extract repeat information encoded
            # as metadata within the ID.
            repeat = App.request "system:notifications:id:repeat", id
            repeat.weekday is moment().day()

        todaysNotifications.push
          id: idToAdd
          activationDate: reminder.get('activationDate')
          reminderId: reminder.get('id')

      new Entities.SuppressionNotifications todaysNotifications

  App.reqres.setHandler "notifications:survey:scheduled:latertoday", (surveyId) ->
    reminders = App.request "reminders:survey:scheduled:latertoday", surveyId
    if reminders.length > 0 then API.getLaterToday(reminders)
