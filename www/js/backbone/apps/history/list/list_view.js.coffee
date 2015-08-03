@Ohmage.module "HistoryApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Notice extends App.Views.ItemView
    template: "history/list/notice"
    className: "notice-nopop"

  class List.SelectorItem extends App.Views.ItemView
    tagName: "option"
    template: "history/list/_selector_item"
    attributes: ->
      options = {}
      options['value'] = @model.get 'name'
      if @model.isChosen() then options['selected'] = 'selected'
      options

  class List.BucketsSelector extends App.Views.CollectionView
    tagName: "select"
    childView: List.SelectorItem
  class List.EntriesEmpty extends App.Views.ItemView
    tagName: 'li'
    className: "empty-container"
    template: "history/list/_entries_empty"

  class List.Entry extends App.Views.ItemView
    tagName: 'li'
    template: "history/list/entry"
    triggers:
      "click": "clicked"

  class List.EntryWithHeader extends App.Views.ItemView
    tagName: 'li'
    template: "history/list/_entry_with_header"
    triggers:
      "click .active.item": "clicked"

  class List.Entries extends App.Views.CollectionView
    tagName: 'ul'
    emptyView: List.EntriesEmpty
    myBucket: false

    initialize: ->
      @listenTo @collection, 'reset', @render

    getChildView: (model) ->
      if @collection.at(0) is model or @myBucket isnt model.get('bucket')
        # It is VERY weird that the first entry
        # must be forced to include a header with
        # `@collection.at(0) is model`
        # When getChildView first runs myBucket is false.
        # false is not equal to the first bucket!
        # And this still happens even when adding an
        # onRender that sets myBucket to false, in case
        # a lingering value remained.
        myView = List.EntryWithHeader
        @myBucket = model.get('bucket')
      else
        myView = List.Entry
      myView

  class List.Layout extends App.Views.Layout
    id: 'history-section'
    template: "history/list/list_layout"
    regions:
      noticeRegion: "#notice-region-nopop"
      bucketsControlRegion: "#buckets-control-region"
      listRegion: "#list-region"
