@Ohmage.module "HistoryApp", (HistoryApp, App, Backbone, Marionette, $, _) ->

  class HistoryApp.Router extends Marionette.AppRouter
    before: ->
      if !App.request("credentials:isloggedin")
        App.navigate Routes.default_route(), trigger: true
        return false
    appRoutes:
      "history": "list"
      "history/:id": "entry"

  API =
    list: ->
      App.vent.trigger "nav:choose", "history"
      console.log 'HistoryApp list'
      new HistoryApp.List.Controller
    entry: (id) ->
      App.vent.trigger "nav:choose", "history"
      new HistoryApp.Entry.Controller
        entry_id: id

  App.addInitializer ->
    new HistoryApp.Router
      controller: API

  App.vent.on "history:entries:fetch:error history:entries:fetch:success", ->
    App.vent.trigger "loading:hide"
  App.vent.on "history:entry:close:clicked", (model) ->
    API.list()
    App.navigate "history"
