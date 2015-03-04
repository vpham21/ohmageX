@Ohmage.module "ProfileApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Profile extends App.Views.ItemView
    className: "text-container"
    template: "profile/show/info"
    triggers:
      "click .change-password": "password:clicked"
    serializeData: ->
      data = @model.toJSON()
      data.showPassword = App.request "credentials:ispassword"
      data

  class Show.Layout extends App.Views.Layout
    template: "profile/show/show_layout"
    regions:
      profileRegion: "#profile-region"
