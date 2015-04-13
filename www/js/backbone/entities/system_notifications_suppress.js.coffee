@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->



  class Entities.SuppressionNotification extends Entities.Model
    initialize: ->
      @listenTo "suppress", @suppress
    suppress: ->
      switch @get('repeat')
        when 'day'
          # it's a repeating daily reminder, use plugin update()
          cordova.plugins.notification.local.update
            id: @get('id')
            at: @get('activationDate').add(1, 'days')
        when 'week'
          # it's a repeating weekly reminder, use plugin update()
          cordova.plugins.notification.local.update
            id: @get('id')
            at: @get('activationDate').add(1, 'weeks')
        when false
          # non-repeating reminder, just delete it
          App.execute "reminder:delete:byid", @get('reminderId')

  class Entities.SuppressionNotifications extends Entities.SuppressionNotification
    initialize: ->
      @listenTo "suppress", @suppress
    suppress: (ids) ->
      # suppression is triggered with an event that includes
      # an array of notification IDs to suppress.
      @each (model) => model.trigger "suppress"

  API =

    getLaterToday: (reminders) ->

      notifications = []

      _.each reminder.get('notifications'), (notificationId) =>
        notifications.push
          id: notificationId
          activationDate: reminder.get 'activationDate'
          reminderId: reminder.get 'id'
          repeat: reminder.get 'repeat'

      new Entities.SuppressionNotifications notifications

  App.reqres.setHandler "notifications:survey:scheduled:latertoday", (surveyId) ->
    reminders = App.request "reminders:survey:scheduled:latertoday", surveyId
    API.getLaterToday reminders
