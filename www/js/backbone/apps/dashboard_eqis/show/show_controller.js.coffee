@Ohmage.module "DashboardeQISApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # DashboardeQISApp renders the e-QIS dashboard.

  class Show.Controller extends App.Controllers.Application
    initialize: ->
      @layout = @getLayoutView()
      @show @layout

    getLayoutView: ->
      new Show.Layout
