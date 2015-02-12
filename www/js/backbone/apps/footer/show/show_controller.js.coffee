@Ohmage.module "FooterApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Application

    initialize: (options) ->
      { navs } = options

      @layout = @getShowView()

      @listenTo navs, "change:chosen", (model) =>
        # this event fires every time all instances of the
        # `chosen` attribute within the model are changed.

        if model.isChosen()
          if model.get('name') in App.custom.menu_items_disabled.footer
            # clear the region if the current menu item is disabled.
            @layout.contentRegion.reset()
      @show @layout

    getContentsView: ->
      new Show.Contents

    getShowView: ->
      new Show.Footer
