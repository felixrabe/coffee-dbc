require('chai').should()
dbc = require '../src/coffee-dbc'

describe 'Design By Contract', ->

  it 'should return a class', ->
    Cls = dbc.class ->
    new Cls

  it 'should allow a constructor', ->
    Cls = dbc.class ->
      constructor: (@x) ->
    obj = new Cls(24)
    obj.x.should.equal 24
