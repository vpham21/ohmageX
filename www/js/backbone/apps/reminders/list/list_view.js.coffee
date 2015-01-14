@Ohmage.module "RemindersApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Reminder extends App.Views.ItemView
    initialize: ->
      @listenTo @model, 'change', @render
    tagName: 'li'
    template: "reminders/list/_item"

  class List.RemindersEmpty extends App.Views.ItemView
    className: "text-container"
    template: "reminders/list/_reminders_empty"

  class List.Reminders extends App.Views.CompositeView
    tagName: 'nav'
    className: 'list'
    template: "reminders/list/reminders"
    childView: List.Reminder
    childViewContainer: "ul"
    emptyView: List.RemindersEmpty

  class List.Layout extends App.Views.Layout
    template: "reminders/list/layout"
    regions:
      noticeRegion: "#notice-region"
      listRegion: "#list-region"
