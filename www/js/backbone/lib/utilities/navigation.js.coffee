@Ohmage.module "Utilities", (Utilities, App, Backbone, Marionette, $, _) ->

  _.extend App,

    navigate: (route, options = {}) ->
      @previousUrl = Backbone.history.fragment
      Backbone.history.navigate route, options

    getCurrentRoute: ->
      frag = Backbone.history.fragment
      if _.isEmpty(frag) then null else frag

    historyPrevious: ->
      if Backbone.history
        Backbone.history.navigate @previousUrl, { trigger: true }

    historyBack: ->
      if Backbone.history
        window.history.back()

    startHistory: ->
      if Backbone.history
        Backbone.history.start()
