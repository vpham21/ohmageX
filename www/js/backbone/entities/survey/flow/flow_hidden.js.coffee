@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The flow Hidden entity handles initializing and preparing all hidden flow items
  # for a given survey.

  # async warning: Flow hidden initializes after the flow:init:complete event.
  # This event does not block subsequent events from happening such as responses:init,
  # followed by survey:start.
  # It's possible that a survey could start with hidden prompts not initialized. 
  # Assuming that doesn't happen right now. if there are errors with hidden prompt 
  # behavior such as rendering or data missing, this may need to be accounted for.

  API =
    initHidden: (flow) ->

      flow.each (step) =>
        myId = step.get('id')
        myHidden = App.request 'flow:meta:property:text', myId, 'hidden'
        if myHidden isnt false
          # we have a hidden prompt. Begin initializing.
          throw new Error "Only random values for hidden prompt #{myId} implemented, #{myHidden} not valid" if myHidden isnt 'random'
