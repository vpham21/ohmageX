@Ohmage.module "FooterApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Contents extends App.Views.ItemView
    template: "footer/show/_contents"

  class Show.Footer extends App.Views.Layout
    template: "footer/show/footer"
    tagName: "footer"
    regions:
      contentRegion: ".content-region"
