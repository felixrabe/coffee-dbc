dbc = exports

dbc.ContractException = class ContractException
  constructor: (@contractName, @partName) ->
    @message = "Contract '#{@contractName}.#{@partName}' was broken"
    @name = 'ContractException'

# Google: custom exception javascript
# => http://stackoverflow.com/q/783818
# and http://stackoverflow.com/a/4728903
dbc.ContractException:: = Error::


dbc.QueryMutationException = class QueryMutationException
  constructor: (@queryName) ->
    @message = "Object state was mutated by query '#{@queryName}'"
    @name = 'QueryMutationException'

dbc.QueryMutationException:: = Error::


# Google: javascript get names of function arguments
# => http://stackoverflow.com/a/9924463
dbc.getFnArgNames = (fn) ->
  s = fn.toString()
  s.slice(s.indexOf('(') + 1, s.indexOf(')')).match(/([^\s,]+)/g)


# Google: javascript clone object
# => http://stackoverflow.com/a/5344074
# => http://jsperf.com/cloning-an-object/2
dbc.clone = (obj) ->
  target = Object.create obj
  for own key, value of obj
    if key == '_innerInstance'
      value = dbc.clone value
    target[key] = value
  target


class Contract
  constructor: (@name, @contractParts) ->
  checkFor: (contractContext) ->
    for own partName, contractFn of @contractParts
      passed = contractFn.apply contractContext
      throw new ContractException @name, partName unless passed


dbc.class = (dbcClassTemplate) ->
  template = dbcClassTemplate()
  constructor = template?.constructor
  invariantContract = new Contract 'invariant', template?.invariant
  queries = template?.queries ? {}
  commands = template?.commands ? {}

  class _InnerClass
    # https://github.com/jashkenas/coffee-script/issues/2961
    constructor: ->
      constructor?.apply @, arguments

  Cls = class
    constructor: (arg...) ->
      @_innerInstance = new _InnerClass(arg...)
      invariantContract.checkFor new: @

  for own queryName, queryFn of queries
    do (queryName, queryFn) ->
      Cls::[queryName] = ->
        old_innerInstance = dbc.clone @_innerInstance
        result = queryFn.apply @_innerInstance
        for own key, value of old_innerInstance
          if value != @_innerInstance[key]
            throw new QueryMutationException queryName
        result

  for own commandName, commandFn of commands
    fnArgNames = dbc.getFnArgNames commandFn
    command = commandFn()
    commandRequireContract = new Contract "#{commandName}.require", command?.require
    commandDo = command?.do
    commandEnsureContract = new Contract "#{commandName}.ensure", command?.ensure
    do (fnArgNames, commandRequireContract, commandDo, commandEnsureContract) ->
      Cls::[commandName] = ->
        args = {}
        args[fnArgNames[i]] = arguments[i] for i in [0...arguments.length]
        commandRequireContract.checkFor args
        args.old = dbc.clone @
        commandDo.apply @_innerInstance, arguments
        args.new = @
        commandEnsureContract.checkFor args, true
        invariantContract.checkFor new: @
        undefined

  Cls
