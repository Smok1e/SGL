local component = require ("component")
local computer  = require ("computer")
local io        = require ("io")

local gpu = component.gpu 

------------------------------------------------

if not component.isAvailable ("internet") then

  return nil, "Internet card not found"

end

local internet = component.internet

------------------------------------------------

local SGL_URL         = "https://raw.githubusercontent.com/Smok1e/SGL/master/SGL.lua"
local SGL_VERSION_URL = "https://raw.githubusercontent.com/Smok1e/SGL/master/SGL_Version.lua"

local SGL_INSTALL_PATH         = "/lib/SGL.lua"
local SGL_VERSION_INSTALL_PATH = "/lib/SGL_Version.lua"

local background = 0x161616
local foreground = 0x00ffff

------------------------------------------------

local function getData (url)

  local request = internet.request (url)
 
  if not request or request.response () then return nil, "Failed to get data from " .. url end
 
  local data = ""
 
  while true do
 
    local chunk = request.read ()
 
    if not chunk then break end
 
    data = data .. chunk
 
  end
 
  return data
 
end

------------------------------------------------

local function download (url, path)

  local data, reason = getData (url)

  if not data then return nil, reason end

  local file, reason = io.open (path, "w")

  if not file then return nil, reason end

  file:write (chunk)
 
  file:close ()
 
  return true
 
end

------------------------------------------------

do

  return 

  local version = load (getData (SGL_VERSION_URL)) ()

  if require ("SGL_Version").Version ~= version.Version then

    download (SGL_URL,         SGL_INSTALL_PATH)
    download (SGL_VERSION_URL, SGL_VERSION_INSTALL_PATH)

  end

  local w, h = gpu.getResolution ()

  gpu.setBackground (background)
  gpu.setForeground (foreground)

  local message1 = "SGL was updated to version " .. version.Version
  local message2 = "'" .. version.Changes .. "'"

  gpu.fill (1, 1, w, h, " ")

  gpu.set (w / 2 - #message1 / 2, h / 2,     message1)
  gpu.set (w / 2 - #message2 / 2, h / 2 + 1, message2)

  while computer.pullSignal (1) ~= "key_down" do end

end
