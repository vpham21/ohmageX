do ($) ->
  # Add custom jQuery methods, e.g.
  # $.fn.myCustomMethod = (obj = {}, init = true) ->

  # Shorthand for the text contents of a specific tag found 
  # within an element's DOM. It's assumed that this is used
  # in a low-level DOM context, meaning it's close to the
  # bottom tier of leaf nodes and there is no checking 
  # for duplicates.
  $.fn.tagText = (tagName) ->
    if @find(tagName).length < 1 then return false
    $.trim(@find(tagName).text())

  $.fn.tagHTML = (tagName) ->
    if @find(tagName).length < 1 then return false
    $.trim(@find(tagName).html())

  # Selects a jQuery DOM element based on its exact contents.
  # Not case sensitive.
  # Example Usage: "div:containsExact('John')"
  $.extend $.expr[":"],
    containsExact: $.expr.createPseudo((text) ->
      (elem) ->
        # use elem.textContent property - not supported in IE8 and below,
        # but IE compatibility is not required anyway
        $.trim(elem.textContent.toLowerCase()) is text.toLowerCase()
    )

  $.ajaxSetup({
    timeout: 6000
  });
