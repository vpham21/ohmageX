@Ohmage.module "FooterApp", (FooterApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  API =
    show: (navs) ->
      new FooterApp.Show.Controller
        region: App.footerRegion
        navs: navs

  FooterApp.on "start", (navs) ->
    API.show navs
