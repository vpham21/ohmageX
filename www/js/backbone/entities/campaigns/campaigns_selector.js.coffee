@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The campaigns selector creates data for the Campaign chooser
  # in the campaign list.

  class Entities.CampaignsNav extends Entities.NavsCollection

    chosenName: ->
      (@findWhere(chosen: true) or @first()).get('name')

  API =
    getNavs: (saved) ->
      navs = new Entities.CampaignsNav [
        { name: 'All' }
        { name: 'Saved' }
      ]
      # choose Saved campaigns by default if the user has
      # saved any campaigns.
      # chosen = if saved.length > 0 then 'Saved' else 'All'
      chosen = 'All'
      navs.chooseByName(chosen)
      navs

  App.reqres.setHandler "campaigns:selector:entities", ->
    saved = App.request "campaigns:saved:current"
    API.getNavs saved
