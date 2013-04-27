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

    it 'should not mutate object state', ->
      Cls = dbc.class ->
        constructor: (@x = 0) ->
        queries: x: -> @x++
      (-> new Cls(2).x()).should.throw dbc.ContractException, \
        "Object state was mutated by query 'x'"


  describe 'Commands', ->

    it 'should be possible and have access to instance variables', ->
      Cls = dbc.class ->
        constructor: -> @internal = 0
        queries: x: -> @internal
        commands:
          addToX: (x) ->
            do: (x) -> @internal += x
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

    it 'should allow for preconditions ("require")', ->
      Cls = dbc.class ->
        constructor: (@internal) ->
        queries: name: -> @internal
        commands:
          setName: (name) ->
            require:
              nameIsNotLongerThan10Characters: -> @name.length <= 10
            do: (name) -> @internal = name
      obj = new Cls 'Felix'
      (-> obj.setName '1234567890').should.not.throw Error
      (-> obj.setName '12345678901').should.throw dbc.ContractException, \
        "Contract 'setName.require.nameIsNotLongerThan10Characters' was broken"
      obj.name().should.not.equal '12345678901'
      obj.name().should.equal '1234567890'

    it 'should allow for postconditions ("ensure")', ->
      Cls = dbc.class ->
        constructor: (@internal) ->
        queries: name: -> @internal
        commands:
          setName: (name) ->
            do: (name) -> @internal_ = name
            ensure:
              actuallySetsName: -> @new.name() == @name
      obj = new Cls 'Felix'
      (-> obj.setName 'Peter').should.throw dbc.ContractException, \
        "Contract 'setName.ensure.actuallySetsName' was broken"

    it 'should provide the previous state in postconditions', ->
      Cls = dbc.class ->
        constructor: (@_x) ->
        queries: x: -> @_x
        commands:
          incrementByOne: ->
            do: -> @_x += 1
            ensure:
              incrementsXByOne: ->
                # typeof @old.x != 'undefined'
                @new.x() == @old.x() + 1
      obj = new Cls(0)
      (-> obj.incrementByOne()).should.not.throw Error


  describe 'Class Invariant', ->

    it 'should be checked after construction', ->
      Cls = dbc.class ->
        constructor: (@internal) ->
        queries: name: -> @internal
        invariant:
          nameIsAString: -> typeof @new.name() == 'string'
      (-> new Cls 5).should.throw dbc.ContractException, \
        "Contract 'invariant.nameIsAString' was broken"
      (-> new Cls 5).should.not.throw \
        "Contract 'nameIsAString' was broken"

    it 'should check for correct values', ->
      Cls = dbc.class ->
        constructor: (@internal) ->
        queries: x: -> @internal
        invariant:
          xIsSmallerThan12: -> @new.x() < 12
      (-> new Cls 5).should.not.throw Error
      (-> new Cls 15).should.throw Error
      (-> new Cls 15).should.throw dbc.ContractException

    it 'should be checked after every command call', ->
      Cls = dbc.class ->
        constructor: (@internal) ->
        queries: name: -> @internal
        invariant:
          nameIsAString: -> typeof @new.name() == 'string'
        commands:
          setName: (name) ->
            do: (name) -> @internal = name
      obj = null
      (-> new Cls).should.throw dbc.ContractException
      (-> new Cls 5).should.throw dbc.ContractException
      (-> obj = new Cls 'Heinz').should.not.throw dbc.ContractException
      (-> obj.setName 5).should.throw dbc.ContractException, /nameIsAString/


  describe '#getFnArgNames', ->

    it 'should get the list of argument names', ->
      should.not.exist dbc.getFnArgNames ->
      (dbc.getFnArgNames (alabama) ->).should.deep.equal ['alabama']
      (dbc.getFnArgNames (a, b, c = 5) ->).should.deep.equal ['a', 'b', 'c']
      should.not.exist dbc.getFnArgNames (a, b, c...) ->  # CoffeeScript uses arguments here


  describe 'Time Of Day Example', ->

    it 'reduced example 1 should work', ->
      TimeOfDay = dbc.class ->
        constructor: ->
          @hour = 0

        queries:
          hour: -> @hour

        commands:
          setHour: (h) ->
            require: validH: -> 0 <= @h <= 23
            do: (h) -> @hour = h
            ensure: hourSet: -> @new.hour() == @h

      coffeeTime = new TimeOfDay();
      (-> coffeeTime.setHour 23).should.not.throw Error
      (-> coffeeTime.setHour 24).should.throw dbc.ContractException

    it 'reduced example 2 should work', ->
      TimeOfDay = dbc.class ->

        constructor: ->
          @hour   = 5

        queries:

          hour:   -> @hour
          minute: -> @minute

        commands:

          setHour: (h) ->
            require:
              validH: -> 0 <= @h <= 23
            do: (h) -> @hour = h
            ensure:
              hourSet:         -> @new.hour()   == @h
              minuteUnchanged: -> @new.minute() == @old.minute()

          setMinute: (m) ->
            require:
              validM: -> 0 <= @m and @m <= 59
            do: (m) -> @minute = m
            ensure:
              minuteSet:       -> @new.minute() == @m
              hourUnchanged:   -> @new.hour()   == @old.hour()

      coffeeTime = new TimeOfDay();
      coffeeTime.hour().should.equal 5
      (-> coffeeTime.setHour 23).should.not.throw Error
      coffeeTime.hour().should.equal 23
      (-> coffeeTime.setHour 24).should.throw dbc.ContractException

    it 'full example should work', ->
      TimeOfDay = dbc.class ->

        constructor: ->
          @hour   = 2
          @minute = 3
          @second = 4

        queries:

          hour:   -> @hour
          minute: -> @minute
          second: -> @second

        commands:

          setHour: (h) ->
            require:
              validH: -> 0 <= @h <= 23
            do: (h) -> @hour = h
            ensure:
              hourSet:         -> @new.hour()   == @h
              minuteUnchanged: -> @new.minute() == @old.minute()
              secondUnchanged: -> @new.second() == @old.second()

          setMinute: (m) ->
            require:
              validM: -> 0 <= @m and @m <= 59
            do: (m) -> @minute = m
            ensure:
              minuteSet:       -> @new.minute() == @m
              hourUnchanged:   -> @new.hour()   == @old.hour()
              secondUnchanged: -> @new.second() == @old.second()

          setSecond: (s) ->
            do: (s) -> @second = s

      coffeeTime = new TimeOfDay();
      coffeeTime.hour().should.equal 2
      (-> coffeeTime.setHour 23).should.not.throw Error
      coffeeTime.hour().should.equal 23
      (-> coffeeTime.setHour 24).should.throw dbc.ContractException
      coffeeTime.minute().should.equal 3
      (-> coffeeTime.setMinute 59).should.not.throw Error
      coffeeTime.minute().should.equal 59
      (-> coffeeTime.setHour 60).should.throw dbc.ContractException
