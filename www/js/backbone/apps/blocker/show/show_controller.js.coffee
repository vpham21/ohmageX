@Ohmage.module "BlockerApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Application

    initialize: (options) ->
      { contentViewLabel } = options
      blocker = App.request "blocker:entity", contentViewLabel
      @layout = @getLayoutView blocker

      @listenTo App.loading, 'loading:show', =>
        blocker.blockerHide()

      @listenTo App.loading, 'loading:hide', =>
        blocker.blockerShow()

      @listenTo @layout, "show", =>
        blocker.blockerShow()
      @show @layout

    noticeRegion: (message) ->
      notice = new Backbone.Model message: message
      noticeView = @getNoticeView notice

      @show noticeView, region: @layout.noticeRegion

    contentRegion: (blocker, options) ->

      contentView = switch options.contentViewLabel
        when "password:invalid"
          invalidView = @getPasswordInvalidView()
        when "password:change"
          changeView = @getPasswordChangeView()
      @show contentView, region: @layout.contentRegion

    getNoticeView: (notice) ->
      new Show.Notice
        model: notice

    getPasswordInvalidView: ->
      new Show.PasswordInvalid()

    getPasswordChangeView: ->
      new Show.PasswordChange()

    getNoticeView: (notice) ->
      new Show.Notice
        model: notice

    getLayoutView: (blocker) ->
      new Show.Layout
        model: blocker
