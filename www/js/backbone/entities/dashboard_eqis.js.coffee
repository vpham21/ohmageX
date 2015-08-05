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

      else
        # just prepoulate it with an array of @numDays+1 items all containing zero.
        # we use @numDays+1 because there are two additional surveys.
        responseCounts = _.range(0,@numDays+1,0)

      results = [
          rowLabel: "Initial"
          bucket: "Initial Reflection"
          surveyId: '1InitialReflection'
          secondSurveyId: false
          newPrepopIndex: false
          newPrepopfirstSurveyStep: false
          newPrepopSecondSurveyStep: false
          responseCount: responseCounts[0]
      ]

      days = []
      _.each responseCounts, (count, index) =>
        if index > 0 and index < @numDays+1
          days.push
            rowLabel: "Day #{index}"
            bucket: "Day #{index}"
            surveyId: '2AssessmentArtifacts'
            secondSurveyId: '3InstructionArtifacts'
            newPrepopIndex: index-1
            newPrepopfirstSurveyStep: "AssessmentArtifactDayFolder"
            newPrepopSecondSurveyStep: "InstructionalArtifactDayFolder"
            responseCount: count

      results = results.concat days

      # add suffix results
      results = results.concat [
        rowLabel: "Concluding"
        bucket: "Concluding Reflection"
        surveyId: '4ConcludingReflection'
        secondSurveyId: false
        newPrepopIndex: false
        newPrepopfirstSurveyStep: false
        newPrepopSecondSurveyStep: false
        responseCount: responseCounts[@numDays+1]
      ]
      console.log 'results', results
      results

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
      results[@numDays+1] = if "Concluding_Reflection" of bucketCountsObj then bucketCountsObj.Concluding_Reflection else 0
      results

  API =
    getArtifacts: (entries) ->
      new Entities.eQISArtifacts entries, parse: true

  App.reqres.setHandler "dashboardeqis:artifacts", ->
    entries = App.request "history:entries"
    API.getArtifacts entries
