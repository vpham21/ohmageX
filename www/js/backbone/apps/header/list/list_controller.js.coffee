@Ohmage.module "HeaderApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Application

    initialize: (options) ->
      { navs } = options
      @layout = @getLayoutView navs

      @listenTo @layout, "show", =>
        @listRegion navs
      @show @layout

    listRegion: (navs) ->
      listView = @getListView navs

      @show listView, region: @layout.listRegion

    getListView: (navs) ->
      new List.Header
        collection: navs

    getLayoutView: (navs) ->
      new List.Layout
        collection: navs
