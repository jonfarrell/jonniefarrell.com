module.exports = (grunt) ->
  grunt.initConfig(
    pkg: grunt.file.readJSON("package.json")
    stylus:
      compile:
        files: [
          {
            expand: true
            cwd: "app/stylus/"
            src: ["**/*.styl", "!**/_**"]
            dest: "public/stylesheets"
            ext: ".css"
          }
        ]
    pug:
      compile:
        files: [
          {
            expand: true
            cwd: "app/pug/"
            src: ["**/*.pug", "!**/_**"]
            dest: "public/"
            ext: ".html"
          }
          {
            expand: true
            cwd: "app/templates/"
            src: ["**/*.pug", "!**/_**"]
            dest: "public/templates"
            ext: ".html"
          }

        ]
    coffee:
      compile:
        options:
          sourceMap: true
        files: [
          {
            expand: true
            cwd: "app/coffee/"
            src: ["**/*.coffee"]
            dest: "public/javascripts"
            ext: ".js"
          }
        ]

    copy:
      main:
        files: [
          {
            expand: true
            cwd: "app/assets"
            src: ["**"]
            dest: "public/"
          }
        ]

    watch:
      assets:
        files: ["app/assets/**/*.*"]
        tasks: ["newer:copy"]
        options:
          spawn: false
      css:
        files: ["app/stylus/**/*.styl"]
        tasks: ["stylus"]
        options:
          spawn: false
      coffee:
        files: ["app/coffee/**/*.coffee"]
        tasks: ["newer:coffee"]
        options:
          spawn: false
      pug:
        files: ["app/pug/**/*.pug", "app/templates/**/*.pug", "!app/pug/**/_*.pug"]
        tasks: ["newer:pug"]
        options:
          spawn: false
      mixins:
        files: ["app/pug/**/_*.pug"]
        tasks: ["pug"]
        options:
          spawn: false
      data:
        files: ["app/site_data.json"]
        tasks: ["pug"]
        options:
          spawn: false
  )

  grunt.loadNpmTasks("grunt-contrib-stylus");
  grunt.loadNpmTasks("grunt-contrib-pug");
  grunt.loadNpmTasks("grunt-contrib-coffee");
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks("grunt-contrib-watch");
  grunt.loadNpmTasks("grunt-newer");

  grunt.registerTask("build", ["copy", "stylus", "pug", "coffee"])
  grunt.registerTask("default", ["watch"])
