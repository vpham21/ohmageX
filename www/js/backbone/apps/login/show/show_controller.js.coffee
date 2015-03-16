@Ohmage.module "LoginApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # LoginApp renders a Login form.

  class Show.Controller extends App.Controllers.Application
    initialize: ->
      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        console.log "showing layout"
        @formRegion()

      @show @layout

      @listenTo App.vent, "credentials:invalidated", (responseErrors) =>
        @showInvalidErrors responseErrors

      @listenTo App.vent, "serverpath:set:error", (responseErrors) =>
        @showInvalidErrors [
          text: responseErrors[0]
          code: '0000'
        ]

    showInvalidErrors: (responseErrors) ->
      # response errors is an array containing objects:
      # text: "error text"
      # code: "error code"
      console.log responseErrors
      # append all errors into one string
      result = _.reduce(responseErrors, ((errorStr, error) ->
        suffix = if errorStr.length > 0 then ": #{errorStr}" else ""
        return "#{error.text} #{suffix}"
      ), "")

      App.execute "notice:show",
        data:
          title: "Login Error"
          description: result
          showCancel: false
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

      if App.request('serverlist:selectable')
        @listenTo formView, "show", =>
          @serversRegion formView, App.request('serverlist:entity')

      @show formView, region: @layout.formRegion

    serversRegion: (formView, serverList) ->

      serversView = @getServersView serverList

      @listenTo serversView, "custom:focus", =>
        formView.trigger "errors:reset"

      @listenTo serversView, "serverpath:submit", (value) =>
        console.log 'serverpath:submit', value
        App.execute "serverpath:update", value

      @show serversView, region: formView.serversRegion

    getServersView: (serverList) ->
      new Show.ServerList
        collection: serverList

    getFormView: (myPath) ->

      new Show.Form
        model: myPath

    getLayoutView: ->
      new Show.Layout
