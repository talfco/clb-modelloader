## Overview

The clb-modelloader is a small utility which is loading moongoose model definition files from a file directory location into a nodejs server instance and and automatically creates corresponding REST request handlers for handling the Create, Read, Update and Delete (CRUD) operations.

The request handlers are expecting a JSON document and will take over the persistency interaction part with the moongoose library.

The library can be easily integrated with a client side Backbone model which results in a transparent handling of the DB interactions for CRUD operations in a Backbone backed Web Application.

Because REST is an architectural style and not a strict standard, it allows for a lot of flexibility. The library will make sure that each model will offer an interface which is following the same API design principles.

The library can be easily integrated with a client side Backbone model which results in a transparent handling of the DB interactions for CRUD operations in a Backbone backed Web Application.

## Documentation

For a detailled documentation refer to [http://cloudburo.github.com/docs/opensource/clb-modelloader/](http://cloudburo.github.com/docs/opensource/clb-modelloader)



