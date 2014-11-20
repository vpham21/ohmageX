@Ohmage.module "Components.Notice", (Notice, App, Backbone, Marionette, $, _) ->

  # Notice component manages a Notice View. When this view is rendered,
  # 

  class Notice.ShowController extends App.Controllers.Application

    initialize: (options) ->
      { region, data, cancelListener, okListener } = options
      
      if !region then throw new Error "Notice component instantiated with invalid region"

      @myView = @getNoticeView App.request('notice:entity', data)

      if data.showCancel is true and cancelListener isnt false then @listenTo @myView, "cancel:clicked", cancelListener

      @listenTo @myView, "ok:clicked", okListener

      @listenTo @myView, "destroy", @destroy

      @show @myView

    getNoticeView: (entity) ->
      new Notice.Show
        model: entity

  App.commands.setHandler "notice:show:view", (data) ->

    _.defaults data,
      cancelListener: false

    result = new Notice.ShowController
      region: App.request "notice:region"
      data: data.data
      cancelListener: data.cancelListener
      okListener: data.okListener

    result.myView
