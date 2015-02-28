@Ohmage.module "BlockerApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Notice extends App.Views.ItemView
    template: "blocker/show/_notice"

  class Show.PasswordInvalid extends App.Views.ItemView
    template: "blocker/show/password_invalid"
    serializeData: ->
      username: App.request "credentials:username"

  class Show.PasswordChange extends App.Views.ItemView
    template: "blocker/show/password_change"
    serializeData: ->
      username: App.request "credentials:username"

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
    triggers:
      "click .cancel-button": "cancel:clicked"
      "click .ok-button": "ok:clicked"
