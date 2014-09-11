@Ohmage.module "DashboardApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Prompt extends App.Views.ItemView
    template: "dashboard/show/prompt"
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

  # Prompt Multi Choice
  class Show.PromptMCItem extends App.Views.ItemView
    tagName: 'li'
    template: "dashboard/show/prompt_mc_item"

  class Show.PromptMC extends App.Views.CompositeView
    template: "dashboard/show/prompt_mc"
    itemView: Show.PromptMCItem
    itemViewContainer: ".prompt-list"

  # Prompt Single Choice Custom
  class Show.PromptSCCustom extends App.Views.CompositeView
    initialize: ->
      @listenTo @, 'choice:toggle', @toggleChoice
      @listenTo @, 'choice:add', @addChoice
      @listenTo @, 'choice:cancel', @cancelChoice
    toggleChoice: (args) ->
      $addForm = @$el.find '.add-form'
      $addForm.toggleClass 'hidden'

    cancelChoice: ->
      $addForm = @$el.find '.add-form'
      $addForm.addClass 'hidden'

    addChoice: (args) ->
      $addForm = @$el.find '.add-form'
      if not $addForm.hasClass 'hidden'

        # add new choice, based on the contents of the text prompt,
        # to the view's Collection. Validation and parsing takes
        # place within the ChoiceCollection's model.

        # Also, will add an event to clear the value of the input
        # on successful submit.

        args.collection.add([{
          "key": _.uniqueId()
          "label": $addForm.find(".add-value").val()
          "parentId": args.model.get('id')
        }])

    template: "dashboard/show/prompt_sc_custom"
    itemView: Show.PromptSCItem
    itemViewContainer: ".prompt-list"
    triggers:
      "click button.my-add": "choice:toggle"
      "click .add-form .add-submit": "choice:add"
      "click .add-form .add-cancel": "choice:cancel"

  class Show.PromptMCCustom extends Show.PromptSCCustom
    # this can use the same templates and triggers
    # as the SC Custom - later, may consolidate
    # Single and Multi Composite Views. Only
    # difference here is the ItemView to render,
    # and a different value to submit (JSON), which
    # will be added in a new event Trigger
    itemView: Show.PromptMCItem



  class Show.Layout extends App.Views.Layout
    template: "dashboard/show/show_layout"
    regions:
      promptShortRegion: "#prompt-text-short-region"
      promptLongRegion: "#prompt-text-long-region"
      promptSCRegion: "#prompt-single-choice-region"
      promptMCRegion: "#prompt-multi-choice-region"
      promptSCCustomRegion: "#prompt-single-choice-custom-region"
      promptMCCustomRegion: "#prompt-multi-choice-custom-region"
