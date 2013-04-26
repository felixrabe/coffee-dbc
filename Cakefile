# http://danneu.com/posts/14-setting-up-mocha-testing-with-coffeescript-node-js-and-a-cakefile/

{exec} = require "child_process"

REPORTER = "spec"

task "test", "run tests", ->
  exec "NODE_ENV=test
    ./node_modules/.bin/mocha
    --compilers coffee:coffee-script
    --reporter #{REPORTER}
    --require coffee-script
    --require test/test-helper.coffee
    --colors
  ", (err, output) ->
    throw err if err
    console.log output
