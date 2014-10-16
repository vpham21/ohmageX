@Ohmage = do (Backbone, Marionette) ->

  App = new Marionette.Application

  App.on "before:start", (options) ->
    App.environment = options.environment
    App.navs = App.request "nav:entities"

  App.addRegions
    headerRegion: "body > header"
    mainRegion:    "body > section > article.primary"
    footerRegion: "body > section > footer"

  App.rootRoute = Routes.default_route()

  App.addInitializer ->
    App.module("HeaderApp").start(App.navs)
    App.module("FooterApp").start()

  App.reqres.setHandler "default:region", -> 
    console.log "default:region"
    App.mainRegion

  App.on "start", ->
    @startHistory()
    @navigate(@rootRoute, trigger: true) unless @getCurrentRoute()

  App
