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

      notifications = []

      reminders.each (reminder) =>
        # The notification has the repeat information encoded
        # as metadata within the last digit of the ID.



      new Entities.SuppressionNotifications notifications

  App.reqres.setHandler "notifications:survey:scheduled:latertoday", (surveyId) ->
    reminders = App.request "reminders:survey:scheduled:latertoday", surveyId
    if reminders.length > 0 then API.getLaterToday(reminders)
