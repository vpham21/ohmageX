@Ohmage.module "Uploadqueue.Item", (Item, App, Backbone, Marionette, $, _) ->

  class Item.ResponsesEmpty extends App.Views.ItemView
    className: "empty-container"
    template: "uploadqueue/item/_responses_empty"

  class Item.ResponseBase extends App.Views.ItemView
    getIcon: ->
      switch @model.get('type')
        when 'multi_choice','multi_choice_custom'
          'th'
        when 'number'
          'sort-numeric-asc'
        when 'photo'
          'camera-retro'
        when 'document'
          'file-code-o'
        when 'single_choice','single_choice_custom'
          'list'
        when 'text'
          'align-left'
        when 'timestamp'
          'clock-o'
        else
          'question'
    attributes:
      "class": "item"
    serializeData: ->
      data = @model.toJSON()
      data.icon = @getIcon()
      data

  class Item.ResponseString extends Item.ResponseBase
    template: "uploadqueue/item/response_string"


  class Item.ResponseSingleChoice extends Item.ResponseString
    serializeData: ->
      data = super
      data.response = data.options[data.response]
      data

  class Item.ResponseMultiChoice extends Item.ResponseBase
    template: "uploadqueue/item/response_multi_choice"
    serializeData: ->
      data = super
      # the response is a stringified array referencing options.
      selectionsArr = JSON.parse data.response
      # responses is an array that will be iterated over inside the view.
      data.responses = _.map selectionsArr, (selection) ->
        data.options[selection]
      data

  class Item.ResponseMultiChoiceCustom extends Item.ResponseMultiChoice
    serializeData: ->
      data = super
      # the response is a stringified array referencing custom choice strings.
      selectionsArr = JSON.parse data.response
      # responses is an array that will be iterated over inside the view.
      data.responses = selectionsArr
      data

  class Item.ResponsePhoto extends Item.ResponseBase
    template: "uploadqueue/item/response_photo"
    onRender: ->
      savedImage = @model.get('response')
      if savedImage then @renderImageThumb(savedImage)
    renderImageThumb: (img64) ->
      # display the image in the preview
      $img = @$el.find '.preview-image'
      $img.prop 'src', img64
      $img.css 'display', 'block'

  class Item.ResponseDocument extends Item.ResponseBase
    template: "uploadqueue/item/response_document"
    serializeData: ->
      data = super
      # TODO: Replace placeholder with a file reference of some kind.
      data.response = "Selected Document Placeholder"
      data

  class Item.ResponseUnsupported extends Item.ResponseBase
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
        when 'document'
          Item.ResponseDocument
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
      console.log 'item details data', data
      data.locationExists = data.location?
      data.prettyTimestamp = moment(data.timestamp).format("MM/DD/YYYY, h:mma")
      data.campaign_creation_timestamp = moment(data.campaign_creation_timestamp).format("MM/DD/YYYY, h:mma")
      data

  class Item.Layout extends App.Views.Layout
    id: 'upload-queue'
    template: "uploadqueue/item/layout"
    regions:
      noticeRegion: "#notice-region"
      detailsRegion: "#details-region"
      responsesRegion: "#responses-list"
