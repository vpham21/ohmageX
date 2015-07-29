@Ohmage.module "HistoryApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Notice extends App.Views.ItemView
    template: "history/list/notice"
    className: "notice-nopop"

  class List.EntriesEmpty extends App.Views.ItemView
    tagName: 'li'
    className: "empty-container"
    template: "history/list/_entries_empty"

  class List.Entry extends App.Views.ItemView
    tagName: 'li'
    template: "history/list/entry"
    triggers:
      "click": "clicked"

  class List.Entries extends App.Views.CollectionView
    tagName: 'ul'
    emptyView: List.EntriesEmpty
    childView: List.Entry
    initialize: ->
      @listenTo @collection, 'reset', @render

  class List.Layout extends App.Views.Layout
    id: 'history-section'
    template: "history/list/list_layout"
    regions:
      noticeRegion: "#notice-region-nopop"
      controlRegion: "#control-region"
      listRegion: "#list-region"
