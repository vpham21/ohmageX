@Ohmage.module "LoginApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # LoginApp renders a Login form.

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

      @listenTo formView, "form:submit", (formValues) ->
        console.log 'form:submit', formValues
        App.vent.trigger "login:form:submit:clicked", formValues

      @show formView, region: @layout.formRegion

    getServersView: (serverList) ->
      new Show.ServerList
        collection: serverList

    getFormView: (myPath) ->

      new Show.Form
        model: myPath

    getLayoutView: ->
      new Show.Layout
