@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  $XML = false

  API =
    initXML: ->
      XMLDoc = $.parseXML(Bootstrap)
      $XML = $(XMLDoc)

    getItem: (rawXML, item) ->
      $XML = $(rawXML)
      $XML.find item

  App.reqres.setHandler "xml:get", (rawXML, item) ->
    API.getItem(rawXML, item)

  App.commands.setHandler "xml:destroy", ->
    console.log 'destroy XML'
    $XML = false