## Overview

The clb-modelloader is a small utility which is loading moongoose model definition files from a file directory location into a nodejs server instance and automatically creates corresponding request handlers for

* GET operations: retrieving data
* POST operations: creating a new record
* PUT operations: updating a record
* DELETE operations: delete a record

The request hanlder are expecting a JSON document and will take over the persistency interaction part with the moongoose library.

The library can be easily integrated with a client side Backbone model which results in a transparent handling of the DB interactions for CRUD operations in a Backbone backed Web Application.

## Documentation

For a detailled documentation refer to [http://cloudburo.github.com/docs/opensource/clb-modelloader/](http://cloudburo.github.com/docs/opensource/clb-modelloader)



