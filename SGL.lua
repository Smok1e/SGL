local component = require ("component")
local gpu = component.gpu

--------------------------------------------------------------------------------

local SGL = {Draw = {}}

local Background, Foreground

local Resolution = {}

--------------------------------------------------------------------------------

function SGL.setGpuAddress (address)

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

function SGL.bindScreen (address)

  return gpu.bind (address)

end

--------------------------------------------------------------------------------

function SGL.setBackground (color)

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

function SGL.setForeground (color)

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

function SGL.getBackground ()

  return Background

end

--------------------------------------------------------------------------------

function SGL.getForeground ()

  return Foreground

end

--------------------------------------------------------------------------------

function SGL.setResolution (x, y)

  if Resolution.x == x and Resolution.y == y then

    return false

  else

    Resolution.x, Resolution.y = x, y

    gpu.setResolution (x, y)

    return true

  end  

end

--------------------------------------------------------------------------------

function SGL.getResolution ()

  return Resolution.x, Resolution.y

end

--------------------------------------------------------------------------------

function SGL.Clear (color)

  SGL.Draw.Rect (1, 1, Resolution.x, Resolution.y, color)

end

--------------------------------------------------------------------------------

function SGL.Draw.Pixel (x, y, color)

  if color then SGL.setBackground (color) end

  if x <= Resolution.x and x >= 1 and y <= Resolution.y and y >= 1 then

    gpu.set (x, y, " ")

    return true

  else

    return false

  end

end

--------------------------------------------------------------------------------

function SGL.Draw.Rect (x, y, w, h, color)

  if color then SGL.setBackground (color) end

  gpu.fill (x, y, w, h, " ")

  return true

end

--------------------------------------------------------------------------------

function SGL.Draw.Line (x1, y1, x2, y2, color, step)

  local step = step or 0.5

  if color then SGL.setBackground (color) end

  local a, b = x2 - x1, y2 - y1

  local c = math.sqrt (a * a + b * b)

  local vx, vy = a / c, b / c

  for i = 0, c, step do

    local x, y = x1 + i * vx, y1 + i * vy

    SGL.Draw.Pixel (x, y)

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

end

--------------------------------------------------------------------------------

SGL.init ()

return SGL
