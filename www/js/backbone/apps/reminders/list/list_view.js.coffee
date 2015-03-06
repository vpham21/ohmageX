@Ohmage.module "RemindersApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Add extends App.Views.ItemView
    template:
      "reminders/list/add"
    triggers:
      "click .add-button": "add:clicked"

  class List.Notice extends App.Views.ItemView
    template: "reminders/list/notice"

  class List.ReminderSurvey extends App.Views.ItemView
    template: "reminders/list/_survey"
    tagName: 'option'
    attributes: ->
      options = {}
      options['value'] = @model.get 'id'
      options

  class List.ReminderSurveys extends App.Views.CollectionView
    initialize: ->
      @listenTo @, "item:selected", @chooseItem
      @listenTo @, "option:select", @optionSelect
    childView: List.ReminderSurvey
    tagName: 'select'
    chooseItem: (options) ->
      selected =  @$el.val()
      myModel = options.collection.findWhere(id: selected)
      @trigger "survey:selected", myModel
    optionSelect: (id) ->
      @$el.val(id)
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
      @listenTo @, 'save:reminder', @gatherResponses
      @listenTo @, 'save:reminder', @toggleOff
      @listenTo @, 'repeat:toggle', @repeatToggle
      @listenTo @, 'check:enabled', @checkEnabled
      @listenTo @, 'date:adjust', @fixDate
      @listenTo @, 'active:toggle', @gatherResponses
      @listenTo @, 'time:adjust', @updateTime
    tagName: 'li'
    template: "reminders/list/_item"
    toggleOff: ->
      @$el.removeClass('active')
      @toggler.hide()
      console.log 'toggleOff'
      @$el.find('.toggler-button .my-icon').html('&#9654;')
    toggleOn: ->
      @$el.addClass('active')
      @toggler.show()
      console.log 'toggleOn'
      @$el.find('.toggler-button .my-icon').html('&#9660;')
    selectLabel: (e) ->
      console.log 'selectedLabels'
      $label = $(e.currentTarget)
      $input = $label.prev()
      checked = $input.prop('checked')
      $input.prop('checked', !checked)
    checkEnabled: ->
      @$el.find(".enable-switch input").prop('checked', true)
    repeatToggle: ->
      enabled = @$el.find("input[name='repeat']").prop('checked')
      if enabled
        @$el.find('.date-control').hide()
      else
        @$el.find('.date-control').show()
    getProvidedDate: ->
      offset = new Date().toString().match(/([-\+][0-9]+)\s/)[1]
      moment("#{@$el.find('input[type=date]').val()} #{@$el.find('input[type=time]').val()} #{offset}")
    fixDate: ->
      $dateInput = @$el.find('input[type=date]')
      dateMoment = moment $dateInput.val()
      if dateMoment.isValid
        $dateInput.val @nextHourMinuteSecond(@getProvidedDate(), 'days').format('YYYY-MM-DD')
      else
        # set the invalid date to now.
        $dateInput.val moment().format('YYYY-MM-DD')
    nextHourMinuteSecond: (myMoment, interval) ->
      # gets the next occurrence of a moment's hours, minutes, and seconds.
      # Ignores the month, day and year.
      # it jumps ahead by the given 'interval' for the next occurrence.
      # expected - Moment.js intervals like 'days' or 'weeks'

      input = moment(myMoment)

      hour = input.hour()
      minute = input.minute()
      output = moment().startOf('day').hour(hour).minute(minute).second(0)

      if output > moment() then output else output.add(1, interval)
    updateTime: ->
      currentTime = @$el.find('.time-control input').val()
      timeMoment = moment("#{moment().format('YYYY-MM-DD')} #{currentTime}")
        @$el.find('.display-time').html timeMoment.format("HH:mm:ss")
      if currentTime.length > 0 and timeMoment.isValid
      else
        # set the invalid time to now plus 10 minutes.
        @$el.find('.time-control input').val moment().second(0).add(10,'minutes').format("HH:mm:ss")
        @$el.find('.display-time').html moment().second(0).add(10,'minutes').format("hh:mma")
      @fixDate()
    onRender: ->
      # set up
      @toggler = new VisibilityToggleComponent("#reminder-form-#{@model.get('id')}", @$el)
      @repeater = new VisibilityToggleComponent('.repeat-days', @$el)
      @repeater.toggleOn('click', 'input[name="repeat"]', @$el)

      # prepopulate all fields
      active = @model.get('active')
      if active then @checkEnabled()

      repeat = @model.get('repeat')

      if repeat
        # pre-populate repeating fields.
        @$el.find("input[name='repeat']").prop('checked', true)
        @repeatToggle()
        @repeater.show()
        repeatDays = @model.get('repeatDays')
        if repeatDays.length > 0
          _.each(repeatDays, (repeatDay) =>
            @$el.find("input[name='repeatDays[]'][value='#{repeatDay}']").prop('checked', true)
          )
    events: ->
      if App.device.isNative
        "touchstart .repeat-days label": "selectLabel"
      else
        "click .repeat-days label": "selectLabel"
    gatherResponses: ->
      console.log 'gatherResponses'
      @fixDate()
      @updateTime()

      myRepeat = @$el.find("input[name='repeat']").prop('checked') is true

      # get repeat days into an array
      $repeatDaysEl = @$el.find('input[name="repeatDays[]"]:checked')
      repeatDays = []
      if myRepeat and $repeatDaysEl.length > 0
        repeatDays = _.map($repeatDaysEl, (repeatDayEl) ->
          $(repeatDayEl).val()
        )

      response =
        activationDate: @getProvidedDate()
        active: @$el.find(".enable-switch input").prop('checked') is true
        repeat: myRepeat
        repeatDays: repeatDays

      @trigger "reminder:submit", response

    serializeData: ->
      data = @model.toJSON()
      currentDate = moment(data.activationDate)
      data.currentDateValue = currentDate.format('YYYY-MM-DD')
      data.currentDisplayTime = currentDate.format('hh:mma')
      data.currentTimeValue = currentDate.format('HH:mm:ss')
      data
    regions:
      surveysRegion: '.surveys-region'
      labelRegion: '.label-region'
    triggers:
      "blur .date-control input": "date:adjust"
      "blur .time-control input": "time:adjust"
      "click .toggler-button": "toggle:activate"
      "click .delete-button": "delete:reminder"
      "click .enable-switch input":
        event: "active:toggle"
        preventDefault: false
        stopPropagation: false
      "click .save-button": "save:reminder"
      "click input[name='repeat']":
        event: "repeat:toggle"
        preventDefault: false
        stopPropagation: false

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
