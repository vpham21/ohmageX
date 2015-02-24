@Ohmage.module "Uploadqueue.Item", (Item, App, Backbone, Marionette, $, _) ->

  class Item.ResponsesEmpty extends App.Views.ItemView
    className: "text-container"
    template: "uploadqueue/item/_responses_empty"


  class Item.ResponseString extends App.Views.ItemView
    template: "uploadqueue/item/response_string"
    serializeData: ->
      data = @model.toJSON()
        when 'single_choice'
        when 'multi_choice'
        when 'multi_choice_custom'
        when 'photo'
        else

  class Item.Responses extends App.Views.CollectionView
    childView: Item.Response
    emptyView: Item.ResponsesEmpty

  class Item.Details extends App.Views.ItemView
    template: "uploadqueue/item/details"
    triggers:
      "click button.delete": "delete:clicked"
      "click .running.item button.upload": "upload:clicked"
    serializeData: ->
      data = @model.toJSON()
      console.log(data)
      data.prettyTimestamp = new Date(data.timestamp).toString()
      data

  class Item.Layout extends App.Views.Layout
    id: 'upload-queue'
    template: "uploadqueue/item/layout"
    regions:
      noticeRegion: "#notice-region"
      detailsRegion: "#details-region"
      responsesRegion: "#responses-list"
