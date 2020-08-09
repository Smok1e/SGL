local component = require ("component")
local gpu = component.gpu

--------------------------------------------------------------------------------

local SGL = {Draw = {}, Gpu = {}}

local Background, Foreground

local Resolution = {}

local Buffer = {}

local ScreenBuffer = {}

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

function SGL.Clear (color)

  SGL.Draw.Rect (1, 1, Resolution.x, Resolution.y, color)

end

--------------------------------------------------------------------------------

function SGL.Display ()

  for x = 1, Resolution.x do

    for y = 1, Resolution.y do

      if Buffer[x][y] ~= ScreenBuffer[x][y] then

        SGL.Gpu.setBackground (Buffer[x][y].background)
        SGL.Gpu.setForeground (Buffer[x][y].foreground)

        gpu.set (x, y, Buffer[x][y].char)

      end

    end

  end

  ScreenBuffer = Buffer

end

--------------------------------------------------------------------------------

function SGL.Draw.Pixel (x, y, color)

  if x <= Resolution.x and x >= 1 and y <= Resolution.y and y >= 1 then

    Buffer[x][y] = {background = color, foreground = 0, char = " "}

    return true

  else

    return false

  end

end

--------------------------------------------------------------------------------

function SGL.Draw.Rect (x, y, w, h, color)

  for x_ = 1, x do

    for y_ = 1, y do

      SGL.Draw.Pixel (x_, y_, color)

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

    SGL.Draw.Line (x, y, x + math.sin (A) * r, y + math.cos (A) * r, color, linestep)

  end

end

--------------------------------------------------------------------------------

function SGL.init ()

  Background, Foreground = gpu.getBackground (), gpu.getForeground ()

  Resolution.x, Resolution.y = gpu.getResolution ()

  for x = 1, Resolution.x do

    for y = 1, Resolution.y do

      local char, foreground, background = gpu.get (x, y)

      ScreenBuffer[x][y] = {char = char, background = background, foreground = foreground}

    end

  end

  Buffer = ScreenBuffer

end

--------------------------------------------------------------------------------

SGL.init ()

return SGL
