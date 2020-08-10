local component = require ("component")
local gpu = component.gpu
local computer = require ("computer")

--------------------------------------------------------------------------------

local SGL = {Draw = {}, Gpu = {}}

local Background, Foreground
local Resolution = {}

local Buffer = {}
local ScreenBuffer = {}

local DoubleBuffering = true

local LastDisplayTime = 0

--------------------------------------------------------------------------------

function SGL.SyncScreenBuffer ()

  for x = 1, Resolution.x do

    for y = 1, Resolution.y do

      local char, background, foreground = gpu.get (x, y)

      ScreenBuffer[x][y] = {background = background, foreground = foreground, char = char}

    end

  end

  return true

end

--------------------------------------------------------------------------------

function SGL.Gpu.setGpuAddress (address)

  local proxy = component.proxy (address)

  if proxy then

    gpu = proxy

    SGL.init ()

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

    SGL.SyncScreenBuffer ()

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

function SGL.Display ()

  local uptime = computer.uptime ()

  for x = 1, Resolution.x do

    for y = 1, Resolution.y do

      if DoubleBuffering then

        local s, b = ScreenBuffer[x][y], Buffer[x][y]

        if s.background ~= b.background or 
           s.foreground ~= b.foreground or 
           s.char       ~= b.char then 

          SGL.Gpu.setBackground (b.background)
          SGL.Gpu.setForeground (b.foreground)

          gpu.set (x, y, b.char)

          s.background = b.background
          s.foreground = b.foreground
          s.char       = b.char

        end

      else

        local b = Buffer[x][y]

        SGL.Gpu.setBackground (b.background)
        SGL.Gpu.setForeground (b.foreground)

        gpu.set (x, y, b.char)

      end

    end

  end

  LastDisplayTime = computer.uptime () - uptime

  return true

end

--------------------------------------------------------------------------------

function SGL.Draw.Character (x, y, char, background, foreground)

  x = math.floor (x)
  y = math.floor (y)

  if x <= Resolution.x and x >= 1 and y <= Resolution.y and y >= 1 then

    Buffer[x][y].background = background
    Buffer[x][y].foreground = foreground
    Buffer[x][y].char       = char

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

function SGL.Draw.Rect (x, y, w, h, color)

  for x_ = 0, w - 1 do

    for y_ = 0, h - 1 do

      SGL.Draw.Pixel (x + x_, y + y_, color)

    end

  end

  return true

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

function SGL.Draw.Text (x, y, text, background, foreground)

  for i = 1, #text do

    local char = string.sub (text, i, i)

    SGL.Draw.Character (x + i - 1, y, char, background, foreground)

  end

  return true

end

--------------------------------------------------------------------------------

function SGL.init ()

  Background, Foreground = gpu.getBackground (), gpu.getForeground ()

  Resolution.x, Resolution.y = gpu.getResolution ()

  for x = 1, Resolution.x do

    ScreenBuffer[x] = {}
    Buffer      [x] = {}

    for y = 1, Resolution.y do

      local char, foreground, background = gpu.get (x, y)

      ScreenBuffer[x][y] = {char = char, background = background, foreground = foreground}
      Buffer      [x][y] = {char = char, background = background, foreground = foreground}

    end

  end

end

--------------------------------------------------------------------------------

SGL.init ()

return SGL