local Metric = require('metric')

local aiClass = { }
aiClass.__index = aiClass

local heart = Metric('heart', 0)
local imgFiles = {
  '/images/heart0t.png', '/images/heart1t.png', '/images/heart2t.png', '/images/heart3t.png', '/images/heart4t.png', '/images/heart5t.png', '/images/heart6t.png'
}
local availableSpots = { }

function Ai()
  loadSpots()
  local instance = {
    class = 'ai',
    x = gameWidth, --gameWidth is globally available
    y = gameHeight, --gameHeight is globally available
    destination = door, --door is globally available
    iFile = aiBaseFile,
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
  -- state is globally available
  for idx, feature in ipairs(state.currentRoom.features) do
    table.insert(availableSpots, feature)
  end
end

function aiClass:findSpot(spot)
  for idx, feature in ipairs(self.availableSpots) do
    if spot.name == feature.name then
      print('spot name: ', spot.name)
      print('feature name: ', feature.name)
      return idx
    end
  end
end

-- choose a spot that is not the current spot,
-- or one that has already been visited
function aiClass:nextSpot()
  print('number of available spots: ', table.getn(self.availableSpots))
  print('moving towards ', self.destination.name)

  self:removeLastDestination()
  return self.availableSpots[love.math.random(table.getn(self.availableSpots))]
end

function aiClass:removeLastDestination()
  local idx = self:findSpot(self.destination)
  if idx then
    table.remove(self.availableSpots, idx)
  end
end

function aiClass:movement(dt)
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
    print('self.destination.x: ', self.destination.x)
    print('self.destination.y: ', self.destination.y)
    print('self.x: ', self.x)
    print('self.y: ', self.y)
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
      self.stop = 2 --seconds, this function runs ~60 fps
    end
  end
  -- when the "round" is over (all spots have been visited), start over
  if (table.getn(self.availableSpots) == 1) then
    loadSpots()
    self.availableSpots = availableSpots
  end
end

function aiClass:mouseCollision(x, y)
  local xClick = false
  local yClick = false
  if ((x <= (self.x + aiWidth)) and (x >= self.x)) then
    xClick = true
  end
  if ((y <= (self.y + aiHeight)) and (y >= self.y)) then
    yClick = true
  end
  if xClick and yClick and self.paused then
    if (heart.level < table.getn(imgFiles)) then
      heart:updateLevel(1)
      self.iFile = imgFiles[heart.level + 1]
    end
  end
end

function aiClass:draw()
  img = love.graphics.newImage(self.iFile)
  love.graphics.draw(img, self.x, self.y)
end

function aiClass:update(dt)
  self:movement(dt)
end

return Ai