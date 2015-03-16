@Ohmage.module "BlockerApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Notice extends App.Views.ItemView
    template: "blocker/show/_notice"

  class Show.PasswordInvalid extends App.Views.ItemView
    initialize: ->
      @listenTo @, "get:values", @formValues
    formValues: ->
      val = @$el.find('#updated-password').val()
      if val.length is 0
        @trigger "error:show", "Please provide a password."
        return false
      if val.length < 8
        @trigger "error:show", "Password must be at least 8 characters long."
        return false
      @trigger "submit:password", val

    template: "blocker/show/password_invalid"
    serializeData: ->
      username: App.request "credentials:username"
    onRender: ->
      @$el.find('#updated-password').hideShowPassword
        innerToggle: true
        toggle:
          styles:
            marginTop: "4px"
          verticalAlign: "top"

  class Show.PasswordChange extends App.Views.ItemView
    initialize: ->
      @listenTo @, "get:values", @formValues
    validatePassword: (label, val) ->
      if val.length is 0
        @trigger "error:show", "Please provide the #{label} password."
        return false
      if val.length < 8
        @trigger "error:show", "The #{label} password must be at least 8 characters long."
        return false
      return true
    formValues: ->
      oldVal = @$el.find('#old-password').val()
      newVal = @$el.find('#new-password').val()
      confirmVal = @$el.find('#confirm-password').val()
      if @validatePassword("old", oldVal) and @validatePassword("new", newVal) and @validatePassword("confirmation", confirmVal)
        if newVal isnt confirmVal
          @trigger "error:show", "New password must match password confirmation."
        else
          @trigger "submit:password",
            oldPassword: oldVal
            newPassword: newVal

    template: "blocker/show/password_change"
    serializeData: ->
      username: App.request "credentials:username"
    onRender: ->
      @$el.find('#old-password').hideShowPassword
        innerToggle: true
        toggle:
          styles:
            marginTop: "4px"
          verticalAlign: "top"
      @$el.find('#new-password').hideShowPassword
        innerToggle: true
        toggle:
          styles:
            marginTop: "4px"
          verticalAlign: "top"
      @$el.find('#confirm-password').hideShowPassword
        innerToggle: true
        toggle:
          styles:
            marginTop: "4px"
          verticalAlign: "top"


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
