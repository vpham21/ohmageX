@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Reminders entity.
  # Note: Local notification permissions are a concern for iOS 8+ and Android (if disabled)
  # this requires interaction with the Permissions entity.
  # This interacts with the system notifications entity.

  # id - String - Unique ID for the reminder. Generated per reminder.
  # activationDate - Moment() object - When the reminder is activated.
  # active - Boolean - If the reminder is actually activated or just stored.
  # notificationIds - Array (Strings) - System notification IDs assigned to this reminder.
  # repeat - Boolean - If true then this reminder repeats
  # repeatDays - Array (Integers) - List of repeating days 0 thru 6. 0 is Monday.
  # surveyId - String - ID of the survey to use.
  # surveyTitle - String - Title of the survey. Used in views


  class Entities.Reminder extends Entities.ValidatedModel
    initialize: (options) ->
      @listenTo @, 'visible:false', @visibleFalse
      @listenTo @, 'visible:true', @visibleTrue
      @listenTo @, 'survey:selected', @selectSurvey

    selectSurvey: (surveyModel) ->
      @set('surveyId', surveyModel.get('id'))
      @set('surveyTitle', surveyModel.get('title'))
      @set('campaign', surveyModel.get('campaign_urn'))

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
    defaults: ->
      # generate a numeric id (not a guid).
      # The plugin fails if the id is not numeric (Android requirement)

      return {
        id: _.guid()
        activationDate: moment( moment() + 60 * 1000)
        active: false
        notificationIds: []
        repeat: false
        repeatDays: []
        renderVisible: false
        surveyId: false
        surveyTitle: false
        campaign: false
      }

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

    addNotification: (reminder) ->

      if reminder.get('active') is true
        App.execute "system:notifications:add", reminder
      else
        # This reminder has been disabled. Be sure to deactivate its notifications.
        App.execute "system:notifications:delete", reminder.get('notificationIds')


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
      reminder.set response, { validate: response.active and !response.repeat }

      @updateLocal( =>
        console.log "reminders entity API.validateReminder storage success"
      )

    deleteReminder: (model) ->

      console.log 'deleteReminder'
      myReminder = currentReminders.get model
      currentReminders.remove myReminder

      App.execute "system:notifications:delete", model.get('notificationIds')

      @updateLocal( =>
        console.log "reminders entity API.deleteReminder storage success"
      )

    removeCampaignReminders: (campaign_urn) ->
      console.log 'removedCampaignReminders urn', campaign_urn

      console.log 'currentReminders', currentReminders.toJSON()

      removed = currentReminders.where
        campaign: campaign_urn

      console.log 'removed campaign reminders', removed
      currentReminders.remove removed

      @updateLocal( =>
        console.log "campaign reminders removed from localStorage"
        App.vent.trigger "reminders:campaign:remove:success", campaign_urn
      )

    updateLocal: (callback) ->
      # update localStorage index reminders with the current version of campaignsSaved entity
      App.execute "storage:save", 'reminders', currentReminders.toJSON(), callback

    clear: ->
      currentReminders = new Entities.Reminders

      App.execute "storage:clear", 'reminders', ->
        console.log 'saved reminders erased'
        App.vent.trigger "reminders:saved:cleared"

  App.vent.on "surveys:saved:load:complete", ->
    API.init()

  App.commands.setHandler "reminders:saved:clear", ->
    API.clear()

  App.vent.on "credentials:cleared", ->
    API.clear()

  App.reqres.setHandler "reminders:current", ->
    API.getReminders()

  App.commands.setHandler "reminders:add:new", ->
    API.addNewReminder()

  App.commands.setHandler "reminder:delete", (model) ->
    API.deleteReminder model

  App.commands.setHandler "reminder:delete:json", (json) ->
    model = new Entities.Reminder json
    API.deleteReminder model

  App.commands.setHandler "reminder:validate", (model, response) ->
    API.validateReminder model, response

  App.vent.on "campaign:saved:remove", (campaign_urn) ->
    if currentReminders.length > 0 then API.removeCampaignReminders(campaign_urn)

  App.vent.on "reminder:set:success", (reminderModel) ->
    API.addNotification reminderModel
