@Ohmage.module "BlockerApp", (BlockerApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  API =
    show: (options) ->
      _.defaults options,
        region: App.blockerRegion

      new BlockerApp.Show.Controller options

  App.vent.on "blocker:password:invalid", (options) ->
    _.defaults options,
      contentViewLabel: 'password:invalid'

    # option parameter required:
    # successListener - listener after the action has succeeded

    API.show options

  App.vent.on "blocker:password:change", (options) ->
    _.defaults options,
      contentViewLabel: 'password:change'

    # option parameter required:
    # successListener - listener after the action has succeeded

    API.show options

  App.vent.on "blocker:reminder:update", (options) ->
    _.defaults options,
      contentViewLabel: 'reminder:update'

    # option parameter required:
    # reminderView - reminder view to insert into the reminder layout

    API.show options
