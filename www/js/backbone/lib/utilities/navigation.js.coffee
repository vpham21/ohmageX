@Ohmage.module "Utilities", (Utilities, App, Backbone, Marionette, $, _) ->

  _.extend App,

    navigate: (route, options = {}) ->
      Backbone.history.navigate route, options

    getCurrentRoute: ->
      frag = Backbone.history.fragment
      if _.isEmpty(frag) then null else frag

    historyBack: ->
      if Backbone.history
        window.history.back()

    startHistory: ->
      if Backbone.history
        Backbone.history.start()
