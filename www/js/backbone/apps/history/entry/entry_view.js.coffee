@Ohmage.module "HistoryApp.Entry", (Entry, App, Backbone, Marionette, $, _) ->

  class Entry.Details extends App.Views.ItemView
    template: "history/entry/details"
    triggers:
      "click button.delete": "delete:clicked"
      "click button.close": "close:clicked"
    serializeData: ->
      data = @model.toJSON()
      console.log 'item details data', data
      data.locationExists = data.location.location_status is "valid"
      data.prettyTimestamp = moment(data.timestamp).format("MM/DD/YYYY, h:mma")
      data.campaign_creation_timestamp = moment(data.campaign.creation_timestamp).format("MM/DD/YYYY, h:mma")
      data

  class Entry.Layout extends App.Views.Layout
    id: 'history-section'
    template: "history/entry/layout"
    regions:
      noticeRegion: "#notice-region"
      detailsRegion: "#details-region"
      responsesRegion: "#responses-list"
