exports.ContractException = ContractException = (@message) -> @name = 'ContractException'

ContractException:: = new Error


# Google: javascript get names of function arguments
# => http://stackoverflow.com/a/9924463
exports.getFnArgNames = (fn) ->
  s = fn.toString()
  s.slice(s.indexOf('(') + 1, s.indexOf(')')).match(/([^\s,]+)/g)


class ContractContext
  constructor: (@new) ->


class Contract
  constructor: (@name, @contractParts) ->
  checkFor: (instance) ->
    ctx = new ContractContext instance
    for partName of @contractParts
      contractFn = @contractParts[partName]
      passed = contractFn.apply ctx
      throw new ContractException "Contract '#{@name}.#{partName}' failed" unless passed


exports.class = (dbcClassTemplate) ->
  template = dbcClassTemplate()
  constructor = template?.constructor
  invariant = new Contract 'invariant', template?.invariant
  queries = template?.queries ? {}

  class _InnerClass
    # https://github.com/jashkenas/coffee-script/issues/2961
    constructor: ->
      constructor?.apply @, arguments

  Cls = class
    constructor: (arg...) ->
      @_innerInstance = new _InnerClass(arg...)
      invariant.checkFor @_innerInstance

  for queryName of queries
    queryFn = queries[queryName]
    Cls::[queryName] = -> queryFn.apply @_innerInstance

  Cls
