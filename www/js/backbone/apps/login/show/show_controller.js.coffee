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
      formView = @getFormView()

      @listenTo formView, "form:submit", (formValues) ->
        console.log 'form:submit', formValues
        App.vent.trigger "login:form:submit:clicked", formValues

      @show formView, region: @layout.formRegion

    getFormView: ->
      new Show.Form

    getLayoutView: ->
      new Show.Layout
