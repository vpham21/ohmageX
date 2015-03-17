@Ohmage.module "FooterApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Contents extends App.Views.ItemView
    initialize: ->
      @listenTo @, "link:clicked", @openLink
    template: "footer/show/_contents"
    openLink: ->
      targetHref = @$el.find('a').attr('href')
      if App.device.isNative
        window.open targetHref, '_system'
      else
        window.open targetHref, '_blank'
    serializeData: ->
      data = {}
      data.version = App.version
      data
    triggers:
      "click a": "link:clicked"

  class Show.Footer extends App.Views.Layout
    template: "footer/show/footer"
    tagName: "footer"
    regions:
      contentRegion: ".content-region"
