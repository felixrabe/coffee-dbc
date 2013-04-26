class ContractContext
  constructor: (@new) ->

exports.ContractException = ContractException = (@message) -> @name = 'ContractException'
ContractException:: = new Error

class Contract
  constructor: (@name, @contractParts) ->
  checkFor: (instance) ->
    ctx = new ContractContext instance
    for partName of @contractParts
      contract = @contractParts[partName]
      passed = contract.apply ctx
      throw new ContractException "Contract '#{@name}.#{partName}' failed" unless passed

exports.class = (dbcClassTemplate) ->
  template = dbcClassTemplate()
  constructor = template?.constructor
  invariant = new Contract 'invariant', template?.invariant

  class
    # https://github.com/jashkenas/coffee-script/issues/2961
    constructor: ->
      constructor?.apply @, arguments
      invariant.checkFor @

