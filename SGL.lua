--Simple Graphic Library by @Smok1e--
--https://github.com/Supchik2102/SGL

local component = require ("component")
local computer = require ("computer")
local io = require ("io")

local gpu = component.gpu

--------------------------------------------------------------------------------

local SGL = {Draw = {}, Gpu = {}, Debug = {}, Color = {}}

local Background, Foreground
local Resolution = {}

local Buffer = {}
local ScreenBuffer = {}

local DoubleBuffering = true

local LastDisplayTime = 0

local StartTime = computer.uptime ()

--------------------------------------------------------------------------------

local ALLOW_TRACE = false

--------------------------------------------------------------------------------

function SGL.syncScreenBuffer ()

  for x = 1, Resolution.x do

    for y = 1, Resolution.y do

      local char, background, foreground = gpu.get (x, y)

      ScreenBuffer[x][y] = {background, foreground, char}

    end

  end

  return true

end

--------------------------------------------------------------------------------

function SGL.Gpu.setGpuAddress (address)

  local proxy = component.proxy (address)

  if proxy then

    gpu = proxy

    SGL.Init ()

    return true

  else

    return nil, "no such component"

  end

end

--------------------------------------------------------------------------------

function SGL.Gpu.bindScreen (address)

  return gpu.bind (address)

end

--------------------------------------------------------------------------------

function SGL.Gpu.setBackground (color)

  if color ~= Background then

    Background = color

    if gpu.getBackground () ~= Background then
  
      gpu.setBackground (Background)

      return true

    end

  else

    return false

  end

end

--------------------------------------------------------------------------------

function SGL.Gpu.setForeground (color)

  if color ~= Foreground then

    Foreground = color

    if gpu.getForeground ~= Foreground then

      gpu.setForeground (Foreground)

      return true

    end

  else

    return false

  end

end

--------------------------------------------------------------------------------

function SGL.Gpu.getBackground ()

  return Background

end

--------------------------------------------------------------------------------

function SGL.Gpu.getForeground ()

  return Foreground

end

--------------------------------------------------------------------------------

function SGL.Gpu.setResolution (x, y)

  if Resolution.x == x and Resolution.y == y then

    return false

  else

    Resolution.x, Resolution.y = x, y

    gpu.setResolution (x, y)

    SGL.syncScreenBuffer ()

    return true

  end  

end

--------------------------------------------------------------------------------

function SGL.Gpu.getResolution ()

  return Resolution.x, Resolution.y

end

--------------------------------------------------------------------------------

function SGL.setDoubleBufferingEnabled (enable)

  if DoubleBuffering ~= enable then

    DoubleBuffering = enable

    SGL.syncScreenBuffer ()

    return true

  else

    return false

  end

end

--------------------------------------------------------------------------------

function SGL.isDoubleBufferingEnabled ()

  return DoubleBuffering

end

--------------------------------------------------------------------------------

function SGL.Wait (timeout)

  timeout = timeout or 0

  local uptime = computer.uptime ()

  while computer.uptime (timeout) - uptime < timeout do

    computer.pullSignal (0)

  end

end

--------------------------------------------------------------------------------

function SGL.Clear (color)

  SGL.Draw.Rect (1, 1, Resolution.x, Resolution.y, color)

end

--------------------------------------------------------------------------------

function SGL.getDisplayTime ()

  local DisplayTime = math.floor (LastDisplayTime * 100) / 100

  if DisplayTime <= 0 then DisplayTime = 0.01 end

  return DisplayTime

end

--------------------------------------------------------------------------------

function SGL.Fill (x, y, w, h, background, foreground, char)

  for x_ = 0, w - 1 do

    for y_ = 0, h - 1 do

      SGL.Draw.Character (x + x_, y + y_, char, background, foreground)

    end

  end

  return true

end

--------------------------------------------------------------------------------

function SGL.isRectX (x, y)

  local background, foreground, char = table.unpack (Buffer[x][y])

  for i = 0, Resolution.x - x do

    if Buffer[x + i][y][1] ~= background or 
       Buffer[x + i][y][2] ~= foreground or 
       Buffer[x + i][y][3] ~= char then 

      if i == 1 then 

        return false 

      else 

        return i

      end

    end

  end

  return Resolution.x - x + 1

end

--------------------------------------------------------------------------------

function SGL.isRectY (x, y)

  local background, foreground, char = table.unpack (Buffer[x][y])

  for i = 0, Resolution.y - y do

    if Buffer[x][y + i][1] ~= background or 
       Buffer[x][y + i][2] ~= foreground or 
       Buffer[x][y + i][3] ~= char then 

      if i == 1 then 

        return false 

      else 

        return i

      end

    end

  end

  return Resolution.y - y + 1

end

--------------------------------------------------------------------------------

