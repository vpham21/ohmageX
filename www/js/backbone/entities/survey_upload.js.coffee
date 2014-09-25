@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The survey Entity deals with data relating to all surveys,
  # and single surveys.
  # This module handles the upload process.

  API =
    uploadSurvey: (currentResponses, surveyId) ->
      # Submit a request with placeholder default data,
      # aside from the responses.

      submitResponses = currentResponses.map( (response) ->
        prompt_id: response.get 'id'
        value: response.get 'response'
      )

      # before this, requires credentials to be generated with
      # App.execute "credentials:set", username, password

      submitCredentials = App.request "credentials:current"

      submitSurveys = JSON.stringify(
        [
          survey_key: _.guid()
          time: 1411671421136
          timezone: "America/Los_Angeles"
          location_status: "valid"
          survey_id: surveyId
          survey_launch_context:
            launch_time: 1411671398146
            launch_timezone: "America/Los_Angeles"
            active_triggers: []
          responses: submitResponses
          location:
            provider: "GPS"
            latitude: 34.052234
            longitude: -118.24368499999999
            accuracy: 22000
            time: 1411671398316
            timezone: "America/Los_Angeles"
        ]
      )

      completeSubmit = 
        campaign_urn: 'urn:campaign:ca:ucla:oit:PromptTypesCondition'
        campaign_creation_timestamp: '2014-06-23 20:14:35'
        user: submitCredentials.get 'username'
        password: submitCredentials.get 'password'
        client: 'ohmage-mwf-dw'
        images: {}
        surveys: submitSurveys

      $.ajax
        type: "POST"
        url: 'https://test.ohmage.org/app/survey/upload'
        data: completeSubmit
        dataType: 'json'
        success: (response) =>
          App.vent.trigger "survey:upload:success", response, surveyId

  App.commands.setHandler "survey:upload", (surveyId) ->
    responses = App.request "responses:current"
    API.uploadSurvey responses, surveyId