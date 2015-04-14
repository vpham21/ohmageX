@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->



  class Entities.SuppressionNotification extends Entities.Model
    initialize: ->
      @listenTo @, "suppress:id", @suppress
    bumpNotification: (interval) ->
      # TODO: remove this method, must do this in the collection instead
      # to aggregate notification update
      myId = @get('id')

      cordova.plugins.notification.local.get myId, (notifications) =>
        # get whatever the notification's starting date is.
        # Then bump it by the interval.
        cordova.plugins.notification.local.update
          id: myId
          at: moment(notifications.at).add(1, interval).toDate()
    suppress: ->
      # TODO: remove this method, must do this in the collection instead
      # to aggregate notification update / cancel
      switch @get('repeat')
        when 'day'
          @bumpNotification 'days'
        when 'week'
          @bumpNotification 'weeks'
        when false
          # non-repeating reminder, just delete it
          App.execute "reminder:delete:byid", @get('reminderId')

  class Entities.SuppressionNotifications extends Entities.Collection
    model: Entities.SuppressionNotification
    initialize: ->
      @listenTo @, "suppress", @suppress
    suppress: (ids) ->
      # suppression is triggered with an event that includes
      # an array of notification IDs to suppress.
      console.log 'suppress ids', ids 

      ### 
      TODO:
      loop through all ids that will be suppressed.
      check the ID metadata. For a given notification:

      append all one-time notifications to a one-time array.
      this is so all of the one-times can be `cancel()`ed simultaneously.
      after cancel, delete the matching one-time Reminder entities by id.

      Then append all repeating notifications to repeating array.
      This is so the repeating items can be `update()`ed simultaneously.
      Any repeats should already be filtered by:
      Non-consecutive repeating notification that matches today
      A daily notification

      update() and cancel() may need to be chained so they don't clobber
      each other (has happened with past plugin versions)

      most likely remove this code, left for reference:
      suppressed = @filter (model) => model.get('id') in ids
      _.each suppressed, (model) =>
        model.trigger "suppress:id"
      ###

  API =

    getLaterToday: (reminders) ->

      notifications = []

      reminders.each (reminder) =>
        # The notification has the repeat information encoded
        # as metadata within the last digit of the ID.

        # TODO
        # push all valid notifications to a flat array:
        # - one-time notifications
        # - daily repeating notifications
        # - weekly notifications that match the current weekday
        #   - no need to loop through `notificationIds`, just
        #     get the one that matches today

        # notifications.push
        #   id: notificationId
        #   activationDate: reminder.get('activationDate')
        #   reminderId: reminder.get('id')
        #   # no need to add repeat, it's encoded in `id`

      new Entities.SuppressionNotifications notifications

  App.reqres.setHandler "notifications:survey:scheduled:latertoday", (surveyId) ->
    reminders = App.request "reminders:survey:scheduled:latertoday", surveyId
    if reminders.length > 0 then API.getLaterToday(reminders)
