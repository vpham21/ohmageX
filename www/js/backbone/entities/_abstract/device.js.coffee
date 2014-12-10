@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  API =
    initDevice: ->
      myDevice = {}
      myDevice.isNative = document.URL.indexOf('http://') is -1 and document.URL.indexOf('https://') is -1

      if myDevice.isNative
        myDevice.isiOS7 = @isDeviceiOS7Plus()
      else
        myDevice.isiOS7 = false

      myDevice

    isDeviceiOS7Plus: ->
      version = @getDeviceiOSVersion()
      version[0] >= 7

    getDeviceiOSVersion: ->
      v = (navigator.appVersion).match(/OS (\d+)_(\d+)_?(\d+)?/)
      [ parseInt(v[1], 10), parseInt(v[2], 10), parseInt(v[3] or 0, 10) ]


  App.reqres.setHandler "device:init", ->
    API.initDevice()
