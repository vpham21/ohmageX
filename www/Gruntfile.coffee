module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    my_js_lib_prod_files: [
      "js/vendor/modernizr-2.6.2.custom.min.js"
      "js/vendor/jquery-1.10.2.min.js"
    ]
    my_build_files: [
      "js/vendor/underscore.js"
      "js/vendor/backbone.js"
      "js/vendor/backbone.touch.js"
      "js/vendor/backbone.marionette.js"
      "js/vendor/ratchet.js" # customized Ratchet, minus push.js
      "js/vendor/syphon.js"
      "js/vendor/spin.js"
      "js/vendor/jquery.spin.js"
      "js/vendor/backbone-routefilter.js"
      "js/vendor/placeholder_polyfill.jquery.js"
      "js/vendor/ConditionalParser.js"
      "js/vendor/jstz.js"
      "js/build/templates.js"
      "js/build/mycoffee.js"
    ]
    my_template_files: [
      "js/backbone/apps/**/*.eco"
      "js/backbone/lib/components/**/*.eco"
    ]
    my_coffeescript_files: [
      "js/config/**/*.coffee"
      "js/backbone/app.js.coffee"
      "js/backbone/lib/concerns/**/*.coffee"
      "js/backbone/lib/entities/**/*.coffee"
      "js/backbone/lib/utilities/**/*.coffee"
      "js/backbone/lib/views/**/*.coffee"
      "js/backbone/lib/controllers/**/*.coffee"
      "js/backbone/lib/components/**/*.coffee"
      "js/backbone/entities/**/*.coffee"
      "js/backbone/apps/**/*.coffee"
    ]

    eco:
      app:
        files:
          "js/build/templates.js": ["<%= my_template_files %>"]


    coffee:
      compile:
        options: {}
        files:
          "js/build/mycoffee.js": "<%= my_coffeescript_files %>" # concat then compile into single file

    compass:
      dist:
        options:
          config: 'config.rb'

    cssmin:
      combine:
        expand: true
        cwd: "css/"
        src: ["*.css", "!*.min.css", "!lib/*", "!fonts/*"]
        dest: "css/"
        ext: ".min.css"
      compress:
        files:
          "css/lib/groundwork-core.min.css" : ["css/lib/groundwork-core.css"]

    connect:
      server:
        options:
          base: '.'
          port: '8088'
          useAvailablePort: true
          hostname: '*' # using '*' makes the server accessible from anywhere, for development

    watch:
      templates:
        files: ["<%= my_template_files %>"]
        tasks: ["eco", "concat"]
      coffee:
        files: ["<%= my_coffeescript_files %>"]
        tasks: ["coffee", "concat"]
      template:
        files: ["index.html.tpl"]
        tasks: ["template:dev"]
      css:
        files: '**/*.sass'
        tasks: ['compass']

    concat:
      options:
        separator: ";"
      dist:
        src: ["<%= my_build_files %>"]
        dest: "js/<%= pkg.name %>.js"

    uglify:
      options:
        mangle:
          except: ["jQuery", "$", "Backbone", "_", "Marionette"]
      my_target:
        files:
          "js/<%= pkg.name %>.min.js": ['js/<%= pkg.name %>.js']
          "js/lib/modernizr-2.6.2.custom.min.js": ["js/lib/modernizr-2.6.2.custom.js"]

    template:
      dev:
        options:
          data:
            css_path: "css/main.css"
            css_core_path: "css/lib/core.css"
            js_modernizr_path: "js/vendor/modernizr-2.6.2.custom.js"
            js_jquery_path: "js/vendor/jquery-1.10.2.js"
            js_path: "js/<%= pkg.name %>.js"
            js_env: "development"
            js_url: "http://0.0.0.0:8088/"
            root_path: "/"
        files:
          "index.html": ["index.html.tpl"]

  
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-compass"

  # grunt-eco generates compatible JS from ECO-style templates.
  grunt.loadNpmTasks "grunt-eco"
  grunt.loadNpmTasks "grunt-contrib-cssmin"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-copy"
  
  # Here grunt-template is used to allow grunt to generate alternate index.html for different environments.
  grunt.loadNpmTasks "grunt-template"

  grunt.registerTask "default", [
    "template:dev"
    "eco"
    "coffee"
    "concat"
    "compass"
    "connect:server"
    "watch"
  ]
  grunt.registerTask "dev", [
    "template:dev"
    "eco"
    "coffee"
    "concat"
    "compass"
  ]
