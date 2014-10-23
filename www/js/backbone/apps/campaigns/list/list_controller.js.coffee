@Ohmage.module "CampaignsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Application

    initialize: ->
      campaigns = App.request "campaigns:user"
      @layout = @getLayoutView campaigns

      @listenTo @layout, "show", =>
        console.log "show campaigns list layout"
        @campaignsRegion campaigns

      @show @layout, loading: true

    campaignsRegion: (campaigns) ->
      campaignsView = @getCampaignsView campaigns

      @listenTo campaignsView, "childview:campaign:clicked", (child, args) ->
        console.log 'childview:campaign:clicked args', args.model
        App.vent.trigger "campaign:list:item:clicked", args.model

      @show campaignsView, region: @layout.listRegion

    getCampaignsView: (campaigns) ->
      new List.Campaigns
        collection: campaigns

    getLayoutView: (campaigns) ->
      new List.Layout
        collection: campaigns