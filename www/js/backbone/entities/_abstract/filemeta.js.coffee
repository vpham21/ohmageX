@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The FileMeta entity stores meta information about stored files on the device.
  # Currently the File Meta store does not erase on logout like other components.
  # Only the user can erase it.

  class Entities.FileMetaEntry extends Entities.Model

  class Entities.FileMeta extends Entities.Collection
    model: Entities.FileMetaEntry


  storedMeta = false

