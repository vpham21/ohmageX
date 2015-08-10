@Ohmage.module "ProfileApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Profile extends App.Views.ItemView
    className: "text-container"
    template: "profile/show/info"
    triggers:
      "click .change-password": "password:clicked"
    events: ->
      "change #enable-switch-wifi": "setWifiUploadOnly"
    setWifiUploadOnly: (e) ->
      e.preventDefault()
      e.stopPropagation()
      App.request 'user:preferences:set', 'wifi_upload_only', @$el.find("#enable-switch-wifi").prop('checked') is true
    checkEnabledWifiOnly: ->
      @$el.find("#enable-switch-wifi").prop('checked', true)
    serializeData: ->
      data = @model.toJSON()
      data.showPassword = App.request "credentials:ispassword"
      data.serverPath = App.request "serverpath:current"
      data
    onRender: ->
      wifiUploadOnly = App.request "user:preferences:get", 'wifi_upload_only'
      console.log "setting wifi upload only to: "+wifiUploadOnly
      if wifiUploadOnly then @checkEnabledWifiOnly()

  class Show.Layout extends App.Views.Layout
    template: "profile/show/show_layout"
    regions:
      profileRegion: "#profile-region"
