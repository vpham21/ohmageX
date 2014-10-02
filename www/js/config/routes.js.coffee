@Routes = {}

@Routes = do (Routes) ->

  class _Routes
    default_route: ->
      'login'
    dashboard_route: ->
      'home'

  new _Routes
