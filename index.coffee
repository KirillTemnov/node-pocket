request  = require "request"
_        = require "underscore"

#
# Class for interacting with getpocket.com api
# 
# All callback functions accept 2 params:
#    1) error, must be null,
#    2) resulting object in json/javascript format.
#
class Pocket
  ###
  Class constructor, `user` and `password` params may be ommitted only for
  signup call

  @param {String} user Username
  @param {String} password User password
  @param {String} apikey Application api key
  ###
  constructor: (@user, @password, @apikey) ->
    @_domain = "https://getpocket.com/v2"
    @password = @password


  ###
  ##  --------------------------------------------------------------------------------
  ##   Helper functions
  ##  --------------------------------------------------------------------------------
  ###

  ###
  Join params from dict to query string

  @param {Object} params Dict of params
  ###
  _joinParams: (params={}) ->
    params.username  ||= @user
    params.password  ||= @password
    params.apikey      = @apikey
    p                  = []
    for k, v of params
      p.push "#{k}=#{escape v}" if v
    p.join "&"

  ###
  Check result for errors
  ###
  _checkErrors: (err, res, fn) ->
    if err
      fn err, no
    else
      fn null, res.statusCode is 200

  ###
  Get responce body, if no errors, otherwise return error
  ###
  _getBody: (err, res, body, fn) ->
      if err
        fn err
      else if res.statusCode is 200
        fn null, JSON.parse body
      else
        fn errCode: res.statusCode

  # --------------------------------------------------------------------------------

  ###
  Authenticate user

  @param {Function} fn Callback function
  ###
  auth: (fn) ->
    url = "#{@_domain}/auth?#{@_joinParams()}"
    request url, (err, res) => @_checkErrors err, res, fn

  ###
  Signup new user

  @param {String} username New user name
  @param {String} password Password for user
  @param {Function} fn Callback function
  ###
  signup: (user, password, fn) ->
    url = "#{@_domain}/signup?#{@_joinParams username: user, password: password}"
    request url, (err, res) => @_checkErrors err, res, fn

  ###
  Add new url to pocket

  @param {String} url Url, starting from http
  @param {String} title Personal title for url
  @param {String|Function} ref_id Ref_id string, or callback function
  @param {Function} fn Callback function, if ref_id is set
  ###
  add: (url, title, ref_id, fn) ->
    if "function" is typeof ref_id
      fn = ref_id
      ref_id = null
    url = "#{@_domain}/add?#{@_joinParams url: url, title: title, ref_id: ref_id}"
    request url, (err, res) => @_checkErrors err, res, fn

  ###
  Get stats for user

  @param {Function} fn Callback function
  ###
  stats: (fn) ->
    request "#{@_domain}/stats?#{@_joinParams()}", (err, res, body) => @_getBody err, res, body, fn


  ###
  Get api info - dict with "x-limit-..." values

  @param {Function} fn Callback function
  ###
  apiInfo: (fn) ->
    request "#{@_domain}/api?apikey=#{@apikey}", (err, res) ->
      if err
        fn err
      else if res.statusCode is 200
        out = {}
        for k, v of res.headers
          out[k] = v if 0 is k.toLowerCase().indexOf "x-limit"
        fn null, out
      else
        fn errCode: res.statusCode

  ###
  Get request with predefined options
  ###
  _get: (opts, fn) ->
    opts.format     = "json"          # set json
    opts.tags       = if opts.tags is no then 0 else 1
    opts.myAppOnly  = if opts.myAppOnly is yes then 1 else 0
    request "#{@_domain}/get?#{@_joinParams opts}",  (err, res, body) => @_getBody err, res, body, fn

  ###
  Get user urls

  @param {Object} opts Options
                  opts.myAppOnly - set to yes for getting urls, saved only from current app
                  opts.state     - get urls with state: "read", "unread", undefined (default)
                  opts.since     - select url updted/added after this time (unix format)
                  opts.count     - count for urls, default - infinity, not recommended!
                  opts.page      - page number, for paged output
                  opts.tags      - include tags, default is yes
  @param {Function} fn Callback function
  ###
  get: (opts, fn) ->
    @_get opts, fn

  ###
  Normalize object for pushing to api: if object type is Array,
  it will be normalized to dictionary

  @param {Object|Array} obj Object to normalize
  @return {Object} obj Normalized object
  ###
  _normalizeObject: (obj) ->
    if obj instanceof Array
      o = {}
      o[i] = v for v,i in obj
      o
    else
      obj

  ###
  Internal function for sending data, utilised by `new`, `read`, `updateTitle`, `updateTags`

  @param {Object} obj Object to send, @see http://getpocket.com/api/docs/#send
  @param {Function} fn Callback function
  ###
  _sendData: (obj, fn) ->
    url = "#{@_domain}/send?#{@_joinParams()}"
    headers = {"content-type" : "application/x-www-form-urlencoded"}
    body = []
    for k, v of obj
      if k in ["new", "read", "update_title", "update_tags"]
        body.push "#{k}=#{JSON.stringify @_normalizeObject obj[k]}"
    request.post {url: url, headers: headers, body: body.join "&"}, (err, res)  => @_checkErrors err, res, fn


  ###
  Send new data objects in Array

  @param {Array} data Url objects
                 data[].url     - url
                 data[].title   - title for url
                 data[].ref_id  - id, only for twitter clients
  @param {Function} fn Callback function
  ###
  new: (data, fn) ->
    @_sendData {new: data}, fn


  ###
  Mark urls in array as read

  @param {Array} data Url objects
                 data[].url     - url
  @param {Function} fn Callback function
  ###
  read: (data, fn) ->
    @_sendData {read: data}, fn


  ###
  Update Title for array of urls

  @param {Array} data Urls with new titles
                 data[].url     - url
                 data[].title   - new title for url
  @param {Function} fn Callback function
  ###
  updateTitle: (data, fn) ->
    @_sendData {update_title: data}, fn


  ###
  Update url tags

  @param {Array} data Urls with new titles
                 data[].url     - url
                 data[].tags    - new tags - string, comma separated
  @param {Function} fn Callback function
  ###
  updateTags: (data, fn) ->
    @_sendData {update_tags: data}, fn



