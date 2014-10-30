@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The CampaignsUser entity provides an interface for user Campaigns.
  # Campaigns can be retrieved by URN.
  # Campaign Status Codes:
  # available - campaign NOT saved, is available to the user to download
  # saved     - campaign saved locally, and surveys can be taken
  # ghost_stopped     - campaign saved locally, remote campaign stopped
  # ghost_outdated    - campaign saved locally, remote campaign wrong timestamp
  # ghost_nonexistent - campaign saved locally, remote campaign doesn't exist

  currentCampaignsUser = false

  class Entities.CampaignUser extends Entities.Model

  class Entities.CampaignsUser extends Entities.Collection
    model: Entities.CampaignUser
    url: ->
      "#{App.request("serverpath:current")}/app/campaign/read"
    parse: (response, options) ->
      # parse the response data into values ready to be added
      # to the Collection of User Campaigns.

      # Only want to create a Campaign entry for a campaign 
      # that is valid.
      # The .map() creates a new array, each key is object or false.
      # The .filter() removes the false keys.

      _.chain(response.data).map((value, key) ->
        isValidCampaign = value.running_state is "running"
        if isValidCampaign
          return {
            id: key # campaign URN
            creation_timestamp: value.creation_timestamp
            name: value.name
            description: value.description
          }
        else
          return false
      ).filter((result) -> !!result).value()

  API =
    init: ->
      currentCampaignsUser = new Entities.CampaignsUser
    getCampaigns: ->
      credentials = App.request "credentials:current"
      currentCampaignsUser.fetch
        reset: true
        type: 'POST' # not RESTful but the 2.0 API requires it
        data:
          user: credentials.get 'username'
          password: credentials.get 'password'
          client: 'ohmage-mwf-dw-browser'
          output_format: 'short'
        success: (collection, response, options) =>
          console.log 'campaign fetch success', response, collection
        error: (collection, response, options) =>
          console.log 'campaign fetch error'
      currentCampaignsUser
    getCampaign: (id) ->
      currentCampaignsUser.get id

  App.on "before:start", ->
    API.init()

  App.reqres.setHandler "campaign:entity", (id) ->
    API.getCampaign id

  App.reqres.setHandler "campaigns:user", ->
    API.getCampaigns()