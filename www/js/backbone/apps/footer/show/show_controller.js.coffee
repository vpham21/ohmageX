@Ohmage.module "FooterApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Application

    initialize: (options) ->
      { navs } = options

      @layout = @getShowView()

      @show @layout
    getShowView: ->
      new Show.Footer
