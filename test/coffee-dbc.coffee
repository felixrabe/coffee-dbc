require('chai').should()
dbc = require '../src/coffee-dbc'

describe 'Design By Contract', ->

  it 'should return a class', ->
    Cls = dbc.class ->
    new Cls
