@Ohmage.module "HeaderApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Nav extends App.Views.ItemView
    tagName: "li"

    modelEvents:
      "change:chosen": "changeChosen"

    getTemplate: -> 
      if @model.isDivider() then false else "header/list/_nav"

    onRender: ->
      @$el.addClass "divider" if @model.isDivider()

    attributes: ->
      # TODO: Replace inline style with proper style
      # Attempted using ".hide" and "data-visible=[false]"
      # but both were exceeded in precedence by other selectors
      if @model.get('visible') is false then {style: "display: none !important"} else {}

    changeChosen: (model, value, options) ->
      @$el.toggleClass "active", value

    triggers:
      "click": "chosen:check"

  class List.Title extends App.Views.ItemView
    tagName: "span"
    template: "header/list/_title"
    serializeData: ->
      chosenModel = @collection.findWhere(chosen: true)
      data = {}
      if chosenModel is undefined 
        data.pageTitle = App.package_info.app_name
      else
        name = chosenModel.get("name")
        data.pageTitle = App.dictionary "menu", name
      data

  class List.Header extends App.Views.CollectionView
    initialize: ->
      @listenTo @collection, "reveal", @render
      @listenTo @, "childview:chosen:check", @chosenCheck
    chosenCheck: (args) ->
      myName = args.model.get('name')
      myUrl = args.model.get('url')

      surveyActive = App.request "surveytracker:active"
      logoutChosen = myName is "Logout"

      showDialog = surveyActive or logoutChosen
      if showDialog
        if surveyActive and logoutChosen
          message = 'Do you want to logout and exit the survey?'
        else if surveyActive
          message = 'Do you want to exit the survey?'
        else if logoutChosen
          message = 'Do you want to logout?'

        App.execute "dialog:confirm", message, (=>
          # reset active survey's entities.
          if surveyActive then App.vent.trigger "survey:reset"
          App.navigate myUrl, { trigger: true }
        ),(=>
          @collection.trigger "chosen:canceled"
        )
      else
        App.navigate myUrl, { trigger: true }

    tagName: "ul"
    attributes:
      class: "right"
    childView: List.Nav

  class List.Layout extends App.Views.Layout
    initialize: ->
      @listenTo @collection, "change:chosen", (model) ->
        if model.isChosen() then @menu.close()
      @listenTo @collection, "chosen:canceled", ->
        @menu.close()
    template: "header/list/layout"
    attributes: ->
      if App.device.isiOS7 then { class: "ios7" }
    regions:
      listRegion: "#app-menu .list-container"
      buttonRegion: "#button-region"
      titleRegion: "#page-title"
    onRender: ->
      triggerEvent = if App.device.isNative then 'touchstart' else 'click'
      @menu = new SlideOutComponent('#app-menu', @$el, triggerEvent)
      @menu.toggleOn('.app-menu-trigger', @$el)
