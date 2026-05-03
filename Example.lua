-- made by vyxonq, modified by halis and aibmpk

-- https://discord.gg/Q2wggVjp



-- load libary

local HorizonUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/LIAM893134/HorizonGUI/refs/heads/main/HorizonLibary.luau"))()

local ui = HorizonUI.new("Horizon Test")

ui:SetWatermark(true)
ui:SetStatus("🧪 Test Mode")

local tab1 = ui:AddTab("Toggles & Sliders", nil, "HOT")
local tab2 = ui:AddTab("Dropdowns", nil, "3")
local tab3 = ui:AddTab("Input & Number", nil)
local tab4 = ui:AddTab("Labels & Progress", nil)
local tab5 = ui:AddTab("Buttons & Keys", nil)
local tab6 = ui:AddTab("Toast Test", nil, "!")
local tab7 = ui:AddTab("Config & Theme", nil)
local tab8 = ui:AddTab("Misc & API", nil)

task.wait(0.8)
ui:Notify("HorizonUI", "Test script loaded! All elements ready.", "success", 4)

local secTog1 = tab1:AddSection("Toggle Test")

local togAimbot = secTog1:AddToggle("Aimbot", false, function(val)
    print("[Toggle] Aimbot:", val)
    ui:Notify("Aimbot", val and "Enabled" or "Disabled", val and "success" or "warning", 2)
end)

local togESP = secTog1:AddToggle("ESP (Default: On)", true, function(val)
    print("[Toggle] ESP:", val)
end)

local togSpeed = secTog1:AddToggle("SpeedHack", false, function(val)
    print("[Toggle] SpeedHack:", val)
end)

local togDisabled = secTog1:AddToggle("Disabled Toggle", false, function(val)
    print("[Toggle] This should not fire!")
end)
togDisabled:setDisabled(true)

task.delay(4, function()
    togAimbot:setValue(true)
    print("[API] togAimbot:setValue(true) called")
end)

task.delay(7, function()
    togAimbot:setValue(false)
    print("[API] togAimbot:setValue(false) called")
end)

local secSlider = tab1:AddSection("Slider Test")

local sliderWalk = secSlider:AddSlider("WalkSpeed", 16, 500, 16, function(val)
    print("[Slider] WalkSpeed:", val)
    local plr = game:GetService("Players").LocalPlayer
    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid.WalkSpeed = val
    end
end)

local sliderJump = secSlider:AddSlider("JumpPower", 50, 500, 50, function(val)
    print("[Slider] JumpPower:", val)
    local plr = game:GetService("Players").LocalPlayer
    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid.JumpPower = val
    end
end)

local sliderFOV = secSlider:AddSlider("Field of View", 70, 120, 90, function(val)
    print("[Slider] FOV:", val)
    workspace.CurrentCamera.FieldOfView = val
end)

local sliderDis = secSlider:AddSlider("Disabled Slider", 0, 100, 50, function(val)
    print("[Slider] Should not fire!")
end)
sliderDis:setDisabled(true)

local secCollapse = tab1:AddSection("Collapsible Section Test")

secCollapse:AddLabel("Click the section header to collapse and expand it.")
secCollapse:AddToggle("Collapse Test Toggle", false, function(val)
    print("[Collapse] Toggle:", val)
end)
secCollapse:AddSlider("Collapse Test Slider", 0, 100, 25, function(val)
    print("[Collapse] Slider:", val)
end)

local secEmpty = tab1:AddSection("")

secEmpty:AddLabel("This section has no header — different look.")

local secDrop = tab2:AddSection("Standard Dropdown")

local drop1 = secDrop:AddDropdown("Select Weapon", {
    "Glock", "AK47", "AWP", "M4A1", "Desert Eagle", "UMP45", "MP5"
}, "Glock", function(val)
    print("[Dropdown] Weapon:", val)
    ui:Notify("Weapon", val .. " selected", "info", 2)
end)

local drop2 = secDrop:AddDropdown("Game Mode", {
    "Normal", "Hardcore", "Casual", "Ranked", "Custom"
}, "Normal", function(val)
    print("[Dropdown] Mode:", val)
end)

local secSearchDrop = tab2:AddSection("SearchableDropdown Test")

local searchDrop = secSearchDrop:AddSearchableDropdown("Select Map", {
    "Dust2", "Mirage", "Inferno", "Nuke", "Overpass",
    "Vertigo", "Ancient", "Anubis", "Cache", "Train",
    "Cobblestone", "Season", "Agency", "Office"
}, "Dust2", function(val)
    print("[SearchableDropdown] Map:", val)
    ui:Notify("Map", val .. " selected!", "success", 2)
end)

local secMulti = tab2:AddSection("MultiSelect Dropdown Test")

