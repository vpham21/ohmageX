@Ohmage.module "SurveyMultipromptApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # renders multiple prompts on a given page.
  # A fundamental assumption of multiprompt rendering:
  # if a page begins with an intro, beforeSurveySubmit, or afterSurveySubmit step,
  # it is the ONLY step on that page. Any other assumption will break this layout.
  # This assumption is enforced in the flow_pages entity as well.

