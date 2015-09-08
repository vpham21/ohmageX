@Ohmage.module "Entities", ((Entities, App, Backbone, Marionette, $, _, markdown) ->

  # This entity handles markdown parsing.
  # Note that this module includes an extra parameter "markdown"
  # that is passed in from the global scope.

  API =
    getMarkdown: (options) ->
      # TODO: offline image capability feature
      # When online, intercept image references and cache them
      # for inline replacement

      # For caching, use other options passed in to this method to
      # extract and reference the correct image ID and/or
      # create the appropriate image file

      # TODO: Add HTML escape before parsing into markdown
      markdown.toHTML options.originalText

    # TODO: Add method to map a ChoiceCollection's labels
    # into markdown-enabled choice labels

  App.reqres.setHandler "prompt:markdown", (options) ->
    API.getMarkdown options

), markdown
