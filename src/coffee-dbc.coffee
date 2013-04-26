exports.ContractException = class ContractException
  constructor: (@name, @partName) ->
    @message = "Contract '#{@name}.#{@partName}' was broken"
    @name = 'ContractException'

ContractException:: = new Error


# Google: javascript get names of function arguments
# => http://stackoverflow.com/a/9924463
exports.getFnArgNames = getFnArgNames = (fn) ->
  s = fn.toString()
  s.slice(s.indexOf('(') + 1, s.indexOf(')')).match(/([^\s,]+)/g)


class Contract
  constructor: (@name, @contractParts) ->
  checkFor: (contractContext) ->
    for partName of @contractParts
      contractFn = @contractParts[partName]
      passed = contractFn.apply contractContext
      throw new ContractException @name, partName unless passed


exports.class = (dbcClassTemplate) ->
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

  for queryName of queries
    queryFn = queries[queryName]
    Cls::[queryName] = -> queryFn.apply @_innerInstance

  for commandName of commands
    commandFn = commands[commandName]
    fnArgNames = getFnArgNames commandFn
    command = commandFn()
    commandRequireContract = new Contract "#{commandName}.require", command?.require
    commandDo = command?.do
    commandEnsureContract = new Contract "#{commandName}.ensure", command?.ensure
    Cls::[commandName] = ->
      args = {}
      args[fnArgNames[i]] = arguments[i] for i in [0...arguments.length]
      commandRequireContract.checkFor args
      commandDo.apply @_innerInstance, arguments
      args.new = @
      commandEnsureContract.checkFor args
      invariantContract.checkFor new: @
      undefined

  Cls
