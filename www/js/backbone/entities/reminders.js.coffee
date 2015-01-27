@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Reminders entity.
  # Note: Local notification permissions are a concern for iOS 8+ and Android (if disabled)
  # this requires interaction with the Permissions entity.

  # id - String - Unique ID for the reminder. Generated per reminder.
  # activationDate - Moment() object - When the reminder is activated.
  # active - Boolean - If the reminder is actually activated or just stored.
  # notificationIds - Array (Strings) - System notification IDs assigned to this reminder.
  # repeat - Boolean - If true then this reminder repeats
  # repeatDays - Array (Integers) - List of repeating days 0 thru 6. 0 is Monday.
  # surveyId - String - ID of the survey to use.
  # surveyTitle - String - Title of the survey. Used in views

  class Entities.ReminderSurveys extends Entities.NavsCollection
    chosenId: ->
      (@findWhere(chosen: true) or @first()).get('id')
    chooseById: (nav) ->
      @choose (@findWhere(id: nav) or @first())


  class Entities.Reminder extends Entities.ValidatedModel
    initialize: (options) ->
      @listenTo @, 'visible:false', @visibleFalse
      @listenTo @, 'visible:true', @visibleTrue
    validate: (attrs, options) ->
      # defining a placeholder value here,
      # so a property can be passed into the rulesMap.
      attrs.properties =
        activationDate: true
      attrs.response = attrs.activationDate
      myRulesMap =
        timestampISO: 'activationDate'
        futureTimestamp: 'activationDate'
      super attrs, options, myRulesMap

    visibleFalse: ->
      @set('renderVisible', false)
    visibleTrue: ->
      @set('renderVisible', true)
    defaults:
      id: _.guid()
      activationDate: moment.unix( moment() + 120 * 1000)
      active: false
      notificationIds: []
      repeat: false
      repeatDays: []
      renderVisible: false
      surveyId: false
      surveyTitle: false

  class Entities.Reminders extends Entities.Collection
    model: Entities.Reminder
  currentReminders = false

  API =
    init: ->
      App.request "storage:get", 'reminders', ((result) =>
        # saved reminders retrieved from raw JSON.
        console.log 'saved reminders retrieved from storage'
        # currentReminders = new Entities.Reminders result
        currentReminders = new Entities.Reminders
        App.vent.trigger "reminders:saved:init:success"
      ), =>
        console.log 'saved reminders not retrieved from storage'
        currentReminders = new Entities.Reminders
        App.vent.trigger "reminders:saved:init:failure"

      @initNotificationEvents()

    initNotificationEvents: ->
      window.plugin.notification.local.onclick = (id, state, json) ->
        console.log 'onclick event!'
        console.log 'id', id
        result = JSON.parse json
        console.log "survey/#{result.surveyId}"
        App.navigate "survey/#{result.surveyId}", trigger: true


    addNewReminder: ->
      console.log 'addReminder'
      currentReminders.add({}, { validate: false })

    addNotification: (reminder) ->

      if reminder.get('active') is true
        console.log 'addNotification reminder', reminder
        window.plugin.notification.local.cancelAll()
        console.log "reminder.get('surveyId')", reminder.get('surveyId')

        console.log 'reminder notification_id', reminder.get('id')

        metadata = JSON.stringify reminder.toJSON()

        window.plugin.notification.local.add
          id: reminder.get('surveyId')
          title: "#{reminder.get('surveyTitle')}"
          message: "Take survey #{reminder.get('surveyTitle')}"
          repeat: "weekly"
          date: reminder.get('activationDate').toDate()
          autoCancel: false
          console.log "reminder set callback"
          # add listener here for the reminder action.
          # use the same ID as this generated ID.
          # Save the generated ID.
          # App.execute "dialog:alert", "reminder set"
        ), @


    getReminders: ->
      currentReminders

    validateReminder: (model, response) ->
      console.log 'validateReminder'
      if response.repeat and response.repeatDays.length is 0
        App.vent.trigger "reminder:validate:fail", 'Please select days to repeat this reminder.'
        return false

      console.log 'validateReminder model', model
      console.log 'response', response
      reminder = currentReminders.get(model)
      reminder.set response, { validate: true }
      # App.execute "storage:save", 'reminders', currentReminders.toJSON(), =>
      #   console.log "reminders entity API.validateReminder storage success"

    clear: ->
      currentReminders = new Entities.Reminders

      App.execute "storage:clear", 'reminders', ->
        console.log 'saved reminders erased'
        App.vent.trigger "reminders:saved:cleared"

  App.vent.on "surveys:saved:load:complete", ->
    # if App.device.isNative
    API.init()

  App.commands.setHandler "reminders:saved:clear", ->
    API.clear()

  App.vent.on "credentials:cleared", ->
    API.clear()

  App.reqres.setHandler "reminders:current", ->
    API.getReminders()

  App.commands.setHandler "reminders:add:new", ->
    API.addNewReminder()

  App.commands.setHandler "reminder:validate", (model, response) ->
    API.validateReminder model, response

  App.vent.on "reminder:set:success", (reminderModel) ->
    API.addNotification reminderModel
