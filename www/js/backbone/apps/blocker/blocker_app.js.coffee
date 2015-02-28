@Ohmage.module "BlockerApp", (BlockerApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  API =
    show: (options) ->
      _.defaults options,
        region: App.blockerRegion

      new BlockerApp.Show.Controller options
