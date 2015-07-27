@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # This deals with campaigns for all surveys.

  API =
    getCampaignUrns: (surveys) ->
      surveys.pluck 'campaign_urn'

  App.reqres.setHandler "surveys:saved:campaign_urns", ->
    surveys = App.request "surveys:saved"
    if surveys.length is 0 then return false
    API.getCampaignUrns surveys
