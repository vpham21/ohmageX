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
            okLabel: "Change"
          }
        when "password:invalid"
          {
            title: "Password Failed"
            cancelLabel: "Cancel"
            okLabel: "Submit"
          }
        when "reminder:update"
          {
            title: "Configure Reminder"
            cancelLabel: "Cancel"
            okLabel: "Save"
          }
      @set result
    blockerShow: ->
      @trigger 'blocker:show'
    blockerClose: ->
      @trigger 'blocker:close'

  App.reqres.setHandler "blocker:entity", (contentViewLabel) ->
    new Entities.Blocker
      contentViewLabel: contentViewLabel
