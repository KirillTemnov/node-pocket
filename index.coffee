request = require "request"

###
Class for interacting with getpocket.com api

All callback functions accept 2 params:
    1) error, must be null,
    2) resulting object in json/javascript format.
###
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



exports.Pocket = Pocket


exports.version = "0.2.4"
