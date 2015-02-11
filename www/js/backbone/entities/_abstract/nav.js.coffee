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
        loginItems = [
          "campaign"
          "survey"
          "queue"
          "reminder"
          "profile"
          "logout"
        ]
        if App.device.isNative
          filterItems = App.custom.menu_items_disabled.native
        else
          filterItems = App.custom.menu_items_disabled.browser

        visibleItems = _.difference(loginItems, filterItems)
      else
        visibleItems = [
          "login"
        ]
      App.navs.each((nav) ->
        visible = nav.get('name') in visibleItems
        nav.set 'visible', visible
      )
      App.navs.trigger "reveal"

    getNavs: ->
      # TODO: only show reminders in the nav menu on mobile devices.
      if App.device.isNative
        App.navs = new Entities.NavsCollection [
          { name: "login", url: "#login", icon: "", visible: false }
          { name: "campaign", url: "#campaigns", icon: "", visible: false }
          { name: "survey", url: "#surveys", icon: "", visible: false }
          { name: "queue", url: "#uploadqueue", icon: "", visible: false }
          { name: "reminder", url: "#reminders", icon: "", visible: false }
          { name: "profile", url: "#profile", icon: "", visible: false }
          { name: "logout", url: "#logout", icon: "", visible: false }
        ]
      else
        App.navs = new Entities.NavsCollection [
          { name: "login", url: "#login", icon: "", visible: false }
          { name: "campaign", url: "#campaigns", icon: "", visible: false }
          { name: "survey", url: "#surveys", icon: "", visible: false }
          { name: "queue", url: "#uploadqueue", icon: "", visible: false }
          { name: "profile", url: "#profile", icon: "", visible: false }
          { name: "logout", url: "#logout", icon: "", visible: false }
        ]

  App.vent.on "credentials:storage:load:success credentials:storage:load:failure", ->
    API.reveal App.request("credentials:isloggedin")

  App.reqres.setHandler "nav:entities", ->
    API.getNavs()

  App.vent.on "credentials:cleared", ->
    API.reveal false

  App.vent.on "credentials:validated", ->
    API.reveal true
