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
        @contentRegion blocker, options
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

          @listenTo @layout, 'ok:clicked', =>
            @noticeRegion ''
            invalidView.trigger "get:values"

          @listenTo invalidView, "submit:password", (password) =>
            console.log 'submit:passsword', password
            App.vent.trigger "credentials:password:update", password

          @listenTo App.vent, "credentials:password:update:validated", options.successListener
          @listenTo App.vent, "credentials:password:update:validated", (=>
            console.log 'test'
            blocker.blockerHide()
            @destroy()
          )

          @listenTo App.vent, "credentials:password:update:invalidated", (responseErrors) =>
            @noticeRegion responseErrors

          @listenTo @layout, 'cancel:clicked', =>
            saveLocation = if App.device.isNative then "on this device" else "on this web browser"
            App.execute "dialog:confirm", "Are you sure you want to logout? Any data saved #{saveLocation} will be lost.", (=>
              App.navigate "logout", { trigger: true }
              blocker.blockerHide()
              @destroy()
            ), (=>
              console.log 'dialog canceled'
            )

          invalidView
        when "password:change"
          changeView = @getPasswordChangeView()

          @listenTo @layout, 'ok:clicked', =>
            @noticeRegion ''
            changeView.trigger "get:values"

          @listenTo changeView, "submit:password", (passwords) =>
            App.vent.trigger "credentials:password:change", passwords

          @listenTo App.vent, "credentials:password:change:validated", options.successListener
          @listenTo App.vent, "credentials:password:change:validated", (=>
            blocker.blockerHide()
            @destroy()
          )

          @listenTo App.vent, "credentials:password:change:invalidated", (responseErrors) =>
            @noticeRegion responseErrors


          @listenTo @layout, 'cancel:clicked', =>
            blocker.blockerHide()
            @destroy()
          changeView

      @listenTo contentView, "error:show", (message) ->
        @noticeRegion message


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
