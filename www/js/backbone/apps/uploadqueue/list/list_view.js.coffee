@Ohmage.module "Uploadqueue.List", (List, App, Backbone, Marionette, $, _) ->

  class List.QueueEmpty extends App.Views.ItemView
    tagName: 'li'
    className: 'empty-container'
    template: "uploadqueue/list/_queue_empty"

  class List.QueueItem extends App.Views.ItemView
    initialize: ->
      @listenTo @model, 'change', @render
    tagName: 'li'
    getTemplate: ->
      if @model.get('status') is 'running' then "uploadqueue/list/_item_running" else "uploadqueue/list/_item_stopped"
    triggers:
      "click .stopped.item [role=\"link\"]": "stopped:clicked"
      "click button.delete": "delete:clicked"
      "click .running.item [role=\"link\"]": "running:clicked"
      "click .running.item .right-arrow": "running:clicked"
      "click .running.item button.upload": "upload:clicked"
    serializeData: ->
      data = @model.toJSON()
      console.log(data)
      data.prettyTimestamp = moment(data.timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
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
