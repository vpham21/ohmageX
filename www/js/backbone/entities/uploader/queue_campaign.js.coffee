@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The UploadQueue Campaign Entity contains upload queue handlers
  # that pertain to campaigns.

  API =
    getCampaignQueueItem: (queue, campaign_urn) ->
      item = queue.where
        campaign_urn: campaign_urn
      if item.length is 0 then false else item

  App.reqres.setHandler "uploadqueue:campaign", (campaign_urn) ->
    queue = App.request "uploadqueue:entity"
    if !!queue then API.getCampaignQueueItem(queue, campaign_urn) else false
