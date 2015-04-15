@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Reminders Filter entity.
  # methods for fetching reminder based on filter criteria.

  API =

    todayHourMinute: (myMoment) ->
      input = moment(myMoment)

      hour = input.hour()
      minute = input.minute()
      second = input.second()

      moment().startOf('day').hour(hour).minute(minute).second(second)


    surveyScheduledLaterToday: (reminders, surveyId) ->
      now = moment()
      dayEnd = moment(now).endOf('day')

      reminders.filter (reminder) =>
        activationDate = reminder.get('activationDate')
        todayHourMinute = @todayHourMinute activationDate

        console.log 'reminders filter'
        # active reminders only.
        if !reminder.get('active') then return false
        console.log 'active PASSED'
        # ensure the reminder matches the survey ID.
        if reminder.get('surveyId') isnt surveyId then return false
        console.log 'survey ID match PASSED'

        # for all cases:
        # verify the hour and minute of this activationDate
        # is later than now.
        # non-suppressed daily reminders will pass the filter if this is true.
        if now > todayHourMinute then return false
        console.log 'hour minute later than now PASSED'

        if !reminder.get('repeat')
          # reminder is non-repeating
          # check the activationDate of this specific reminder
          # occurring later today.
          # only passes if:
          # now < activationDate < dayEnd
          if !(now < activationDate and activationDate < dayEnd) then return false
          console.log 'non-repeating, now < activationDate < dayEnd PASSED'
        else 
          # because of suppression, repeating reminders that pass this test
          # must have an activationDate that is before the end of today.
          if activationDate >= dayEnd then return false
          console.log 'repeating reminder suppression check, activationDate in the past PASSED'

          if reminder.get('repeatDays').length isnt 7
            # reminder is a collection of "weekly" notifications
            # must make sure that today is in the collection of repeatDays.
            # note type conversion of now.day() to string for comparison.
            if !("#{now.day()}" in reminder.get('repeatDays')) then return false
            console.log 'non-consecutive repeating, today is in repeatDays PASSED'

        return true

  App.reqres.setHandler "reminders:survey:scheduled:latertoday", (surveyId) ->
    reminders = App.request "reminders:current"
    new Entities.Reminders API.surveyScheduledLaterToday(reminders, surveyId)
