@Routes = {}

@Routes = do (Routes) ->

  class _Routes
    default_route: ->
      'login'
      'home'

  new _Routes
