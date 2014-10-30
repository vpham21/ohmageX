@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The CampaignsFiltered entity is a decorator for Campaigns,
  # allowing campaigns to be filtered into different parts based on their
  # attributes, such as name.

  API =
    getFiltered: (campaigns) ->
      filtered = new campaigns.constructor()

      filtered._callbacks = {}

      filtered.where = (criteria) ->
        if (criteria)
          # name search with fuzzy matching
          nameSearch = new RegExp criteria.name.split('').join('\\w*').replace(/\W/,""), "i"
          items = campaigns.filter((campaign) ->
            myName = campaign.get('name')
            myName.match(nameSearch)
          )
        else
          items = campaigns.models

        console.log 'items', items
        console.log 'criteria', criteria
        filtered._currentCriteria = criteria

        filtered.reset items

      campaigns.on "reset", ->
        filtered.where filtered._currentCriteria

      if campaigns.length > 0
        # repopulates the list if our campaigns list starts out not empty,
        # such as when navigating back to the campaigns list when
        # the list has already been fetched.
        campaigns.trigger 'reset'

      filtered

  App.reqres.setHandler "campaigns:filtered", (campaigns) ->
    console.log 'campaigns:filtered', campaigns
    API.getFiltered campaigns
