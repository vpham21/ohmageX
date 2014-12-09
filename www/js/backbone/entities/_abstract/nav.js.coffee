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
    reveal: (isLoggedIn) ->
      console.log 'reveal isLoggedIn', isLoggedIn
      if isLoggedIn
        visibleItems = [
          "Campaigns"
          "Surveys"
          "Upload Queue"
          "Profile"
          "Logout"
        ]
      else
        visibleItems = [
          "Login"
        ]
      App.navs.each((nav) ->
        visible = nav.get('name') in visibleItems
        nav.set 'visible', visible
      )
      App.navs.trigger "reveal"

    getNavs: ->
      App.navs = new Entities.NavsCollection [
        { name: "Login", url: "#login", icon: "", visible: false }
        { name: "Campaigns", url: "#campaigns", icon: "", visible: false }
        { name: "Surveys", url: "#surveys", icon: "", visible: false }
        { name: "Upload Queue", url: "#uploadqueue", icon: "", visible: false }
        { name: "Profile", url: "#profile", icon: "", visible: false }
        { name: "Logout", url: "#logout", icon: "", visible: false }
      ]

  App.vent.on "credentials:storage:load:success credentials:storage:load:failure", ->
    API.reveal App.request("credentials:isloggedin")

  App.reqres.setHandler "nav:entities", ->
    API.getNavs()

  App.vent.on "credentials:cleared", ->
    API.reveal false

  App.vent.on "credentials:validated", ->
    API.reveal true
