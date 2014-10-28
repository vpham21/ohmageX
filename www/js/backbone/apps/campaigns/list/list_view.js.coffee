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
    tagName: 'li'
    template: "campaigns/list/campaign_item"
    triggers:
      "click": "campaign:clicked"

  class List.Campaigns extends App.Views.CompositeView
    initialize: ->
      @listenTo @collection, 'reset', @render
    template: "campaigns/list/campaigns"
    childView: List.Campaign
    childViewContainer: ".campaigns"

  class List.Layout extends App.Views.Layout
    template: "campaigns/list/list_layout"
    regions:
      listRegion: "#list-region"
      searchRegion: "#search-region"
