@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  App.reqres.setHandler "prompt:unsupported:entity", (type) ->
    new Entities.Model
      type: type
