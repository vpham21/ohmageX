# Require any additional compass plugins here.
require 'sass-css-importer'

# Set this to the root of your project when deployed:
http_path = "www/"
css_dir = http_path+"css"
sass_dir = http_path+"sass"
images_dir = http_path+"img"
javascripts_dir = http_path+"js"
fonts_dir = http_path+"css/fonts"

# You can select your preferred output style here (can be overridden via the command line):
# output_style = :expanded or :nested or :compact or :compressed
output_style = :expanded

# To enable relative paths to assets via compass helper functions. Uncomment:
relative_assets = true

# To disable debugging comments that display the original location of your selectors. Uncomment:
# line_comments = false

# https://github.com/chriseppstein/sass-css-importer
# The Sass CSS Importer allows you to import a CSS file into Sass.
# Example: @import "CSS:library/some_css_file"
require 'sass-css-importer'
# specify the absolute path to the css folder for CssImporter.
add_import_path Sass::CssImporter::Importer.new(http_path+"css")

# If you prefer the indented syntax, you might want to regenerate this
# project again passing --syntax sass, or you can uncomment this:
preferred_syntax = :sass
# and then run:
# sass-convert -R --from scss --to sass sass scss && rm -rf sass && mv scss sass

Sass::Script::Number.precision = 3