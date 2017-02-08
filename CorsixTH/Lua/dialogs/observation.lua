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

--! The multi-purpose panel for launching dialogs / screens and dynamic information.
class "UIObservation" (Window)

---@type UIObservation
local UIObservation = _G["UIObservation"]

local col_bg = {
  red = 154,
  green = 146,
  blue = 198,
}

local col_caption = {
  red = 174,
  green = 166,
  blue = 218,
}

local col_textbox = {
  red = 0,
  green = 0,
  blue = 0,
}

local col_highlight = {
  red = 174,
  green = 166,
  blue = 218,
}

local col_shadow = {
  red = 134,
  green = 126,
  blue = 178,
}

function UIObservation:UIObservation(ui)
  self:Window()

  local app = ui.app

  self.ui = ui
  self.world = app.world
  self.on_top = false
  self.width = 180
  self.height = 220
  self:setDefaultPosition(0, 0.5)

  self.observation_panel =
    self:addBevelPanel(0, 0, 180, 40, col_bg):setLabel("Observation")

  self.start_date = 0
  self.time_limit = 30
  self:addBevelPanel(0, 40, 120, 40, col_shadow, col_bg, col_bg)
    :setLabel("Duration (days)").lowered = true
  self.time_textbox = self:addBevelPanel(120, 40, 60, 40, col_textbox, col_highlight, col_shadow)
  :setAutoClip(true)
  :makeTextbox(
  --[[persistable:new_game_confirm_time]]function()
    if not self.world:isPaused() then
      return
    end
    local time = self.time_textbox.text
    if tonumber(time) == nil then
      self.time_textbox:setText(tostring(self.time_limit))
    else
      self.time_limit = tonumber(time)
    end
  end,
  --[[persistable:new_game_abort_time]]function() self.time_textbox:setText(tostring(self.time_limit)) end)
  :allowedInput({"numbers"}):characterLimit(5):setText(tostring(self.time_limit))

  self.observation_button = self:addBevelPanel(0, 80, 180, 40, col_bg):setLabel("Start")
    :makeToggleButton(0, 0, 180, 40, nil, self.toggleObservationMode)
    :setToggleState(false):setTooltip(_S.tooltip.customise_window.paused)

  -- "load" button
  self:addBevelPanel(0, 150, 180, 40, col_bg):setLabel("Load Last Save")
    :makeButton(0, 0, 180, 40, nil, self.buttonLoad)

  -- "save" button
  self:addBevelPanel(0, 200, 180, 40, col_bg):setLabel("Save Current State")
    :makeButton(0, 0, 180, 40, nil, self.buttonSave)
end

function UIObservation:hitTest(x, y, x_offset)
  return x >= (x_offset and x_offset or 0) and y >= 0 and x < self.width and y < self.height
end

function UIObservation:toggleObservationMode( btn,checked,state )
  local app = self.ui.app
  if checked then
    self.previous_time_limit = self.time_limit
    self.start_date = self.world.day
    self.observation_button:setVisible(false)
    self.world:setSpeed("Normal")
  end
end

function UIObservation:buttonSave()
  self.ui:addWindow(UISaveGame(self.ui))
end

function UIObservation:buttonLoad()
  self.ui:addWindow(UILoadGame(self.ui, "game"))
end

function UIObservation:onTick()
  if not self.world:isPaused() and self.start_date ~= self.world.day then
    self.time_limit = self.time_limit - 1
    self.start_date = self.world.day
    if self.time_limit == 0 then
      self.time_limit = self.previous_time_limit
      self.observation_button:setVisible(true)
      self.world:setSpeed("Pause")
      self.ui:addWindow(UIGraphs(self.ui))
    end
    self.time_textbox:setText(tostring(self.time_limit))
  end
  Window.onTick(self)
end

-- function UIObservation:afterLoad(old, new)
--   Window.afterLoad(self, old, new)
-- end

