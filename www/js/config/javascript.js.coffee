@my$XmlToString = ($xmlData) -> # requires JQuery XML data
  xmlString = `undefined`
  xmlString = $xmlData[0].xml  if window.ActiveXObject
  if xmlString is `undefined`
    oSerializer = new XMLSerializer()
    xmlString = oSerializer.serializeToString($xmlData[0])
  # trim any rogue characters that may exist in the XML
  xmlString.substr(xmlString.indexOf("<"), xmlString.lastIndexOf(">") + 1)

@myGetCookie = (sKey) ->
  # method taken from Mozilla's mini cookie reader/writer at Web API document.cookie docs
  if (!sKey) then return null
  return decodeURIComponent(document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + encodeURIComponent(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1")) || null

if typeof String.prototype.capitalizeFirstLetter isnt 'function'
  String.prototype.capitalizeFirstLetter = ->
    @ && @[0].toUpperCase() + @slice(1)

if typeof String.prototype.endsWith isnt 'function'
  String.prototype.endsWith = (suffix) ->
    @indexOf(suffix, @length - suffix.length) isnt -1
