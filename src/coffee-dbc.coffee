exports.class = (dbcClassTemplate) ->
  dbcClassTemplate = dbcClassTemplate()
  constructor = dbcClassTemplate?.constructor

  class
    # https://github.com/jashkenas/coffee-script/issues/2961
    constructor: -> constructor?.apply @, arguments

