@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The survey Entity deals with data relating to all surveys,
  # and single surveys.

  API =
    getSurvey: (id) ->
      $surveys = App.request "xml:get", "survey"
      $surveys.find("id:containsExact('#{id}')").parent()
    getSurveyRoot: ($surveyXML) ->
      # return clone of passed-in $surveyXML minus content
      $result = $('<survey></survey>')
      $result.append( $surveyXML.children().not('contentList') )

    getSurveyContent: ($surveyXML) ->
      # return contentList tag from passed-in $surveyXML
      $surveyXML.find('contentList')

  App.reqres.setHandler "survey:xml", (id) ->
    API.getSurvey id

  App.reqres.setHandler "survey:xml:root", ($surveyXML) ->
    API.getSurveyRoot $surveyXML

  App.reqres.setHandler "survey:xml:content", ($surveyXML) ->
    API.getSurveyContent $surveyXML
