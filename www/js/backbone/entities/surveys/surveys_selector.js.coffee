@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The surveys selector creates data for the Campaign chooser.

  class Entities.SurveysCampaign extends Entities.Nav
    initialize: (options) ->
      # map saved campaigns into our version of this list
      console.log 'SurveysCampaign initialize'
      if options.name isnt 'All'
        console.log 'isnt all'
        @set { name: options.name, url: "#surveys/#{options.id}" }
        @unset 'status'
        @unset 'description'

  class Entities.SurveysCampaigns extends Entities.NavsCollection
    model: Entities.SurveysCampaign
    chooseById: (nav) ->
      # we expect chosen to be false if no campaign is selected,
      # it chooses the first (default) item in the list if this is the case
      @choose (@findWhere(id: nav) or @first())

  API =
    getNavs: (saved, chosen) ->
      # Ensure All link is prepended to the list.
      navs = new Entities.SurveysCampaigns [{ name: 'All', url: "#surveys" }]
      navs.add saved.toJSON()
      navs.chooseById(chosen)
      navs

  App.reqres.setHandler "surveys:selector:entities", (chosen) ->
    saved = App.request "campaigns:saved:current"
    API.getNavs saved, chosen
