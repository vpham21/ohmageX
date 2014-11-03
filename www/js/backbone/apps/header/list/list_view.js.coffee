@Ohmage.module "HeaderApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Nav extends App.Views.ItemView
    tagName: "li"

    modelEvents:
      "change:chosen": "changeChosen"

    getTemplate: -> 
      if @model.isDivider() then false else "header/list/_nav"

    onRender: ->
      @$el.addClass "divider" if @model.isDivider()

    changeChosen: (model, value, options) ->
      @$el.toggleClass "active", value

  class List.Header extends App.Views.CollectionView
    tagName: "ul"
    attributes:
      class: "right"
    childView: List.Nav
