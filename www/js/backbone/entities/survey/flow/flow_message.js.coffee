@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Flow Message entity handles returning data relevant to message
  # prompts in the flow.

  API =
    getMessageIds: (flow) ->
      if !!!flow.where(type: 'message') then return false
      _.chain(flow.toJSON()).where(type: 'message').pluck('id').value()


  App.reqres.setHandler "flow:message:ids", ->
    currentFlow = App.request "flow:current"
    API.getMessageIds currentFlow
