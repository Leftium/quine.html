# vim: tabstop=2 shiftwidth=2

module.exports = (grunt) ->
  # Project configuration.
  grunt.initConfig
    pkg:
      grunt.file.readJSON 'package.json'

    coffee:
      compile:
        files:
          'built/quine.js': 'src/coffee/quine.coffee' # 1:1 compile

    cssmin:
      target:
        files:
          'built/style.css': 'src/style.css'

    uglify:
      options:
        maxLineLen: 80 # UglifyJS2 doesn't honor this; modified npm module.
      files:
        src: [
          'lib/codemirror/lib/codemirror.js',
          'lib/codemirror/addon/fold/foldcode.js',
          'lib/codemirror/addon/fold/foldgutter.js',
          'lib/codemirror/addon/fold/indent-fold.js',
          'built/quine.js'
        ]
        dest: 'built/quine.js'

    inline:
      options:
          tag: ''
      files:
        src: 'src/quine.html',
        dest: 'built/quine.html'

    finish:
      files:
        src: 'built/quine.html'
        dest: 'built/quine.html'


  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-inline'

  grunt.registerMultiTask 'finish', 'Ensure clean taskpaper formatting.', () ->
    @.files.forEach (filePair) ->
      # Check that the source file exists
      if filePair.src.length is 0 then return

      value = grunt.file.read filePair.src

      metadataRE = /^Metadata:[\s\S]*$/m
      metadata = value.match(metadataRE)[0]

      # Remove unformatted Metadata: project
      value = value.replace metadataRE, ''

      lines = metadata.split '\n'

      htmlStart = lines.length - 1
      while htmlStart > 0 and not /^<!doctype/.test lines[htmlStart]
        htmlStart--

      # Restore project name and any notes; newlines intact
      value += lines[0...htmlStart].join '\n'

      # Compress html lines to single line
      value += "\n  #{lines[htmlStart..].join ''}"

      # Append vim modeline to end of Metadata project
      lines = value.split '\n'
      modeline = lines[0]
      value = value.slice 1
      value = "#{lines[1..].join '\n'}\n\n#{modeline}"

      grunt.file.write filePair.dest, value


  # Default task(s).
  grunt.registerTask 'default', ['coffee', 'cssmin', 'uglify', 'inline', 'finish']

