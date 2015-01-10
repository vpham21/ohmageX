@Ohmage.module "LoadingspinnerApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    tagName: "figure"
    initialize: ->
      @listenTo @model, "loading:show", ->
        @loading.show()
      @listenTo @model, "loading:hide", ->
        @loading.hide()
      @listenTo @model, "change:message", @render

    template: "loadingspinner/show/layout"
    attributes: ->
      if App.device.isiOS7 then { class: "ios7" }
    # regions:
    #   buttonRegion: "#button-region"
    onRender: ->
      @loading = new LoadingSpinnerComponent('#loading-spinner')
