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

class "CheckFormsAction" (HumanoidAction)

---@type CheckFormsAction
local CheckFormsAction = _G["CheckFormsAction"]

function CheckFormsAction:CheckFormsAction()
  self:HumanoidAction("check_forms")
  self:setMustHappen(true)
end

local function action_check_forms_start(action, humanoid)
  local world = humanoid.world
  humanoid.working = true

  -- process forms
  local forms_process_time =  math.random(1, 5)
  local index = #humanoid.forms

  -- Callback function when the clerk has returned back 
  local clerk_file_forms = --[[persistable:clerk_check_forms_after_use]] function ()
    for i=1,#humanoid.forms do
      local patient = humanoid.forms[i]
      patient.form_filed = true
    end
    humanoid.forms = nil
    humanoid.working = false
    humanoid:queueAction(MeanderAction())
  end

  local check_forms = --[[persistable:check_forms_loop_callback]] function(ac)
    if index <= 0 then
      -- File them
      local obj, ox, oy = world:findObjectNear(humanoid, "cabinet")
      humanoid:walkTo(ox, oy)
      humanoid:queueAction(UseObjectAction(obj):setAfterUse(clerk_file_forms))
    end
    index = index - 1
  end

  local obj, ox, oy = world:findObjectNear(humanoid, "desk")
  humanoid:queueAction(WalkAction(ox, oy))
  humanoid:queueAction(UseObjectAction(obj):setLoopCallback(check_forms))


  humanoid:finishAction(action)
end

return action_check_forms_start
