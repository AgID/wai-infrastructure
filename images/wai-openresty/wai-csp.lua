local ngx_log = ngx.log
local ngx_ERR = ngx.ERR
local ngx_NOTICE = ngx.NOTICE
local ngx_WARN = ngx.WARN

-- Test if data is an ampty string or null or nil
local function _is_empty(s) 
  return s == nil or s == '' or s == ngx.null
end

local function exit_401() 
  ngx.status = ngx.HTTP_UNAUTHORIZED
  ngx.exit(ngx.HTTP_OK)
end

local waicsp = {
  _VERSION = '0.0.1',
}

waicsp.__index = waicsp

function waicsp.evaluate(opts) 
  local args, err = ngx.req.get_uri_args()
  local cspValue = opts.defaultCsp
  if (err ~= "truncated" and args["module"] == "Widgetize" and args["action"] == "iframe" and args["widget"] == "1" and args["idSite"] ~= nil ) then
    local siteId = args["idSite"]
    ngx_log(ngx_NOTICE, "Parameters are ok. CSP procedure activated")
    local rc = require("resty.redis.connector").new()
    local redis, err = rc:connect(opts.redis)
    if err then 
        ngx_log(ngx_ERR, "Unable to connect to redis " .. opts.redis.url)
        ngx_log(ngx_ERR, err)
        ngx.header["Content-Security-Policy"] = "frame-ancestors " .. cspValue
        return nil, err
    end
    ngx_log(ngx_NOTICE, "Lookup to redis for keys on siteId " .. siteId )
    local siteUrl = redis:get(siteId)
    if(not _is_empty(siteUrl)) then
      cspValue = cspValue .. " " .. siteUrl
    end
    redis:close()
    local referer = ngx.req.get_headers()["referer"]
    local match = false
    if(referer == ngx.null or referer == nil) then
      exit_401()
    end
    ngx_log(ngx_NOTICE, "Redis data is " .. cspValue)
    ngx_log(ngx_NOTICE, "Referer is " .. referer)
    for host in string.gmatch(cspValue, '([^%s]+)') do
      ngx_log(ngx_NOTICE, "Testing '" .. referer .. "' on '" .. host .. "'")
      if ( referer:find(host, 1, true) == 1 ) then
        match = true
      end
    end
    if(match == false) then
      exit_401()
    end  
  end
  ngx.header["Content-Security-Policy"] = "frame-ancestors " .. cspValue
end

return waicsp
