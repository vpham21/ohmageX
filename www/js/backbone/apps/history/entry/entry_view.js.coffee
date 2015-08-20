@Ohmage.module "HistoryApp.Entry", (Entry, App, Backbone, Marionette, $, _) ->

  class Entry.ResponsesEmpty extends App.Views.ItemView
    className: "empty-container"
    template: "history/entry/_responses_empty"

  class Entry.ResponseBase extends App.Views.ItemView
    getIcon: ->
      switch @model.get('prompt_type')
        when 'multi_choice','multi_choice_custom'
          'th'
        when 'number'
          'sort-numeric-asc'
        when 'photo'
          'camera-retro'
        when 'document'
          'file-code-o'
        when 'video'
          'play-circle'
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

  class Entry.ResponseNotDisplayed extends App.Views.ItemView
    # handles alternate response of NOT_DISPLAYED
    template: false

  class Entry.ResponseAlternate extends Entry.ResponseBase
    # handles alternate responses, such as
    # NOT_DISPLAYED and SKIPPED
    template: "history/entry/response_alternate"

  class Entry.ResponseString extends Entry.ResponseBase
    template: "history/entry/response_string"

  class Entry.ResponseSingleChoice extends Entry.ResponseString
    serializeData: ->
      data = super
      mySelection = data.prompt_response
      data.prompt_response = data.prompt_choice_glossary[mySelection].label
      data

  class Entry.ResponseMultiChoice extends Entry.ResponseBase
    template: "history/entry/response_multi_choice"
    serializeData: ->
      data = super
      data.responses = _.map data.prompt_response, (selectionIndex) ->
        data.prompt_choice_glossary[selectionIndex].label
      data

  class Entry.ResponseMultiChoiceCustom extends Entry.ResponseBase
    template: "history/entry/response_multi_choice"
    serializeData: ->
      data = super
      data.responses = data.prompt_response
      data

  class Entry.ResponseUnsupported extends Entry.ResponseBase
    template: "history/entry/response_unsupported"

  class Entry.Responses extends App.Views.CollectionView
    getChildView: (model) ->
      console.log 'childview model', model
      if model.get('prompt_response') in ["NOT_DISPLAYED","SKIPPED"]
        return Entry.ResponseAlternate

      myView = switch model.get('prompt_type')
        when 'single_choice'
          Entry.ResponseSingleChoice
        when 'multi_choice'
          Entry.ResponseMultiChoice
        when 'multi_choice_custom'
          Entry.ResponseMultiChoiceCustom
        when 'text','number','timestamp', 'photo', 'document', 'video', 'single_choice_custom'
          Entry.ResponseString
        else
          Entry.ResponseUnsupported
      myView
    emptyView: Entry.ResponsesEmpty

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
