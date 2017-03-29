--[[ Copyright (c) 2009 Peter "Corsix" Cawley

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. --]]

class "PickupFormsAction" (HumanoidAction)

---@type PickupFormsAction
local PickupFormsAction = _G["PickupFormsAction"]

function PickupFormsAction:PickupFormsAction(desk)
  assert(class.is(desk, ReceptionDesk), "Invalid value for parameter 'desk'")
  
  self:HumanoidAction("pickup_forms")
  self.reception_desk = desk
end

local function action_pickup_forms_start(action, humanoid)
  local world = humanoid.world
  local best_desk = action.reception_desk
  humanoid.working = true

  if best_desk then
    -- We found a desk to go to!
    local orientation = best_desk.object_type.orientations[best_desk.direction]
    local x = best_desk.tile_x + orientation.use_position[1]
    local y = best_desk.tile_y + orientation.use_position[2]
    humanoid:updateDynamicInfo(_S.dynamic_info.patient.actions.on_my_way_to
      :format(best_desk.object_type.name))

    -- Walk to there
    local face_x, face_y = best_desk:getSecondaryUsageTile()
    humanoid:queueAction(WalkAction(x, y):setMustHappen(action.must_happen))

    local room = humanoid.in_room
    if not room or not room.room_info.id == "administrative" or not room.is_active then
      local score
      local distance = 2^30
      for _, r in pairs(world.rooms) do repeat
        if r.built and r.room_info.id == "administrative" and r.is_active 
          and r:testStaffCriteria(r:getMaximumStaffCriteria(), humanoid) then
          local x, y = r:getEntranceXY(false)
          local d = world:getPathDistance(humanoid.tile_x, humanoid.tile_y, x, y)
          if not d or d > distance then
            break -- continue
          end
          local this_score = d
          if not score or this_score < score then
            score = this_score
            room = r
          end
        end
      until true end
    end

    -- Send back to any empty office
    -- Make sure that the room is still there though.
    -- If not, just answer the call
    if room then
      
      -- picking them up
      humanoid.forms = best_desk:takeAllForms()

      -- returning back
      humanoid:queueAction(room:createEnterAction(humanoid))
      humanoid:setDynamicInfoText(_S.dynamic_info.staff.actions.heading_for:format(room.room_info.name))
    else
      -- Let the staff meander
      humanoid:queueAction(MeanderAction())
    end
  else
    -- No reception desk found. One will probably be built soon, somewhere in
    -- the hospital, so either walk to the hospital, or walk around the hospital.
    local procrastination
    if humanoid.hospital:isInHospital(humanoid.tile_x, humanoid.tile_y) then
      procrastination = MeanderAction():setCount(1):setMustHappen(action.must_happen)
      if not humanoid.waiting then
        -- Eventually people are going to get bored and leave.
        humanoid.waiting = 5
      end
    else
      local _, hosp_x, hosp_y = world.pathfinder:isReachableFromHospital(humanoid.tile_x, humanoid.tile_y)
      procrastination = WalkAction(hosp_x, hosp_y):setMustHappen(action.must_happen)
    end
    humanoid:queueAction(procrastination, 0)
  end
  humanoid:finishAction()
end

return action_pickup_forms_start
