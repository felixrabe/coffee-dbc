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

  describe 'Class Invariant', ->
    it 'should be checked after construction', ->
      Cls = dbc.class ->
        invariant:
          something: -> false
      (-> new Cls).should.throw Error

    it 'should provide access to instance variables' #, ->
      # Cls = dbc.class ->
      #   invariant:
      #     hasX: -> @new.x?
