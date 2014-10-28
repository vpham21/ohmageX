@Ohmage.module "CampaignsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Application

    initialize: ->
      campaigns = App.request "campaigns:filtered", App.request("campaigns:user")
      @layout = @getLayoutView campaigns

      @listenTo @layout, "show", =>
        console.log "show campaigns list layout"
        @searchRegion campaigns
        @campaignsRegion campaigns

      @show @layout, loading: true

    searchRegion: (campaigns) ->
      searchView = @getSearchView campaigns

      @show searchView, region: @layout.searchRegion


    campaignsRegion: (campaigns) ->
      campaignsView = @getCampaignsView campaigns

      @listenTo campaignsView, "childview:campaign:clicked", (child, args) ->
        console.log 'childview:campaign:clicked args', args.model
        App.vent.trigger "campaign:list:item:clicked", args.model

      @show campaignsView, region: @layout.listRegion

    getSearchView: (campaigns) ->
      new List.Search
        collection: campaigns

    getCampaignsView: (campaigns) ->
      new List.Campaigns
        collection: campaigns

    getLayoutView: (campaigns) ->
      new List.Layout
        collection: campaigns