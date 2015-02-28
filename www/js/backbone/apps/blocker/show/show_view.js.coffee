@Ohmage.module "BlockerApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Notice extends App.Views.ItemView
    template: "blocker/show/_notice"

  class Show.Layout extends App.Views.Layout
    tagName: "figure"
    initialize: ->
      @listenTo @model, "blocker:show", ->
        @blocker.show()
      @listenTo @model, "blocker:hide", ->
        @blocker.hide()
    template: "blocker/show/layout"
    attributes: ->
      if App.device.isiOS7 then { class: "ios7" }
    regions:
      noticeRegion: "#notice"
      contentRegion: "#content-region"
    onRender: ->
      @blocker = new LoadingSpinnerComponent('#ui-blocker')
