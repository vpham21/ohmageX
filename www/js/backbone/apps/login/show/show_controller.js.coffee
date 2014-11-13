@Ohmage.module "LoginApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # LoginApp renders a Login form with minimal functionality,
  # enough to allow testing.

  class Show.Controller extends App.Controllers.Application
    initialize: ->
      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        console.log "showing layout"
        @formRegion()

      @show @layout

    formRegion: ->
      myPath = App.request "serverpath:entity"

      @listenTo myPath, "invalid", (formModel) =>
        # path validation failed
        console.log "path invalid, errors are", formModel.validationError
        App.vent.trigger "serverpath:set:error", formModel.validationError

      @listenTo myPath, "change:path", (formModel) =>
        # path validation succeeded
        console.log "path valid, arg is", formModel.get 'path'
        App.vent.trigger "serverpath:set:success", formModel.get('path')

      formView = @getFormView myPath

      @listenTo formView, "serverpath:submit", (value) =>
        console.log 'serverpath:submit', value
        App.execute "serverpath:update", value

      @listenTo formView, "form:submit", (formValues) ->
        console.log 'form:submit', formValues
        App.vent.trigger "login:form:submit:clicked", formValues

      @show formView, region: @layout.formRegion

    getFormView: (myPath) ->

      new Show.Form
        model: myPath

    getLayoutView: ->
      new Show.Layout
