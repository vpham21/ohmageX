@Ohmage.module "DashboardApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Prompt extends App.Views.ItemView
    template: "dashboard/show/prompt"
    initialize: ->
      @listenTo @, 'validateStub', @validateStub
    validateStub: ->
      submitVal = @$el.find("input[type='text']").val()
      console.log submitVal
      properties = @model.get('properties')
      window.myProperties = properties
      if submitVal.length < properties.get('min')
        console.log 'length too short'
      if submitVal.length > properties.get('max')
        console.log 'length too long'
    triggers:
      "click button[type='submit']" : "validateStub"

  class Show.Layout extends App.Views.Layout
    template: "dashboard/show/show_layout"

    regions:
      promptShortRegion: "#prompt-text-short-region"
      promptLongRegion: "#prompt-text-long-region"