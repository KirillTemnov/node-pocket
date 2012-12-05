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
  @version = "0.9.4"


  #
  # Public: Create new Pocket client object
  #
  # consumer_key - app key value
  # access_token - access token (optional)
  # 
  constructor: (@consumer_key, @access_token) ->

  #
  # Join params from dict to query string
  #
  # @param {Object} params Dict of params
  #
  _joinParams: (params={}) ->
    p = []
    for k, v of params
      p.push "#{k}=#{encodeURIComponent v}" if v
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
  # opts - options
  #   :url - url to redirect after approve
  #   :redirect - "http" (default) or "ios"
  # 
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
        if opts.redirect is "ios"
          redir = "pocket-oauth-v1:///authorize?request_token=#{b.code}&redirect_uri=#{uri}"
        else
          redir = "https://getpocket.com/auth/authorize?request_token=#{b.code}&redirect_uri=#{uri}"
        fn null,
          code        : b.code
          redirectUrl : redir


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

    request.post {url: "https://getpocket.com/v3/add", headers: headers, body: bodyStr},
      (err, res, body) => @_getBody err, res, body, fn


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
  # add          - Add a new item to the user's list
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
    request "https://getpocket.com/v3/get?#{par}", (err, res, body) => @_getBody err, res, body, fn


module.exports = Pocket


