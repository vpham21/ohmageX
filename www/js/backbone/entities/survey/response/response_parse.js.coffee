@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Response Entity contains data related to the responses
  # within a given Survey.
  # This module contains the handlers that parse a response.

  # currentResponses
  # References the current Response ResponseCollection object, defined in response.js.coffee
  # via the interface "responses:current"

  API = 
    parseFalseToValue: (myStatus, stepId) ->
      # convert false responses (aka invalid)
      # into equivalents required by the server,
      # based on the flow status of the step.
      switch myStatus
        when 'pending'
          return false
        when 'skipped'
          return 'SKIPPED'
        when 'not_displayed'
          return 'NOT_DISPLAYED'
        else
          throw new Error "false response for step #{stepId} with invalid flow status: #{myStatus}"

    parseValueByType: (options) ->
      { responseValue, type, addImageUUID } = options
      switch type
        when 'timestamp'
          # because timestamp responses are raw strings,
          # even though they have been tested with the validator, they
          # have not been saved in the required ISO format, and
          # must be parsed.
          m = moment(responseValue)
          return m.format()
        when 'photo'
          # photo responses must reference a UUID, not the base64.
          # base64 are submitted with a separate parameter `images`
          # which is generated from the survey_upload_images entity.

          # we only want to add and create Image UUIDs in special
          # circumstances, such as survey upload.
          if !addImageUUID then return responseValue

          App.execute "survey:images:add", responseValue
          return App.request "survey:images:uuid:last"
        else
          return responseValue

    parseValue: (options) ->
      { stepId, myResponse, addImageUUID } = options

      if myResponse.get('response') is false
        return @parseFalseToValue App.request("flow:status", stepId), options.stepId
      else
        return @parseValueByType
          responseValue: myResponse.get 'response'
          type: myResponse.get 'type'
          addImageUUID: addImageUUID

  App.reqres.setHandler "response:value:parsed", (options) ->
    options.myResponse = App.request "response:get", options.stepId
    API.parseValue options
