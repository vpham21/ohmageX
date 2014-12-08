@Ohmage = do (Backbone, Marionette) ->

  App = new Marionette.Application

  App.on "before:start", (options) ->
    App.environment = options.environment
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
    credentials = App.request "credentials:current"

    if !!!credentials or !credentials.has('username')
      # the user isn't logged in, redirect them to the login page.
      @navigate(Routes.default_route(), trigger: true)
    else
      App.rootRoute = Routes.dashboard_route()
      @navigate(@rootRoute, trigger: true) unless @getCurrentRoute()

    window.onbeforeunload = ->
      if App.request "surveytracker:active"
        return 'Are you sure you want to leave the Survey Taking tool?'

  App
