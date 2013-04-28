fs     = require 'fs'
{exec} = require 'child_process'

CoffeeScript = require 'coffee-script'
mkdirp       = require 'mkdirp'

compile = (sourceFile, outFile, executable) ->
  fs.readFile sourceFile, 'utf-8', (error, coffeeCode) ->
    throw error if error

    javaScript = CoffeeScript.compile(coffeeCode)
    javaScript = '#!/usr/bin/env node\n' + javaScript if executable

    # outFile = sourceFile.replace '.coffee', '.js'
    fs.writeFile outFile, javaScript, 'utf8', ->
      if executable
        fs.chmodSync outFile, 0o755

task 'clean', 'remove compiled output', (options) ->
  fs.exists './lib/coffee-dbc.coffee', (exists) ->
    fs.unlink './lib/coffee-dbc.coffee' if exists

task 'build', 'compile coffeescript files', (options) ->
  invoke 'clean'
  mkdirp('./lib')
  compile './src/coffee-dbc.coffee', './lib/coffee-dbc.js'

# http://danneu.com/posts/14-setting-up-mocha-testing-with-coffeescript-node-js-and-a-cakefile/

task "test", "run tests", ->
  exec "NODE_ENV=test
    ./node_modules/.bin/mocha
    --compilers coffee:coffee-script
    --reporter spec
    --require coffee-script
    --require test/test-helper.coffee
    --colors
  ", (err, output) ->
    throw err if err
    console.log output
