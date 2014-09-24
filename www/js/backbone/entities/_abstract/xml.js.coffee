@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  $XML = {}

  API =
    initXML: ->
      XMLDoc = $.parseXML(Bootstrap)
      $XML = $(XMLDoc)

    getItem: (item) ->
      $XML.find item

  App.on "initialize:before", ->
    API.initXML()

  App.reqres.setHandler "xml:get", (item) ->
    API.getItem(item)