function SGL.Display ()

  SGL.Debug.DumpFreeMemory ()

  local uptime = computer.uptime ()

  for x = 1, Resolution.x do

    for y = 1, Resolution.y do

      if DoubleBuffering then

        local s, b = ScreenBuffer[x][y], Buffer[x][y] 

        if s[1] ~= b[1] or 
           s[2] ~= b[2] or 
           s[3] ~= b[3] then 

          SGL.Gpu.setBackground (b[1])
          SGL.Gpu.setForeground (b[2])

          local rectwidth  = SGL.isRectX (x, y)
          local rectheight = SGL.isRectY (x, y)

          if rectwidth then

            gpu.fill (x, y, rectwidth, 1, b[3])
            
            for i = 0, rectwidth - 1 do

              ScreenBuffer[x + i][y] = {Background, Foreground, b[3]}

            end

          end

          if rectheight then

            gpu.fill (x, y, 1, rectheight, b[3])
            
            y = y + rectheight

          end

          if not rectwidth and not rectheight then

            gpu.set (x, y, b[3])

          end

          s[1] = b[1]
          s[2] = b[2]
          s[3] = b[3]

        end

      else

        local b = Buffer[x][y]

        SGL.Gpu.setBackground (b[1])
        SGL.Gpu.setForeground (b[2])

        gpu.set (x, y, b[3])

      end

    end

  end

  LastDisplayTime = computer.uptime () - uptime

  return true

end

--------------------------------------------------------------------------------

function SGL.getCharacterFromBuffer (x, y)

  return {background = Buffer[x][y][1], foreground = Buffer[x][y][2], char = Buffer[x][y][3]}

end

--------------------------------------------------------------------------------

function SGL.getCharacterFromScreen (x, y)

  return {background = Buffer[x][y][1], foreground = Buffer[x][y][2], char = Buffer[x][y][3]}

end

--------------------------------------------------------------------------------

function SGL.Draw.Character (x, y, char, background, foreground)

  x = math.floor (x)
  y = math.floor (y)

  if x <= Resolution.x and x >= 1 and y <= Resolution.y and y >= 1 then

    if background then Buffer[x][y][1] = background end
    if foreground then Buffer[x][y][2] = foreground end
    if char       then Buffer[x][y][3] = char       end

    return true

  else

    return false

  end

end

--------------------------------------------------------------------------------

function SGL.Draw.Pixel (x, y, color)

  return SGL.Draw.Character (x, y, " ", color, 0)

end

--------------------------------------------------------------------------------

function SGL.Draw.Semipixel (x, y, topcolor, bottomcolor)

  return SGL.Draw.Character (x, y, "▄", topcolor, bottomcolor)

end

--------------------------------------------------------------------------------

function SGL.Draw.Rect (x, y, w, h, color)

  return SGL.Fill (x, y, w, h, color, 0, " ")

end

--------------------------------------------------------------------------------

function SGL.Draw.Line (x1, y1, x2, y2, color, step)

  local step = step or 0.5

  local a, b = x2 - x1, y2 - y1

  local c = math.sqrt (a * a + b * b)

  local vx, vy = a / c, b / c

  for i = 0, c, step do

    local x, y = x1 + i * vx, y1 + i * vy

    SGL.Draw.Pixel (x, y, color)

  end

  return true

end

--------------------------------------------------------------------------------

function SGL.Draw.Circle (x, y, r, color, circlestep, linestep)

  local circlestep = circlestep or 16

  for A = 0, math.pi * 2, math.pi / circlestep do

    SGL.Draw.Line (x, y, x + math.sin (A) * r * 2, y + math.cos (A) * r, color, linestep)

  end

end

--------------------------------------------------------------------------------

function SGL.Draw.Text (x, y, text, background, foreground, center)

  if center then x = x - #text / 2 end

  for i = 1, #text do

    local char = string.sub (text, i, i)

    SGL.Draw.Character (x + i - 1, y, char, background, foreground)

  end

  return true

end

--------------------------------------------------------------------------------

function SGL.Debug.DumpFreeMemory (message)

  if ALLOW_TRACE then

    local info = debug.getinfo (3)
  
    local line, funcname = info.currentline, info.name

    local file = io.open ("/SGLMemoryLog.log", "a")

    file:write ("[" .. computer.uptime () - StartTime .. "] in function '" .. funcname .. "' [line " .. line .. "]: " .. computer.freeMemory ())

    if message then

      file:write (" '" .. message .. "'")

    end

    file:write ("\n")

    file:close ()

    return true

  else

    return false

  end

end

--------------------------------------------------------------------------------

function SGL.Color.Pack (r, g, b)

  return (r *(256^2)) + (g * 256) + b

end

--------------------------------------------------------------------------------

function SGL.Color.Extract (color)

  color = color % 0x1000000  
 
  local r = math.floor(color / 0x10000)  
  local g = math.floor((color - r * 0x10000) / 0x100)
  local b = color - r * 0x10000 - g * 0x100
 
  return r, g, b

end

--------------------------------------------------------------------------------

function SGL.Init ()

  SGL.Debug.DumpFreeMemory ()

  Background, Foreground = gpu.getBackground (), gpu.getForeground ()

  Resolution.x, Resolution.y = gpu.getResolution ()

  for x = 1, Resolution.x do

    SGL.Debug.DumpFreeMemory ("x = " .. x)

    ScreenBuffer[x] = {}
    Buffer      [x] = {}

    for y = 1, Resolution.y do

      local char, foreground, background = gpu.get (x, y)

      ScreenBuffer[x][y] = {background, foreground, char}
      Buffer      [x][y] = {background, foreground, char}

    end

  end

end

--------------------------------------------------------------------------------

return SGL