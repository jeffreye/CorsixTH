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

--! Load Map Window
class "UILoadAppointment" (UIFileBrowser)

---@type UILoadAppointment
local UILoadAppointment = _G["UILoadAppointment"]

function UILoadAppointment:UILoadAppointment(ui, mode)
  local pathsep = package.config:sub(1, 1)
  local base_dir = ui.app.level_dir:sub(1, -8)
  local path = base_dir .. "Schedule" .. pathsep
  local treenode = FilteredFileTreeNode(path, ".txt")
  treenode.label = "Schedule"
  self:UIFileBrowser(ui, mode, "Schedule", 295, treenode, true)
  -- The most probable preference of sorting is by date - what you played last
  -- is the thing you want to play soon again.
  self.control:sortByDate()
end

function UILoadAppointment:choiceMade(filename)
  local app = self.ui.app
  local f = assert(io.open(filename, "rb"))
  local data = f:read("*a")
  f:close()
  -- Remove all spaces
  data = data:gsub("%s+", "")
  -- Split by comma and parse
  local appointments = {}
  for word in string.gmatch(data, '([^,]+)') do
    local n = tonumber(word)
    if(n) ~= nil then
      appointments[#appointments + 1] = n
    else
      ui:addWindow(UIInformation(ui, {"File contains non-number strings."}))
      return
    end
  end

  app.world:applySpawnTable(appointments)
  self:close()
end