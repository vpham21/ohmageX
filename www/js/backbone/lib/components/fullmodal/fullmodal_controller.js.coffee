@Ohmage.module "Components.FullModal", (FullModal, App, Backbone, Marionette, $, _) ->

  # The FullModal component is an alternative to the
  # mainRegion. It overlaps the mainRegion when activated,
  # and includes its own close button. Options such as
  # a callback (that triggers when the Close button is activated)
  # can be sent to this component.

  # In any view that uses this, it's advised that the
  # closeCallback fires events that the parent view
  # can use for cleanup, since the mainRegion is unaffected 
  # by this view.

  class FullModal.FullModalController extends App.Controllers.Application

    initialize: (options) ->
      { view, config } = options

      config = if _.isBoolean(config) then {} else config

      _.defaults config,
        closeCallback: false

      @layout = @getLayoutView()

      @show @layout

    getLayoutView: ->
      new FullModal.Layout

