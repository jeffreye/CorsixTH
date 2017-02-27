--[[ Copyright (c) 2010 Manuel "Roujin" Wolf

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

--MATT CAREY STATS WINDOW

--! Tip of the Day Window
class "UIPatientStats" (UIResizable)

---@type UIPatientStats
local UIPatientStats = _G["UIPatientStats"]

local col_bg = {
  red = 0,
  green = 0,
  blue = 200,
}

function UIPatientStats:UIPatientStats(ui, world)
  self:UIResizable(ui, 225, 40, col_bg)

  local app = ui.app
  self.ui = ui
  self.resizable = false
  self:setDefaultPosition(-40, -300)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  
  self.world = world

end

function UIPatientStats:draw(canvas, x, y)
  -- Draw window components
  UIResizable.draw(self, canvas, x, y)
  
  local num_patients_with_stats = 0
  local cycle_total = 0
  local waiting_total = 0
  local num_patients_in_hospital = 0
  
  if self.world.patient_stats then
  for _, stats in ipairs(self.world.patient_stats) do
	num_patients_with_stats = num_patients_with_stats + 1
	if stats["cycle_time"] then
	  cycle_total = cycle_total + stats["cycle_time"]
	end
	if stats["waiting_time"] then
	  waiting_total = waiting_total + stats["waiting_time"]
	end
  end
    cycle_total = cycle_total / num_patients_with_stats
    waiting_total = waiting_total / num_patients_with_stats
  end
  
  for _, entity in ipairs(self.world.entities) do
	if class.is(entity, Patient) then
	  if entity:isInHospital() then
		num_patients_in_hospital = num_patients_in_hospital + 1
	  end
	end
  end
  
  
  
  x, y = self.x + x, self.y + y
  local text_total = "Total patients in hospital: " .. num_patients_in_hospital
  self.white_font:drawWrapped(canvas, text_total, x + 10, y + 10, self.width - 20)
  
  if cycle_total and waiting_total then
    local text_cycle = "Cycle Time Average: " .. string.format("%.2f", cycle_total)
    self.white_font:drawWrapped(canvas, text_cycle, x + 10, y + 20, self.width - 20)
  
    local text_waiting = "Wait Time Average: " .. string.format("%.2f", waiting_total)
    self.white_font:drawWrapped(canvas, text_waiting, x + 10, y + 30, self.width - 20)
  end
end
