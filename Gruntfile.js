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
      files: {
        src: 'built/quine.js',
        dest: 'built/quine.js'
      },
    },
    smoosher: {
      files: {
        src: 'src/quine.html',
        dest: 'built/smoosher/quine.html'
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-html-smoosher-install-fix');

  // Default task(s).
  grunt.registerTask('default', ['coffee', 'uglify', 'smoosher']);

};

