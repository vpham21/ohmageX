@Ohmage.module "BlockerApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Application

    initialize: (options) ->
      { contentViewLabel } = options
      blocker = App.request "blocker:entity", contentViewLabel
      @layout = @getLayoutView blocker
      @show @layout
    getLayoutView: (blocker) ->
      new Show.Layout
        model: blocker
