module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    cordova_project_folder: "cordova-build"
    web_root_folder: "www"
    hybrid_build_folder: "www-mobile"
    my_js_lib_prod_files: [
      "<%= web_root_folder %>/js/vendor/modernizr-2.6.2.custom.min.js"
      "<%= web_root_folder %>/js/vendor/jquery-1.10.2.min.js"
    ]
    my_build_files: [
      "<%= web_root_folder %>/.blocks/build/blocks.js"
      "<%= web_root_folder %>/js/vendor/underscore.js"
      "<%= web_root_folder %>/js/vendor/backbone.js"
      "<%= web_root_folder %>/js/vendor/backbone.touch.js"
      "<%= web_root_folder %>/js/vendor/backbone.marionette.js"
      "<%= web_root_folder %>/js/vendor/syphon.js"
      "<%= web_root_folder %>/js/vendor/spin.js"
      "<%= web_root_folder %>/js/vendor/jquery.spin.js"
      "<%= web_root_folder %>/js/vendor/backbone-routefilter.js"
      "<%= web_root_folder %>/js/vendor/placeholder_polyfill.jquery.js"
      "<%= web_root_folder %>/js/vendor/ConditionalParser.js"
      "<%= web_root_folder %>/js/vendor/jstz.js"
      "<%= web_root_folder %>/js/build/templates.js"
      "<%= web_root_folder %>/js/build/mycoffee.js"
    ]
    my_template_files: [
      "<%= web_root_folder %>/js/backbone/apps/**/*.eco"
      "<%= web_root_folder %>/js/backbone/lib/components/**/*.eco"
    ]
    my_coffeescript_files: [
      "<%= web_root_folder %>/js/config/**/*.coffee"
      "<%= web_root_folder %>/js/backbone/app.js.coffee"
      "<%= web_root_folder %>/js/backbone/lib/concerns/**/*.coffee"
      "<%= web_root_folder %>/js/backbone/lib/entities/**/*.coffee"
      "<%= web_root_folder %>/js/backbone/lib/utilities/**/*.coffee"
      "<%= web_root_folder %>/js/backbone/lib/views/**/*.coffee"
      "<%= web_root_folder %>/js/backbone/lib/controllers/**/*.coffee"
      "<%= web_root_folder %>/js/backbone/lib/components/**/*.coffee"
      "<%= web_root_folder %>/js/backbone/entities/**/*.coffee"
      "<%= web_root_folder %>/js/backbone/apps/**/*.coffee"
    ]

    eco:
      app:
        options:
          basePath: "<%= web_root_folder %>/"
        files:
          "<%= web_root_folder %>/js/build/templates.js": ["<%= my_template_files %>"]


    coffee:
      compile:
        options: {}
        files:
          "<%= web_root_folder %>/js/build/mycoffee.js": "<%= my_coffeescript_files %>" # concat then compile into single file

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

    connect:
      server:
        options:
          base: './www'
          port: '8088'
          useAvailablePort: true
          hostname: '*' # using '*' makes the server accessible from anywhere, for development
      mobile_web:
        options:
          base: "./<%= hybrid_build_folder %>"
          port: '8089'
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
        files: ["<%= web_root_folder %>/index.html.tpl"]
        tasks: ["template:dev"]
      css:
        files: "<%= web_root_folder %>/**/*.sass"
        tasks: ['compass']

    concat:
      options:
        separator: ";"
      dist:
        src: ["<%= my_build_files %>"]
        dest: "<%= web_root_folder %>/js/<%= pkg.name %>.js"

    uglify:
      options:
        mangle:
          except: ["jQuery", "$", "Backbone", "_", "Marionette"]
      my_target:
        files:
          "<%= web_root_folder %>/js/<%= pkg.name %>.min.js": ["<%= web_root_folder %>/js/<%= pkg.name %>.js"]
          "<%= web_root_folder %>/js/lib/modernizr-2.6.2.custom.min.js": ["<%= web_root_folder %>/js/lib/modernizr-2.6.2.custom.js"]

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
          "<%= web_root_folder %>/index.html": ["<%= web_root_folder %>/index.html.tpl"]

  
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-compass"

  # Command line interface for Cordova
  grunt.loadNpmTasks "grunt-cordovacli"

  # grunt-eco generates compatible JS from ECO-style templates.
  grunt.loadNpmTasks "grunt-eco"
  grunt.loadNpmTasks "grunt-contrib-cssmin"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-exec"
  
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
