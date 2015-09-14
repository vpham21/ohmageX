@Ohmage.module "HelpApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Help extends App.Views.ItemView
    className: "text-container"
    template: "help/show/info"

    serializeData: ->

    onRender: ->

  class Show.Layout extends App.Views.Layout
    template: "help/show/show_layout"
    regions:
      helpRegion: "#help-region"
