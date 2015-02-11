@Ohmage.module "LoginApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Form extends App.Views.ItemView
  class Show.Form extends App.Views.Layout
    initialize: ->
      @listenTo @, "errors:reset", @resetErrors

      @listenTo @, "submit:clicked", =>
        @trigger "errors:reset"
        @trigger "form:submit", @formValues()

      @listenTo App.vent, "credentials:invalidated", (responseErrors) =>
        @showInvalidErrors responseErrors

      @listenTo App.vent, "serverpath:set:error", (responseErrors) =>
        @showInvalidErrors [
          text: responseErrors[0]
          code: '0000'
        ]

      @listenTo App.vent, "serverpath:set:success", =>
        @trigger "errors:reset"
        @trigger "path:updated"

    resetErrors: ->
      @$el.find('p.error').html('')

    showInvalidErrors: (responseErrors) ->
      # response errors is an array containing objects:
      # text: "error text"
      # code: "error code"
      console.log responseErrors
      # append all errors into one string
      result = _.reduce(responseErrors, ((errorStr, error) ->
        return "#{error.text}<br />#{errorStr}"
      ), "")

      @$el.find('p.error').html(result)

    formValues: ->
      username: @$el.find('input.username').val()
      password: @$el.find('input.pass').val()
    template: "login/show/form"
    regions:
      serversRegion: ".server-selector"
    triggers:
      "click button[type=submit]": "submit:clicked"
      "blur input[name=username]": "errors:reset"
      "blur input[name=username]": "errors:reset"


  class Show.Layout extends App.Views.Layout
    template: "login/show/show_layout"
    regions:
      formRegion: "#form-region"
