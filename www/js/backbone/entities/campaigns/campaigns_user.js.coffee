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

      # Collect all savedIDs for later filtering.
      savedIDs = options.saved_campaigns.pluck 'id'
      console.log "savedIDs",savedIDs

      # Only want to create a Campaign entry for a campaign 
      # that is valid.
      # The .map() creates a new array, each key is object or false.
      # The .filter() removes the false keys.
      user = _.chain(response.data).map((value, key) =>
        matchingSaved = options.saved_campaigns.get(key)
        hasMatchingSaved = typeof matchingSaved isnt 'undefined'
        isRunningCampaign = value.running_state is "running"
        hasMatchingTimestamp = hasMatchingSaved and matchingSaved.get('creation_timestamp') is value.creation_timestamp

        if !hasMatchingSaved and !isRunningCampaign
          # filter invalid (non-running without matching saved
          # campaigns) campaigns from results completely.
          return false

        # before we go through the checks, we assume that a given
        # campaign is going to be "available"
        myStatus = 'available'

        if hasMatchingSaved
          # remove the matching campaign from our list of
          # saved IDs.
          savedIDs = _.without savedIDs, key

          if hasMatchingTimestamp
            if isRunningCampaign
              # timestamp matches, campaign is running
              myStatus = 'saved'
            else
              # timestamp matches, campaign isn't running
              myStatus = 'ghost_stopped'
          else
            # timestamp doesn't match
            myStatus = 'ghost_outdated'

        return {
          id: key # campaign URN
          creation_timestamp: value.creation_timestamp
          name: "#{myStatus} #{value.name}"
          description: value.description
          status: myStatus
        }

      ).filter((result) -> !!result).value()
      user = @_appendNonexistent savedIDs, user, options.saved_campaigns
      user
    _appendNonexistent: (savedIDs, user, saved_campaigns) ->
      if savedIDs.length > 0
        # We have saved IDs that are not part of the existing user campaigns.
        # Create new ghost saved campaign entries for later merging into the final result.
        saved = _.map(savedIDs, (id) =>
          myCampaign = saved_campaigns.get id
          myStatus = 'ghost_nonexistent'
          return {
            id: myCampaign.get 'id'
            creation_timestamp: myCampaign.get 'creation_timestamp'
            name: "#{myStatus} #{myCampaign.get('name')}"
            description: myCampaign.get 'description'
            status: 'ghost_nonexistent'
          }
        )
        console.log "new saved", saved
        # merge ghosted campaigns into our final result.
        return _.uniq( _.union(user, saved), false, (item, key, id) -> item.id )
      else
        return user

  API =
    init: ->
      App.request "storage:get", 'campaigns_user', ((result) =>
        # user campaigns retrieved from raw JSON.
        console.log 'user campaigns retrieved from storage'
        currentCampaignsUser = new Entities.CampaignsUser result
      ), =>
        console.log 'user campaigns not retrieved from storage'
        currentCampaignsUser = new Entities.CampaignsUser

    syncCampaigns: ->
      credentials = App.request "credentials:current"
      currentCampaignsUser.fetch
        reset: true
        type: 'POST' # not RESTful but the 2.0 API requires it
        data:
          user: credentials.get 'username'
          password: credentials.get 'password'
          client: 'ohmage-mwf-dw-browser'
          output_format: 'short'
        saved_campaigns: App.request 'campaigns:saved:current'
        success: (collection, response, options) =>
          console.log 'campaign fetch success', response, collection
          @saveLocalCampaigns response, collection
        error: (collection, response, options) =>
          console.log 'campaign fetch error'
      currentCampaignsUser
    saveLocalCampaigns: (response, collection) ->
      # update localStorage index campaigns_user with the current version of campaignsUser entity
      App.execute "storage:save", 'campaigns_user', collection.toJSON(), =>
        console.log "campaignsUser entity saved in localStorage"

    getCampaigns: ->
      if currentCampaignsUser.length < 1
        # fetch the campaign object from the server and sync,
        # because our current version is empty
        @syncCampaigns()
      else
        currentCampaignsUser
    getCampaign: (id) ->
      currentCampaignsUser.get id
    clear: ->
      currentCampaignsUser = new Entities.CampaignsUser

      App.execute "storage:clear", 'campaigns_user', ->
        console.log 'user campaigns erased'
        App.vent.trigger "campaigns:user:cleared"

  App.vent.on "campaigns:saved:init:success", ->
    console.log "campaigns:saved:init:success"

  App.vent.on "campaigns:saved:init:failure", ->
    console.log "campaigns:saved:init:failure"

  App.reqres.setHandler "campaign:entity", (id) ->
    API.getCampaign id

  App.reqres.setHandler "campaigns:user", ->
    API.getCampaigns()

  App.commands.setHandler "campaigns:sync", ->
    API.syncCampaigns()

  App.commands.setHandler "campaigns:user:clear", ->
    API.clear()
