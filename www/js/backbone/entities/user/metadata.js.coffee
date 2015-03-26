@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The User Metadata Entity contains meta data about the user.

  API =
    hasCampaignData: (campaign_urn) ->
      App.request('prompt:customchoice:campaign', campaign_urn) or 
        App.request('uploadqueue:campaign', campaign_urn)

  App.reqres.setHandler "user:metadata:has:campaign", (campaign_urn) ->
    API.hasCampaignData campaign_urn
