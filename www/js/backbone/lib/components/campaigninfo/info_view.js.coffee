@Ohmage.module "Components.CampaignInfo", (CampaignInfo, App, Backbone, Marionette, $, _) ->

  class CampaignInfo.Info extends App.Views.ItemView
    initialize: ->
      @listenTo @, 'close:clicked', @destroy
    template: "campaigninfo/info"
    triggers:
      "click .button-close": "close:clicked"
