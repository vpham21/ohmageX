@Ohmage.module "FooterApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Application

    initialize: (options) ->
      { navs } = options

      @layout = @getShowView()

      @listenTo navs, "change:chosen", (model) =>
        # this event fires every time all instances of the
        # `chosen` attribute within the model are changed.

      @show @layout

    getContentsView: ->
      new Show.Contents

    getShowView: ->
      new Show.Footer
