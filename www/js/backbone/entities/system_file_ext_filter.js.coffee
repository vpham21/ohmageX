@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Systems File extensions filter.
  # Filter for valid and invalid file extensions.

  # whitelist based on file opener plugin.
  extWhitelist = [
    'gif','jpg','jpeg','png', # images
    'txt', # text
    'mpg','mpeg','mpe','mp4','avi','3gp','3gpp','3g2', # video
    'doc','docx', # Word doc
    'pdf', # pdf
    'ppt','pptx', # Powerpoint
    'xls','xlsx', # Excel
    'rtf' # Rich Text format
  ]

  extVideos = [
    'mpg','mpeg','mpe','mp4','avi','3gp','3gpp','3g2' # video
  ]

  API =
    compareExtToArray: (filename, myArr) ->
      fileExt = filename.match(/\.[0-9a-z]+$/i)
      if fileExt is null then return false

      # truncate `.` from the front
      myJustExt = fileExt[0].slice 1

      myJustExt in myArr

    checkFileExt: (filename) ->
      API.compareExtToArray filename, extWhitelist

  App.reqres.setHandler "system:file:name:is:valid", (filename) ->
    API.checkFileExt filename

