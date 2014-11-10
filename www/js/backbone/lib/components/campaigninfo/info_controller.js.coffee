@Ohmage.module "Components.CampaignInfo", (CampaignInfo, App, Backbone, Marionette, $, _) ->

  # This CampaignInfo Selector returns a specific view, based on the
  # currently selected Nav button

  class CampaignInfo.InfoController extends App.Controllers.Application
    initialize: (options) ->
      { entity } = options

      @myView = @infoView entity

      @listenTo @myView, "close:clicked", =>
        console.log "close:clicked in CampaignInfo Component"
        App.vent.trigger "campaigninfo:closed", entity

      # Ensure this controller is removed during view cleanup.
      @listenTo @myView, "destroy", @destroy

    infoView: (campaign) ->
      new CampaignInfo.Info
        model: campaign

  App.reqres.setHandler "campaigninfo:view", (campaign) ->
    info = new CampaignInfo.InfoController
      entity: campaign

    info.myView
