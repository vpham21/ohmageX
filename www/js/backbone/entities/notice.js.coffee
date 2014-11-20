@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Notice Entity generates entities for the custom 
  # Notice component.

  ###
  options expected:
    title
    description
    showCancel (T/F)
    cancelLabel
    okLabel
  ###
  
  currentRegion = false

  class Entities.Notice extends Entities.Model
    defaults: # default values for all Notices
      title: "Alert"
      description: "Something happened"
      showCancel: false # It's a single button notice by default
      cancelLabel: "Cancel"
      okLabel: "Ok"

  App.reqres.setHandler "notice:entity", (options) ->
    new Entities.Notice options

  App.reqres.setHandler "notice:region", ->
    if !!currentRegion then currentRegion else false

  App.commands.setHandler "notice:region:set", (region) ->
    currentRegion = region
