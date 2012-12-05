# node-pocket
  `node-pocket` is an API wrapper for https://getpocket.com service.

  This project designed by current api docs: http://getpocket.com/developer/


## Installation
   
```bash
npm install node-pocket
```

## Using node-pocket
   
   For using this wrapper you need to create `Pocket` class instanse from main module, passing
   to it valid `consumer_key` and `access_token` fetched from user.
   

### Fetching access_token

  First of all we need to get request token, by calling `getRequestToken`. The `url` key must contain valid callback url for our application. You may set parameter redirect to "ios" for approving from native iOS app, but first read this: http://getpocket.com/developer/docs/authentication

```coffee-script  
    Pocket = require "node-pocket"
    consumer_key = "12345-102a2012b..23d" # set yours
    p = new Pocket consumer_key
    p.getRequestToken url: "http://127.0.0.1:8080/get-access-token", (err, result) ->
      unless err
        # save result.code in session, e.g.
        req.session.code = result.code
        # redirect to result.redirectUrl
      else
        # proceed error
```

After approving of deniying permissions, user redirects to `url`, specified as `getRequestToken` parameter. Then you must proceed this url and try to get access token:

```coffee-script
    ...
    p = new Pocket consumer_key
    code = req.session.code
    p.getAccessToken code: code, (err, data) ->
      unless err
        # save data.access_token
      else
        # proceed error
```

After saving access_token, you may use other api methods

### Using API
   Each of callback function accept 2 parameters:

   1) Error code, null if no errors
   2) Result - a json object

#### `get(opts, fn)` [Official docs](http://getpocket.com/developer/docs/v3/retrieve)

  Search and filter items. 
  
  - `opts`              - Options for searching and filter results
  - `fn(err, result)`   - callback function

  
  Example:
  
```coffee-script
    ...
    p = new Pocket consumer_key, access_token
    p.get {sort: "newest", count: 10}, (err, data) ->
      # proceed error/data    
```

#### `add(opts, fn)` [Official docs](http://getpocket.com/developer/docs/v3/add)

  Add a single item to pocket.  

  - `opts`              - Options for searching and filter results
  - `fn(err, result)`   - callback function

  Example

```coffee-script
    ...
    p = new Pocket consumer_key, access_token
    p.add url: "http://getpocket.com/developer/docs/v3/add", tags: "pocket, api, add", (err, data) ->
      # proceed error/data
```

  For multiple additions use `modify` method.

#### `modify(opts, fn)`  [Official docs](http://getpocket.com/developer/docs/v3/modify)

  Create new item(s), update item tags, archive/delete, favorite or unfavorite item(s).

  - `opts`              - Options for searching and filter results
  - `fn(err, result)`   - callback function


```coffee-script
    ...
    ...
    p = new Pocket consumer_key, access_token
    p.modify actions: [action: "tags_replace", tags: ["pocket", "awesome", "api"], item_id: "00000000", (err, data) ->
      # proceed error/data
      
```

Detailed options description in [source code](https://github.com/selead/node-pocket/blob/master/index.coffee)


## License

The MIT License (MIT)
Copyright (c) 2012 Kirill Temnov

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
