@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The profile Entity provides an interface for the logged-in user's profile.

  class Entities.UserProfile extends Entities.Model

  API =
    getProfile: ->
      new Entities.UserProfile 
        username: App.request('credentials:username')

  App.reqres.setHandler "profile:current", ->
    API.getProfile()
