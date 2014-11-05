@Ohmage.module "CampaignsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Search extends App.Views.ItemView
    initialize: ->
      @listenTo @, 'search:update', @updateSearch
    updateSearch: ->
      val = @$el.find('input').val()
      console.log 'updateSearch val', val
      if val
        @collection.where
          name: val
      else
        @collection.where()

    template: "campaigns/list/search"
    triggers:
      "keyup input": "search:update"

  class List.Campaign extends App.Views.ItemView
    initialize: ->
      @listenTo @model, 'change', @render
      @listenTo @, 'ghost:remove:clicked', @confirmRemove
    tagName: 'li'
    confirmRemove: ->
      reason = switch @model.get 'status'
        when 'ghost_outdated' then 'is out of date'
        when 'ghost_stopped' then 'is stopped'
        when 'ghost_nonexistent' then 'does not exist in the system'
        else throw new Error "Invalid campaign ghost state: #{@model.get 'status'}"
      if window.confirm("This campaign #{reason}.\nRemove this campaign and any related survey responses?")
        @trigger "ghost:unsave:clicked"
    getTemplate: ->
      result = switch @model.get 'status'
        when 'available' then "campaigns/list/_available_campaign"
        when 'saved' then "campaigns/list/_saved_campaign"
        else "campaigns/list/_ghost_campaign"
      result
    triggers:
      "click .available-campaign button": "save:clicked"
      "click .available-campaign h3": "save:clicked"
      "click .saved-campaign button": "unsave:clicked"
      "click .saved-campaign h3": "navigate:clicked"
      "click .ghost-campaign button": "ghost:remove:clicked"
      "click .ghost-campaign h3": "ghost:remove:clicked"

  class List.Campaigns extends App.Views.CompositeView
    initialize: ->
      @listenTo @collection, 'reset', @render
      @listenTo @collection, 'remove', @render
    template: "campaigns/list/campaigns"
    childView: List.Campaign
    childViewContainer: ".campaigns"

  class List.Layout extends App.Views.Layout
    template: "campaigns/list/list_layout"
    regions:
      listRegion: "#list-region"
      searchRegion: "#search-region"
