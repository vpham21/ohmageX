@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # This saves and restores locally triggered surveys for a user.
  # This is separate from the system Notifications; triggered
  # surveys are saved locally.

  currentTriggered = false
