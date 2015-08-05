@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The History Entity generates the user's saved response history.

  class Entities.eQISArtifact extends Entities.Model

  class Entities.eQISArtifacts extends Entities.Collection
    model: Entities.eQISArtifact
    initialize: (models) ->
      @entries = models

      # only create this listener if entries is an actual Collection.
      if @entries instanceof Entities.UserHistoryEntries
        @listenTo @entries, "sync:stop reset", =>
          @reset @entries, parse: true

    numDays: 10 # number of days that the survey lasts.

