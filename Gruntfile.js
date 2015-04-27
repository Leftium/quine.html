module.exports = function(grunt) {
  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    coffee: {
      compile: {
        files: {
          'built/quine.js': 'src/coffee/quine.coffee', // 1:1 compile
        }
      },
    },
    uglify: {
      options: {
        maxLineLen: 80 // UglifyJS2 doesn't honor this; modified npm module.
      },
      files: {
        src: [
             'lib/codemirror/lib/codemirror.js',
             'lib/codemirror/addon/fold/foldcode.js',
             'lib/codemirror/addon/fold/foldgutter.js',
             'lib/codemirror/addon/fold/indent-fold.js',
             'built/quine.js'
             ],
        dest: 'built/quine.js'
      },
    },
    inline: {
      options: {
          cssmin: true,
          tag: ''
      },
      files: {
        src: 'src/quine.html',
        dest: 'built/inline/quine.html'
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-inline');


  // Default task(s).
  grunt.registerTask('default', ['coffee', 'uglify', 'inline']);
};


