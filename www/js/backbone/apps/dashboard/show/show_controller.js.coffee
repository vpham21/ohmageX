@Ohmage.module "DashboardApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # Dashboard currently renders a series of prompts in sequence on a single page,
  # showing that the XML is being parsed and rendering templates as a result.
  # These are added to a Layout containing multiple individual regions
  # with each region assigned an individual Prompt.

  class Show.Controller extends App.Controllers.Application

    initialize: ->
      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        @promptShortRegion()
        @promptLongRegion()
        @promptSCRegion()

      @show @layout

    promptShortRegion: ->
      shortPrompt = App.request "prompt:get", 0
      promptsView = @getPromptsView shortPrompt
      @show promptsView, region: @layout.promptShortRegion

    promptLongRegion: ->
      longPrompt = App.request "prompt:get", 1
      promptsView = @getPromptsView longPrompt
      @show promptsView, region: @layout.promptLongRegion

    promptSCRegion: ->
      scPrompt = App.request "prompt:get", 2

      promptsView = @getPromptSCView scPrompt
      @show promptsView, region: @layout.promptSCRegion

    getPromptsView: (promptContent) ->
      new Show.Prompt
        model: promptContent

    getPromptSCView: (promptContent) ->
      console.log "properties",promptContent.get('properties')
      new Show.PromptSC
        model: promptContent
        collection: promptContent.get('properties')

    getLayoutView: ->
      new Show.Layout