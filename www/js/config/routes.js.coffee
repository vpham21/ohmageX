@Routes = {}

@Routes = do (Routes) ->

  class _Routes
    default_route: ->
      'login'
    dashboard_route: ->
      'campaigns'

  new _Routes
