@Ohmage = do (Backbone, Marionette) ->

  App = new Marionette.Application

  App.on "initialize:before", (options) ->
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

  App.reqres.setHandler "default:region", -> App.mainRegion

  App.on "initialize:after", ->
    @startHistory()
    @navigate(@rootRoute, trigger: true) unless @getCurrentRoute()

  App