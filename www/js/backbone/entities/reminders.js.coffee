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
  # repeatDays - Array (Integers) - List of repeating days 0 thru 6. 0 is Sunday.
  # surveyId - String - ID of the survey to use.
  # surveyTitle - String - Title of the survey. Used in views


  class Entities.Reminder extends Entities.ValidatedModel
    initialize: (options) ->
      @listenTo @, 'survey:selected', @selectSurvey
      @listenTo @, 'internal:success', @propagateResponses
      # Be sure to initialize activationDate as a moment if it's provided on init.
      # If retrieving from localStorage, the activationDate is stored as a string.
      if options.activationDate? then @set('activationDate', moment(options.activationDate))
    propagateResponses: (attrs) ->
      # delete the 'response' and 'properties' properties
      # because they're validation placeholders.
      delete attrs.properties
      delete attrs.response
      result = new Entities.Reminder attrs
      @trigger 'validated:success', result
    selectSurvey: (surveyModel) ->
      @set('surveyTitle', surveyModel.get('title'))
      @set('surveyId', surveyModel.get('id'))
      @set('campaign', surveyModel.get('campaign_urn'))

    validate: (attrs, options) ->
      # defining a placeholder value here,
      # so a property can be passed into the rulesMap.
      attrs.properties =
        activationDate: true
      attrs.response = attrs.activationDate
      myRulesMap =
        futureTimestamp: 'activationDate'
      super attrs, options, myRulesMap

    defaults: ->

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
    initialize: ->
      @listenTo @, "survey:selected", =>
        App.execute "storage:save", 'reminders', @toJSON(), =>
          console.log "reminders entity Reminders Collection survey:selected storage success"

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

    toggleSystemNotifications: (reminder) ->
      if reminder.get('active') is true
        App.execute "system:notifications:add", reminder
      else
        # This reminder has been disabled. Be sure to deactivate its notifications.
        console.log 'toggleSystemNotifications disabled notification ids', reminder.get('notificationIds')
        App.execute "system:notifications:delete", reminder


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
      validateIt = response.active and !response.repeat

      reminder.set response, { validate: validateIt }

      if !validateIt then reminder.trigger("validated:success", reminder)

      @updateLocal( =>
        console.log "reminders entity API.validateReminder storage success"
      )

    deleteReminder: (reminderId) ->

      myReminder = currentReminders.get reminderId
      currentReminders.remove myReminder


      @updateLocal( =>
        console.log "reminders entity API.deleteReminder storage success"
      )

    removeCampaignReminders: (campaign_urn) ->
      console.log 'removedCampaignReminders urn', campaign_urn

      console.log 'currentReminders', currentReminders.toJSON()

      removed = currentReminders.where
        campaign: campaign_urn

      _.each removed, (reminder) =>
        console.log 'reminder ID', reminder.get 'id'
        App.execute "system:notifications:delete", reminder.get 'id'

      currentReminders.remove removed

      @updateLocal( =>
        console.log "campaign reminders removed from localStorage"
        App.vent.trigger "reminders:campaign:remove:success", campaign_urn
      )

    setAttribute: (reminderId, attribute, value) ->
      reminder = currentReminders.get reminderId
      reminder.set attribute, value

      @updateLocal( =>
        console.log "reminder notification #{attribute} set", value
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
    App.execute "system:notifications:delete", model.get 'id'
    API.deleteReminder model.get 'id'

  App.commands.setHandler "reminder:validate", (model, response) ->
    API.validateReminder model, response

  App.commands.setHandler "reminder:notifications:set", (reminder, ids) ->
    # ids - array of IDs to set for the notification
    console.log "reminder:notifications:set", JSON.stringify(reminder.toJSON())
    API.setAttribute reminder.get('id'), 'notificationIds', ids

  App.commands.setHandler "reminder:date:set", (reminder, date) ->
    # ids - array of IDs to set for the notification
    API.setAttribute reminder.get('id'), 'activationDate', date

  App.vent.on "campaign:saved:remove", (campaign_urn) ->
    if currentReminders.length > 0 then API.removeCampaignReminders(campaign_urn)

  App.vent.on "reminder:set:success", (reminderModel) ->
    API.toggleSystemNotifications reminderModel
