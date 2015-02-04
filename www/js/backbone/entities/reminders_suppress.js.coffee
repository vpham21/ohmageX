@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Entity to Suppress reminders.

  API =
    suppressReminders: (reminders, ids) ->
      console.log 'suppressReminders ids', ids     
      reminders.each (reminder) =>
        if reminder.get('id') in ids
          App.execute "system:notifications:suppress", reminder

  App.commands.setHandler "reminders:suppress", (ids) ->
    reminders = App.request "reminders:current"
    API.suppressReminders reminders, ids
