@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->



  class Entities.SuppressionNotification extends Entities.Model

  class Entities.SuppressionNotifications extends Entities.Collection
    model: Entities.SuppressionNotification
    initialize: ->
      @listenTo @, "suppress", @suppress
    suppress: (ids) ->
      # suppression is triggered with an event that includes
      # an array of notification IDs to suppress.
      console.log 'suppress ids', ids 




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
