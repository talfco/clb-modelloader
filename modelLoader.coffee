_und = require "underscore"
mongoose = require "mongoose"

module.exports = class ModelLoader

  constructor: (@dbPath,@version,@winston,@errDocUrl) ->
    mongoose.connect(@dbPath)  
  
  autoload: (serv,modelpath) ->
    fs = require "fs"
    path = require "path"
 
    @winston.info "Loading models from path " + modelpath
    files = fs.readdirSync modelpath
    
    modelNames = _und.map files, (f) -> 
      path.basename f
    _und.each modelNames, (modelName) =>  
       if modelName != undefined
         suffix = ".coffee"
         if modelName.indexOf(suffix, modelName.length - suffix.length) != -1
           modelC = require modelpath + "/" + modelName
           @winston.info "Creating mogoose object for: "+modelName
           model = new modelC({winston: @winston})        
           @expose(model,serv) 
    
  # The expose will introduce its own set of request handler for handling model requests
  expose : (model, serv)->
    collection = model.getCollection()
    @winston.info 'ModelLoader: installing request handlers for /'+collection

    serv.get '/'+@version+'/'+collection, (req, res) =>
      @winston.info 'ModelLoader: GET for  '+collection+' received, sending the collection for '+model.getDBModel().modelName
      skipC = 0;
      projection = undefined
      
      if req.query["offset"] != undefined
        skipC = parseInt req.query["offset"]
        @winston.info "Query Parameter 'offset' provided with value "+skipC
        if isNaN(skipC)
          @.createJSONErrMsg res, 400, 
            'Bad Request Query Parameter provided to the clb-modelloader API for "'+model.getCollection()+'": "offset" parameter is not at number',
            '0001',@errDocUrl+'0001'     
          return        
      if req.query["fields"] != undefined
        projection = {}
        _und.each req.query["fields"].split(","), (elem, index, list) ->
          projection[elem] = 1
        @winston.info("Got projection "+projection)

      if req.query["maxRec"] != undefined
        @winston.info "No count query necessary"
        maxRec = parseInt req.query["maxRec"]
        @winston.info "Query Parameter 'maxRec' provided with value "+maxRec
        if isNaN(maxRec)
          @.createJSONErrMsg res, 400,
            'Bad Request Query Parameter provided to the clb-modelloader API for "'+model.getCollection()+'": "maxRec" parameter is not at number',
            '0002',@errDocUrl+'0002'    
          return
        @getCollection res,model,skipC,maxRec,projection
      else
        query = model.getDBModel().find({})
        query.count  (err, count) => 
          @winston.info "Number of records "+count+" skip "+skipC
          @getCollection res,model,skipC,count,projection
        
    serv.get '/'+@version+'/'+collection+'/:id', (req, res) =>
      @winston.info 'ModelLoader: GET received for '+collection+'  model '+req.params.id
      conditions  = { _id: req.params.id }
      model.getDBModel().find(conditions, (err, docs) => 
        @winston.info "JSON Data", docs
        if err != null
          @.createJSONErrMsg res, 500, 
            'There was a technical error when requesting an entity "'+model.getCollection()+'":'+err,
            '0100',@errDocUrl+'0100' 
        else
          res.send(docs))

    serv.put '/'+@version+'/'+collection+'/:id', (req, res) =>
      @winston.info 'ModelLoader: PUT received for model '+req.params.id
      @winston.info "JSON Data received ", req.body
      conditions  = { _id: req.params.id }
      doc = req.body
      delete doc._id
      model.getDBModel().update conditions, doc,{}, (err, numAffected) => 
        @winston.info 'ModelLoader: Update done on '+numAffected+" row - errors: "+err 
        if err == null 
          res.send(doc)
        else
          @.createJSONErrMsg res, 500, 
            'There was a technical error when updating an entity "'+model.getCollection()+'":'+err,
            '0100',@errDocUrl+'0100'

    serv.del '/'+@version+'/'+collection+'/:id', (req, res) =>
      @winston.info 'ModelLoader: DELETE received for model '+req.params.id
      conditions  = { _id: req.params.id }
      model.getDBModel().remove conditions, (err, numAffected) => 
        @winston.info 'ModelLoader: Delete done on '+numAffected+" row - errors: "+err 
        if err == null 
          res.json  200
        else
          res.json err, 500    

    serv.post '/'+@version+'/'+collection, (req, res) =>
      @winston.info 'ModelLoader: POST received for model '+ collection
      @winston.info "JSON Data received ", req.body
      conditions  = { _id: req.params.id }
      doc = req.body
      @winston.info 'ModelLoader: Creating new instance for '+ model.getModelName()
      dbModel = model.getDBModel()
      obj = new dbModel(doc)
      obj.save() 
      @winston.info 'ModelLoader: New record created'
      @winston.info obj
      res.send  obj
    
  createJSONErrMsg:  (res, statusCode, usrMsg, errCode, moreInfo) ->
    errMsg = { 
      'message' : usrMsg,
      'errorCode' : errCode,
      'moreInfo' : moreInfo 
    }
    res.json errMsg, statusCode

  getCollection: (res,model,skipC,count,projection) ->  
    @winston.info "Got projection '"+projection+"'"
    query = model.getDBModel().find({},projection).limit(model.getQueryLimit()).skip(skipC).sort({"_id":-1})  
    query.exec {}, (err, docs) => 
      @winston.info "Fetched records with skip "+skipC
      countStr =  count+''
      limitStr = model.getQueryLimit()+''
      skipStr = skipC+''
      docs.push( _maxRec: countStr, _limit: limitStr, _offset: skipStr);
      if err != null
        @.createJSONErrMsg res, 500,
          'There was a technical error when requesting entities "'+model.getCollection()+'":'+err,
          '0100',@errDocUrl+'0100'
      else
        res.send(docs)

  
