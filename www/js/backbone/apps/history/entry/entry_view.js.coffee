@Ohmage.module "HistoryApp.Entry", (Entry, App, Backbone, Marionette, $, _) ->
  class Entry.Layout extends App.Views.Layout
    id: 'history-section'
    template: "history/entry/layout"
    regions:
      noticeRegion: "#notice-region"
      detailsRegion: "#details-region"
      responsesRegion: "#responses-list"
