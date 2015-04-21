module.exports = function(grunt) {
  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    uglify: {
      options : {
        wrap: 'quine'
      },
      files: {
        src: 'src/js/quine.js',
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

  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-html-smoosher-install-fix');

  // Default task(s).
  grunt.registerTask('default', ['uglify', 'smoosher']);

};

