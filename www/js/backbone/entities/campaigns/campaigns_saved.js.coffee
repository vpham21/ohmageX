@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The CampaignsSaved entity provides an interface for saved Campaigns
  # that the user has saved to their device.

  currentCampaignsSaved = false

  class Entities.CampaignSaved extends Entities.Model

  class Entities.CampaignsSaved extends Entities.Collection
    model: Entities.CampaignSaved

  API =
    init: ->
      App.request "storage:get", 'campaigns_saved', ((result) =>
        # saved campaigns retrieved from raw JSON.
        console.log 'saved campaigns retrieved from storage'
        currentCampaignsSaved = new Entities.CampaignsSaved result
      ), =>
        console.log 'saved campaigns not retrieved from storage'
        currentCampaignsSaved = new Entities.CampaignsSaved

    getCampaignsSaved: ->
      currentCampaignsSaved

    saveCampaign: (campaign) ->
      currentCampaignsSaved.add campaign
      @updateLocal()

    unsaveCampaign: (id) ->
      removed = currentCampaignsSaved.get id
      currentCampaignsSaved.remove removed
      @updateLocal()

    updateLocal: ->
      # update localStorage index campaigns_saved with the current version of campaignsSaved entity
      App.execute "storage:save", 'campaigns_saved', currentCampaignsSaved.toJSON(), =>
        console.log "campaignsSaved entity saved in localStorage"

    clear: ->
      currentCampaignsSaved = new Entities.CampaignsSaved

      App.execute "storage:clear", 'campaigns_saved', ->
        console.log 'saved campaigns erased'
        App.vent.trigger "campaigns:saved:cleared"

  App.on "before:start", ->
    API.init()

  App.reqres.setHandler "campaigns:saved:current", ->
    API.getCampaignsSaved()

  App.commands.setHandler "campaign:save", (campaign) ->
    # expects campaign to be a Model or JSON format.
    API.saveCampaign campaign

  App.commands.setHandler "campaign:unsave", (id) ->
    API.unsaveCampaign id

  App.commands.setHandler "campaigns:saved:clear", ->
    API.clear()
