@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  $XML = false

  API =
    initXML: ->
      XMLDoc = $.parseXML(Bootstrap)
      $XML = $(XMLDoc)

    getItem: (item) ->
      if !$XML then API.initXML()
      $XML.find item

  App.reqres.setHandler "xml:get", (item) ->
    API.getItem(item)

  App.commands.setHandler "xml:destroy", ->
    console.log 'destroy XML'
    $XML = false