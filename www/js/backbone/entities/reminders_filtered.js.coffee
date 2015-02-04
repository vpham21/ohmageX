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
        todayHourMinute = @todayHourMinute reminder.get('activationDate')

        # active reminders only.
        if !reminder.get('active') then return false
