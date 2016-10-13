'use strict';

module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    swf: {
      src: 'src/as/VideoJSOSMF.as',
      dest: 'dist/videojs-osmf.swf',
      version: '<%= pkg.version %>'
    },

    shell: {
      mxmlc: {
        command: './compiler/bin/mxmlc -define+=CONFIG::VERSION,1 -define+=CONFIG::FLASH_10_1,true -define+=CONFIG::LOGGING,true -define+=CONFIG::PLATFORM,true -define+=CONFIG::MOCK,false -define+=CONFIG::DASH,true -library-path+=libs/ <%= swf.src %> -o <%= swf.dest %>',
        options: {
          callback: function (err, stdout, stderr, cb) {
            if (err) {
              grunt.log.error(stderr);
            }
            grunt.log.writeln(stdout);
            cb();
          }
        }
      }
    },

    connect: {
      dev: {
        options: {
          port: 1234,
          keepalive: true
        }
      }
    },

    open : {
      dev : {
        path: 'http://localhost:<%= connect.dev.options.port %>/example.html',
        app: 'Google Chrome'
      }
    },

    watch: {
      as: {
        files: ['src/as/**/*.as'],
        tasks: ['shell:mxmlc']
      },
      grunt: {
        files: ['Gruntfile.js'],
        tasks: ['shell:mxmlc']
      },
      js: {
        files: ['src/**/*.js', 'Gruntfile.js'],
        tasks: ['jshint']
      }
    },

    browserify: {
      development: {
        src: [
          './src/js/videojs5-osmf-controller-es6.js'
        ],
        dest: './dist/videojs5-osmf-controller-standalone.js',
        options: {
          browserifyOptions: {
            debug: true,
            watch: true,
            keepAlive: false,
            standalone: 'videojs5-osmf-controller-standalone'
          },
          transform: [
            ["babelify", {
              loose: "all"
            }]
          ]
        }
      }
    },

    babel: {
      options: {
        sourceMap: false,
        presets: ['es2015']
      },
      dist: {
        files: [{
          expand: true,
          cwd: 'src',
          src: ['**/js/videojs5-osmf-controller-es6.js'],
          dest: 'dist/lib',
          ext:'.js'
        }]
      }
    },

    concurrent: {
      dev: {
        tasks: ['connect:dev', 'open', 'watch'],
        options: {
          logConcurrentOutput: true
        }
      }
    }
  });

  // Load Grunt tasks.
  require('load-grunt-tasks')(grunt);

  // Default task.
  grunt.registerTask('default', ['build', 'browserify', 'babel']);
  grunt.registerTask('dev', 'Launching Dev Environment', ['build','concurrent:dev']);
  grunt.registerTask('build', ['shell:mxmlc']);

};
