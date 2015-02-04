@Ohmage.module "Components.Steps", (Steps, App, Backbone, Marionette, $, _) ->

  class Steps.Intro extends App.Views.ItemView
    className: "text-container"
    template: "steps/intro"
    serializeData: ->
      data = @model.toJSON()
      console.log 'Steps.Intro data', data
      data

  class Steps.Message extends App.Views.ItemView
    className: "text-container"
    template: "steps/message"
    serializeData: ->
      data = @model.toJSON()
      console.log 'Steps.Message data', data
      data

  class Steps.BeforeSubmission extends App.Views.ItemView
    className: "text-container"
    template: "steps/beforesubmission"
    serializeData: ->
      data = @model.toJSON()
      console.log 'Steps.BeforeSubmission data', data
      data.completeTitle = 'Uploading Survey...'
      data

  class Steps.AfterNoReminders extends App.Views.ItemView
    className: "text-container"
    template: "steps/after_noreminders"
    triggers:
      "click .reminder-create": "new:reminder"

  class Steps.ReminderTime extends App.Views.ItemView
    tagName: "li"
    template: "steps/_remindertime"
    serializeData: ->
      data = @model.toJSON()
      console.log 'Steps.AfterReminder data', data
      data
  class Steps.AfterHasReminders extends App.Views.CompositeView
    className: "text-container"
    template: "steps/after_hasreminders"
    childView: Steps.ReminderTime
    childViewContainer: ".reminder-times"
    triggers:
      "click .reminder-create": "new:reminder"

  class Steps.AfterSubmission extends App.Views.ItemView
    className: "text-container"
    template: "steps/aftersubmission"
    serializeData: ->
      data = @model.toJSON()
      console.log 'Steps.AfterSubmission data', data
      data.completeTitle = 'Survey Complete'
      data.summary = "Survey submitted."
      data
