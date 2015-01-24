@Ohmage.module "RemindersApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Add extends App.Views.ItemView
    template:
      "reminders/list/add"
    triggers:
      "click .add-button": "add:clicked"

  class List.Notice extends App.Views.ItemView
    template: "reminders/list/notice"

  class List.ReminderSurvey extends App.Views.ItemView
    initialize: ->
      @listenTo @model, "change:chosen", =>
        if @model.isChosen()
          @trigger "chosen:changed", @model
    template: "reminders/list/_survey"
    tagName: 'option'
    attributes: ->
      options = {}
      options['value'] = @model.get 'id'
      if @model.isChosen() then options['selected'] = 'selected'
      options

  class List.ReminderSurveys extends App.Views.CollectionView
    initialize: ->
      @listenTo @, "item:selected", @chooseItem
    childView: List.ReminderSurvey
    tagName: 'select'
    chooseItem: (options) ->
      console.log 'chooseItem options', options
      @collection.chooseById @$el.val()
      console.log 'chosen id', @collection.chosenId()
    triggers: ->
      "change": "item:selected"

  class List.ReminderLabel extends App.Views.ItemView
    initialize: ->
      @listenTo @model, 'change', @render
    template: "reminders/list/_label"
    tagName: 'span'

  class List.Reminder extends App.Views.Layout
    initialize: ->
      @listenTo @model, 'visible:false', @toggleOff
      @listenTo @model, 'visible:true', @toggleOn
    tagName: 'li'
    template: "reminders/list/_item"
    toggleOff: ->
      @toggler.hide()
      console.log 'toggleOff'
      @$el.find('.toggler-button .my-icon').html('&#9654;')
    toggleOn: ->
      @toggler.show()
      console.log 'toggleOn'
      @$el.find('.toggler-button .my-icon').html('&#9660;')
    onRender: ->
      # set up
      @toggler = new VisibilityToggleComponent("#reminder-form-#{@model.get('id')}", @$el)
      @repeater = new VisibilityToggleComponent('.repeat-days', @$el)
      @repeater.toggleOn('click', 'input[name="repeat"]', @$el)
      active = @model.get('active')
      if active then @$el.find("input[name='active-switch']").prop('checked', true)
    regions:
      surveysRegion: '.surveys-region'
      labelRegion: '.label-region'
    triggers:
      "click .toggler-button": "toggle:activate"

  class List.RemindersEmpty extends App.Views.ItemView
    className: "text-container"
    template: "reminders/list/_reminders_empty"

  class List.Reminders extends App.Views.CompositeView
    initialize: ->
      @listenTo @, "childview:toggle:activate", @toggleSelectedOnly

    toggleSelectedOnly: (options) ->
      visibleModel = @collection.findWhere(renderVisible: true)
      if typeof visibleModel isnt "undefined" then visibleModel.trigger('visible:false')
      options.model.trigger('visible:true')
    tagName: 'nav'
    className: 'list'
    template: "reminders/list/reminders"
    childView: List.Reminder
    childViewContainer: "ul"
    emptyView: List.RemindersEmpty

  class List.Layout extends App.Views.Layout
    getTemplate: ->
      if @model.get('localNotification') is true then "reminders/list/layout_enabled" else "reminders/list/layout_disabled"
    regions: (options) ->
      if options.model.get('localNotification') is true
        return {
          noticeRegion: "#notice-region-nopop"
          addRegion: "#add-region"
          listRegion: "#list-region"
        }
      else
        return {
          noticeRegion: "#notice-region-nopop"
        }
