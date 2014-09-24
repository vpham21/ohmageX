@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Nav extends Entities.Model
    isDivider: -> @get('divider')

    isChosen: -> @get('chosen')

    choose: ->
      @set chosen: true

    unchoose: ->
      @set chosen: false
 
    chooseByCollection: ->
      @collection.choose @

  class Entities.NavsCollection extends Entities.Collection
    model: Entities.Nav

    choose: (model) ->
      _(@where chosen: true).invoke("unchoose")
      model.choose()

    chooseByName: (nav) ->
      @choose (@findWhere(name: nav) or @first())

  API =
    getNavs: ->
      new Entities.NavsCollection [
        { divider: true }
        { name: "Dashboard", url: "#dashboard", icon: ""}
        { name: "Campaigns", url: "#campaigns", icon: ""}
        { name: "Profile",   url: "#profile",   icon: ""}
        { name: "Settings",  url: "#settings",  icon: ""}
      ]

  App.reqres.setHandler "nav:entities", ->
    API.getNavs()