module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    coffee:
      glob_to_multiple:
        expand: true
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'lib'
        ext: '.js'

    coffeelint:
      options:
        no_empty_param_list:
          level: 'error'
        max_line_length:
          level: 'ignore'

      src: ['src/*.coffee']
      test: ['spec/*.coffee']

    shell:
      'test':
        command: 'node node_modules/.bin/jasmine-focused --coffee --forceexit --captureExceptions spec'
        options:
          stdout: true
          stderr: true
          failOnError: true

      'install':
        command: 'npm install'

    watch:
      config:
        files: ['Gruntfile.coffee']
        options:
          reload: true

      install:
        files: ['package.json']
        tasks: ['shell:install']

      scripts:
        files: [
          'src/**/*.coffee'
          'spec/**/*.coffee'
        ]
        tasks: ['coffee', 'lint']

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-shell')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-contrib-watch')

  grunt.registerTask 'clean', -> require('rimraf').sync('lib')
  grunt.registerTask('lint', ['coffeelint:src', 'coffeelint:test'])
  grunt.registerTask('default', ['coffeelint', 'coffee'])
  grunt.registerTask('test', ['coffee', 'lint', 'shell:test'])
