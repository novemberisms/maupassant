local TimedUpdateManager = {}

local elements = {}

function TimedUpdateManager:update(dt)
  for i = 1, #elements do
    elements[i]:timedUpdate(dt)
  end
end

function TimedUpdateManager:register(element)
  for i = 1, #elements do
    if elements[i] == element then return end
  end
  table.insert(elements, element)
end

function TimedUpdateManager:unregister(element)
  for i = 1, #elements do
    if elements[i] == element then
      table.remove(elements, i)
      return
    end
  end
end

return TimedUpdateManager