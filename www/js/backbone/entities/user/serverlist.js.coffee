@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The ServerList Entity contains the list of servers.
  # Used on the login page.

  class Entities.ServerList extends Entities.NavsCollection

  API =
    defaultServer: ->
      myServerList = @serverList()
      if myServerList.length is 0 then return 'custom'
      myServerList.at(0).get('name')
  App.reqres.setHandler "serverlist:default", ->
    API.defaultServer()

