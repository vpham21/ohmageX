@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # This Entity handles upload processing for responses.

  class Entities.Uploader extends Entities.Model

  API =
    parseUploadErrors: (responseData, response, surveyId) ->
      console.log 'parseUploadErrors'
      if response.result is "success"
        App.execute "survey:images:destroy"
        console.log 'newUploader Success!'
        App.vent.trigger "survey:upload:success", response, surveyId
      else
        console.log 'response.errors[0].code', response.errors[0].code
        type = switch response.errors[0].code
          when '0710','0703','0617','0700' then "campaign"
          when '0100' then "server"
          when '0600','0307' then "response"
          when '0200' then "auth"
        console.log 'type', type
        App.vent.trigger "survey:upload:failure:#{type}", responseData, response.errors[0].text, surveyId

    newUploader: (responseData, surveyId) ->

      # add auth credentials to the response before saving.
      # may later move this to the model's custom "sync" method.
      myAuth = App.request 'credentials:upload:params'
      throw new Error "Authentication credentials not set in uploader" if myAuth is false

      # uploader = new Entities.Uploader _.extend(myAuth, responseData)


      # Uses $.ajax() instead of Backbone.save() because of server error.
      # See Issue #208

      $.ajax
        type: 'POST' # not RESTful but the Ohmage 2.0 API requires it
        data: _.extend(myAuth, responseData)
        url: "#{App.request("serverpath:current")}/app/survey/upload"
        dataType: 'json'
        success: (response) =>
          @parseUploadErrors responseData, response, surveyId
        error: (response) =>
          console.log 'survey upload error'
          # assume all error callbacks here are network related
          App.vent.trigger "survey:upload:failure:network", responseData, response, surveyId

  App.commands.setHandler "uploader:new", (responseData, surveyId) ->
    # campaign_urn serves as the "foreign key" between
    # surveysSaved and CampaignsUser
    campaign_urn = App.request "survey:saved:urn", surveyId
    myCampaign = App.request "campaign:entity", campaign_urn

    responsePackage = _.extend responseData, 
      campaign_urn: campaign_urn
      campaign_creation_timestamp: myCampaign.get('creation_timestamp')

    API.newUploader responsePackage, surveyId
