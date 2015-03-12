@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # This saves and restores locally triggered surveys for a user.
  # This is separate from the system Notifications; triggered
  # surveys are saved locally.

  currentTriggered = false

  class Entities.SurveyTriggered extends Entities.Model

  class Entities.SurveysTriggered extends Entities.Collection
    model: Entities.SurveyTriggered

  API =
    init: ->
      App.request "storage:get", 'surveys_triggered', ((result) =>
        # customChoice is retrieved from raw JSON.
        console.log 'triggered surveys retrieved from storage'
        currentTriggered = new Entities.SurveysTriggered result
      ), =>
        console.log 'triggered surveys not retrieved from storage'
        currentTriggered = false

    exists: (surveyId) ->
      currentTriggered and currentTriggered.where(surveyId: surveyId).length > 0

    addTriggered: (surveyId) ->
      if !@exists surveyId
        if !currentTriggered then currentTriggered = new Entities.SurveysTriggered

        currentTriggered.add
          campaign_urn: App.request "survey:saved:urn", surveyId
          surveyId: surveyId

        @updateLocal( =>
          console.log "surveys_triggered entity saved in localStorage"
          App.vent.trigger "surveys:local:triggered:new:success", surveyId
        )

    removeTriggered: (surveyId) ->
      removed = currentTriggered.where
        surveyId: surveyId

      currentTriggered.remove removed
      @updateLocal( =>
        console.log "surveys_triggered entity removed from localStorage"
        App.vent.trigger "surveys:local:triggered:remove:success", surveyId
      )

    removeCampaignTriggered: (campaign_urn) ->
      removed = currentTriggered.where
        campaign_urn: campaign_urn

      currentTriggered.remove removed
      @updateLocal( =>
        console.log "campaign triggered surveys removed from localStorage"
        App.vent.trigger "surveys:local:triggered:campaign:remove:success", campaign_urn
      )


    updateLocal: (callback) ->
      # update localStorage index surveys_triggered with the current version of campaignsSaved entity
      App.execute "storage:save", 'surveys_triggered', currentTriggered.toJSON(), callback
  App.reqres.setHandler "surveys:local:triggered:entity", ->
    currentTriggered

  App.reqres.setHandler "surveys:local:triggered:exists", (surveyId) ->
    API.exists surveyId

  App.commands.setHandler "surveys:local:triggered:add", (surveyId) ->
    API.addTriggered surveyId

  App.vent.on "survey:start", (surveyId) ->
    if currentTriggered then API.removeTriggered(surveyId)

  App.vent.on "reminder:delete:success", (reminder) ->
    if currentTriggered then API.removeTriggered(reminder.get('surveyId'))

  App.vent.on "campaign:saved:remove", (campaign_urn) ->
    if currentTriggered then API.removeCampaignTriggered(campaign_urn)

  Entities.on "start", ->
    API.init()
