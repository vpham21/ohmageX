@Ohmage.module "Components.FullModal", (FullModal, App, Backbone, Marionette, $, _) ->

  class FullModal.Layout extends App.Views.Layout
    template: "fullmodal/layout"
    className: "fullmodal-container"
    triggers:
      "click .button-close": "close:clicked"
    regions:
      contentRegion: "article"

    onRender: ->
      @modal = new FullModalComponent('#fullmodal-root')
      @modal.show()
