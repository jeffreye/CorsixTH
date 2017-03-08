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

local room = {}
room.id = "administrative"
room.level_config_id = 25
room.class = "Administrative"
room.name = "Administrative Office"
room.long_name = _S.rooms_long.gps_office
room.tooltip = _S.tooltip.rooms.gps_office
room.objects_additional = {  "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { desk = 1, cabinet = 1 }
room.build_preview_animation = 900
room.categories = {
  facilities = 3,
}
room.minimum_size = 4
room.wall_type = "white"
room.floor_tile = 18
room.required_staff = {
  Clerk = 1,
}
room.maximum_staff = room.required_staff
room.has_no_queue_dialog = true

class "Administrative" (Room)

---@type Administrative
local Administrative = _G["Administrative"]

function Administrative:Administrative(...)
  self:Room(...)
  self.forms = {} -- this would be set by pickup forms action
end

function Administrative:commandEnteringStaff(humanoid)
  self:doStaffUseCycle(humanoid)
  return Room.commandEnteringStaff(self, humanoid, true)
end

function Administrative:doStaffUseCycle(humanoid)
  humanoid:setNextAction(CheckFormsAction())
end

return room
