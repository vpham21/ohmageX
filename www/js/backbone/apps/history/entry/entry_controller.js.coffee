@Ohmage.module "HistoryApp.Entry", (Entry, App, Backbone, Marionette, $, _) ->

  # History Entry Controller renders a single entry in the history.

  class Entry.Controller extends App.Controllers.Application
    initialize: (options) ->
      { entry_id } = options
      @entry_id = entry_id
      entry = App.request "history:entry", @entry_id

      @layout = @getLayoutView entry
      @show @layout, loading: false


    getLayoutView: (entry) ->
      new Entry.Layout
        model: entry
