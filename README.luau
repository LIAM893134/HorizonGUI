-- made by vyxonq, modified by halis and aibmpk

-- https://discord.gg/Q2wggVjp



-- load libary

local HorizonUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/LIAM893134/HorizonGUI/refs/heads/main/HorizonLibary.luau"))()



-- create libary 
local lib = HorizonUI.new("RTX CLAN -- GUI EXAMPLE")

-- add tab
local main = lib:AddTab("Main", "rbxassetid://10723407389")

-- add section
local sec1 = main:AddSection("Main")

-- add label
sec1:AddLabel("this is a label")

-- add button 
sec1:AddButton("Feature",function()
-- code here 
end)

-- add toogle 

local toggle = sec1:AddToggle("Enable Feature", false, function(state)
	print("Toggle:", state)
end)

-- add slider
sec1:AddSlider("Speed", 0, 200, 80, function(val)
	print("Slider:", val)
end)

-- add dropdown
sec1:AddDropdown("Team", {"Red", "Blue", "Green"}, "Blue", function(choice)
	print("Selected:", choice)
end)

-- create color picker
sec1:AddColorPicker("pick a color", nil)
