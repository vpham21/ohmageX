@Ohmage.module "HistoryApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: "history/list/list_layout"
    regions:
      controlRegion: "#control-region"
      listRegion: "#list-region"
