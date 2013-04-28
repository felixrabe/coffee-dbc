#!/usr/bin/env coffee

# This is based on the example used in the presentation at:
#   http://www.eiffel.com/developers/presentations/dbc/partone/player.html
# See also: (Google: "design by contract example class time_of_day")
#   http://docs.eiffel.com/book/platform-specifics/design-contract-and-assertions

dbc = require './src/coffee-dbc'

TimeOfDay = dbc.class ->

  constructor: ->
    @hour   = 0
    @minute = 0
    @second = 0

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


coffeeTime = new TimeOfDay()

coffeeTime.setHour 23
console.log coffeeTime.hour()

coffeeTime.setHour 24  # => ContractException: Contract 'setHour.require.validH' was broken
console.log coffeeTime.hour()
