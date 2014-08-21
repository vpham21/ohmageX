@Ohmage.module "DashboardApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Application

    initialize: ->
      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        @promptShortRegion()
        @promptLongRegion()

      @show @layout

    promptShortRegion: ->
      shortPrompt = App.request "prompt:get", 0
      promptsView = @getPromptsView shortPrompt
      @show promptsView, region: @layout.promptShortRegion

    promptLongRegion: ->
      longPrompt = App.request "prompt:get", 1
      promptsView = @getPromptsView longPrompt
      @show promptsView, region: @layout.promptLongRegion

    getPromptsView: (promptContent) ->
      new Show.Prompt
        model: promptContent

    getLayoutView: ->
      new Show.Layout