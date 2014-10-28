@Ohmage.module "CampaignsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Campaign extends App.Views.ItemView
    tagName: 'li'
    template: "campaigns/list/campaign_item"
    triggers:
      "click": "campaign:clicked"

  class List.Campaigns extends App.Views.CompositeView
    template: "campaigns/list/campaigns"
    childView: List.Campaign
    childViewContainer: ".campaigns"

  class List.Layout extends App.Views.Layout
    template: "campaigns/list/list_layout"
    regions:
      listRegion: "#list-region"
      searchRegion: "#search-region"
