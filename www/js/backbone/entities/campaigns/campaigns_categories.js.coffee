@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The campaignsSync ensures that proper campaign data is loaded
  # in the proper sequence for syncing between CampaignsUser, CampaignsVisible,
  # and CampaignsSaved.

  API =
  	getCategories: ->
  		[
  		 {
  		 	name: "Assessments"
  		 	url: "#surveys/assessments"
  		 },
  		 {
  		 	name: "Resources"
  		 	url: "#surveys/resources"
  		 },
  		 {
  		 	name: "Recipes"
  		 	url: "#surveys/assessments"
  		 }
  		]

  App.reqres.setHandler "campaigns:saved:categories", ->
    API.getCategories()
