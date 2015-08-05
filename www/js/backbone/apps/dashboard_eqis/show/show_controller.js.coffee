@Ohmage.module "DashboardeQISApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # DashboardeQISApp renders the e-QIS dashboard.

  class Show.Controller extends App.Controllers.Application
    initialize: ->
      @layout = @getLayoutView()
      @show @layout

    noticeRegion: (message) ->
      notice = new Backbone.Model message: message
      noticeView = @getNoticeView notice

      @show noticeView, region: @layout.noticeRegion


    getNoticeView: (notice) ->
      new Show.Notice
        model: notice

    getLayoutView: ->
      new Show.Layout
