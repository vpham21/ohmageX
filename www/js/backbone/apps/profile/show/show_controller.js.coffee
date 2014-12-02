@Ohmage.module "ProfileApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # ProfileApp renders the Profile page.

  class Show.Controller extends App.Controllers.Application
    initialize: ->
      @layout = @getLayoutView()

      profile = App.request 'profile:current'

      @listenTo @layout, "show", =>
        console.log "showing layout"
        @infoRegion profile

      @show @layout

    infoRegion: (profile) ->
      infoView = @getInfoView profile

      @show infoView, region: @layout.infoRegion

    getInfoView: (profile) ->
      new Show.Info
        model: profile

    getLayoutView: ->
      new Show.Layout
