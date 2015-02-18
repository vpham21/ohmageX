@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The UploadQueue Campaign Entity contains upload queue handlers
  # that pertain to campaigns.

  API =
    getCampaignQueueItem: (queue, campaign_urn) ->
      item = queue.where
        campaign_urn: campaign_urn
      console.log "campaign queue item for #{campaign_urn}", item
      if item.length is 0 then false else item

  App.reqres.setHandler "uploadqueue:campaign", (campaign_urn) ->
    queue = App.request "uploadqueue:entity"
    console.log "queue entity", queue
    if !!queue then API.getCampaignQueueItem(queue, campaign_urn) else false
