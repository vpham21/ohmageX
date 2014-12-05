@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  API =
    getFromStorage: (label, success, error) ->
      item = localStorage.getItem label
      if item
        item = JSON.parse item
        success(item)
      else
        error()

    saveToStorage: (label, value, callback) ->
      value = JSON.stringify value 

      try
        item = localStorage.setItem label, value
      catch domException
        if domException.name is "QuotaExceededError" or domException.name is "NS_ERROR_DOM_QUOTA_REACHED"
          alert 'browser storage limit exceeded, please clear some space to continue using the app.'

      callback value

    clearFromStorage: (label, callback) ->
      localStorage.removeItem(label)
      callback(label)

  App.reqres.setHandler "storage:get", (label, success, error) ->
    API.getFromStorage(label, success, error)

  App.commands.setHandler "storage:save", (label, value, callback) ->
    API.saveToStorage(label, value, callback)

  App.commands.setHandler "storage:clear", (label, callback) ->
    API.clearFromStorage(label, callback)
