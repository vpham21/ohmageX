@Ohmage.module "Components.Prompts", (Prompts, App, Backbone, Marionette, $, _) ->

  class Prompts.Text extends App.Views.ItemView
    template: "prompts/prompt"
    initialize: ->
      @listenTo @, 'validateStub', @validateStub
    validateStub: ->
      submitVal = @$el.find("input[type='text']").val()
      console.log submitVal
      properties = @model.get('properties')
      if submitVal.length < properties.get('min')
        console.log 'length too short'
      if submitVal.length > properties.get('max')
        console.log 'length too long'
