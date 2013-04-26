should = require('chai').should()
dbc = require '../src/coffee-dbc'

describe 'Design By Contract', ->

  it 'should return a class', ->
    Cls = dbc.class ->
    new Cls

  it 'should allow for a constructor' #, ->
    # Cls = dbc.class ->
    #   constructor: (@x) ->
    # obj = new Cls(24)
    # obj.x.should.equal 24

  it 'should only allow access to instance variables via queries', ->
    Cls = dbc.class ->
      constructor: (@x) ->
    obj = new Cls(24)
    should.not.exist obj.x

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
      (-> new Cls 123).should.not.throw dbc.ContractException
      (-> new Cls).should.throw dbc.ContractException

    it 'should check for correct values', ->
      Cls = dbc.class ->
        constructor: (@x) ->
        invariant:
          xIsSmallerThan12: -> @new.x < 12
      (-> new Cls 5).should.not.throw dbc.ContractException
      (-> new Cls 15).should.throw dbc.ContractException

  describe 'getFnArgNames', ->

    it 'should get the list of argument names', ->
      should.not.exist dbc.getFnArgNames ->
      (dbc.getFnArgNames (alabama) ->).should.deep.equal ['alabama']
      (dbc.getFnArgNames (a, b, c = 5) ->).should.deep.equal ['a', 'b', 'c']
      should.not.exist dbc.getFnArgNames (a, b, c...) ->  # CoffeeScript uses arguments here
