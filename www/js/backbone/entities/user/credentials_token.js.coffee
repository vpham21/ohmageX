@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The credentials token Entity provides an interface for login via token.

  currentAuthToken = false

  API =
    tokenVerify: ->
      # use whoami to get the username and save it.
      currentAuthToken = myGetCookie('auth_token')

      if currentAuthToken is null
        @tokenLoginRedirect()
        return false
    tokenLoginRedirect: ->
      # redirect to server login page.
      window.location.replace '/web/#login'

