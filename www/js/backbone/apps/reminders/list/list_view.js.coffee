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
    childView: List.ReminderSurvey
    tagName: 'select'
    chooseItem: (options) ->
      selected =  @$el.val()
      myModel = options.collection.findWhere(id: selected)
      @trigger "survey:selected", myModel
    triggers: ->
      "change": "item:selected"
    onRender: ->
      @collection.every (survey) =>
        if survey.get('selected')
          @$el.val(survey.get 'id')
          false
        else true


  class List.UpdateBlocker extends App.Views.Layout
    initialize: ->
      @listenTo @, 'save:reminder', @gatherResponses
      @listenTo @, 'repeat:toggle', @repeatToggle
      @listenTo @, 'check:enabled', @checkEnabled
      @listenTo @, 'date:adjust', @fixDate
      @listenTo @, 'time:adjust', @updateTime
    tagName: 'li'
    template: "reminders/list/_item"
    selectLabel: (e) ->
      console.log 'selectedLabels'
      $label = $(e.currentTarget)
      $input = $label.prev()
      checked = $input.prop('checked')
      $input.prop('checked', !checked)
    repeatToggle: ->
      enabled = @$el.find("input[name='repeat']").prop('checked')
      if enabled
        @$el.find('.date-control').hide()
      else
        @$el.find('.date-control').show()
    getProvidedDate: ->
      dateString = "#{@$el.find('input[type=date]').val()}T#{@$el.find('input[type=time]').val()}#{moment().format('Z')}"
      moment(dateString).second(0)
    fixDate: ->
      $dateInput = @$el.find('input[type=date]')
      currentDate = $dateInput.val()
      dateMoment = moment currentDate
      if currentDate.length > 0 and dateMoment.isValid
        currentDateTime = @getProvidedDate()
        if moment().diff(currentDateTime) > 0
          # the current date and time is in the past.
          # get the next occurrence of this hour minute and second.
          currentDateTime = @nextHourMinuteSecond(@getProvidedDate(), 'days')
        $dateInput.val currentDateTime.format('YYYY-MM-DD')
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
      if currentTime.length > 0 and timeMoment.isValid
        # round the valid time seconds to 0.
        timeMoment = timeMoment.second(0)
        @$el.find('.display-time').html timeMoment.format("hh:mma")
        @$el.find('.time-control input').val timeMoment.format("HH:mm:ss")
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
        active: true
        repeat: myRepeat
        repeatDays: repeatDays

      @trigger "reminder:submit", response

    serializeData: ->
      data = @model.toJSON()
      currentDate = moment(data.activationDate)
      data.currentDateValue = currentDate.format('YYYY-MM-DD')
      data.currentTimeValue = currentDate.format('HH:mm:ss')
      data
    regions:
      surveysRegion: '.surveys-region'
    triggers:
      "blur .date-control input": "date:adjust"
      "blur .time-control input": "time:adjust"
      "click .delete-button": "delete:reminder"
      "click input[name='repeat']":
        event: "repeat:toggle"
        preventDefault: false
        stopPropagation: false

  class List.RemindersEmpty extends App.Views.ItemView
    className: "text-container"
    template: "reminders/list/_reminders_empty"

  class List.ReminderSummary extends App.Views.ItemView
    initialize: ->
      @listenTo @, "active:toggle", @setSwitch
      @listenTo @model, 'change', @render
      @listenTo @, 'check:enabled', @checkEnabled
    template: "reminders/list/_item_summary"
    tagName: 'li'
    setSwitch: ->
      console.log 'setSwitch'
      @model.set 'active', @$el.find(".enable-switch input").prop('checked') is true
      @trigger "active:complete"
    checkEnabled: ->
      @$el.find(".enable-switch input").prop('checked', true)
    serializeData: ->
      data = @model.toJSON()
      currentDisplayTime = data.activationDate.format('h:mma')
      if data.repeat
        # repeat is enabled
        if data.repeatDays.length is 7
          data.summaryText = "Repeats daily at #{currentDisplayTime}"
        else
          dayList = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']
          console.log 'repeatDays', data.repeatDays
          dayText = _.reduce(data.repeatDays, (dayText, repeatDay, index) ->
            console.log 'repeatDay', repeatDay
            console.log 'repeatDay parseint', parseInt(repeatDay)
            console.log 'index', index
            if index isnt data.repeatDays.length-1
              prefix = ""
              suffix = ", "
            else
              prefix = " and "
              suffix = ""
            dayText + "#{prefix}#{dayList[parseInt(repeatDay)]}#{suffix}"
          , "")
          data.summaryText = "Repeats on #{dayText} at #{currentDisplayTime}"
      else
        # one time reminder.
        data.summaryText = data.activationDate.calendar()
      data
    onRender: ->
      # prepopulate all fields
      active = @model.get('active')
      if active then @checkEnabled()
    triggers:
      "change .enable-switch input":
        event: "active:toggle"
        preventDefault: false
        stopPropagation: false
      "click .edit-button,h3,p": "click:edit"

  class List.Reminders extends App.Views.CompositeView
    tagName: 'nav'
    className: 'list'
    template: "reminders/list/reminders"
    childView: List.ReminderSummary
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
