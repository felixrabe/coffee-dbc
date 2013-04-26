should = require('chai').should()
dbc = require '../src/coffee-dbc'

describe 'Design By Contract', ->

  describe '#class', ->

    it 'should return a class', ->
      Cls = dbc.class ->
      new Cls

    it 'should allow for a constructor', ->
      Cls = dbc.class ->
        constructor: (@x) ->
      obj = new Cls(24)

    it 'should not allow direct access to instance variables', ->
      Cls = dbc.class ->
        constructor: (@x) ->
      obj = new Cls(24)
      should.not.exist obj.x

  describe 'Queries', ->

    it 'should be possible', ->
      Cls = dbc.class ->
        queries:
          x: -> 24
      obj = new Cls
      obj.x().should.equal 24

    it 'should have access to instance variables', ->
      Cls = dbc.class ->
        constructor: (@x) ->
        queries: x: -> @x * 2
      new Cls(5).x().should.equal 10

  describe 'Commands', ->

    it 'should be possible and have access to instance variables', ->
      Cls = dbc.class ->
        constructor: -> @internal = 0
        queries: x: -> @internal
        commands:
          addToX: (x) ->
            do: (x) ->
              @internal += x
      obj = new Cls
      obj.x().should.equal 0
      obj.addToX(33)
      obj.x().should.equal 33
      obj.addToX(15)
      obj.x().should.equal 48

    it 'should be forced to return undefined', ->
      Cls = dbc.class ->
        commands:
          justChangeSomething: ->
            do: -> return 'a value'
      should.not.exist new Cls().justChangeSomething()

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

  describe '#getFnArgNames', ->

    it 'should get the list of argument names', ->
      should.not.exist dbc.getFnArgNames ->
      (dbc.getFnArgNames (alabama) ->).should.deep.equal ['alabama']
      (dbc.getFnArgNames (a, b, c = 5) ->).should.deep.equal ['a', 'b', 'c']
      should.not.exist dbc.getFnArgNames (a, b, c...) ->  # CoffeeScript uses arguments here
