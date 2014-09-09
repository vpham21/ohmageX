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

  class Show.PromptSCItem extends App.Views.ItemView
    tagName: 'li'
    template: "dashboard/show/prompt_sc_item"

  # Prompt Single Choice
  class Show.PromptSC extends App.Views.CompositeView
    template: "dashboard/show/prompt_sc"
    itemView: Show.PromptSCItem
    itemViewContainer: ".prompt-list"

  class Show.Layout extends App.Views.Layout
    template: "dashboard/show/show_layout"
    regions:
      promptShortRegion: "#prompt-text-short-region"
      promptLongRegion: "#prompt-text-long-region"
      promptSCRegion: "#prompt-single-choice-region"