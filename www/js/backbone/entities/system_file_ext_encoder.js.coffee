@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Systems File extensions encoder.
  # Encode and decode file extensions into and out of a UUID.

  # *********************  WARNING *********************
  # Note that the only reason this exists is because the server
  # fails to provide media file metadata. File extensions are required
  # for Android file plugins to function at all, and the server
  # only returns UUID + binary data. THIS ENCODER/DECODER IS A STOPGAP
  # SOLUTION, because encoding data into a field that was never
  # meant to contain anything but a unique identifier will
  # inevitably lead to problems later. Also, because of this 
  # encoding/decoding stopgap there is a limitation of max 4
  # characters allowable in a file extension (ignoring the `.`)

  # Not backwards-compatible
  # Any attempt to open a media file of a document
  # or video response that was created before this encoder
  # was implemented will fail completely, because the
  # trailing 8 characters of its UUID will be translated
  # into gibberish.

  # Images seem to be immune to this, they render properly
  # even if the extension does not match the file type,
  # because they are rendered inline using the src attr.
  # *********************  WARNING *********************
