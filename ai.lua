local Spot = require('spot')

local aiClass = { }
aiClass.__index = aiClass

local spots = {
  Spot('computer', 1, 200, 500),
  Spot('bed', 2, 400, 100),
  Spot('trash', 3, 100, 300),
  Spot('laundry', 4, 200, 400),
  Spot('oven', 5, 500, 300),
  Spot('fridge', 6, 600, 200), 
  Spot('vacuum', 7, 600, 500) 
}
local availableSpots = { }

function Ai(spot)
  loadSpots()
  local instance = {
    class = 'ai',
    x = door.x,
    y = door.y,
    destination = spot,
    paused = false,
    stop = 0, -- no idea how to balance yet 
    variation = 1, -- rng lvl from 1 to length
    availableSpots = availableSpots,
    -- add r later to look like walking
  }
  setmetatable(instance, aiClass)
  return instance
end

function loadSpots()
  for n = 1, table.getn(spots) do
    table.insert(entities, spots[n])
    table.insert(availableSpots, spots[n])
  end
end

-- choose a spot that is not the current spot,
-- or one that has already been visited
function aiClass:nextSpot()
  print('length of available spots table: ', table.getn(self.availableSpots))
  print('current destination: ', self.destination.name)
  self:removeLastDestination()
  return self.availableSpots[love.math.random(table.getn(self.availableSpots))]
end

function aiClass:removeLastDestination()
  table.remove(self.availableSpots, self.destination.position)
end

function aiClass:draw()
  love.graphics.draw(aiImage, self.x, self.y)
end

function aiClass:update(dt)
  print('paused: ', self.paused)
  if self.paused then --pausing at a destination spot
    self.stop = self.stop - dt
    -- self.stop will never actually be zero except when set
    if self.stop < 0 then
      self.destination = self:nextSpot()
      -- reset the clock
      self.paused = false
      self.stop = 0
    end
  else --movement to a destination spot
    -- close the distance between current position of the center and the destination
    if (self.destination.x > self.x) then
      self.x = self.x + (self.variation)
    end
    if (self.destination.x < self.x) then
      self.x = self.x - (self.variation)
    end
    if (self.destination.y > self.y) then
      self.y = self.y + (self.variation)
    end
    if (self.destination.y < self.y) then
      self.y = self.y - (self.variation)
    end
    -- when the distance between the current center position and the destination is closed, choose the next destination
    if (self.destination.x == self.x and self.destination.y == self.y and self.stop == 0) then
      self.paused = true
      self.stop = 2 --this function runs ~60 fps
    end
  end
  -- when the "round" is over (all spots have been visited), start over
  if (table.getn(self.availableSpots) == 1) then
    loadSpots()
    self.availableSpots = availableSpots
  end
end

return Ai