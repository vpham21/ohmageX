@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The History Selector Entity is the generic object definition
  # for a single selector dropdown, used for filtering History entries.

  class Entities.UserHistorySelectorNav extends Entities.NavsCollection
    initialize: (models, options) ->

      _.defaults options,
        defaultLabel: "All"

      # filterType is the property of Entries
      # to use to filter the unique contents of the dropdown.
      @filterType = options.filterType

