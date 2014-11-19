@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The survey Entity deals with data relating to a single survey.
  # This module handles the upload process.

  API =
    prepResponseUpload: (currentResponses, currentFlow) ->
      currentResponses.map( (response) =>
        myId = response.get 'id'
        myResponse = App.request "response:value:parsed", { stepId: myId, addImageUUID: true }
        {
          prompt_id: myId
          value: myResponse
        }
      )

    uploadSurvey: (options) ->
      { currentResponses, location, surveyId } = options

      submitResponses = @prepResponseUpload currentResponses

      currentTime = (new Date).getTime()
      currentTZ = _.jstz()

      submitSurveys = 
        survey_key: _.guid()
        time: currentTime
        timezone: currentTZ
        location_status: if location then "valid" else "unavailable"
        survey_id: App.request "survey:saved:server_id", surveyId
        survey_launch_context:
          launch_time: 1411671398146
          launch_timezone: "America/Los_Angeles"
          active_triggers: []
        responses: submitResponses

      # campaign_urn serves as the "foreign key" between
      # surveysSaved and CampaignsUser
      campaign_urn = App.request "survey:saved:urn", surveyId
      myCampaign = App.request "campaign:entity", campaign_urn

      if location
        # if the location status is unavailable,
        # it is an error to send a location object.
        submitSurveys.location = location

      completeSubmit = 
        campaign_urn: campaign_urn
        campaign_creation_timestamp: myCampaign.get 'creation_timestamp'
        user: submitCredentials.get 'username'
        password: submitCredentials.get 'password'
        client: 'ohmage-mwf-dw'
        images: App.request "survey:images:string"
        surveys: JSON.stringify([submitSurveys])

      serverPath = App.request "serverpath:current"

      $.ajax
        type: "POST"
        url: "#{serverPath}/app/survey/upload"
        data: completeSubmit
        dataType: 'json'
        success: (response) =>
          App.execute "survey:images:destroy"
          App.vent.trigger "survey:upload:success", response, surveyId
    getLocation: (responses, surveyId) ->
      # get geolocation
      location = App.request "geolocation:get"
      console.log 'getLocation location', location
      if location isnt false
        @uploadSurvey
          currentResponses: responses
          location: location
          surveyId: surveyId
      else
        App.execute("survey:geolocation:fetch", surveyId)

  App.commands.setHandler "survey:upload", (surveyId) ->
    responses = App.request "responses:current"
    API.getLocation responses, surveyId

  App.vent.on "survey:geolocation:fetch:failure", (surveyId) ->
    console.log 'geolocation fetch failure', surveyId
    responses = App.request "responses:current"
    API.uploadSurvey
      currentResponses: responses
      location: false
      surveyId: surveyId

  App.vent.on "survey:geolocation:fetch:success", (surveyId) ->
    console.log 'geolocation fetch success', App.request "geolocation:get"
    responses = App.request "responses:current"
    API.uploadSurvey
      currentResponses: responses
      location: App.request "geolocation:get"
      surveyId: surveyId
