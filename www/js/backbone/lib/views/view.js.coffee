@Ohmage.module "Views", (Views, App, Backbone, Marionette, $, _) ->

  _remove = Marionette.View::remove

  _.extend Marionette.View::,

    onAttach: ->
      # add fastclick to the view
      # possible TODO: only do this if it contains "click" event triggers?
      # But, may not be possible if events hash isn't accessible here.
      # Investigate further if FastClick cause any touch issues.
      if App.device.isNative then FastClick.attach @el

    addOpacityWrapper: (init = true) ->
      @$el.toggleWrapper
        className: "opacity"
      , init

    setInstancePropertiesFor: (args...) ->
      for key, val of _.pick(@options, args...)
        @[key] = val

    remove: (args...) ->
      # console.log "removing", @

      _remove.apply @, args

    templateHelpers: ->

      linkTo: (name, url, options = {}) ->
        _.defaults options,
          external: false

        url = "#" + url unless options.external

        "<a href='#{url}'>#{@escape(name)}</a>"