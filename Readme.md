# node-pocket
  `node-pocet` is an API wrapper for https://getpocket.com service.

  This project designed by current api docs: http://getpocket.com/api/docs


## Installation
   
```bash
npm install node-pocket
```

## Using
   
   For using this wrapper you need to create `Pocket` class instanse from main module, passing
   to it valid username, password and *your api key*.
   

## Documentation

   For detailed explanation of error codes see http://getpocket.com/api/docs/#response.

   Any request, that return code 200 considered successfull.

   Each of callback function accept 2 parameters:

   1) Error code, null if no errors
   2) Result - a json object

   Before call any method, we create instance:

```coffee-script
p = new (require "node-pocket").Pocket "<USERNAME>", "<PASSWORD>", "<APIKEY>"
```

   List of methods

   - [auth](#auth)
   - [signup](#signup)
   - [add](#add)
   - [stats](#stats)
   - [apiInfo](#apiInfo)
   - [get](#get)
   - [new](#new)
   - [read](#read)
   - [updateTitle](#updateTitle)
   - [updateTags](#updateTags)


<a name='auth'>
### auth(fn)   

  Authenticate user with password

```coffee-script
p.auth (err, ok) ->
  if not err and ok
     console.log "auth successfull"
  else
     console.log "auth fail"
```

<a name='signup'>
### signup(new_username, password, fn)

  Signup new user. This call will be successfull only for unique usernames.

```coffee-script
p = new (require "node-pocket").Pocket null, null, "<APIKEY>"
p.signup "uname", "password, "<APIKEY>", (err, ok) ->
  if not err and ok
     console.log "new user created"
  else
     console.log "error creating new user"
```


  *this method was designed according api docs, but not tested yet!*

<a name='add'>
### add(url, title, [ref_id], fn)
    
  Add new url to pocket, accept single page data, for batch adding use [send](#send) method.

  Parameter ref_id must be set for twitter client, see more: http://getpocket.com/api/docs/#add_ref_id
  
```coffee-script
p.add "http://getpocket.com/", "Pocket main page", (err, ok) ->
  if not err and ok
     console.log "page added
  else
     console.log "page adding error"
```

  Note, that title that accessible by api may not match with title, that visible on
  page http://getpocket.com/a/queue/

<a name='stats'>
### stats(fn)

  Get statistics by user.

```coffee-script
p.stats, (err, statObj) ->
  unless err
     console.log "user stats: #{JSON.stringify statObj, null, 2}
  else
     console.log "error fetching stat"
```

<a name='apiInfo'>
### apiInfo(fn) 

  Get limits for application

```coffee-script
p.apiInfo, (err, info) ->
  unless err
     console.log "user stats: #{JSON.stringify info, null, 2}
  else
     console.log "error fetching stat"
```

  `info` is a dictionary with "x-limit-..." keys.

<a name='get'>
### get(options, fn) 

  `options` dictionary may contain fields:

  - `state` {String} - state for fetched pages, may be "read", "unread" and empty for both read and unread
  - `myAppOnly` {Boolean} - get results only if they were saved from application with same apikey, default `false`.
  - `since` {Number} - get results only if they were saved or created after `since` timestamp (unix formatted)
  - `count` {Number} - max number of results to fetch. By dedault all matched results will be returned, but if you ignore `count` parameter, *your application may be banned any time*.
  - `page` {Number} - page number for getting results, starting from 1, default 1
  - `tags` {Boolean} - include tags in result , default `true`

```coffee-script
p.get {count:10}, (err, pages) ->
  unless err
    console.log "Timestamp: #{pages.since}"
    for k,v of pages.list
      console.log "#{k}\t[#{v.url}](#{v.title})"
      console.log "read: #{if v.state is '1' then 'yes' else 'no'}"
      console.log "tags: #{if v.tags? then v.tags else '{empty}'}\n"
  else
    console.log "error fetching pages"
```

<a name='new'> 
### new(data, fn)

  Batch creation of new pages
  
  `data` is an array of objects:
  
  - `data[].url` {String} - page url
  - `data[].title` {String} - page title
  - `data[].ref_id` {String}  - ref_id, only for twitter clients, see http://getpocket.com/api/docs/#add_ref_id

```coffee-script
data = [
     {url: "http://getpocket.com/", title: "Pocket main"},
     {url: "http://duckduckgo.com/", title: "Go go duck!"}
     ]
p.new data, (err) ->
  unless err
    console.log "pages added"
  else
    console.log "pages wasn't added"
```    

<a name='read'> 
### read(data, fn)

  Batch mark pages as read

  `data` is an array of objects:
  
  - `data[].url` {String} - page url

```coffee-script
p.read [{url: "http://getpocket.com/"}], (err) ->
  unless err
    console.log "mark getpocket as read""
  else
    console.log "page wasn't marked as read"
```

<a name='updateTitle'> 
### updateTitle(data, fn)

  Batch updating titles for pages

  `data` is an array of objects:
  
  - `data[].url` {String} - page url
  - `data[].title` {String} - page title

```coffee-script
data = [
     {url: "http://getpocket.com/", title: "My Pocket"},
     {url: "http://duckduckgo.com/", title: "Search"}
     ]
p.updateTitle data, (err) ->
  unless err
    console.log "pages updated"
  else
    console.log "pages wasn't updated"
```  


<a name='updateTags'> 
### updateTags(data, fn)

  Batch update tags for pages

  `data` is an array of objects:
  
  - `data[].url` {String} - page url
  - `data[].tags` {String}  - comma separated tags

```coffee-script
data = [
     {url: "http://getpocket.com/", tags: "pocket,bookmarks"},
     {url: "http://duckduckgo.com/", tags: "search-engine"}
     ]
p.updateTags data, (err) ->
  unless err
    console.log "pages tags updated"
  else
    console.log "pages tags wasn't updated"
```

## License

The MIT License (MIT)
Copyright (c) 2012 Kirill Temnov

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
