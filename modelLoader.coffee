_und = require("underscore")
winston = require("winston")

module.exports = class ModelLoader

  autoload: (serv,db, modelpath) ->
    fs = require "fs"
    path = require "path"
 
    winston.info "Loading models from path " + modelpath
    files = fs.readdirSync modelpath
    
    modelNames = _und.map files, (f) -> 
      path.basename f
    _und.each modelNames, (modelName) =>  
       if modelName != undefined
         suffix = ".coffee"
         if modelName.indexOf(suffix, modelName.length - suffix.length) != -1
           modelC = require modelpath + "/" + modelName
           winston.info "Creating mogoose object for: "+modelName
           model = new modelC()        
           @expose(model,serv)
    
  # The expose will introduce its own set of request handler for handling model requests
  expose : (model, serv)->
    collection = model.getCollection()
    winston.info 'ModelLoader: installing request handlers for /'+collection

    serv.get '/'+collection, (req, res) ->
      winston.info 'ModelLoader: GET for  '+collection+' received, sending the collection for '+model.getDBModel().modelName
      model.getDBModel().find({}, (err, docs) -> 
        winston.info "JSON Data", docs
        if err != null
          res.json err, 500
        else
          res.send(docs))

    serv.get '/'+collection+'/:id', (req, res) ->
      winston.info 'ModelLoader: GET received for '+collection+'  model '+req.params.id
      conditions  = { _id: req.params.id }
      model.getDBModel().find(conditions, (err, docs) -> 
        winston.info "JSON Data", docs
        if err != null
          res.json err, 500
        else
          res.send(docs))

    serv.put '/'+collection+'/:id', (req, res) ->
      winston.info 'ModelLoader: PUT received for model '+req.params.id
      winston.info "JSON Data received ", req.body
      conditions  = { _id: req.params.id }
      doc = req.body
      delete doc._id
      model.getDBModel().update conditions, doc,{}, (err, numAffected) -> 
        winston.info 'ModelLoader: Update done on '+numAffected+" row - errors: "+err 
        if err == null 
          res.send(doc)
        else
          res.json err, 500

    serv.del '/'+collection+'/:id', (req, res) ->
      winston.info 'ModelLoader: DELETE received for model '+req.params.id
      conditions  = { _id: req.params.id }
      model.getDBModel().remove conditions, (err, numAffected) -> 
        winston.info 'ModelLoader: Delete done on '+numAffected+" row - errors: "+err 
        if err == null 
          res.json  200
        else
          res.json err, 500    

    serv.post '/'+collection, (req, res) ->
      winston.info 'ModelLoader: POST received for model '+ collection
      winston.info "JSON Data received ", req.body
      conditions  = { _id: req.params.id }
      doc = req.body
      obj = model.newInstance doc 
      winston.info 'ModelLoader: Save to dbmodel '+ model.getModelName()
      obj.save()  
      winston.info 'ModelLoader: New record created'
      winston.info "JSON Data", obj.model
      res.send  obj.model
    
    

  
