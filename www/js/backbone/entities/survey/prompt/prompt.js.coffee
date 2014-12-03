@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The prompt entity defines data for a single prompt.

  class Entities.ChoiceModel extends Entities.Model
    defaults:
      custom: false # individual choices may be custom.

  class Entities.ChoiceCollection extends Entities.Collection
    model: Entities.ChoiceModel

  class Entities.PromptProperty extends Entities.Model

  class Entities.Prompt extends Entities.Model
    initialize: (options) ->
      @set 'skippable', if options.skippable is 'true' then true else false
      if not (options.properties instanceof Entities.ChoiceCollection)
        # If it's a ChoiceCollection, it's a list of items to be rendered,
        # not a PromptProperty, so don't overwrite it
        @set 'properties', new Entities.PromptProperty options.properties
