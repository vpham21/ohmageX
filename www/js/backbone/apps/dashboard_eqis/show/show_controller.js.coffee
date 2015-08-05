@Ohmage.module "DashboardeQISApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # DashboardeQISApp renders the e-QIS dashboard.

    getLayoutView: ->
      new Show.Layout
