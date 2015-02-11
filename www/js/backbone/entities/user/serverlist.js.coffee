@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The ServerList Entity contains the list of servers.
  # Used on the login page.

  class Entities.ServerList extends Entities.NavsCollection

  API =
    serverList: (storedServer) ->
      serversObj = _.map(App.custom.server_list.servers, (server) ->
        label: server
        name: server
      )
      serverList = new Entities.ServerList serversObj
      if App.custom.server_list.custom then serverList.add
        label: "Custom..."
        name: 'custom'

      if !App.custom.server_list.custom and serverList.length is 0
        throw new Error "App server_list config invalid. `custom` disabled and `servers` is empty"

      serverList.chooseByName storedServer
      serverList

    defaultServer: ->
      myServerList = @serverList()
      if myServerList.length is 0 then return 'custom'
      myServerList.at(0).get('name')
  App.reqres.setHandler "serverlist:default", ->
    API.defaultServer()

  App.reqres.setHandler "serverlist:entity", ->
    API.serverList App.request('serverpath:current')
