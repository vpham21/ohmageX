@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The credentials token Entity provides an interface for login via token.

  currentAuthToken = false
