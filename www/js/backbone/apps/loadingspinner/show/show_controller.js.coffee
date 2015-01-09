@Ohmage.module "LoadingspinnerApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Application

    initialize: (options) ->
      { loading } = options
      @layout = @getLayoutView loading

      @show @layout

    getLayoutView: (loading) ->
      new Show.Layout
        model: loading
