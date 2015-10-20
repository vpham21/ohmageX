@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # This handles History Media Queue operations on all items.

  currentDeferred = []
  currentIndices = []

