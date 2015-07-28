@Ohmage.module "HistoryApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Notice extends App.Views.ItemView
    template: "history/list/notice"
    className: "notice-nopop"

  class List.Layout extends App.Views.Layout
    template: "history/list/list_layout"
    regions:
      noticeRegion: "#notice-region-nopop"
      controlRegion: "#control-region"
      listRegion: "#list-region"
