class Contract
  constructor: (@name, @contractParts) ->
  checkFor: (instance) ->
    for partName of @contractParts
      contract = @contractParts[partName]()
      passed = contract()
      throw { name: 'ContractException', message: "Contract '#{@name}.#{partName}' failed" } unless passed

exports.class = (dbcClassTemplate) ->
  template = dbcClassTemplate()
  constructor = template?.constructor
  invariant = new Contract 'invariant', template?.invariant

  class
    # https://github.com/jashkenas/coffee-script/issues/2961
    constructor: ->
      constructor?.apply @, arguments
      invariant.checkFor @

