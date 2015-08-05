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

    parse: (entries) ->
      # establish scaffolding for all entries.
      if @entries? and @entries.length > 0 and @entries instanceof Entities.UserHistoryEntries
        # update all of the response counts
        responseCounts = @getResponseCounts @entries


    getResponseCounts: (entries) ->
      # get a pre-populated array of numbers from 1 - numDays
      dayNumbers = _.range(1,@numDays+1,1)
      # get buckets, converting spaces into underscores
      # so they can be mapped to object properties
      bucketCountsObj = entries.countBy (entry) -> entry.get('bucket').replace(" ", "_")
      # returns an object like:
      # {bucket_1: 3, bucket_3: 4, ... }
      results = []
      results[0] = if "Initial_Reflection" of bucketCountsObj then bucketCountsObj.Initial_Reflection else 0
      # returns an array of 10 items, with bucket count in sequence.
      results = results.concat( _.map dayNumbers, (dayNumber) ->
        # we mapped the spaces to underscores, include an underscore here!
        targetBucket = "Day_#{dayNumber}"
        if targetBucket of bucketCountsObj
          # The key exists.
          # return the value of this bucket's count.
          return bucketCountsObj[targetBucket]
        else
          # key does not exist, its count is zero.
          return 0
      )
