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
        @promptMCRegion()
        @promptSCCustomRegion()
        @promptMCCustomRegion()

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

    promptMCRegion: ->
      mcPrompt = App.request "prompt:get", 3

      promptsView = @getPromptMCView mcPrompt
      @show promptsView, region: @layout.promptMCRegion

    promptSCCustomRegion: ->
      scPrompt = App.request "prompt:get", 4

      promptsView = @getPromptSCCustomView scPrompt
      @show promptsView, region: @layout.promptSCCustomRegion

    promptMCCustomRegion: ->
      mcPrompt = App.request "prompt:get", 5

      promptsView = @getPromptMCCustomView mcPrompt
      @show promptsView, region: @layout.promptMCCustomRegion

    getPromptsView: (promptContent) ->
      new Show.Prompt
        model: promptContent

    getPromptSCView: (promptContent) ->
      new Show.PromptSC
        model: promptContent
        collection: promptContent.get('properties')

    getPromptMCView: (promptContent) ->
      new Show.PromptMC
        model: promptContent
        collection: promptContent.get('properties')

    getPromptSCCustomView: (promptContent) ->
      new Show.PromptSCCustom
        model: promptContent
        collection: promptContent.get('properties')

    getPromptMCCustomView: (promptContent) ->
      new Show.PromptMCCustom
        model: promptContent
        collection: promptContent.get('properties')


    getLayoutView: ->
      new Show.Layout