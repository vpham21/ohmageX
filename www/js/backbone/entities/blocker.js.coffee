@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Blocker Entity generates entities for the custom 
  # Blocker component.

  ###
  options expected:
    contentViewLabel
  ###

  class Entities.Blocker extends Entities.Model
    blockerShow: ->
      @trigger 'blocker:show'
    blockerHide: ->
      @trigger 'blocker:hide'
