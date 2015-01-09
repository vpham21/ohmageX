@Ohmage.module "LoadingspinnerApp", (LoadingspinnerApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  API =
    show: (loading) ->
      new LoadingspinnerApp.Show.Controller
        region: App.loadingRegion
        loading: loading

  LoadingspinnerApp.on "start", (loading) ->
    API.show loading
