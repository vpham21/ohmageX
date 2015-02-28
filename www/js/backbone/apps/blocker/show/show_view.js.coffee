@Ohmage.module "BlockerApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Notice extends App.Views.ItemView
    template: "blocker/show/_notice"

  class Show.Layout extends App.Views.Layout
    tagName: "figure"
