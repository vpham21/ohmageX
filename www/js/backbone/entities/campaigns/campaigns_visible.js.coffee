@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The CampaignsVisible entity provides an interface for visible Campaigns,
  # rendered to the user with different status codes.
  # Campaign Status Codes:
  # available - campaign NOT saved, is available to the user to download
  # saved     - campaign saved locally, and surveys can be taken
  # ghosted   - campaign saved locally, but surveys CANNOT be taken

  currentCampaignsVisible = false

  class Entities.CampaignVisible extends Entities.Model

  class Entities.CampaignsVisible extends Entities.Collection
    model: Entities.CampaignVisible

  API =
    init: ->
      App.request "storage:get", 'campaigns_visible', ((result) =>
        # visible campaigns retrieved from raw JSON.
        console.log 'visible campaigns retrieved from storage'
        currentCampaignsVisible = new Entities.CampaignsVisible result
      ), =>
        console.log 'visible campaigns not retrieved from storage'
        currentCampaignsVisible = new Entities.CampaignsVisible
    getCampaignsVisible: ->
      currentCampaignsVisible
    clear: ->
      currentCampaignsVisible = new Entities.CampaignsVisible

      App.execute "storage:clear", 'campaigns_visible', ->
        console.log 'visible campaigns erased'
        App.vent.trigger "campaigns:visible:cleared"

  App.on "before:start", ->
    API.init()

  App.reqres.setHandler "campaigns:visible:current", ->
    API.getCampaignsVisible()

  App.commands.setHandler "campaigns:visible:clear", ->
    API.clear()
