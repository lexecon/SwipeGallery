gulp = require "gulp"
debug = require 'gulp-debug'
tap = require 'gulp-tap'
path = require "./pat"





gulp.task 'default', ->
  gulp.src("src/*.coffee")
    .pipe debug {title: 'all coffee file:'}
    .pipe tap (file, t)->
      console.log "#{file} #{t}"
    .pipe gulp.dest("build/")
