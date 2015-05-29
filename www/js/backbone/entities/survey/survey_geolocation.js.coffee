@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # This Entity handles geolocation.
  # it provides an interface for geolocation.
  currentLocation = false
  API =
    fetchSuccess: (position) ->
      currentLocation = 
        provider: "GPS"
        latitude: position.coords.latitude
        longitude: position.coords.longitude
        accuracy: position.coords.accuracy
        time: moment(position.timestamp).valueOf()
        timezone: _.jstz()
      App.vent.trigger "survey:geolocation:fetch:success", @surveyId

    fetchError: ->
      App.vent.trigger "survey:geolocation:fetch:failure", @surveyId

    getLocation: (surveyId) ->
      @surveyId = surveyId

      if App.device.isNative and device.platform is "Android" and navigator.connection.type == Connection.NONE
        # if using Android with no network connection, fetching location may never time out,
        # so fail it immediately.
        @fetchError()
        return false

      navigator.geolocation.getCurrentPosition( _.bind(@fetchSuccess, @), _.bind(@fetchError, @) )

  App.reqres.setHandler "geolocation:get", ->
    currentLocation

  App.commands.setHandler "survey:geolocation:fetch", (surveyId) ->
    API.getLocation surveyId
