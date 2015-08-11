@Ohmage.module "ProfileApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Profile extends App.Views.ItemView
    className: "text-container"
    template: "profile/show/info"
    triggers:
      "click .change-password": "password:clicked"
    events: ->
      "change #enable-switch-wifi": "setWifiUploadOnly"
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
