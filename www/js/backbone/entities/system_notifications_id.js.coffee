@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Systems Notifications ID entity.

  # This provides the interface for metadata encoded within a notification's
  # ID. This reduces complexity, eliminating asynchronous requests
  # to the notifications plugin.

  oldId = false

  API =

    generateMetadataId: (repeat, repeatDay) ->
      # generate a numeric id (not a guid) encoded with repeat metadata in the last digit.
      # Local notifications plugin fails if the id is not an Android-valid integer
      # (Max for 32 bits is 2147483647)

      # Encoding rules:
      # The X digit represents the notification's repeat.
      # Example: 90000000X
      # Values for X
      # 0 thru 6 = The Moment.js weekday of a weekly repeating notification
      # 7        = A daily repeating notification ("7 days a week")
      # 9        = A one-time notification

      myId = "9xxxxxxx".replace /[xy]/g, (c) ->
        r = Math.random() * 9 | 0
        v = (if c is "x" then r else (r & 0x3 | 0x8))
        v.toString 10

      if repeatDay
        # Weekly
        # Exception handler for an invalid repeatDay
        throw new Error "Invalid repeatDay #{repeatDay}" unless parseInt(repeatDay) < 7
        myId += "#{repeatDay}"
      else if repeat
        # Daily
        myId += "7"
      else
        # One-time
        myId += "9"

      myId

    getRepeat: (id) ->
      # extract repeat information from a given notification's ID.

      # return the following object properties:

      # `type`:
      #   false - non-repeating notification
      #   'daily' - daily notification
      #   'weekly' - weekly notificatoin
      # if weekly, it includes `weekday`:
      # - the Moment.js weekday that it repeats

      repeatStr = id.slice(-1)

      if repeatStr is "9"
        return {
          type: false
        }
      else if repeatStr is "7"
        return {
          type: 'daily'
        }
      else
        return {
          type: 'weekly'
          weekday: parseInt(repeatStr)
        }
    compare: (id) ->
      # This ensure that duplicate notification IDs aren't called successively.
      # workaround for a plugin bug that causes multiple trigger events to fire
      # for a single notification ID when it triggers once.

      if id isnt oldId
        oldId = id
        return true
      else
        return false

  App.reqres.setHandler "system:notifications:id:generate", (repeat, repeatDay = false) ->
    API.generateMetadataId repeat, repeatDay

  App.reqres.setHandler "system:notifications:id:repeat", (id) ->
    API.getRepeat id

  App.reqres.setHandler "system:notifications:oldid:compare", (id) ->
    API.compare id

  App.reqres.setHandler "system:notifications:oldid:reset", ->
    oldId = false
