//// Note the new way of requesting CoffeeScript since 1.7.x
//require('coffee-script/register');
//// This bootstraps your Gulp's main file
//require('./gulpfile.coffee');


var gulp = require("gulp"),
debug = require('gulp-debug'),
tap = require('gulp-tap'),
pat = require("./pat")





gulp.task('default', function(){
  gulp.src("src/*.coffee")
    .pipe(debug({title: 'all coffee file:'}))
    .pipe(tap(function(file, t){
      console.log("#{file} #{t}")
    }))
    .pipe(gulp.dest("build/"))
})
