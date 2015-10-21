@Ohmage.module "GoalsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Goals extends App.Views.ItemView
    className: "text-container"
    template: "goals/show/info"
    triggers:
      "click .change-goals": "clicked:save" 

    initialize: ->
      @listenTo @, "clicked:save", @saveClicked

    saveClicked: ->
      console.log "saving goals"
      isGoalSnacks = @$el.find('input[id=goalSnacks]').is(':checked')
      isGoalMeals = @$el.find('input[id=goalMeals]').is(':checked')
      isGoalEnergyDensity = @$el.find('input[id=goalEnergyDensity]').is(':checked')
      isGoalCarbohydrates = @$el.find('input[id=goalCarbohydrates]').is(':checked')
      isGoalWorkoutSnack = @$el.find('input[id=goalWorkoutSnack]').is(':checked')
      isGoalIntakeFrequency = @$el.find('input[id=goalIntakeFrequency]').is(':checked')
      isGoalBoneNutrients = @$el.find('input[id=goalBoneNutrients]').is(':checked')

      goals = 
        isGoalSnacks: isGoalSnacks
        isGoalMeals: isGoalMeals
        isGoalEnergyDensity: isGoalEnergyDensity
        isGoalCarbohydrates: isGoalCarbohydrates
        isGoalWorkoutSnack: isGoalWorkoutSnack
        isGoalIntakeFrequency: isGoalIntakeFrequency
        isGoalBoneNutrients: isGoalBoneNutrients

      App.vent.trigger "goals:save:clicked", goals

    serializeData: ->
      goals = App.request "user:preferences:get", "goals"

      if typeof(goals) == 'undefined'
        data = 
          isGoalSnacks: false
          isGoalMeals: false
          isGoalEnergyDensity: false
          isGoalCarbohydrates: false
          isGoalWorkoutSnack: false
          isGoalIntakeFrequency: false
          isGoalBoneNutrients: false
      else 
        data = goals
      data

  class Show.Layout extends App.Views.Layout
    template: "goals/show/show_layout"
    regions:
      goalsRegion: "#goals-region"
