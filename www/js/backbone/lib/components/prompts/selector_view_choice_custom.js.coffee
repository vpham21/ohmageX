@Ohmage.module "Components.Prompts", (Prompts, App, Backbone, Marionette, $, _) ->

  # Prompt Single Choice Custom
  class Prompts.SingleChoiceCustom extends Prompts.BaseComposite
    template: "prompts/choice_custom"
    childView: Prompts.SingleChoiceItem
    childViewContainer: ".prompt-list"
    triggers:
      "click button.my-add": "customchoice:toggle"
      "click .add-form .add-submit": "customchoice:add"
      "click .add-form .add-cancel": "customchoice:cancel"
    initialize: ->
      super
      @listenTo @, 'customchoice:toggle', @toggleChoice
      @listenTo @, 'customchoice:add', @addChoice
      @listenTo @, 'customchoice:cancel', @cancelChoice

      @listenTo @, 'childview:customchoice:remove', @removeChoice

      @listenTo @, 'customchoice:add:invalid', (-> App.execute "dialog:alert", 'invalid custom choice, please try again.')
      @listenTo @, 'customchoice:add:exists', (-> App.execute "dialog:alert", 'Custom choice exists, please try again.')


    removeChoice: (args) ->
      value = args.model.get 'label'
      @collection.remove @collection.where(label: value)
      @trigger "customchoice:remove", value

    toggleChoice: (args) ->
      $addForm = @$el.find '.add-form'
      $addForm.toggleClass 'hidden'

    cancelChoice: ->
      $addForm = @$el.find '.add-form'
      $addForm.addClass 'hidden'
      $addForm.find(".add-value").val('')

    addChoice: (args) ->
      $addForm = @$el.find '.add-form'
      myVal = $addForm.find(".add-value").val().trim()

      if !!!myVal.length
        # ensure a new custom choice isn't blank.
        @trigger "customchoice:add:invalid"
        return false

      if not $addForm.hasClass 'hidden'

        # add new choice, based on the contents of the text prompt,
        # to the view's Collection. Validation and parsing takes
        # place within the ChoiceCollection's model.

        if args.collection.where(label: myVal).length > 0
          # the custom choice already exists
          @trigger "customchoice:add:exists"
          return false

        args.collection.add([{
          "key": _.uniqueId()
          "label": myVal
          "parentId": args.model.get('id')
          "custom": true
        }])

        # clear the input on successful submit.
        @trigger "customchoice:add:success", myVal
        $addForm.find(".add-value").val('')


  class Prompts.MultiChoiceCustom extends Prompts.SingleChoiceCustom
    childView: Prompts.MultiChoiceItem


