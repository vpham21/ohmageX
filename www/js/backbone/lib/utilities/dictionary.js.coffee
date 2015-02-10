@Ohmage.module "Utilities", (Utilities, App, Backbone, Marionette, $, _) ->

  _.extend App,

    dictionary: (group, name) ->
      groupObj = App.custom.dictionary[group]
      if name of groupObj then groupObj[name] else "#{name} not in dictionary #{group}"