local multiDrop = secMulti:AddMultiDropdown("Active Features", {
    "Aimbot", "ESP", "WallHack", "SpeedHack",
    "BunnyHop", "TriggerBot", "NoRecoil", "AutoShoot"
}, {"ESP", "WallHack"}, function(vals)
    print("[MultiDropdown] Selected:", table.concat(vals, ", "))
    ui:Notify("MultiSelect", #vals .. " features selected", "info", 2)
end)

secMulti:AddButton("Print Selected Values", function()
    local vals = multiDrop:getValue()
    print("[MultiDropdown] Currently selected:", table.concat(vals, ", "))
    ui:Notify("Selected", table.concat(vals, " | "), "info", 3)
end)

local secInput = tab3:AddSection("Text Input Test")

local input1 = secInput:AddInput("Player Name", "Enter username...", function(text)
    print("[Input] Player Name:", text)
    ui:Notify("Search", "Searching for '" .. text .. "'...", "info", 2)
end)

local input2 = secInput:AddInput("Custom Message", "Type your message...", function(text)
    print("[Input] Message:", text)
end)

local input3 = secInput:AddInput("Webhook URL", "https://...", function(text)
    print("[Input] URL:", text)
end)

task.delay(3, function()
    input1:setValue("TestPlayer123")
    print("[API] input1:setValue() called")
end)

local secNum = tab3:AddSection("NumberInput (+/- Buttons) Test")

local num1 = secNum:AddNumberInput("Max Bullets", 1, 999, 30, 1, function(val)
    print("[NumberInput] Bullets:", val)
end)

local num2 = secNum:AddNumberInput("Rate (%)", 0, 100, 50, 5, function(val)
    print("[NumberInput] Rate:", val)
    ui:Notify("Rate", "%" .. val .. " set", "info", 2)
end)

local num3 = secNum:AddNumberInput("Delay (ms)", 0, 2000, 100, 25, function(val)
    print("[NumberInput] Delay:", val)
end)

local num4 = secNum:AddNumberInput("Disabled Input", 0, 100, 50, 1, function(val)
    print("[NumberInput] Should not fire!")
end)
num4:setDisabled(true)

task.delay(5, function()
    num1:setValue(100)
    print("[API] num1:setValue(100) called")
end)

local secLbl = tab4:AddSection("Label Test")

local lbl1 = secLbl:AddLabel("This is a normal AddLabel text.")
local lbl2 = secLbl:AddLabel("RichText: <b>Bold</b>, <i>Italic</i>, <font color='rgb(99,102,241)'>Colored</font>")

task.delay(4, function()
    lbl1:setText("Label updated! setText() API is working ✓")
end)

local secRich = tab4:AddSection("RichText / Paragraph Label Test")

local richInfo    = secRich:AddRichLabel("This is an info message — info type display.", "info")
local richSuccess = secRich:AddRichLabel("Operation completed successfully — success type.", "success")
local richWarn    = secRich:AddRichLabel("Caution! This is a warning message — warning type.", "warning")
local richError   = secRich:AddRichLabel("An error occurred! — error type display.", "error")
local richPlain   = secRich:AddRichLabel("No type specified — plain paragraph text. Can be used for longer content.")

task.delay(6, function()
    richInfo:setText("RichLabel updated! setText() API is working ✓")
end)

local secProg = tab4:AddSection("ProgressBar Test")

local progHP   = secProg:AddProgressBar("Health (HP)", 0, 100, 100)
local progXP   = secProg:AddProgressBar("Experience (XP)", 0, 1000, 240)
local progAmmo = secProg:AddProgressBar("Ammo", 0, 30, 30)
local progLoad = secProg:AddProgressBar("Loading...", 0, 100, 0)

task.spawn(function()
    local v = 0
    while progLoad and task.wait(0.07) do
        v = (v + 1) % 101
        progLoad:setValue(v)
    end
end)

task.delay(3, function()
    progHP:setValue(45)
    ui:Notify("HP Dropped!", "Health: 45/100", "error", 3)
end)

task.delay(6, function()
    progHP:setValue(100)
    progAmmo:setValue(0)
    ui:Notify("HP Restored!", "Health: 100/100", "success", 2)
end)

task.delay(8, function()
    progXP:setValue(1000)
    ui:Notify("Level Up!", "XP: 1000/1000 — Max level!", "success", 3)
end)

local secBtn = tab5:AddSection("Button Test")

secBtn:AddButton("Teleport → Origin", function()
    local plr = game:GetService("Players").LocalPlayer
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        plr.Character.HumanoidRootPart.CFrame = CFrame.new(0, 5, 0)
    end
    ui:Notify("Teleport", "Teleported to origin!", "success", 2)
end)

secBtn:AddButton("Print All getValue Results", function()
    print("=== getValue RESULTS ===")
    print("togAimbot:", togAimbot:getValue())
    print("togESP:", togESP:getValue())
    print("sliderWalk:", sliderWalk:getValue())
    print("sliderFOV:", sliderFOV:getValue())
    print("drop1:", drop1:getValue())
    print("searchDrop:", searchDrop:getValue())
    print("multiDrop:", table.concat(multiDrop:getValue(), ", "))
    print("input1:", input1:getValue())
    print("num1:", num1:getValue())
    print("num2:", num2:getValue())
    print("progHP:", progHP:getValue())
    print("=======================")
    ui:Notify("getValue", "All values printed to console!", "info", 3)
end)

local btnDis = secBtn:AddButton("Disabled Button", function()
    print("[Button] This should not fire!")
end)
btnDis:setDisabled(true)

secBtn:AddButton("Toggle Enable/Disable Cycle", function()
    togDisabled:setDisabled(false)
    ui:Notify("API", "Disabled toggle is now active!", "success", 2)
    task.delay(3, function()
        togDisabled:setDisabled(true)
        ui:Notify("API", "Toggle disabled again!", "warning", 2)
    end)
end)

local secKey = tab5:AddSection("Keybind Test")

local kb1 = secKey:AddKeybind("Toggle ESP (Key)", Enum.KeyCode.F1, function(key)
    print("[Keybind] Pressed:", key.Name)
    ui:Notify("Keybind", key.Name .. " key pressed!", "info", 2)
end)

local kb2 = secKey:AddKeybind("Panic Key", Enum.KeyCode.Delete, function(key)
    print("[Keybind] Panic:", key.Name)
    ui:Notify("PANIC", "Exit key: " .. key.Name, "error", 3)
end)

local kb3 = secKey:AddKeybind("Teleport Key", Enum.KeyCode.F5, function(key)
    local plr = game:GetService("Players").LocalPlayer
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        plr.Character.HumanoidRootPart.CFrame = CFrame.new(0, 5, 0)
    end
    ui:Notify("Teleport Key", "Teleported via " .. key.Name .. "!", "success", 2)
end)

secKey:AddButton("kb1 getValue", function()
    print("[Keybind] kb1 value:", kb1:getValue().Name)
    ui:Notify("Keybind getValue", kb1:getValue().Name, "info", 2)
end)

local secToast = tab6:AddSection("Toast Notify Types")

secToast:AddButton("Info Toast", function()
    ui:Notify("Information", "This is an info notification.", "info", 3)
end)

secToast:AddButton("Success Toast", function()
    ui:Notify("Success", "Operation completed successfully!", "success", 3)
end)

secToast:AddButton("Warning Toast", function()
    ui:Notify("Warning", "This is a warning message, be careful!", "warning", 3)
end)

secToast:AddButton("Error Toast", function()
    ui:Notify("Error", "A critical error has occurred!", "error", 3)
end)

local secToastAdv = tab6:AddSection("Advanced Toast Tests")

secToastAdv:AddButton("Long Duration (8s)", function()
    ui:Notify("Long Toast", "This notification will stay on screen for 8 seconds.", "info", 8)
end)

secToastAdv:AddButton("Short Duration (1s)", function()
    ui:Notify("Quick", "Very short!", "success", 1)
end)

secToastAdv:AddButton("Spam (5 Toasts At Once)", function()
    ui:Notify("Toast 1", "First notification", "info", 3)
    task.wait(0.15)
    ui:Notify("Toast 2", "Second notification", "success", 3)
    task.wait(0.15)
    ui:Notify("Toast 3", "Third notification", "warning", 3)
    task.wait(0.15)
    ui:Notify("Toast 4", "Fourth notification", "error", 3)
    task.wait(0.15)
    ui:Notify("Toast 5", "Fifth notification", "info", 3)
end)

secToastAdv:AddButton("Long Message Toast", function()
    ui:Notify("Detailed Notification", "This message is very long and tests the text wrapping behavior of the toast component.", "warning", 5)
end)

local secTheme = tab7:AddSection("Theme / ColorPicker Test")

secTheme:AddColorPicker("Select Theme Color", function(idx, theme)
    print("[ColorPicker] Theme:", theme.name, "Index:", idx)
    ui:Notify("Theme Changed", theme.name .. " applied!", "success", 2)
end)

local secCfg = tab7:AddSection("Config Save / Load Test")

secCfg:AddButton("Save Config ('testcfg')", function()
    ui:SaveConfig("testcfg")
end)

secCfg:AddButton("Load Config ('testcfg')", function()
    ui:LoadConfig("testcfg")
end)

secCfg:AddButton("Save As ('backup')", function()
    ui:SaveConfig("backup")
end)

secCfg:AddButton("Load Non-Existent Config (Warning Test)", function()
    ui:LoadConfig("nonexistent_file_xyz")
end)

local secWM = tab7:AddSection("Watermark / HUD Bar Test")

local wmTog = secWM:AddToggle("Watermark Active", true, function(val)
    ui:SetWatermark(val)
end)

secWM:AddButton("Custom Watermark Text", function()
    ui:SetWatermark(true, "Horizon | Custom Text | v2.0")
    wmTog:setValue(true)
    ui:Notify("Watermark", "Custom text applied", "info", 2)
end)

secWM:AddButton("Default Watermark (FPS/Ping)", function()
    ui:SetWatermark(true)
    wmTog:setValue(true)
    ui:Notify("Watermark", "FPS/Ping mode active", "success", 2)
end)

secWM:AddButton("Disable Watermark", function()
    ui:SetWatermark(false)
    wmTog:setValue(false)
    ui:Notify("Watermark", "Disabled", "warning", 2)
end)

local secBadge = tab8:AddSection("Tab Badge Test")

secBadge:AddButton("tab2 Badge → 'NEW'", function()
    tab2:SetBadge("NEW")
    ui:Notify("Badge", "tab2 badge set to 'NEW'", "success", 2)
end)

secBadge:AddButton("tab2 Badge → '99'", function()
    tab2:SetBadge("99")
    ui:Notify("Badge", "tab2 badge set to '99'", "info", 2)
end)

secBadge:AddButton("tab2 Badge Remove", function()
    tab2:SetBadge(nil)
    ui:Notify("Badge", "tab2 badge removed", "warning", 2)
end)

secBadge:AddButton("tab8 Badge → '🔥'", function()
    tab8:SetBadge("🔥")
    ui:Notify("Badge", "This tab badge updated", "success", 2)
end)

local secStatus = tab8:AddSection("SetStatus Test")

secStatus:AddButton("Status: Online", function()
    ui:SetStatus("🟢 Online")
end)

secStatus:AddButton("Status: Active", function()
    ui:SetStatus("⚡ Active...")
end)

secStatus:AddButton("Status: AFK", function()
    ui:SetStatus("💤 AFK")
end)

secStatus:AddButton("Status: Default (@username)", function()
    local plr = game:GetService("Players").LocalPlayer
    ui:SetStatus("@" .. plr.Name)
end)

local secGSearch = tab8:AddSection("Global Search Bar Test")

secGSearch:AddLabel("Use the search box in the left sidebar.")
secGSearch:AddRichLabel("Try typing 'toggle', 'slider', 'input', 'button'.", "info")
secGSearch:AddRichLabel("Search filters elements in the currently active tab.", "warning")
secGSearch:AddToggle("Search Test Toggle 1", false, function(val) print("Search1:", val) end)
secGSearch:AddToggle("Search Test Toggle 2", false, function(val) print("Search2:", val) end)
secGSearch:AddButton("Search Test Button", function() print("Search button clicked") end)
secGSearch:AddSlider("Search Test Slider", 0, 100, 50, function(val) print("Search slider:", val) end)

local secAPI = tab8:AddSection("Element Enable / Disable API Test")

local apiToggle = secAPI:AddToggle("API Test Toggle", false, function(val)
    print("[API Toggle]:", val)
end)

local apiSlider = secAPI:AddSlider("API Test Slider", 0, 100, 50, function(val)
    print("[API Slider]:", val)
end)

local apiInput = secAPI:AddInput("API Test Input", "Type here...", function(text)
    print("[API Input]:", text)
end)

secAPI:AddButton("Disable All", function()
    apiToggle:setDisabled(true)
    apiSlider:setDisabled(true)
    apiInput:setDisabled(true)
    ui:Notify("Disabled", "Toggle, Slider, Input disabled!", "warning", 3)
end)

secAPI:AddButton("Enable All", function()
    apiToggle:setDisabled(false)
    apiSlider:setDisabled(false)
    apiInput:setDisabled(false)
    ui:Notify("Enabled", "Toggle, Slider, Input re-enabled!", "success", 3)
end)

local secHotkey = tab8:AddSection("Hotkeys & UI Controls")

secHotkey:AddRichLabel("INSERT → Hide / Show UI", "info")
secHotkey:AddRichLabel("Minimize button (—) → Pill / compact mode", "info")
secHotkey:AddRichLabel("Resize grip (bottom-right corner) → Resize window", "info")
secHotkey:AddRichLabel("Close button (X) → Opens confirmation dialog", "warning")

print("[HorizonUI Test] All elements loaded successfully!")
print("[HorizonUI Test] Tabs: 8 | Sections: 30+ | Elements: 60+")
