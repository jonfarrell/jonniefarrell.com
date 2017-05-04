http = require("http")
url = require("url")
fs = require("fs")
path = require("path")

con = console

onRequest = (request, response) ->
  pathname = url.parse(request.url).pathname
  response.writeHead(200, {"Content-Type": "text/plain", "Access-Control-Allow-Origin": "*"})
  
  fs.stat("#{ projectPath }#{ config.base }#{ pathname }", (err, stat) ->
    if(!err and stat.isFile())
      respondWithFile(pathname, response)
    else
      if(!err)
        fs.exists("#{ projectPath }#{ config.base }#{ pathname }/#{ config.indexFile }", (exists) ->
          if(exists)
            return respondWithFile("#{ pathname }/#{ config.indexFile }", response)
          else
            handleNoFile(pathname, request, response)
        )
      else
        handleNoFile(pathname, request, response)
  )

respondWithFile = (filePath, response) ->
  fs.readFile(projectPath + config.base + filePath, "binary", (err, file) ->
    if (err)
      response.writeHead(500, {"Content-Type": "text/plain", "Access-Control-Allow-Origin": "*"})
      response.write("There was an error opening the file")
      response.write("#{err}\n")
      response.end()
      return
    fileExtension = ""
    if filePath? and filePath.indexOf(".") isnt -1
      fileExtension = filePath.substr(filePath.lastIndexOf(".") + 1)
    mimeType = config.mimeTypes[fileExtension]
    if mimeType?
      response.writeHead(200, {"Content-Type": mimeType, "Access-Control-Allow-Origin": "*"})
    else
      response.writeHead(200, {"Content-Type": "text/plain", "Access-Control-Allow-Origin": "*"})
    response.write(file, "binary")
    response.end()
  )

handleNoFile = (pathname, request, response) ->
  # Check if there are any pre redirects before matching routes
  if config.redirects and config.redirects.pre
    return if checkRedirects(request.url, request, response, config.redirects.pre)
  # Try and match against a route
  return if checkRoutes(pathname, response)
  # Check if there  are any post redirects after a path has failed to match
  if config.redirects and config.redirects.post
    return if checkRedirects(request.url, request, response, config.redirects.post)
  # No file, no redirects, no routes -> 404 time
  respond404(response, pathname)

checkRoutes = (pathname, response) ->
  for r, f of config.routes
    if matchRoute(r, pathname)
      respondWithFile(f, response) 
      return true
  return false

checkRedirects = (pathname, request, response, redirects) ->
  for r, l of redirects
    if matchRoute(r, pathname)
      respond301(request, response, l)
      return true
  return false

matchRoute = (route, pathname) ->
  return true if route is pathname
  if(route.indexOf("*") isnt -1)
    return true if pathname.indexOf(route.split("*")[0]) == 0
  return false

respond404 = (response, filePath) ->
  text404 = () ->
    response.writeHead(404, {"Content-Type": "text/plain"})
    response.write("404 Not Found\n")
    response.end()

  fileExtension = ""
  if filePath? and filePath.indexOf(".") isnt -1
    fileExtension = filePath.substr(filePath.lastIndexOf(".") + 1)

  if (fileExtension is "" or fileExtension is "html") and config["404"]?
    fs.readFile(projectPath + config.base + config["404"], "binary", (err, file) ->
      return text404() if err
      response.writeHead(404, {"Content-Type": "text/html"})
      response.write(file, "binary")
      response.end()
    )
  else
    text404()

respond301 = (request, response, location) ->
  response.writeHead(301, {
    "Location": "http://#{ request.headers.host }#{ location }"
  })
  response.end()

projectPath = process.argv[2] || "./"

try
  config = JSON.parse(fs.readFileSync(projectPath + "server_config.json", "utf8"))
catch e
  console.log("Failed to load stouter_config.json")
  console.log("For more info on config files see https://github.com/roddeh/stouter")
  console.log(e.message)
  process.exit(1)

port = process.env.PORT || config.port

http.createServer(onRequest).listen(port)

console.log("----------------------------")
console.log("Started Server on port #{config.port}")
console.log("----------------------------")