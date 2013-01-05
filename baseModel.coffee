# Moongoose based Model
mongoose = require "mongoose"

module.exports = class BaseModel

  constructor: (@modelName,@collection,schemaJSON,props) ->
    
    if props.winston != undefined
      props.winston.info "BaseModel: "+ @modelName+" - "+@collection, schemaJSON
    @schema = new mongoose.Schema schemaJSON
    @dbModel = mongoose.model(@modelName, @schema,@collection)
    if props.doc != undefined
      @model = new @dbModel(props.doc)
    else
      @model = new @dbModel()
    if props.querylimit != undefined
      @queryLimit = props.queryLimit
    else
      @queryLimit = 20
    
    @schema.virtual('id').get -> return this._id

    @schema.methods.toBackbone = ->
      obj = this.toObject();
      obj.id = obj._id;
      return obj;

  getModelName: -> @modelName
  
  getCollection: -> @collection

  getDBModel: ->  @dbModel 

  getDBSchema: -> @schema

  getQueryLimit: -> @queryLimit

  save: -> @model.save()
  


  