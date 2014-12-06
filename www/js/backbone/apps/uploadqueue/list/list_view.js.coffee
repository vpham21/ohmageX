@Ohmage.module "Uploadqueue.List", (List, App, Backbone, Marionette, $, _) ->

  class List.QueueEmpty extends App.Views.ItemView
    tagName: 'li'
    className: 'empty'
    template: "uploadqueue/list/_queue_empty"

  class List.QueueItem extends App.Views.ItemView
    initialize: ->
      @listenTo @model, 'change', @render
    tagName: 'li'
    getTemplate: ->
      if @model.get('status') is 'running' then "uploadqueue/list/_item_running" else "uploadqueue/list/_item_stopped"
    triggers:
      "click .stopped-item": "stopped:clicked"
      "click .delete-button": "delete:clicked"
      "click .running-item .item-label": "running:clicked"
      "click .running-item .upload-button": "upload:clicked"
    serializeData: ->
      data = @model.toJSON()
      data.prettyTimestamp = new Date(data.timestamp).toString()
      data

  class List.Queue extends App.Views.CollectionView
    tagName: 'ul'
    emptyView: List.QueueEmpty
    childView: List.QueueItem

  class List.Layout extends App.Views.Layout
    id: 'upload-queue'
    template: "uploadqueue/list/layout"
    regions:
      noticeRegion: "#notice-region"
      listRegion: "#list-region"
