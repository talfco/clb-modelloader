// Generated by CoffeeScript 1.4.0
(function() {
  var ModelLoader, mongoose, _und;

  _und = require("underscore");

  mongoose = require("mongoose");

  module.exports = ModelLoader = (function() {

    function ModelLoader(dbPath, winston) {
      this.dbPath = dbPath;
      this.winston = winston;
      mongoose.connect(this.dbPath);
    }

    ModelLoader.prototype.autoload = function(serv, modelpath) {
      var files, fs, modelNames, path,
        _this = this;
      fs = require("fs");
      path = require("path");
      this.winston.info("Loading models from path " + modelpath);
      files = fs.readdirSync(modelpath);
      modelNames = _und.map(files, function(f) {
        return path.basename(f);
      });
      return _und.each(modelNames, function(modelName) {
        var model, modelC, suffix;
        if (modelName !== void 0) {
          suffix = ".coffee";
          if (modelName.indexOf(suffix, modelName.length - suffix.length) !== -1) {
            modelC = require(modelpath + "/" + modelName);
            _this.winston.info("Creating mogoose object for: " + modelName);
            model = new modelC({
              winston: _this.winston
            });
            return _this.expose(model, serv);
          }
        }
      });
    };

    ModelLoader.prototype.expose = function(model, serv) {
      var collection,
        _this = this;
      collection = model.getCollection();
      this.winston.info('ModelLoader: installing request handlers for /' + collection);
      serv.get('/' + collection, function(req, res) {
        var query;
        _this.winston.info('ModelLoader: GET for  ' + collection + ' received, sending the collection for ' + model.getDBModel().modelName);
        query = model.getDBModel().find({});
        return query.count(function(err, count) {
          _this.winston.info("Number of records ", count);
          query = model.getDBModel().find().limit(20).sort({
            "_id": 1
          });
          return query.exec({}, function(err, docs) {
            var countStr;
            countStr = count + '';
            _this.winston.info("Docs", docs);
            _this.winston.info("Err", err);
            docs.push({
              _maxRec: countStr,
              _limit: '10',
              _offset: '0'
            });
            _this.winston.info("JSON Data", docs);
            if (err !== null) {
              return res.json(err, 500);
            } else {
              return res.send(docs);
            }
          });
        });
      });
      serv.get('/' + collection + '/:id', function(req, res) {
        var conditions;
        _this.winston.info('ModelLoader: GET received for ' + collection + '  model ' + req.params.id);
        conditions = {
          _id: req.params.id
        };
        return model.getDBModel().find(conditions, function(err, docs) {
          _this.winston.info("JSON Data", docs);
          if (err !== null) {
            return res.json(err, 500);
          } else {
            return res.send(docs);
          }
        });
      });
      serv.put('/' + collection + '/:id', function(req, res) {
        var conditions, doc;
        _this.winston.info('ModelLoader: PUT received for model ' + req.params.id);
        _this.winston.info("JSON Data received ", req.body);
        conditions = {
          _id: req.params.id
        };
        doc = req.body;
        delete doc._id;
        return model.getDBModel().update(conditions, doc, {}, function(err, numAffected) {
          _this.winston.info('ModelLoader: Update done on ' + numAffected + " row - errors: " + err);
          if (err === null) {
            return res.send(doc);
          } else {
            return res.json(err, 500);
          }
        });
      });
      serv.del('/' + collection + '/:id', function(req, res) {
        var conditions;
        _this.winston.info('ModelLoader: DELETE received for model ' + req.params.id);
        conditions = {
          _id: req.params.id
        };
        return model.getDBModel().remove(conditions, function(err, numAffected) {
          _this.winston.info('ModelLoader: Delete done on ' + numAffected + " row - errors: " + err);
          if (err === null) {
            return res.json(200);
          } else {
            return res.json(err, 500);
          }
        });
      });
      return serv.post('/' + collection, function(req, res) {
        var conditions, dbModel, doc, obj;
        _this.winston.info('ModelLoader: POST received for model ' + collection);
        _this.winston.info("JSON Data received ", req.body);
        conditions = {
          _id: req.params.id
        };
        doc = req.body;
        _this.winston.info('ModelLoader: Creating new instance for ' + model.getModelName());
        dbModel = model.getDBModel();
        obj = new dbModel(doc);
        obj.save();
        _this.winston.info('ModelLoader: New record created');
        _this.winston.info(obj);
        return res.send(obj);
      });
    };

    return ModelLoader;

  })();

}).call(this);