#exports.Pocket = Pocket

class Pocket2
  constructor: (@consumer_key, @access_token) ->

  #
  # Join params from dict to query string
  #
  # @param {Object} params Dict of params
  #
  _joinParams: (params={}) ->
    p                  = []
    for k, v of params
      p.push "#{k}=#{escape v}" if v
    p.join "&"

  #
  # Get responce body, if no errors, otherwise return error
  #
  _getBody: (err, res, body, fn) ->
      if err
        fn err
      else if res.statusCode is 200
        fn null, JSON.parse body
      else
        fn errCode: res.statusCode

  #
  # Public: Get request token
  #
  # url - url to redirect after approve
  # fn(err, rd) - callback function
  # 
  getRequestToken: (opts={}, fn=->) ->
    uri = encodeURIComponent opts.url
    endpt = "consumer_key=#{@consumer_key}&redirect_uri=#{uri}"
    headers = {"content-type" : "application/x-www-form-urlencoded", "X-accept": "application/json"}
    request.post {url: "https://getpocket.com/v3/oauth/request", headers: headers, body: endpt }, (err, res, body) ->
      if err
        fn err, body
      else
        b = JSON.parse body
        fn null,
          code        : b.code
          redirectUrl : "https://getpocket.com/auth/authorize?request_token=#{b.code}&redirect_uri=#{uri}"


  #
  # Public: Get access token, needs code
  #
  # code - code for get acccess token
  # fn(err, result) - callback function
  #
  getAccessToken: (opts={}, fn=->) ->
    bodyStr = "consumer_key=#{@consumer_key}&code=#{opts.code}"
    headers = {"content-type" : "application/x-www-form-urlencoded", "X-accept": "application/json"}
    request.post {url: "https://getpocket.com/v3/oauth/authorize", headers:headers, body: bodyStr}, (err, res, body) =>
      if err
        fn err, body
      else
        result = JSON.parse body
        @acccess_token = result.acccess_token
        fn null, result

  #
  # Public: Add new url to pocket
  #
  # opts             - options
  #   :url           - 	The URL of the item you want to save (required)
  #   :title         -	The title of the item you want to save
  #   :tags          - 	A comma-separated list of tags to apply to the item
  #   :tweet_id      - 	If you are adding Pocket support to a Twitter client,
  #                      please send along a reference to the tweet status id.
  #                      This allows Pocket to show the original
  #                      tweet alongside the article.
  #  :acccess_token  - access token for client
  #
  # fn(err, data)    - callback function
  #
  add: (opts={}, fn=->) ->
    opts.consumer_key	= @consumer_key
    opts.access_token ||= @access_token
    for k in ["access_token", "url"]
      unless opts[k]
        return fn {err: "#{k} parameter missed"}
    
    bodyStr = @_joinParams opts
    headers = {"content-type" : "application/x-www-form-urlencoded", "X-accept": "application/json"}

    request.post {url: "https://getpocket.com/v3/add", headers: headers, body: bodyStr}, (err, res, body) => @_getBody err, res, body, fn


  #
  # Public: Modify item data
  #
  # opts - here comes actions
  #   :access_token  - access_token (optional)
  #   :actions       - array of actions
  #                    each action consist from `action`, `item_id`, `time`
  #                    and may have additional params.
  # fn(err, data)    - callback function
  #
  # 
  # List of actions:
  # 
  #  add          - Add a new item to the user's list
  #   :item_id    - The id of the item to perform the action on.
  #   :ref_id     - A Twitter status id; this is used to show tweet attribution.
  #   :tags       - A list of one or more tags.
  #   :time       - The time the action occurred.
  #   :title      - The title of the item.
  #   :url        - The url of the item; provide this only if you do not have an item_id.
  #
  # 
  # archive       - Move an item to the user's archive
  #   :item_id    - id of the item to perform the action on.
  #   :time       - The time the action occurred.
  #
  # favorite      - Mark an item as a favorite
  #   :item_id    - id of the item to perform the action on.
  #   :time       - The time the action occurred.
  # 
  # unfavorite    - Remove an item from the user's favorites
  #   :item_id    - id of the item to perform the action on.
  #   :time       - The time the action occurred.
  #
  # delete        - Permanently remove an item from the user'
  #   :item_id    - id of the item to perform the action on.
  #   :time       - The time the action occurred.
  #
  #  
  # tags_add      - Add one or more tags to an item
  #   :item_id    - The id of the item to perform the action on.
  #   :tags       - A list of one or more tags.
  #   :time       - optional	The time the action occurred.
  #
  # tags_remove   - Remove one or more tags from an item
  #   :item_id    - The id of the item to perform the action on.
  #   :tags       - A list of one or more tags to remove.
  #   :time       - optional	The time the action occurred.
  #
  # tags_replace  - Replace all of the tags for an item with one or more provided tags
  #   :item_id    - The id of the item to perform the action on.
  #   :tags       - A list of one or more tags to add.
  #   :time       - optional	The time the action occurred.
  #
  # tags_clear    - Remove all tags from an item
  #   :item_id    - The id of the item to perform the action on.
  #   :time       - optional	The time the action occurred.
  #
  # tag_rename    - Rename a tag; this affects all items with this tag
  #   :item_id    - The id of the item to perform the action on.
  #   :old_tag    - The tag name that will be replaced.
  #   :new_tag    - The new tag name that will be added.
  #   :time       - optional	The time the action occurred.
  # 
  modify: (opts={}, fn=->) ->
    opts.consumer_key	= @consumer_key
    opts.access_token ||= @access_token
    unless opts.actions instanceof Array
      return fn {err: "missed or wrond actions format"}
    
    for a in opts.actions
      unless a.time
        a.time = Date.now()

    query = JSON.stringify opts

    headers = {"content-type" : "application/json", "X-accept": "application/json"}
    request.post {url: "https://getpocket.com/v3/send", headers: headers, body: query}, (err, res, body) => @_getBody err, res, body, fn



  #
  # Public: Get person reading list with params
  #
  # opts - filter options
  #   :state                    -  filter state of item
  #               "unread"      - for unread
  #               "archive"     - for archive
  #
  # 
  #   :favorite                 - filter favorites
  #               0, false      - only unfavourites
  #               1, true       - only favorites
  #
  # 
  #   :tag                      - tag to search
  #               any_string    - return only with tags, containing any_string tag
  #               "_untagged_"  - return only untagged items
  #
  # 
  #   :contentType              - type of content
  #               "article"     - return only articles
  #               "video"       - return only videos or articles with embedded videos
  #               "image"       - "return only images"
  #
  # 
  #   :sort                     - Sort type
  #               "newest"      - return items in order of newest to oldest
  #               "oldest"      - return items in order of oldest to newest
  #               "title"       - return items in order of title alphabetically
  #               "site"        - return items in order of url alphabetically
  #
  # 
  #   :detailType               - filter detail
  #               "simple"      - only return the titles and urls of each item
  #               "complete"    - return all data about each item, including tags,
  #                               images, authors, videos and more
  #
  # 
  #   :search                 	-  return items whose title or url contain the search string
  # 
  #   :domain                 	-  return items from a particular domain
  # 
  #   :since                    -  return items modified since the given since unix timestamp
  # 
  #   :count                    -	 return count number of items
  # 
  #   :offset                   -	Used only with count; start returning from offset
  #                               position of results
  #   
  get: (opts={}, fn=->) ->
    if opts.access_token
      at = opts.access_token
      delete opts.access_token
    else
      at = @access_token
    if "undefined" isnt typeof opts.favorite
      opts.favorite += 0
    par = @_joinParams _.extend consumer_key: @consumer_key, access_token: at, opts
    console.log "calling " + "https://getpocket.com/v3/get?#{par}"
    request "https://getpocket.com/v3/get?#{par}", (err, res, body) => @_getBody err, res, body, fn


exports.Pocket = Pocket2

exports.version = "0.9.1"
