@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # UserPrefences entity.
  # This pertains to storing, retrieving and setting user preferences.

  class Entities.UserPreferences extends Entities.Model

  storedPreferences = false

  API =
    init: ->
      App.request "storage:get", 'user_preferences', ((result) =>
        console.log 'saved user preferences retrieved from storage'
        storedPreferences = new Entities.UserPreferences result
        App.vent.trigger "userpreferences:saved:init:success"
      ), =>
        console.log 'saved user preferences not retrieved from storage'
        storedPreferences = new Entities.UserPreferences
          wifi_upload_only: App.custom.user_preference_defaults.wifi_upload_only
        App.vent.trigger "userpreferences:saved:init:failure"

    updateLocal: (callback) ->
      App.execute "storage:save", 'user_preferences', storedPreferences.toJSON(), callback

    getPreference: (preference) ->
      storedPreferences.get(preference)

    setPreference: (preference, state) ->
      storedPreferences.set(preference, state)
      @updateLocal( =>
        console.log "UserPreferences entity saved in localStorage"
      )

  App.on "before:start", ->
    API.init()

  App.reqres.setHandler "user:preferences:get", (preference) ->
    API.getPreference preference

  App.reqres.setHandler "user:preferences:set", (preference, state) ->
    API.setPreference preference, state