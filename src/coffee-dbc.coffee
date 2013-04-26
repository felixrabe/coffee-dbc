exports.class = (dbcClassTemplate) ->
  dbcClassTemplate = dbcClassTemplate()
  constructor = dbcClassTemplate?.constructor

  class
    # constructor: dbcClassTemplate()?.constructor  # CoffeeScript compiles to JS code that tries to call undefined
    constructor: -> constructor?.apply @, arguments

