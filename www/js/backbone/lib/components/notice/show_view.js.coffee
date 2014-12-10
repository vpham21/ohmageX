@Ohmage.module "Components.Notice", (Notice, App, Backbone, Marionette, $, _) ->

  class Notice.Show extends App.Views.ItemView
    initialize: ->
      # activating either button closes the Notice
      @listenTo @, 'cancel:clicked ok:clicked', @destroy
    template: "notice/show"
    triggers:
      "click .cancel-button": "cancel:clicked"
      "click .ok-button": "ok:clicked"
