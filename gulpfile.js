const gulp = require("gulp");
const uglify = require("gulp-uglify");
const babel = require("gulp-babel");
const argv = require('minimist')(process.argv.slice(2));
const babelOptions = require('./babel.config.js');

gulp.task('appboard-dev', () => {
    return gulp.src(argv.filePath || './common/dist/appboard/*.js')
        .pipe(babel(babelOptions))
        .pipe(gulp.dest('./common/dist/appboard'));
});

gulp.task('appboard-build', () => {
    return gulp.src('./common/dist/appboard/*.js')
        .pipe(babel(babelOptions))
        .pipe(uglify())
        .pipe(gulp.dest('./common/dist/appboard'));
});

gulp.task('default', gulp.parallel('appboard-dev'));