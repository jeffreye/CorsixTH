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
class "UILoadMapConfiguration" (UIFileBrowser)

---@type UILoadMapConfiguration
local UILoadMapConfiguration = _G["UILoadMapConfiguration"]

function UILoadMapConfiguration:UILoadMapConfiguration(ui)
  local path = ui.app.level_dir
  local treenode = FilteredFileTreeNode(path, ".level")
  treenode.label = "Level Configuration"
  self:UIFileBrowser(ui, "menu", _S.load_game_window.caption:format(".level"), 295, treenode, true)
  -- The most probable preference of sorting is by date - what you played last
  -- is the thing you want to play soon again.
  self.control:sortByDate()

end

function UILoadMapConfiguration:choiceMade(name)
  local app = self.ui.app
  -- Make sure there is no blue filter active.
  app.video:setBlueFilterActive(false)
  -- name = name:sub(app.level_dir:len() + 1)
  app.map:applyConfiguration(name)
  self:close()
end

function UILoadMapConfiguration:close()
  UIResizable.close(self)
end
