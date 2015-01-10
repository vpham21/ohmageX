@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Loading extends Entities.Model
    defaults:
      message: 'Now Loading...'
    timer: false
    loadShow: (message = false) ->
      if message isnt false then @set('message', message)
      @timer = window.setTimeout (=>
        @trigger 'loading:show'
      ), 500
    loadHide: ->
      @set 'message', 'Now Loading...'
      @trigger 'loading:hide'
      window.clearTimeout @timer
    loadUpdate: (message) ->
      @set 'message', message
      @trigger 'loading:update', message

  API =
    getLoading: (message) ->
      new Entities.Loading message: message

  App.reqres.setHandler "loading:entities", ->
    API.getLoading()
