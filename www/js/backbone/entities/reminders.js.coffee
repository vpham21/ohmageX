@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Reminders entity.
  # Note: Local notification permissions are a concern for iOS 8+ and Android (if disabled)
  # this requires interaction with the Permissions entity.

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
      renderVisible: false
  class Entities.Reminders extends Entities.Collection
    model: Entities.Reminder

  currentReminders = false

  API =
    init: ->
      App.request "storage:get", 'reminders', ((result) =>
        # saved reminders retrieved from raw JSON.
        console.log 'saved reminders retrieved from storage'
        currentReminders = new Entities.Reminders result
        App.vent.trigger "reminders:saved:init:success"
      ), =>
        console.log 'saved reminders not retrieved from storage'
        currentReminders = new Entities.Reminders
        App.vent.trigger "reminders:saved:init:failure"

    addNewReminder: ->
      console.log 'addReminder'
      currentReminders.add({}, { validate: false })

    getReminders: ->
      currentReminders

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
