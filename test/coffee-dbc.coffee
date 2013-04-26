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
          notTrue: -> false
      (-> new Cls).should.throw "Contract 'invariant.notTrue' failed"

    it 'should provide access to instance variables', ->
      Cls = dbc.class ->
        constructor: (@x) ->
        invariant:
          hasX: -> @new.x?
      (-> new Cls 123).should.not.throw Error
      (-> new Cls).should.throw Error
