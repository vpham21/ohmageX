@Ohmage.module "CampaignsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Search extends App.Views.ItemView
    initialize: ->
      @listenTo @, 'search:update', @updateSearch
      @listenTo @collection, 'filter:search:clear', @clearSearch
    clearSearch: ->
      @$el.find('input').val('')
    updateSearch: ->
      val = @$el.find('input').val()
      console.log 'updateSearch val', val
      if val
        @collection.where
          name: val
      else
        @collection.where()

    template: "campaigns/list/search"
    triggers:
      "keyup input": "search:update"
    onRender: ->
      @menu = new VisibilityToggleComponent('input', @$el)
      @menu.toggleOn('click', '.icon.search', @$el)


  # Render Selector using Dropdown
  class List.SelectorItem extends App.Views.ItemView
    tagName: "option"
    template: "campaigns/list/_selector_item"
    attributes: ->
      options = {}
      options['value'] = @model.get 'name'
      if @model.isChosen() then options['selected'] = 'selected'
      options

  class List.SavedSelector extends App.Views.CollectionView
    initialize: ->
      @listenTo @, "saved:selected", @chooseItem
      @listenTo @collection, 'filter:saved:clear', @clearSaved
    clearSaved: ->
      if @$el.val() is 'Saved' then @$el.val('All')
    chooseItem: (options) ->
      console.log 'chooseItem options', options
      @collection.chooseByName @$el.val()
    tagName: "select"
    childView: List.SelectorItem
    triggers: ->
      "change": "saved:selected"

  ###
  # Render selector using Radio
  class List.SelectorItem extends App.Views.ItemView
    tagName: "div"
    template: "campaigns/list/_selector_item_radio"
    serializeData: ->
      data = @model.toJSON()
      data.checked = if @model.isChosen() then 'checked' else ''
      data

  class List.SavedSelector extends App.Views.CollectionView
    initialize: ->
      @listenTo @, "saved:selected", @chooseItem
      @listenTo @collection, 'filter:saved:clear', @clearSaved
    clearSaved: ->
      if @$el.find('input:checked').val() is 'Saved' then @$el.find('input[value="All"]').prop('checked', true)
    chooseItem: (options) ->
      console.log 'chooseItem options', options
      @collection.chooseByName @$el.find('input:checked').val()
    tagName: "div"
    childView: List.SelectorItem
    triggers: ->
      "change input": "saved:selected"
  ###

  class List.Campaign extends App.Views.ItemView
    initialize: ->
      @listenTo @model, 'change', @render
    tagName: 'li'
    getTemplate: ->
      result = switch @model.get 'status'
        when 'available' then "campaigns/list/_available_campaign"
        when 'saved' then "campaigns/list/_saved_campaign"
        else "campaigns/list/_ghost_campaign"
      result
    triggers:
      "click .available.campaign button.save": "save:clicked"
      "click .available.campaign [role=\"link\"]": "save:clicked"
      "click .available.campaign button.info": "info:clicked"
      "click .saved.campaign button.delete": "unsave:clicked"
      "click .saved.campaign [role=\"link\"]": "navigate:clicked"
      "click .saved.campaign button.navigate": "navigate:clicked"
      "click .ghost.campaign button.delete": "ghost:remove:clicked"
      "click .ghost.campaign [role=\"link\"]": "ghost:remove:clicked"

  class List.CampaignsEmpty extends App.Views.ItemView
    template: "campaigns/list/_campaigns_empty"

  class List.Campaigns extends App.Views.CompositeView
    initialize: ->
      @listenTo @collection, 'reset', @render
      @listenTo @collection, 'remove', @render
    template: "campaigns/list/campaigns"
    childView: List.Campaign
    childViewContainer: ".campaigns"
    emptyView: List.CampaignsEmpty

  class List.Layout extends App.Views.Layout
    template: "campaigns/list/list_layout"
    id: 'campaigns'
    regions:
      infoRegion: "#info-region"
      selectorRegion: "#selector-region"
      listRegion: "#list-region"
      searchRegion: "#search-region"
