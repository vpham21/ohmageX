@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The ServerList Entity contains the list of servers.
  # Used on the login page.

  class Entities.ServerList extends Entities.NavsCollection
