@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The survey XML Entity manipulates a Survey's XML.

  API =
    getSurveyRoot: ($surveyXML) ->
      # return clone of passed-in $surveyXML minus content
      $result = $('<xml></xml>')
      $result.append( $surveyXML.children().children().not('contentList') )
      console.log 'survey:xml:root', $result.html()
      $result

    getSurveyContent: ($surveyXML) ->
      # return contentList tag from passed-in $surveyXML
      $surveyXML.find('contentList')

  App.reqres.setHandler "survey:xml:root", ($surveyXML) ->
    API.getSurveyRoot $surveyXML

  App.reqres.setHandler "survey:xml:content", ($surveyXML) ->
    API.getSurveyContent $surveyXML
