@Ohmage.module "Uploadqueue.Item", (Item, App, Backbone, Marionette, $, _) ->

  class Item.ResponsesEmpty extends App.Views.ItemView
    className: "text-container"
    template: "uploadqueue/item/_responses_empty"


  class Item.ResponseString extends App.Views.ItemView
    template: "uploadqueue/item/response_string"

  class Item.ResponseSingleChoice extends Item.ResponseString
    serializeData: ->
      data = @model.toJSON()
      data.response = data.options[data.response]
      data

  class Item.ResponseMultiChoice extends App.Views.ItemView
    template: "uploadqueue/item/response_multi_choice"
    serializeData: ->
      data = @model.toJSON()
      # the response is a stringified array referencing options.
      selectionsArr = JSON.parse data.response
      # responses is an array that will be iterated over inside the view.
      data.responses = _.map selectionsArr, (selection) ->
        data.options[selection]
      data

  class Item.ResponseMultiChoiceCustom extends Item.ResponseMultiChoice
    serializeData: ->
      data = @model.toJSON()
      # the response is a stringified array referencing custom choice strings.
      selectionsArr = JSON.parse data.response
      # responses is an array that will be iterated over inside the view.
      data.responses = selectionsArr
      data

  class Item.ResponsePhoto extends App.Views.ItemView
    template: "uploadqueue/item/response_photo"
    onRender: ->
      savedImage = @model.get('response')
      if savedImage then @renderImageThumb(savedImage)
    renderImageThumb: (img64) ->
      # display the image in the preview
      $img = @$el.find '.preview-image'
      $img.prop 'src', img64
      $img.css 'display', 'block'

  class Item.ResponseUnsupported extends App.Views.ItemView
    template: "uploadqueue/item/response_unsupported"

  class Item.Responses extends App.Views.CollectionView
    getChildView: (model) ->
      myView = switch model.get('type')
        when 'single_choice'
          Item.ResponseSingleChoice
        when 'multi_choice'
          Item.ResponseMultiChoice
        when 'multi_choice_custom'
          Item.ResponseMultiChoiceCustom
        when 'photo'
          Item.ResponsePhoto
        when 'text','number','timestamp','single_choice_custom'
          Item.ResponseString
        else
          Item.ResponseUnsupported
      myView
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