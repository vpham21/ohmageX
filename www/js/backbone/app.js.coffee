@Ohmage = do (Backbone, Marionette) ->

  App = new Marionette.Application

  App.on "before:start", (options) ->
    App.environment = options.environment
    App.credentials = false
    App.navs = App.request "nav:entities"

  App.addRegions
    headerRegion: "body > header"
    mainRegion:    "body > main"
    footerRegion: "body > footer"

  App.rootRoute = Routes.default_route()

  App.addInitializer ->
    App.module("HeaderApp").start(App.navs)
    App.module("FooterApp").start()

  App.reqres.setHandler "default:region", ->
    console.log "default:region"
    App.mainRegion

  App.vent.on "nav:choose", (nav) -> App.navs.chooseByName nav

  App.on "start", ->
    @startHistory()
    App.rootRoute = if @request("credentials:isloggedin") then Routes.dashboard_route() else Routes.default_route()
    @navigate(@rootRoute, trigger: true) unless @getCurrentRoute()

    window.onbeforeunload = ->
      if App.request "surveytracker:active"
        return 'Are you sure you want to leave the Survey Taking tool?'

  App
