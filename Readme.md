# API bindings for getpocket.com

## Installation

    `npm install node-pocket`

## Using

```coffee-script
        p = new (require "node-pocket").Pocket "<USERNAME>", "<PASSWORD>", "<APIKEY>"
        p.auth (err, ok) ->
          if not err and ok
             console.log "auth successfull"
          else
             console.log "auth fail
```

## Functions
