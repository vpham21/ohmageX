@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Blocker Entity generates entities for the custom 
  # Blocker component.

  ###
  options expected:
    contentViewLabel
  ###

  class Entities.Blocker extends Entities.Model
    initialize: (attributes, options) -> # default values for all Blockers
      result = switch attributes.contentViewLabel
        when "password:change"
          {
            title: "Change Password"
            cancelLabel: "Cancel"
            okLabel: "Change Password"
          }
        when "password:invalid"
          {
            title: "Password Failed"
            cancelLabel: "Cancel and Logout"
            okLabel: "Submit Password"
          }
      @set result
    blockerShow: ->
      @trigger 'blocker:show'
    blockerHide: ->
      @trigger 'blocker:hide'
