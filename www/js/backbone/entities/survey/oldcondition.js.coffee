@Ohmage.module "Entities", ((Entities, App, Backbone, Marionette, $, _, ConditionalParser) ->

  # This oldCondition Entity currently references the Conditional
  # Parser code from the previous version of ohmage MWF,
  # stored in a vendor lib file. It acts as a middleware
  # for the data sent to the old library.

  API =
    stringsToArrays: (rawString) ->
      try
        resultArr = JSON.parse(rawString)
      catch Error
        console.log "Error, response #{rawString} failed to convert to string. ", Error
        return rawString
      resultArr
    isArrayResponse: (response) ->
      myType = response.get 'type'
      myType is 'multi_choice' or myType is 'multi_choice_custom'

    prepParser: (rawCondition, responses) ->
      oldParserResponses = {}
      responses.each((response) =>
        myId = response.get 'id'

        if response.get('response') isnt false and @isArrayResponse(response)
          myResponse = @stringsToArrays(response.get 'response')
        else
          myResponse = App.request "response:value:parsed", { stepId: myId, addUploadUUIDs: false }
        oldParserResponses[myId] = myResponse
        oldParserResponses
      )

      console.log 'oldParserResponses', oldParserResponses

      trimCondition = rawCondition.replace(/\)\s*(and|or)\s*\(/i, ") $1 (")
      trimCondition = trimCondition.replace(/\s*(==|!=|<=|=>|>|<)\s*/i, " $1 ")
      ConditionalParser.parse trimCondition, oldParserResponses

  App.reqres.setHandler "oldcondition:evaluate", (rawCondition, responses) ->
    API.prepParser rawCondition, responses

), ConditionalParser