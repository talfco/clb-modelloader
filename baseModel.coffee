# Moongoose based Model
mongoose = require "mongoose"

module.exports = class BaseModel

  constructor: (@modelName,@collection,@schema, props) ->
    @dbModel = mongoose.model(@modelName, @schema,@collection)
    @model = new @dbModel(props)
    @schema.virtual('id').get -> return this._id

    @schema.methods.toBackbone = ->
      obj = this.toObject();
      obj.id = obj._id;
      return obj;

  getModelName: -> @modelName
  
  getCollection: -> @collection

  getDBModel: ->  @dbModel 

  getDBSchema: -> @schema

  save: -> @model.save()

  