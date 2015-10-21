@Ohmage.module "SettingsDateApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.SettingsDate extends App.Views.ItemView
    className: "text-container"
    template: "settings_date/show/info"
    triggers:
      "click .change-start": "clicked:save" 

    initialize: ->
      @listenTo @, "clicked:save", @saveClicked

    saveClicked: ->
    	dateString = @$el.find('input[type=date]').val()
    	if moment(dateString).isValid()
    		@trigger "settings_date:save:clicked", dateString

    serializeData: ->
      start = App.request "user:preferences:get", "start_date"

      if typeof(start) != 'undefined'      
        data = 
          start_date: moment(start).format('YYYY-MM-DD')
      data

  class Show.Layout extends App.Views.Layout
    template: "settings_date/show/show_layout"
    regions:
      settingsDateRegion: "#settings-date-region"
