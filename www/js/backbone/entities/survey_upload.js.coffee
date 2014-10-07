@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The survey Entity deals with data relating to all surveys,
  # and single surveys.
  # This module handles the upload process.

  API =
    imageUUIDs: {}
    prepResponseUpload: (currentResponses, currentFlow) ->
      currentResponses.map( (response) =>
        myId = response.get 'id'
        myStatus = App.request "flow:status", myId
        if response.get('response') is false
          # convert false responses (aka invalid)
          # into equivalents required by the server,
          # based on the flow status of the step.
          switch myStatus
            when 'skipped'
              myResponse = 'SKIPPED'
            when 'not_displayed'
              myResponse = 'NOT_DISPLAYED'
            else
              throw new Error "false response for step #{myId} with invalid flow status: #{myStep.get('status')}"
        else
          if response.get('type') is 'photo'
            # photo responses must reference a UUID, not the base64.
            # base64 are submitted with a separate parameter `images`
            myResponse = @generateImgUUID(response.get 'response')
          else
            myResponse = response.get 'response'
        {
          prompt_id: myId
          value: myResponse
        }
      )

    generateImgUUID: (img64) ->
      # generate a UUID and put it in a group of UUIDs in this format:
      # { UUID: base64EncodedImage }
      myID = _.guid()
      @imageUUIDs[myID] = img64
      myID

    uploadSurvey: (options) ->
      { currentResponses, location, surveyId } = options

      submitResponses = @prepResponseUpload currentResponses
      # before this, requires credentials to be generated with
      # App.execute "credentials:set", username, password
      submitCredentials = App.request "credentials:current"

      currentTime = (new Date).getTime()
      currentTZ = _.jstz()

      submitSurveys = 
        survey_key: _.guid()
        time: currentTime
        timezone: currentTZ
        location_status: if location then "valid" else "unavailable"
        survey_id: surveyId
        survey_launch_context:
          launch_time: 1411671398146
          launch_timezone: "America/Los_Angeles"
          active_triggers: []
        responses: submitResponses

      if location
        # if the location status is unavailable,
        # it is an error to send a location object.
        submitSurveys.location = location

      completeSubmit = 
        campaign_urn: 'urn:campaign:ca:ucla:oit:PromptTypesCondition'
        campaign_creation_timestamp: '2014-06-23 20:14:35'
        user: submitCredentials.get 'username'
        password: submitCredentials.get 'password'
        client: 'ohmage-mwf-dw'
        images: {}
        surveys: JSON.stringify([submitSurveys])

      $.ajax
        type: "POST"
        url: 'https://test.ohmage.org/app/survey/upload'
        data: completeSubmit
        dataType: 'json'
        success: (response) =>
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
