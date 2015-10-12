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

