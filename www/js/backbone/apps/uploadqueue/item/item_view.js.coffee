@Ohmage.module "Uploadqueue.Item", (Item, App, Backbone, Marionette, $, _) ->

  class Item.ResponsesEmpty extends App.Views.ItemView
    className: "text-container"
    template: "uploadqueue/item/_responses_empty"

  class Item.Response extends App.Views.ItemView
    template: "uploadqueue/item/response"
    serializeData: ->
      data = @model.toJSON()
      data.response = switch data.type
        when 'single_choice'
          # the response is a reference to a single choice item referencing an option.
          data.options[data.response]
        when 'multi_choice'
          # the response is a stringified array referencing options.
          selectionsArr = JSON.parse data.response
          output = ''
          _.each selectionsArr, (selection) ->
            output += "#{data.options[selection]} "
          output
        when 'multi_choice_custom'
          # the response is a stringified array referencing responses.
          selectionsArr = JSON.parse data.response
          output = ''
          _.each selectionsArr, (selection) ->
            output += "#{selection} "
          output
        when 'photo'
          # change to render the image base64 into a canvas.
          'image thumbnail goes here'
        else
          data.response
      data

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
