@Ohmage.module "ProfileApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # ProfileApp renders the Profile page.

  class Show.Controller extends App.Controllers.Application
    initialize: ->
      @layout = @getLayoutView()

      profile = App.request 'profile:current'

      @listenTo @layout, "show", =>
        console.log "showing layout"
        @profileRegion profile

      @show @layout

    profileRegion: (profile) ->
      profileView = @getInfoView profile

      @show profileView, region: @layout.profileRegion

    getInfoView: (profile) ->
      new Show.Profile
        model: profile

    getLayoutView: ->
      new Show.Layout
