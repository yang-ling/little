'use strict';

/**
 * For light development
 * 
 * @author xu_z@worksap.co.jp
 */

module.exports = function (grunt) {

  //load all grunt tasks
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-connect');
  grunt.loadNpmTasks('grunt-contrib-livereload');
  grunt.loadNpmTasks('grunt-open');

  //define tasks
  grunt.registerTask('server', ['connect:server','open:server','watch:mypage']);

  //env cfg
  var cfg = {
    src: 'src/main/webapp/',
    targetPage: 'ctm-jr',
    indexPage: 'create-workspace.html',
    // Change 'localhost' to '0.0.0.0' to access the server from outside.
    serverHost: '0.0.0.0',
    serverPort: 9000,
    livereload: 35729
  };

  //grunt config
  grunt.initConfig({
    cfg: cfg,
    connect: {
      options: {
        port: cfg.serverPort,
        hostname: cfg.serverHost,
        middleware: function (connect, options) {
          return [
            require('connect-livereload')({
              port: cfg.livereload
            }),
            // Serve static files.
            connect.static(options.base),
            // Make empty directories browsable.
            connect.directory(options.base),
          ];
        }
      },
      server: {
        options: {
          // keepalive: true,
          base: cfg.src,
        }
      }
    },

    open: {
      server: {
        url: 'http://localhost:' + cfg.serverPort + '/pages/' + cfg.targetPage + '/' + cfg.indexPage
      }
    },

    watch: {
      mypage: {
        files: [
          'src/main/webapp/pages/' + cfg.targetPage + '/*tmpl.*',
          'src/main/webapp/pages/' + cfg.targetPage + '/**/*.json',
          'src/main/webapp/pages/' + cfg.targetPage + '/less/*.less',
          'src/main/webapp/pages/' + cfg.targetPage + '/js/*.js'
        ],
        tasks: [
          'mypage:def'
        ],
        options: {
          nospawn: true,
          livereload: true
        }
      }
    },
    i18n: {
      def: {}
    },
    // Less Compile
    less: {
      mypage: {
        files: grunt.file.expandMapping([
          'src/main/webapp/pages/' + cfg.targetPage + '*/**/less/*.less'
        ], 'css', {
          rename: function (dest, matched) {
            return matched.replace(/\/less\//, '/' + dest + '/').replace(/\.less$/, '.css');
          }
        })
      },
    }
  });
  grunt.event.on('watch', function (action, filepath) {
    grunt.log.writeln(action + ': ' + filepath);

    grunt.config([
      'less', 'page'
    ], {
      files: grunt.file.expandMapping([
        filepath
      ], 'css', {
        rename: function (dest, matched) {
          return matched.replace(/\/less\//, '/' + dest + '/').replace(/\.less$/, '.css');
        }
      })
    });

    grunt.config([
      'i18n', 'filepath'
    ], filepath);

    grunt.config([
      'mock', 'filepath'
    ], filepath);
  });

  grunt.registerTask('mypage', 'for mypage project', function () {
    var currentFilePath = grunt.config([
      'mock', 'filepath'
    ]);
    var fileExt = currentFilePath.split('.').reverse()[0];
    var taskName = '';

    if ('less' === fileExt) {
      taskName = 'less:mypage';
    } else {
      taskName = 'i18n:def';
    }
    grunt.task.run(taskName);
  });

  grunt
    .registerMultiTask(
      'i18n',
      'i18n task for mock project',
      function () {
        var target = grunt.option('target') || cfg.targetPage;
        var pageName = "";
        // var cache = {};

        if (grunt.option('only')) {
          var currentFilePath = grunt.config([
            'i18n', 'filepath'
          ]);
          var fileExt = currentFilePath.split('.').reverse()[0];
          pageName = currentFilePath.split('\\')[4];

          if (fileExt === 'json') {
            doForExtAll();
          } else {
            doForExt(fileExt);
          }

        } else {
          doForExtAll();
        }

        function doForExtAll() {
          doForExt('html');
          doForExt('js');
          doForExt('json');
        }

        function getDirectoryNameBy(fileExt) {
          var dirName = "";
          switch (fileExt) {
          case 'json':
            dirName = '/data';
            break;
          case 'js':
            dirName = '/js';
            break;
          case 'html':
            dirName = '/template';
            break;
          default:
            // none
          }
          return dirName;
        }

        function doForExt(fileExt) {
          var default_dir = 'src/main/webapp/pages/';
          var targets = [];
          if (grunt.option('only')) {
            targets = grunt.file.expand(default_dir + pageName + getDirectoryNameBy(fileExt) + '/*tmpl.' + fileExt);

            if (fileExt === 'html') {
              Array.prototype.push.apply(targets, grunt.file.expand(default_dir + pageName + '/*tmpl.html'));
            }
          } else {
            targets = grunt.file.expand(default_dir + target + '/**/*tmpl.' + fileExt);
          }

          targets
            .forEach(function (filePath) {
              grunt.log.writeln('converting ' + filePath);
              var template = grunt.file.read(filePath);
              var moduleName = filePath.split('/')[4];
              var singleResourceFilePath = default_dir + moduleName + '/i18n.json';
              var localizedResources = grunt.file.expand({
                filter: function (path) {
                  return path.indexOf('runtime.json') < 0;
                }
              }, default_dir + moduleName + '/localized/**.json');
              var resource = {};
              /*
               * if (cache[moduleName]) { console.log('cache found!' + moduleName); resource =
               * cache[moduleName]; } else
               */
              if (localizedResources.length > 0) {
                localizedResources.forEach(function (filePath) {
                  var lang = filePath.substr(filePath.lastIndexOf('/') + 1, filePath.length).replace('.json',
                    '');
                  resource[lang] = grunt.file.readJSON(filePath);
                });
                if (grunt.file.exists(singleResourceFilePath)) {
                  grunt.log.warn('please remove \'' + singleResourceFilePath + '\' from the project. It is going to be deprecated.');
                }
              } else if (grunt.file.exists(singleResourceFilePath)) {
                grunt.log
                  .warn('!!! Single i18n.json is now being deprecated. Instead, please place pages/hoge/localized/en.json, ja.json and so on.');
                resource = grunt.file.readJSON(singleResourceFilePath);
              } else {
                grunt.log.error('Localization resource file not found. Please place pages/' + moduleName + '/localized/en.json, ja.json and so on.');
              }
              
              for (var lang in resource) {
                grunt.file.write(filePath.replace(new RegExp('tmpl.' + fileExt + '$'), lang + '.' + fileExt),
                  grunt.template.process(template, {
                    data: resource[lang]
                  }));
              }
              // default file is in english
              var enFile = filePath.replace(new RegExp('tmpl.' + fileExt + '$'), 'en' + '.' + fileExt);
              if (!grunt.file.exists(enFile)) {
                grunt.log.warn('Default translated file (' + enFile + ') not found.');
                return false;
              }
              grunt.file.write(filePath.replace(new RegExp('tmpl.' + fileExt + '$'), fileExt), grunt.file
                .read(enFile));
            });
        }
        return true;
      });
};