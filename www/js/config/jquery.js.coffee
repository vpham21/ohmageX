do ($) ->
  # Add custom jQuery methods, e.g.
  # $.fn.myCustomMethod = (obj = {}, init = true) ->

  # Shorthand for the text contents of a specific tag found 
  # within an element's DOM. It's assumed that this is used
  # in a low-level DOM context, meaning it's close to the
  # bottom tier of leaf nodes and there is no checking 
  # for duplicates.
  $.fn.tagText = (tagName) ->
    $.trim(@find(tagName).text())

  # Selects a jQuery DOM element based on its exact contents.
  # Not case sensitive.
  # Example Usage: "div:containsExact('John')"
  $.extend $.expr[":"],
    containsExact: $.expr.createPseudo((text) ->
      (elem) ->
        $.trim(elem.innerHTML.toLowerCase()) is text.toLowerCase()
    )
