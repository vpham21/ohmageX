@Ohmage.module "RemindersApp.List", (List, App, Backbone, Marionette, $, _) ->

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
      @listenTo @, 'date:adjust', @saveDate
      @listenTo @, 'time:adjust', @saveTime
      @listenTo @, 'show:future:date', @showFutureDate
      @listenTo @, 'revert:all', @revertAll
    template: "reminders/list/_item"
    attributes:
      class: "reminders-list"
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
    showFutureDate: ->
      @$el.find('input[type=date]').val @model.get('activationDate').format('YYYY-MM-DD')
    revertAll: (surveys) ->
      @model.set('activationDate', @oldDate)
      if @oldSurveyId
        @model.trigger "survey:selected", surveys.findWhere(id: @oldSurveyId)
      else
        # The reminder is a new one.
        @trigger "new:revert", @model
    saveDate: ->
      $dateInput = @$el.find('input[type=date]')
      currentDate = $dateInput.val()
      if !(currentDate.length > 0 and moment(currentDate).isValid)
        # convert invalid date to a valid date before saving
        $dateInput.val moment().format('YYYY-MM-DD')
      # save the date to the model. The model will adjust any invalid dates.
      @model.set 'activationDate', @getProvidedDate()
    saveTime: ->
      currentTime = @$el.find('.time-control input').val()
      timeMoment = moment("#{moment().format('YYYY-MM-DD')} #{currentTime}")
      if currentTime.length > 0 and timeMoment.isValid
        # round the valid time seconds to 0.
        timeMoment = timeMoment.second(0)
      else
        # set the invalid time to now plus 10 minutes.
        timeMoment = moment().second(0).add(10,'minutes')
      @$el.find('.time-control input').val timeMoment.format("HH:mm:ss")
      @saveDate()
    onRender: ->
      # set up
      @repeater = new VisibilityToggleComponent('.repeat-days', @$el)
      @repeater.toggleOn('click', 'input[name="repeat"]', @$el)

      # save the old values as properties on this view so it can be reverted
      # if the user cancels.
      @oldDate = @model.get('activationDate')
      @oldSurveyId = @model.get('surveyId')

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
      @saveTime()

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

      @trigger "reminder:submit", @model, response

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
    className: "empty-container"
    template: "reminders/list/_reminders_empty"

  class List.ReminderSummary extends App.Views.ItemView
    initialize: ->
      @listenTo @, "active:toggle", @setSwitch
      @listenTo @model, 'change', @render
      @listenTo @, 'check:enabled', @checkEnabled
    template: "reminders/list/_item_summary"
    tagName: 'li'
    attributes:
      class: "reminder-summary"
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
          dayList = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
          console.log 'repeatDays', data.repeatDays
          if data.repeatDays.length is 1
            dayText = dayList[parseInt(data.repeatDays[0])]
          else if data.repeatDays.length is 2
            dayText = "#{dayList[parseInt(data.repeatDays[0])]} and #{dayList[parseInt(data.repeatDays[1])]}"
          else
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
        if moment(data.activationDate).startOf('day').diff(moment().startOf('day'), 'weeks') > 0
          # moment calendar() method doesn't display time if it's been more than a week.
          # show a custom formatted date instead.
          data.summaryText = "#{data.activationDate.format('dddd, MMMM Do YYYY')} at #{data.activationDate.format('h:mma')}"
        else
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
