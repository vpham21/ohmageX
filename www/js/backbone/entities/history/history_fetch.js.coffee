@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The HistoryFetch entity manages fetching data
  # for history items that are not part of the original history
  # entry request.
