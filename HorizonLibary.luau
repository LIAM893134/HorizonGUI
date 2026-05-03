-- Horizon UI Full Merged v1.2.0
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local SCALE    = isMobile and 0.78 or 1.0
local TS       = isMobile and 11 or 14

local function s(v) return math.floor(v * SCALE) end
local function clamp(x, a, b) return math.max(a, math.min(b, x)) end

local SIDEBAR_W = isMobile and 190 or 210
local MIN_W, MIN_H = isMobile and 420 or 560, isMobile and 280 or 380
local MAX_W, MAX_H = 1200, 750

local Themes = {
	{name="Horizon",accent1=Color3.fromRGB(99,102,241),accent2=Color3.fromRGB(168,85,247),background=Color3.fromRGB(9,9,14),sidebar=Color3.fromRGB(13,13,20),text=Color3.fromRGB(240,240,250),subtext=Color3.fromRGB(140,140,165),stroke=Color3.fromRGB(50,50,80),elementBg=Color3.fromRGB(18,18,28),toggleOff=Color3.fromRGB(45,45,65),trackBg=Color3.fromRGB(38,38,58)},
	{name="Neon",accent1=Color3.fromRGB(0,255,200),accent2=Color3.fromRGB(0,180,255),background=Color3.fromRGB(5,10,14),sidebar=Color3.fromRGB(7,14,20),text=Color3.fromRGB(230,250,255),subtext=Color3.fromRGB(120,170,190),stroke=Color3.fromRGB(0,80,100),elementBg=Color3.fromRGB(10,20,28),toggleOff=Color3.fromRGB(30,55,65),trackBg=Color3.fromRGB(25,50,65)},
	{name="Rose",accent1=Color3.fromRGB(244,63,94),accent2=Color3.fromRGB(251,113,133),background=Color3.fromRGB(12,7,9),sidebar=Color3.fromRGB(17,10,13),text=Color3.fromRGB(255,240,245),subtext=Color3.fromRGB(180,140,155),stroke=Color3.fromRGB(80,30,45),elementBg=Color3.fromRGB(22,13,18),toggleOff=Color3.fromRGB(65,35,45),trackBg=Color3.fromRGB(55,30,40)},
	{name="Ocean",accent1=Color3.fromRGB(56,189,248),accent2=Color3.fromRGB(99,102,241),background=Color3.fromRGB(7,12,18),sidebar=Color3.fromRGB(10,16,24),text=Color3.fromRGB(230,245,255),subtext=Color3.fromRGB(120,160,190),stroke=Color3.fromRGB(30,70,110),elementBg=Color3.fromRGB(14,22,34),toggleOff=Color3.fromRGB(35,60,85),trackBg=Color3.fromRGB(30,55,80)},
	{name="Gold",accent1=Color3.fromRGB(251,191,36),accent2=Color3.fromRGB(245,158,11),background=Color3.fromRGB(13,11,6),sidebar=Color3.fromRGB(18,15,8),text=Color3.fromRGB(255,250,235),subtext=Color3.fromRGB(180,165,120),stroke=Color3.fromRGB(90,70,20),elementBg=Color3.fromRGB(22,18,10),toggleOff=Color3.fromRGB(65,55,25),trackBg=Color3.fromRGB(58,48,22)},
	{name="Sakura",accent1=Color3.fromRGB(236,72,153),accent2=Color3.fromRGB(168,85,247),background=Color3.fromRGB(12,8,14),sidebar=Color3.fromRGB(17,11,19),text=Color3.fromRGB(255,240,255),subtext=Color3.fromRGB(190,155,210),stroke=Color3.fromRGB(90,40,110),elementBg=Color3.fromRGB(22,14,26),toggleOff=Color3.fromRGB(68,40,80),trackBg=Color3.fromRGB(60,35,72)},
}

local Icons = {
	close="rbxassetid://10747384394",minimize="rbxassetid://10734896206",
	home="rbxassetid://10723407389",settings="rbxassetid://10734950309",
	plus="rbxassetid://10734924532",user="rbxassetid://10747373176",
	star="rbxassetid://10734966248",
}

local function MakeCorner(parent, radius)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius or s(10)); c.Parent = parent; return c
end
local function MakeStroke(parent, color, transparency, thickness)
	local st = Instance.new("UIStroke"); st.Color = color or Color3.fromRGB(255,255,255); st.Transparency = transparency or 0.85; st.Thickness = thickness or 1; st.Parent = parent; return st
end
local function MakeGradient(parent, c1, c2, rotation)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,c1),ColorSequenceKeypoint.new(1,c2)})
	g.Rotation = rotation or 90; g.Parent = parent; return g
end
local function UpdateGradient(g, c1, c2)
	if not g then return end
	g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,c1),ColorSequenceKeypoint.new(1,c2)})
end
local function Tween(obj, props, t, style, dir)
	TweenService:Create(obj, TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end
local function MakeIcon(parent, asset, size, color)
	local img = Instance.new("ImageLabel")
	img.Size = UDim2.new(0,size or s(14),0,size or s(14)); img.AnchorPoint = Vector2.new(0.5,0.5)
	img.Position = UDim2.new(0.5,0,0.5,0); img.BackgroundTransparency = 1
	img.Image = asset or ""; img.ImageColor3 = color or Color3.fromRGB(255,255,255)
	img.Parent = parent; return img
end

local HorizonUI = {}; HorizonUI.__index = HorizonUI
local Tab = {}; Tab.__index = Tab
local Section = {}; Section.__index = Section

local _state = {themeIndex=1, bgTransparency=0.06}

function HorizonUI.new(title)
	local self = setmetatable({}, HorizonUI)
	self.title       = title or "Horizon"
	self.version     = "1.2.0"
	self.discord     = "https://discord.gg/yourlink"
	
	self.player      = Players.LocalPlayer
	self.playerGui   = self.player:WaitForChild("PlayerGui")
	self.tabs        = {}
	self.activeTab   = nil
	self.isMinimized = false
	self.dialogOpen  = false
	self._themeReg   = {}
	self._sliderDrag = false
	self._guiW       = isMobile and 580 or 820
	self._guiH       = isMobile and 370 or 510
	self._searchQuery = ""
	self:_build()
	return self
end

function HorizonUI:_theme() return Themes[_state.themeIndex] end
function HorizonUI:_regTheme(element, kind, extra)
	table.insert(self._themeReg, {element=element, kind=kind, extra=extra})
end


function HorizonUI:SetAccentColor(color)
	local theme = self:_theme()
	theme.accent1 = color
	theme.accent2 = color:lerp(Color3.fromRGB(255,255,255), 0.25)
	self:_applyTheme(_state.themeIndex)
end


function HorizonUI:AddColorPicker(name, default, callback)
	local sec = self.activeTab.sections[1] or self.activeTab:AddSection("")
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,0,s(125))
	frame.BackgroundTransparency = 1
	frame.Parent = sec._elems

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,-s(20),0,s(20))
	lbl.Position = UDim2.new(0,s(12),0,0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = self:_theme().text
	lbl.TextSize = TS
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = frame

	local picker = Instance.new("ImageLabel")
	picker.Size = UDim2.new(0,s(85),0,s(85))
	picker.Position = UDim2.new(0,s(20),0,s(30))
	picker.BackgroundTransparency = 1
	picker.Image = "rbxassetid://415580125"
	picker.Parent = frame

	local thumb = Instance.new("Frame")
	thumb.Size = UDim2.new(0,s(14),0,s(14))
	thumb.BackgroundColor3 = Color3.new(1,1,1)
	thumb.BorderSizePixel = 0
	thumb.ZIndex = 10
	thumb.Parent = picker
	MakeCorner(thumb, s(7))
	MakeStroke(thumb, Color3.new(0,0,0), 0.5, 2)

	local preview = Instance.new("Frame")
	preview.Size = UDim2.new(0,s(70),0,s(32))
	preview.Position = UDim2.new(1,-s(90),0,s(55))
	preview.BackgroundColor3 = default or Color3.fromRGB(99,102,241)
	MakeCorner(preview, s(8))
	preview.Parent = frame

	local currentColor = default or Color3.fromRGB(99,102,241)
	local dragging = false

	picker.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = true end
	end)

	UserInputService.InputChanged:Connect(function(inp)
		if not dragging then return end
		local center = picker.AbsolutePosition + picker.AbsoluteSize/2
		local dir = Vector2.new(inp.Position.X, inp.Position.Y) - center
		local radius = picker.AbsoluteSize.X / 2
		local dist = math.min(dir.Magnitude, radius)
		local angle = math.atan2(dir.Y, dir.X)

		local h = (angle + math.pi) / (2 * math.pi)
		currentColor = Color3.fromHSV(h, dist / radius, 1)

		preview.BackgroundColor3 = currentColor
		thumb.Position = UDim2.new(0.5, math.cos(angle) * dist * 0.82, 0.5, math.sin(angle) * dist * 0.82)

		self:SetAccentColor(currentColor)
		if callback then callback(currentColor) end
	end)

	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
end

function HorizonUI:AddTransparencySlider(callback)
	local sec = self.activeTab.sections[1] or self.activeTab:AddSection("")
	sec:AddSlider("Background Transparency", 0, 100, _state.bgTransparency*100, function(val)
		_state.bgTransparency = val/100
		self.main.BackgroundTransparency = _state.bgTransparency
		if callback then callback(_state.bgTransparency) end
	end)
end

function HorizonUI:SaveConfig(name)
	name = name or "Horizon_Config"
	if not writefile then self:Notify("Config", "writefile not supported!", "error", 3) return end
	local data = {
		theme = _state.themeIndex,
		accent = self:_theme().accent1,
		bgTransparency = _state.bgTransparency
	}
	writefile(name..".json", game:GetService("HttpService"):JSONEncode(data))
	self:Notify("Config Saved", name..".json", "success", 3)
end

function HorizonUI:LoadConfig(name)
	name = name or "Horizon_Config"
	if not readfile then self:Notify("Config", "readfile not supported!", "error", 3) return end
	local ok, raw = pcall(readfile, name..".json")
	if not ok then self:Notify("Config", "File not found", "warning", 3) return end
	local ok2, data = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
	if not ok2 then return end
	if data.accent then self:SetAccentColor(data.accent) end
	if data.bgTransparency then
		_state.bgTransparency = data.bgTransparency
		self.main.BackgroundTransparency = _state.bgTransparency
	end
	self:Notify("Config Loaded", name..".json", "success", 3)
end

function Tab:AddButton(...) return (self.sections[1] or self:AddSection("")).AddButton(...) end
function Tab:AddToggle(...) return (self.sections[1] or self:AddSection("")).AddToggle(...) end
function Tab:AddSlider(...) return (self.sections[1] or self:AddSection("")).AddSlider(...) end
function Tab:AddDropdown(...) return (self.sections[1] or self:AddSection("")).AddDropdown(...) end
function Tab:AddLabel(...) return (self.sections[1] or self:AddSection("")).AddLabel(...) end
function Tab:AddInput(...) return (self.sections[1] or self:AddSection("")).AddInput(...) end


function HorizonUI:_build()
	local theme = self:_theme()
	local W, H  = self._guiW, self._guiH

	self.gui = Instance.new("ScreenGui")
	self.gui.Name = "HorizonUI"; self.gui.ResetOnSpawn = false
	self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; self.gui.Parent = self.playerGui

	self.main = Instance.new("Frame")
	self.main.Name = "Main"; self.main.Size = UDim2.new(0,W,0,H)
	self.main.Position = UDim2.new(0.5,-W/2,0.5,-H/2)
	self.main.BackgroundColor3 = theme.background; self.main.BackgroundTransparency = _state.bgTransparency
	self.main.BorderSizePixel = 0; self.main.Parent = self.gui
	MakeCorner(self.main, s(18)); self.mainStroke = MakeStroke(self.main, theme.stroke, 0.45, 1)

	self.titleBar = Instance.new("Frame")
	self.titleBar.Name = "TitleBar"; self.titleBar.Size = UDim2.new(1,0,0,s(42))
	self.titleBar.BackgroundTransparency = 1; self.titleBar.Parent = self.main

	local sepLine = Instance.new("Frame")
	sepLine.Size = UDim2.new(1,-s(40),0,1); sepLine.Position = UDim2.new(0,s(20),0,s(42))
	sepLine.BorderSizePixel = 0; sepLine.BackgroundColor3 = Color3.fromRGB(255,255,255); sepLine.Parent = self.main
	self._sepLine = sepLine; self._sepGrad = MakeGradient(sepLine, theme.accent1, theme.accent2, 0)

	self._sepAnim = RunService.Heartbeat:Connect(function()
		if self._sepGrad and self._sepGrad.Parent then self._sepGrad.Rotation = (self._sepGrad.Rotation+0.4)%360 end
	end)

	local topEdge = Instance.new("Frame")
	topEdge.Size = UDim2.new(0.6,0,0,1); topEdge.Position = UDim2.new(0.2,0,0,0)
	topEdge.BackgroundColor3 = Color3.fromRGB(255,255,255); topEdge.BackgroundTransparency = 0.55
	topEdge.BorderSizePixel = 0; topEdge.Parent = self.main; MakeCorner(topEdge, 1)

	self:_buildControls(); self:_buildSidebar(); self:_buildContent()
	self:_buildMiniBar(); self:_buildResizeHandle(); self:_buildWatermark()
	self:_setupDrag(); self:_setupHotkey(); self:_applyTheme(_state.themeIndex); self:_animateIn()
end

function HorizonUI:_build()
	local theme = self:_theme()
	local W, H  = self._guiW, self._guiH

	self.gui = Instance.new("ScreenGui")
	self.gui.Name = "HorizonUI"; self.gui.ResetOnSpawn = false
	self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; self.gui.Parent = self.playerGui

	self.main = Instance.new("Frame")
	self.main.Name = "Main"; self.main.Size = UDim2.new(0,W,0,H)
	self.main.Position = UDim2.new(0.5,-W/2,0.5,-H/2)
	self.main.BackgroundColor3 = theme.background; self.main.BackgroundTransparency = 0.06
	self.main.BorderSizePixel = 0; self.main.Parent = self.gui
	MakeCorner(self.main, s(18)); self.mainStroke = MakeStroke(self.main, theme.stroke, 0.45, 1)

	self.titleBar = Instance.new("Frame")
	self.titleBar.Name = "TitleBar"; self.titleBar.Size = UDim2.new(1,0,0,s(42))
	self.titleBar.BackgroundTransparency = 1; self.titleBar.Parent = self.main

	local sepLine = Instance.new("Frame")
	sepLine.Size = UDim2.new(1,-s(40),0,1); sepLine.Position = UDim2.new(0,s(20),0,s(42))
	sepLine.BorderSizePixel = 0; sepLine.BackgroundColor3 = Color3.fromRGB(255,255,255); sepLine.Parent = self.main
	self._sepLine = sepLine; self._sepGrad = MakeGradient(sepLine, theme.accent1, theme.accent2, 0)

	self._sepAnim = RunService.Heartbeat:Connect(function()
		if self._sepGrad and self._sepGrad.Parent then self._sepGrad.Rotation = (self._sepGrad.Rotation+0.4)%360 end
	end)

	local topEdge = Instance.new("Frame")
	topEdge.Size = UDim2.new(0.6,0,0,1); topEdge.Position = UDim2.new(0.2,0,0,0)
	topEdge.BackgroundColor3 = Color3.fromRGB(255,255,255); topEdge.BackgroundTransparency = 0.55
	topEdge.BorderSizePixel = 0; topEdge.Parent = self.main; MakeCorner(topEdge, 1)

	self:_buildControls(); self:_buildSidebar(); self:_buildContent()
	self:_buildMiniBar(); self:_buildResizeHandle(); self:_buildWatermark()
	self:_setupDrag(); self:_setupHotkey(); self:_applyTheme(_state.themeIndex); self:_animateIn()
end

function HorizonUI:_buildWatermark()
	local theme = self:_theme()
	self._watermark = Instance.new("Frame")
	self._watermark.Name = "Watermark"
	self._watermark.Size = UDim2.new(0, s(220), 0, s(26))
	self._watermark.Position = UDim2.new(1, -s(230), 0, s(10))
	self._watermark.BackgroundColor3 = theme.sidebar
	self._watermark.BackgroundTransparency = 0.12
	self._watermark.BorderSizePixel = 0
	self._watermark.Parent = self.gui
	self._watermark.Visible = false
	MakeCorner(self._watermark, s(8))
	MakeStroke(self._watermark, theme.stroke, 0.5, 1)

	self._wmLabel = Instance.new("TextLabel")
	self._wmLabel.Size = UDim2.new(1,-s(10),1,0)
	self._wmLabel.Position = UDim2.new(0,s(8),0,0)
	self._wmLabel.BackgroundTransparency = 1
	self._wmLabel.Text = "Horizon | FPS: -- | Ping: --"
	self._wmLabel.TextColor3 = theme.text
	self._wmLabel.TextSize = s(10)
	self._wmLabel.Font = Enum.Font.GothamBold
	self._wmLabel.TextXAlignment = Enum.TextXAlignment.Left
	self._wmLabel.Parent = self._watermark

	self._wmVisible = false
	self._wmConn = nil
end

function HorizonUI:SetWatermark(enabled, customText)
	self._wmVisible = enabled
	self._watermark.Visible = enabled
	if enabled then
		if self._wmConn then self._wmConn:Disconnect() end
		self._wmConn = RunService.Heartbeat:Connect(function()
			if not self._watermark or not self._watermark.Parent then return end
			local fps = math.floor(1/RunService.Heartbeat:Wait())
			local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
			if customText then
				self._wmLabel.Text = customText
			else
				self._wmLabel.Text = string.format("%s | FPS: %d | Ping: %dms", self.title, fps, math.floor(ping))
			end
		end)
	else
		if self._wmConn then self._wmConn:Disconnect(); self._wmConn = nil end
	end
end

function HorizonUI:Notify(title, message, notifType, duration)
	notifType = notifType or "info"
	duration  = duration or 3
	local typeColors = {
		info    = Color3.fromRGB(99,102,241),
		success = Color3.fromRGB(34,197,94),
		warning = Color3.fromRGB(251,191,36),
		error   = Color3.fromRGB(239,68,68),
	}
	local typeIcons = {info="ℹ", success="✓", warning="⚠", error="✕"}
	local accent = typeColors[notifType] or typeColors.info
	local theme  = self:_theme()
	if not self._notifStack then self._notifStack = 0 end
	self._notifStack = self._notifStack + 1
	local stackIdx = self._notifStack
	local W, H = s(280), s(72)
	local yOff = (stackIdx-1) * (H + s(8))
	local notif = Instance.new("Frame")
	notif.Name = "Notif"
	notif.Size = UDim2.new(0,0,0,H)
	notif.Position = UDim2.new(1,s(10), 1, -(H+s(20)+yOff))
	notif.BackgroundColor3 = theme.sidebar
	notif.BackgroundTransparency = 0.08
	notif.BorderSizePixel = 0
	notif.Parent = self.gui
	MakeCorner(notif, s(12))
	MakeStroke(notif, accent, 0.55, 1)
	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0,s(3),0.7,0); bar.Position = UDim2.new(0,s(8),0.15,0)
	bar.BackgroundColor3 = accent; bar.BorderSizePixel = 0; bar.Parent = notif
	MakeCorner(bar, s(2))
	local iconBg = Instance.new("Frame")
	iconBg.Size = UDim2.new(0,s(28),0,s(28)); iconBg.Position = UDim2.new(0,s(16),0.5,-s(14))
	iconBg.BackgroundColor3 = accent; iconBg.BackgroundTransparency = 0.75
	iconBg.BorderSizePixel = 0; iconBg.Parent = notif; MakeCorner(iconBg, s(8))
	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.new(1,0,1,0); iconLbl.BackgroundTransparency = 1
	iconLbl.Text = typeIcons[notifType] or "ℹ"; iconLbl.TextColor3 = accent
	iconLbl.TextSize = s(14); iconLbl.Font = Enum.Font.GothamBold; iconLbl.Parent = iconBg
	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1,-s(60),0,s(20)); titleLbl.Position = UDim2.new(0,s(52),0,s(10))
	titleLbl.BackgroundTransparency = 1; titleLbl.Text = title or "Notification"
	titleLbl.TextColor3 = theme.text; titleLbl.TextSize = s(12); titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.Parent = notif
	local msgLbl = Instance.new("TextLabel")
	msgLbl.Size = UDim2.new(1,-s(60),0,s(28)); msgLbl.Position = UDim2.new(0,s(52),0,s(30))
	msgLbl.BackgroundTransparency = 1; msgLbl.Text = message or ""
	msgLbl.TextColor3 = theme.subtext; msgLbl.TextSize = s(10); msgLbl.Font = Enum.Font.Gotham
	msgLbl.TextXAlignment = Enum.TextXAlignment.Left; msgLbl.TextWrapped = true; msgLbl.Parent = notif
	local progBg = Instance.new("Frame")
	progBg.Size = UDim2.new(1,-s(16),0,s(2)); progBg.Position = UDim2.new(0,s(8),1,-s(6))
	progBg.BackgroundColor3 = Color3.fromRGB(255,255,255); progBg.BackgroundTransparency = 0.85
	progBg.BorderSizePixel = 0; progBg.Parent = notif; MakeCorner(progBg, 1)
	local progFill = Instance.new("Frame")
	progFill.Size = UDim2.new(1,0,1,0); progFill.BackgroundColor3 = accent
	progFill.BorderSizePixel = 0; progFill.Parent = progBg; MakeCorner(progFill, 1)
	Tween(notif, {Size=UDim2.new(0,W,0,H), Position=UDim2.new(1,-(W+s(12)),1,-(H+s(20)+yOff))}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	Tween(progFill, {Size=UDim2.new(0,0,1,0)}, duration, Enum.EasingStyle.Linear)
	task.delay(duration, function()
		Tween(notif, {Position=UDim2.new(1,s(10),1,-(H+s(20)+yOff))}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.wait(0.3); notif:Destroy(); self._notifStack = math.max(0, self._notifStack-1)
	end)
end

function HorizonUI:_buildControls()
	local theme = self:_theme()
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1,-s(120),1,0); titleLabel.Position = UDim2.new(0,SIDEBAR_W+s(14),0,0)
	titleLabel.BackgroundTransparency = 1; titleLabel.Text = self.title
	titleLabel.TextColor3 = theme.text; titleLabel.TextSize = s(13); titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left; titleLabel.Parent = self.titleBar
	self._titleLabel = titleLabel
	local ctrlFrame = Instance.new("Frame")
	ctrlFrame.Size = UDim2.new(0,s(80),1,0); ctrlFrame.Position = UDim2.new(1,-s(92),0,0)
	ctrlFrame.BackgroundTransparency = 1; ctrlFrame.Parent = self.titleBar
	local function makeBtn(xOff, iconAsset, iconColor)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0,s(30),0,s(30)); btn.Position = UDim2.new(0,xOff,0.5,-s(15))
		btn.BackgroundColor3 = Color3.fromRGB(255,255,255); btn.BackgroundTransparency = 0.92
		btn.BorderSizePixel = 0; btn.Text = ""; btn.Parent = ctrlFrame
		MakeCorner(btn, s(8)); MakeIcon(btn, iconAsset, s(14), iconColor)
		btn.MouseEnter:Connect(function() Tween(btn, {BackgroundTransparency=0.80}) end)
		btn.MouseLeave:Connect(function() Tween(btn, {BackgroundTransparency=0.92}) end)
		return btn
	end
	local minBtn = makeBtn(0, Icons.minimize, Color3.fromRGB(220,220,230))
	minBtn.MouseButton1Click:Connect(function() if not self.dialogOpen then self:_toggleMin() end end)
	local closeBtn = makeBtn(s(40), Icons.close, Color3.fromRGB(255,100,100))
	closeBtn.MouseButton1Click:Connect(function() if not self.dialogOpen then self:_closeDialog() end end)
end

function HorizonUI:_buildSidebar()
	local theme = self:_theme()
	self.sidebar = Instance.new("Frame")
	self.sidebar.Name = "Sidebar"; self.sidebar.Size = UDim2.new(0,SIDEBAR_W,1,0)
	self.sidebar.BackgroundColor3 = theme.sidebar; self.sidebar.BackgroundTransparency = 0.04
	self.sidebar.BorderSizePixel = 0; self.sidebar.Parent = self.main
	MakeCorner(self.sidebar, s(18)); self.sidebarStroke = MakeStroke(self.sidebar, theme.stroke, 0.55, 1)

	local macDots = Instance.new("Frame"); macDots.Size = UDim2.new(0,s(54),0,s(12))
	macDots.Position = UDim2.new(0,s(14),0,s(16)); macDots.BackgroundTransparency = 1; macDots.Parent = self.sidebar
	for i, color in ipairs({Color3.fromRGB(255,95,86),Color3.fromRGB(255,189,46),Color3.fromRGB(39,201,63)}) do
		local dot = Instance.new("Frame"); dot.Size = UDim2.new(0,s(12),0,s(12))
		dot.Position = UDim2.new(0,(i-1)*s(20),0,0); dot.BackgroundColor3 = color
		dot.BorderSizePixel = 0; dot.Parent = macDots; MakeCorner(dot, s(6))
	end

	local logoArea = Instance.new("Frame"); logoArea.Size = UDim2.new(1,-s(24),0,s(52))
	logoArea.Position = UDim2.new(0,s(12),0,s(38)); logoArea.BackgroundTransparency = 1; logoArea.Parent = self.sidebar
	local accentBar = Instance.new("Frame"); accentBar.Size = UDim2.new(0,s(3),0,s(18))
	accentBar.Position = UDim2.new(0,0,0.5,-s(9)); accentBar.BorderSizePixel = 0
	accentBar.BackgroundColor3 = theme.accent1; accentBar.Parent = logoArea; MakeCorner(accentBar, s(4))
	self._accentBarGrad = MakeGradient(accentBar, theme.accent1, theme.accent2, 90)
	spawn(function()
		while accentBar and accentBar.Parent do
			Tween(accentBar,{Size=UDim2.new(0,s(3),0,s(24))},0.9,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
			task.wait(0.9)
			Tween(accentBar,{Size=UDim2.new(0,s(3),0,s(14))},0.9,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
			task.wait(0.9)
		end
	end)
	local logoLabel = Instance.new("TextLabel"); logoLabel.Size = UDim2.new(1,-s(12),1,0)
	logoLabel.Position = UDim2.new(0,s(10),0,0); logoLabel.BackgroundTransparency = 1
	logoLabel.Text = self.title; logoLabel.TextColor3 = theme.text; logoLabel.TextSize = s(19)
	logoLabel.Font = Enum.Font.GothamBold; logoLabel.TextXAlignment = Enum.TextXAlignment.Left
	logoLabel.Parent = logoArea; self._logoLabel = logoLabel

	local searchFrame = Instance.new("Frame")
	searchFrame.Size = UDim2.new(1,-s(24),0,s(30))
	searchFrame.Position = UDim2.new(0,s(12),0,s(96))
	searchFrame.BackgroundColor3 = theme.elementBg
	searchFrame.BackgroundTransparency = 0.25
	searchFrame.BorderSizePixel = 0
	searchFrame.Parent = self.sidebar
	MakeCorner(searchFrame, s(8))
	self._searchStroke = MakeStroke(searchFrame, theme.stroke, 0.55, 1)
	local searchIcon = Instance.new("TextLabel")
	searchIcon.Size = UDim2.new(0,s(20),1,0); searchIcon.Position = UDim2.new(0,s(6),0,0)
	searchIcon.BackgroundTransparency = 1; searchIcon.Text = "⌕"
	searchIcon.TextColor3 = theme.subtext; searchIcon.TextSize = s(14); searchIcon.Font = Enum.Font.Gotham
	searchIcon.Parent = searchFrame
	local searchBox = Instance.new("TextBox")
	searchBox.Size = UDim2.new(1,-s(28),1,0); searchBox.Position = UDim2.new(0,s(22),0,0)
	searchBox.BackgroundTransparency = 1; searchBox.Text = ""
	searchBox.PlaceholderText = "Search..."; searchBox.PlaceholderColor3 = theme.subtext
	searchBox.TextColor3 = theme.text; searchBox.TextSize = s(11); searchBox.Font = Enum.Font.Gotham
	searchBox.TextXAlignment = Enum.TextXAlignment.Left; searchBox.ClearTextOnFocus = false
	searchBox.Parent = searchFrame
	local pad = Instance.new("UIPadding"); pad.PaddingRight = UDim.new(0,s(6)); pad.Parent = searchBox
	searchBox.Focused:Connect(function()
		Tween(self._searchStroke, {Transparency=0.35, Color=self:_theme().accent1})
	end)
	searchBox.FocusLost:Connect(function()
		Tween(self._searchStroke, {Transparency=0.55, Color=self:_theme().stroke})
	end)
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		self._searchQuery = searchBox.Text:lower()
		self:_applySearch()
	end)
	self._searchBox = searchBox


	self.tabsContainer = Instance.new("ScrollingFrame")
	self.tabsContainer.Name = "Tabs"
	self.tabsContainer.Size = UDim2.new(1,-s(8),1,-s(230))
	self.tabsContainer.Position = UDim2.new(0,s(4),0,s(134))
	self.tabsContainer.BackgroundTransparency = 1
	self.tabsContainer.BorderSizePixel = 0
	self.tabsContainer.ScrollBarThickness = 2
	self.tabsContainer.ScrollBarImageColor3 = Color3.fromRGB(255,255,255)
	self.tabsContainer.ScrollBarImageTransparency = 0.7
	self.tabsContainer.CanvasSize = UDim2.new(0,0,0,0)
	self.tabsContainer.ScrollingDirection = Enum.ScrollingDirection.Y
	self.tabsContainer.ClipsDescendants = true
	self.tabsContainer.Parent = self.sidebar

	
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Name = "TabLayout"
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Padding = UDim.new(0, s(6))
	tabLayout.Parent = self.tabsContainer

	local tabPad = Instance.new("UIPadding")
	tabPad.PaddingLeft = UDim.new(0, s(8))
	tabPad.PaddingRight = UDim.new(0, s(8))
	tabPad.PaddingTop = UDim.new(0, s(4))
	tabPad.PaddingBottom = UDim.new(0, s(4))
	tabPad.Parent = self.tabsContainer

	tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.tabsContainer.CanvasSize = UDim2.new(0,0,0,tabLayout.AbsoluteContentSize.Y + s(8))
	end)

	self:_buildUserCard()
end

function HorizonUI:_applySearch()
	local q = self._searchQuery
	if not self.activeTab then return end
	for _, sec in ipairs(self.activeTab.sections) do
		sec:_applySearch(q)
	end
end

function HorizonUI:_buildUserCard()
	local theme  = self:_theme(); local player = self.player
	local card = Instance.new("Frame"); card.Size = UDim2.new(1,-s(24),0,s(62))
	card.Position = UDim2.new(0,s(12),1,-s(76)); card.BackgroundColor3 = Color3.fromRGB(255,255,255)
	card.BackgroundTransparency = 0.94; card.BorderSizePixel = 0; card.Parent = self.sidebar
	MakeCorner(card, s(12)); self._userCardStroke = MakeStroke(card, theme.stroke, 0.6, 1)
	local avatarSize = s(38)
	local avatar = Instance.new("ImageLabel"); avatar.Size = UDim2.new(0,avatarSize,0,avatarSize)
	avatar.Position = UDim2.new(0,s(10),0.5,-avatarSize/2); avatar.BackgroundColor3 = theme.elementBg
	avatar.BorderSizePixel = 0
	avatar.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	avatar.Parent = card; MakeCorner(avatar, avatarSize)
	local ring = Instance.new("Frame"); ring.Size = UDim2.new(0,avatarSize+s(4),0,avatarSize+s(4))
	ring.Position = UDim2.new(0,s(10)-s(2),0.5,-(avatarSize+s(4))/2); ring.BackgroundTransparency = 1
	ring.BorderSizePixel = 0; ring.Parent = card; MakeCorner(ring,(avatarSize+s(4))/2)
	self._avatarRingStroke = MakeStroke(ring, theme.accent1, 0.3, 1.5)
	local nameX = avatarSize+s(14)
	local nameLabel = Instance.new("TextLabel"); nameLabel.Size = UDim2.new(1,-(nameX+s(8)),0,s(18))
	nameLabel.Position = UDim2.new(0,nameX,0,s(12)); nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.DisplayName; nameLabel.TextColor3 = theme.text; nameLabel.TextSize = s(13)
	nameLabel.Font = Enum.Font.GothamBold; nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd; nameLabel.Parent = card
	self._statusLabel = Instance.new("TextLabel"); self._statusLabel.Size = UDim2.new(1,-(nameX+s(8)),0,s(16))
	self._statusLabel.Position = UDim2.new(0,nameX,0,s(30)); self._statusLabel.BackgroundTransparency = 1
	self._statusLabel.Text = "@"..player.Name; self._statusLabel.TextColor3 = theme.subtext
	self._statusLabel.TextSize = s(11); self._statusLabel.Font = Enum.Font.GothamMedium
	self._statusLabel.TextXAlignment = Enum.TextXAlignment.Left; self._statusLabel.TextTruncate = Enum.TextTruncate.AtEnd
	self._statusLabel.Parent = card
end

function HorizonUI:_buildContent()
	self.contentArea = Instance.new("Frame"); self.contentArea.Name = "Content"
	self.contentArea.Size = UDim2.new(1,-SIDEBAR_W,1,-s(44)); self.contentArea.Position = UDim2.new(0,SIDEBAR_W,0,s(44))
	self.contentArea.BackgroundTransparency = 1; self.contentArea.BorderSizePixel = 0; self.contentArea.Parent = self.main
	self.contentContainer = Instance.new("Frame"); self.contentContainer.Name = "Container"
	self.contentContainer.Size = UDim2.new(1,0,1,0); self.contentContainer.BackgroundTransparency = 1
	self.contentContainer.Parent = self.contentArea
end

function HorizonUI:_buildMiniBar()
	local theme = self:_theme()
	self.miniBar = Instance.new("Frame"); self.miniBar.Name = "MiniBar"
	self.miniBar.Size = UDim2.new(1,0,1,0); self.miniBar.Position = UDim2.new(0,0,0,0)
	self.miniBar.BackgroundTransparency = 1; self.miniBar.BorderSizePixel = 0
	self.miniBar.Visible = false; self.miniBar.Parent = self.main
	local crownBg = Instance.new("Frame"); crownBg.Size = UDim2.new(0,s(30),0,s(30))
	crownBg.AnchorPoint = Vector2.new(0,0.5); crownBg.Position = UDim2.new(0,s(14),0.5,0)
	crownBg.BackgroundColor3 = theme.accent1; crownBg.BackgroundTransparency = 0.75
	crownBg.BorderSizePixel = 0; crownBg.Parent = self.miniBar; MakeCorner(crownBg, s(8))
	self._miniCrownBg = crownBg; self._miniCrownGrad = MakeGradient(crownBg, theme.accent1, theme.accent2, 135)
	MakeIcon(crownBg, Icons.star, s(16), Color3.fromRGB(255,255,255))
	local miniTitle = Instance.new("TextLabel"); miniTitle.Size = UDim2.new(1,-(s(30)+s(14)+s(80)),1,0)
	miniTitle.Position = UDim2.new(0,s(14)+s(30)+s(10),0,0); miniTitle.BackgroundTransparency = 1
	miniTitle.Text = self.title; miniTitle.TextColor3 = theme.text; miniTitle.TextSize = s(14)
	miniTitle.Font = Enum.Font.GothamBold; miniTitle.TextXAlignment = Enum.TextXAlignment.Left
	miniTitle.TextTruncate = Enum.TextTruncate.AtEnd; miniTitle.Parent = self.miniBar; self._miniTitle = miniTitle
	local expandBtn = Instance.new("TextButton"); expandBtn.Size = UDim2.new(0,s(90),0,s(28))
	expandBtn.AnchorPoint = Vector2.new(1,0.5); expandBtn.Position = UDim2.new(1,-s(12),0.5,0)
	expandBtn.BackgroundColor3 = theme.accent1; expandBtn.BackgroundTransparency = 0.55
	expandBtn.BorderSizePixel = 0; expandBtn.Text = "▲  Expand"; expandBtn.TextColor3 = Color3.fromRGB(255,255,255)
	expandBtn.TextSize = s(11); expandBtn.Font = Enum.Font.GothamBold; expandBtn.Parent = self.miniBar
	MakeCorner(expandBtn, s(8)); self._miniCrownGrad2 = MakeGradient(expandBtn, theme.accent1, theme.accent2, 135)
	self._miniExpandBtn = expandBtn
	expandBtn.MouseEnter:Connect(function() Tween(expandBtn, {BackgroundTransparency=0.28}) end)
	expandBtn.MouseLeave:Connect(function() Tween(expandBtn, {BackgroundTransparency=0.55}) end)
	expandBtn.MouseButton1Click:Connect(function() if self.isMinimized then self:_toggleMin() end end)
	self:_regTheme(crownBg, "accent_bg", {grad=self._miniCrownGrad})
	self:_regTheme(expandBtn, "accent_bg", {grad=self._miniCrownGrad2})
	self:_regTheme(miniTitle, "text_color", nil)
end

function HorizonUI:_buildResizeHandle()
	local gripSize = s(22)
	local grip = Instance.new("Frame"); grip.Name = "ResizeGrip"
	grip.Size = UDim2.new(0,gripSize,0,gripSize); grip.Position = UDim2.new(1,-gripSize-s(4),1,-gripSize-s(4))
	grip.BackgroundTransparency = 1; grip.BorderSizePixel = 0; grip.Parent = self.main; self._resizeGrip = grip
	local dotPositions = {{x=0.65,y=1.0},{x=1.0,y=0.65},{x=1.0,y=1.0},{x=0.3,y=1.0},{x=1.0,y=0.3}}
	for _, pos in ipairs(dotPositions) do
		local dot = Instance.new("Frame"); dot.Size = UDim2.new(0,s(3),0,s(3))
		dot.AnchorPoint = Vector2.new(pos.x,pos.y); dot.Position = UDim2.new(pos.x,0,pos.y,0)
		dot.BackgroundColor3 = Color3.fromRGB(120,120,160); dot.BackgroundTransparency = 0.3
		dot.BorderSizePixel = 0; dot.Parent = grip; MakeCorner(dot, 2)
	end
	local dragBtn = Instance.new("TextButton"); dragBtn.Size = UDim2.new(0,gripSize+s(8),0,gripSize+s(8))
	dragBtn.Position = UDim2.new(1,-(gripSize+s(12)),1,-(gripSize+s(12))); dragBtn.BackgroundTransparency = 1
	dragBtn.Text = ""; dragBtn.BorderSizePixel = 0; dragBtn.Parent = self.main; dragBtn.ZIndex = 10
	local isDragging,dragStartPos,dragStartSize = false,nil,nil
	local function beginResize(inputPos) isDragging=true; self._sliderDrag=true; dragStartPos=inputPos; dragStartSize=Vector2.new(self.main.AbsoluteSize.X,self.main.AbsoluteSize.Y) end
	local function doResize(inputPos)
		if not isDragging then return end
		local delta = inputPos-dragStartPos
		self.main.Size = UDim2.new(0,clamp(dragStartSize.X+delta.X,MIN_W,MAX_W),0,clamp(dragStartSize.Y+delta.Y,MIN_H,MAX_H))
	end
	local function endResize() if isDragging then isDragging=false; self._sliderDrag=false; self._guiW=self.main.AbsoluteSize.X; self._guiH=self.main.AbsoluteSize.Y; self._origGeo=nil end end
	dragBtn.InputBegan:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then beginResize(Vector2.new(inp.Position.X,inp.Position.Y)) end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if not isDragging then return end
		if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then doResize(Vector2.new(inp.Position.X,inp.Position.Y)) end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then endResize() end
	end)
	dragBtn.MouseEnter:Connect(function()
		for _,dot in pairs(grip:GetChildren()) do if dot:IsA("Frame") then Tween(dot,{BackgroundTransparency=0.0,BackgroundColor3=Color3.fromRGB(160,140,255)},0.15) end end
	end)
	dragBtn.MouseLeave:Connect(function()
		for _,dot in pairs(grip:GetChildren()) do if dot:IsA("Frame") then Tween(dot,{BackgroundTransparency=0.3,BackgroundColor3=Color3.fromRGB(120,120,160)},0.15) end end
	end)
end

function HorizonUI:_setupDrag()
	local dragging,dragStart,startPos = false,nil,nil
	UserInputService.InputBegan:Connect(function(inp)
		local t = inp.UserInputType
		if t~=Enum.UserInputType.MouseButton1 and t~=Enum.UserInputType.Touch then return end
		local pos
		if t==Enum.UserInputType.Touch then pos=Vector2.new(inp.Position.X,inp.Position.Y)
		else local mp=UserInputService:GetMouseLocation(); local gi=game:GetService("GuiService"):GetGuiInset(); pos=mp-gi end
		local tbp=self.titleBar.AbsolutePosition; local tbs=self.titleBar.AbsoluteSize
		if pos.X>=tbp.X and pos.X<=tbp.X+tbs.X and pos.Y>=tbp.Y and pos.Y<=tbp.Y+tbs.Y then
			if not self._sliderDrag and not self.dialogOpen and not self.isMinimized then dragging=true; dragStart=inp.Position; startPos=self.main.Position end
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if dragging and not self._sliderDrag then
			local t=inp.UserInputType
			if t==Enum.UserInputType.MouseMovement or t==Enum.UserInputType.Touch then
				local d=inp.Position-dragStart; self.main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		local t=inp.UserInputType
		if t==Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch then dragging=false end
	end)
end

function HorizonUI:_setupHotkey()
	UserInputService.InputBegan:Connect(function(inp, gp)
		if gp then return end
		if inp.KeyCode==Enum.KeyCode.Insert then
			local W,H=self._guiW,self._guiH
			if self.gui.Enabled then
				Tween(self.main,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)},0.45,Enum.EasingStyle.Back,Enum.EasingDirection.In)
				task.wait(0.45); self.gui.Enabled=false
			else
				self.gui.Enabled=true; self.main.Size=UDim2.new(0,0,0,0); self.main.Position=UDim2.new(0.5,0,0.5,0)
				Tween(self.main,{Size=UDim2.new(0,W,0,H),Position=UDim2.new(0.5,-W/2,0.5,-H/2)},0.7,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
			end
		end
	end)
end

function HorizonUI:_animateIn()
	local W,H=self._guiW,self._guiH; self.main.Size=UDim2.new(0,0,0,0); self.main.Position=UDim2.new(0.5,0,0.5,0)
	Tween(self.main,{Size=UDim2.new(0,W,0,H),Position=UDim2.new(0.5,-W/2,0.5,-H/2)},0.75,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
end

function HorizonUI:_toggleMin()
	if self._minAnim then return end; self.isMinimized = not self.isMinimized
	if not self._origGeo then self._origGeo={Size=self.main.Size,Position=self.main.Position} end
	if self.isMinimized then
		self._minAnim=true
		local pillW,pillH=s(280),s(46)
		local pillX=self.main.AbsolutePosition.X+self.main.AbsoluteSize.X/2-pillW/2; local pillY=s(14)
		self.sidebar.Visible=false; self.contentArea.Visible=false; self.titleBar.Visible=false; self._sepLine.Visible=false
		if self._resizeGrip then self._resizeGrip.Visible=false end
		local tw=TweenService:Create(self.main,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,pillW,0,pillH),Position=UDim2.new(0,pillX,0,pillY)})
		tw:Play(); tw.Completed:Connect(function() self.miniBar.Visible=true; self._minAnim=false end)
	else
		self._minAnim=true; self.miniBar.Visible=false
		local geo=self._origGeo; self.sidebar.Visible=true; self.contentArea.Visible=true; self.titleBar.Visible=true; self._sepLine.Visible=true
		if self._resizeGrip then self._resizeGrip.Visible=true end
		local tw=TweenService:Create(self.main,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=geo.Size,Position=geo.Position})
		tw:Play(); tw.Completed:Connect(function() self._minAnim=false end)
	end
end

function HorizonUI:_closeDialog()
	self.dialogOpen=true; local theme=self:_theme()
	local overlay=Instance.new("Frame"); overlay.Size=UDim2.new(1,0,1,0)
	overlay.BackgroundColor3=Color3.fromRGB(0,0,0); overlay.BackgroundTransparency=0.45
	overlay.BorderSizePixel=0; overlay.ZIndex=100; overlay.Parent=self.main
	local dW,dH=s(300),s(130)
	local dialog=Instance.new("Frame"); dialog.Size=UDim2.new(0,0,0,0)
	dialog.Position=UDim2.new(0.5,-dW/2,0.5,-dH/2); dialog.BackgroundColor3=Color3.fromRGB(18,18,26)
	dialog.BackgroundTransparency=0.04; dialog.BorderSizePixel=0; dialog.ZIndex=101; dialog.Parent=overlay
	MakeCorner(dialog,s(14)); MakeStroke(dialog,theme.stroke,0.5,1)
	local dialogAccent=Instance.new("Frame"); dialogAccent.Size=UDim2.new(0.5,0,0,2)
	dialogAccent.AnchorPoint=Vector2.new(0.5,0); dialogAccent.Position=UDim2.new(0.5,0,0,0)
	dialogAccent.BackgroundColor3=theme.accent1; dialogAccent.BorderSizePixel=0; dialogAccent.ZIndex=102; dialogAccent.Parent=dialog
	MakeGradient(dialogAccent,theme.accent1,theme.accent2,0); MakeCorner(dialogAccent,2)
	local function makeLabel(text,yOff,sz,color,bold)
		local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-s(36),0,s(24)); lbl.Position=UDim2.new(0,s(18),0,yOff)
		lbl.BackgroundTransparency=1; lbl.Text=text; lbl.TextColor3=color or Color3.fromRGB(255,255,255)
		lbl.TextSize=sz or s(13); lbl.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
		lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextWrapped=true; lbl.ZIndex=102; lbl.Parent=dialog
	end
	makeLabel("Close the UI?",s(14),s(16),nil,true); makeLabel("Are you sure?",s(40),s(12),Color3.fromRGB(160,160,175),false)
	local bW,bH=s(116),s(32)
	local function makeBtn(xOff,text,bgColor,bgTrans)
		local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0,bW,0,bH); btn.Position=UDim2.new(0,xOff,1,-s(44))
		btn.BackgroundColor3=bgColor; btn.BackgroundTransparency=bgTrans; btn.BorderSizePixel=0
		btn.Text=text; btn.TextColor3=Color3.fromRGB(255,255,255); btn.TextSize=s(12); btn.Font=Enum.Font.GothamBold
		btn.ZIndex=102; btn.Parent=dialog; MakeCorner(btn,s(9)); return btn
	end
	local cancelBtn=makeBtn(s(18),"Cancel",Color3.fromRGB(255,255,255),0.88)
	local confirmBtn=makeBtn(bW+s(24),"Close",Color3.fromRGB(220,40,40),0.18)
	cancelBtn.MouseButton1Click:Connect(function() overlay:Destroy(); self.dialogOpen=false end)
	confirmBtn.MouseButton1Click:Connect(function() self:Destroy() end)
	cancelBtn.MouseEnter:Connect(function() Tween(cancelBtn,{BackgroundTransparency=0.78}) end)
	cancelBtn.MouseLeave:Connect(function() Tween(cancelBtn,{BackgroundTransparency=0.88}) end)
	confirmBtn.MouseEnter:Connect(function() Tween(confirmBtn,{BackgroundTransparency=0.06}) end)
	confirmBtn.MouseLeave:Connect(function() Tween(confirmBtn,{BackgroundTransparency=0.18}) end)
	TweenService:Create(dialog,TweenInfo.new(0.32,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,dW,0,dH)}):Play()
end

function HorizonUI:_applyTheme(idx)
	local theme=Themes[idx] or Themes[1]; _state.themeIndex=idx
	local function tw(obj,props) if obj and obj.Parent then Tween(obj,props,0.3) end end
	tw(self.main,{BackgroundColor3=theme.background}); tw(self.mainStroke,{Color=theme.stroke})
	tw(self.sidebar,{BackgroundColor3=theme.sidebar}); tw(self.sidebarStroke,{Color=theme.stroke})
	tw(self._userCardStroke,{Color=theme.stroke}); tw(self._avatarRingStroke,{Color=theme.accent1})
	tw(self._statusLabel,{TextColor3=theme.subtext}); tw(self._titleLabel,{TextColor3=theme.text})
	tw(self._logoLabel,{TextColor3=theme.text}); tw(self._miniTitle,{TextColor3=theme.text})
	if self._accentBarGrad then UpdateGradient(self._accentBarGrad,theme.accent1,theme.accent2) end
	if self._sepGrad        then UpdateGradient(self._sepGrad,theme.accent1,theme.accent2) end
	if self._miniCrownGrad  then UpdateGradient(self._miniCrownGrad,theme.accent1,theme.accent2) end
	if self._miniCrownBg    then tw(self._miniCrownBg,{BackgroundColor3=theme.accent1}) end
	for _,tab in ipairs(self.tabs) do tab:_updateTheme(theme) end
	for _,reg in ipairs(self._themeReg) do
		if reg.element and reg.element.Parent then
			local k=reg.kind
			if k=="accent_bg" then tw(reg.element,{BackgroundColor3=theme.accent1}); if reg.extra and reg.extra.grad then UpdateGradient(reg.extra.grad,theme.accent1,theme.accent2) end
			elseif k=="accent_stroke" then tw(reg.element,{Color=theme.accent1})
			elseif k=="toggle_on" then tw(reg.element,{BackgroundColor3=theme.accent1}); if reg.extra and reg.extra.grad then UpdateGradient(reg.extra.grad,theme.accent1,theme.accent2) end
			elseif k=="toggle_off" then tw(reg.element,{BackgroundColor3=theme.toggleOff})
			elseif k=="track" then tw(reg.element,{BackgroundColor3=theme.trackBg})
			elseif k=="fill" then tw(reg.element,{BackgroundColor3=theme.accent1}); if reg.extra and reg.extra.grad then UpdateGradient(reg.extra.grad,theme.accent1,theme.accent2) end
			elseif k=="element_bg" then tw(reg.element,{BackgroundColor3=theme.elementBg})
			end
		end
	end
end

function HorizonUI:SaveConfig(name)
	if not writefile then self:Notify("Config", "writefile not supported!", "error", 3); return end
	local data = {theme = _state.themeIndex, values = {}}
	for k, v in pairs(self._configValues or {}) do data.values[k] = v end
	local ok, err = pcall(function()
		writefile("HorizonUI_"..( name or "config")..".json", game:GetService("HttpService"):JSONEncode(data))
	end)
	if ok then self:Notify("Config Saved", (name or "config")..".json", "success", 3)
	else self:Notify("Config Error", tostring(err), "error", 4) end
end

function HorizonUI:LoadConfig(name)
	if not readfile then self:Notify("Config", "readfile not supported!", "error", 3); return end
	local ok, raw = pcall(readfile, "HorizonUI_"..(name or "config")..".json")
	if not ok or not raw then self:Notify("Config Not Found", (name or "config")..".json", "warning", 3); return end
	local ok2, data = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
	if not ok2 then self:Notify("Config Parse Error", "JSON corrupted", "error", 3); return end
	if data.theme then self:_applyTheme(data.theme) end
	self._loadedConfig = data.values or {}
	self:Notify("Config Loaded", (name or "config")..".json", "success", 3)
	return self._loadedConfig
end

function HorizonUI:_regConfig(key, getter, setter)
	if not self._configValues then self._configValues = {} end
	if not self._configSetters then self._configSetters = {} end
	self._configSetters[key] = setter
	if self._loadedConfig and self._loadedConfig[key] ~= nil then setter(self._loadedConfig[key]) end
	self._configValues[key] = getter()
end

function HorizonUI:SetStatus(text)
	if self._statusLabel then self._statusLabel.Text = text end
end

function HorizonUI:Destroy()
	if self._sepAnim then self._sepAnim:Disconnect() end
	if self._wmConn  then self._wmConn:Disconnect()  end
	Tween(self.main,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)},0.45,Enum.EasingStyle.Back,Enum.EasingDirection.In)
	task.wait(0.45); self.gui:Destroy()
end

function HorizonUI:AddTab(name, icon, badgeText)
	local tab = Tab._new(self, name, icon or Icons.settings, badgeText)
	table.insert(self.tabs, tab)
	if not self.activeTab then self.activeTab = tab; tab:_show() end
	return tab
end

function Tab._new(library, name, icon, badgeText)
	local self = setmetatable({}, Tab)
	self._lib     = library; self.name = name; self.icon = icon
	self.sections = {}; self.isActive = false; self._badgeText = badgeText
	self:_makeBtn(); self:_makeContent()
	return self
end

function Tab:_makeBtn()
	local theme = self._lib:_theme()

	self.btn = Instance.new("TextButton")
	self.btn.Size = UDim2.new(1,0,0,s(40))
	self.btn.LayoutOrder = #self._lib.tabs + 1
	self.btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
	self.btn.BackgroundTransparency = 1
	self.btn.BorderSizePixel = 0
	self.btn.Text = ""
	self.btn.Parent = self._lib.tabsContainer
	MakeCorner(self.btn, s(10))
	self.btnStroke = MakeStroke(self.btn, Color3.fromRGB(255,255,255), 1, 1)

	self.btnIcon = MakeIcon(self.btn, self.icon, s(15), Color3.fromRGB(140,140,165))
	self.btnIcon.AnchorPoint = Vector2.new(0,0.5); self.btnIcon.Position = UDim2.new(0,s(12),0.5,0)

	self.btnText = Instance.new("TextLabel")
	self.btnText.Size = UDim2.new(1,-s(40),1,0)
	self.btnText.Position = UDim2.new(0,s(34),0,0)
	self.btnText.BackgroundTransparency = 1
	self.btnText.Text = self.name
	self.btnText.TextColor3 = Color3.fromRGB(140,140,165)
	self.btnText.TextSize = s(12)
	self.btnText.TextXAlignment = Enum.TextXAlignment.Left
	self.btnText.Font = Enum.Font.GothamMedium
	self.btnText.Parent = self.btn

	if self._badgeText then self:_buildBadge(self._badgeText) end

	self.btn.MouseButton1Click:Connect(function() self:_show() end)
	self.btn.MouseEnter:Connect(function()
		if not self.isActive then Tween(self.btn,{BackgroundTransparency=0.92}); Tween(self.btnStroke,{Transparency=0.82}) end
	end)
	self.btn.MouseLeave:Connect(function()
		if not self.isActive then Tween(self.btn,{BackgroundTransparency=1}); Tween(self.btnStroke,{Transparency=1}) end
	end)
end

function Tab:_buildBadge(text)
	if self._badge then self._badge:Destroy() end
	local badge = Instance.new("Frame")
	badge.Size = UDim2.new(0,s(18),0,s(16)); badge.AnchorPoint = Vector2.new(1,0.5)
	badge.Position = UDim2.new(1,-s(6),0.5,0); badge.BackgroundColor3 = self._lib:_theme().accent1
	badge.BackgroundTransparency = 0.3; badge.BorderSizePixel = 0; badge.Parent = self.btn
	MakeCorner(badge, s(8))
	local badgeLbl = Instance.new("TextLabel"); badgeLbl.Size = UDim2.new(1,0,1,0)
	badgeLbl.BackgroundTransparency = 1; badgeLbl.Text = tostring(text)
	badgeLbl.TextColor3 = Color3.fromRGB(255,255,255); badgeLbl.TextSize = s(9)
	badgeLbl.Font = Enum.Font.GothamBold; badgeLbl.Parent = badge
	self._badge = badge; self._badgeLbl = badgeLbl
end

function Tab:SetBadge(text)
	if text then self:_buildBadge(text)
	else if self._badge then self._badge:Destroy(); self._badge = nil end end
end

function Tab:_makeContent()
	self.content = Instance.new("ScrollingFrame"); self.content.Name = self.name.."Content"
	self.content.Size = UDim2.new(1,-s(24),1,-s(14)); self.content.Position = UDim2.new(0,s(12),0,s(7))
	self.content.BackgroundTransparency = 1; self.content.BorderSizePixel = 0
	self.content.ScrollBarThickness = isMobile and 2 or 3
	self.content.ScrollBarImageColor3 = Color3.fromRGB(255,255,255); self.content.ScrollBarImageTransparency = 0.75
	self.content.CanvasSize = UDim2.new(0,0,0,0); self.content.Visible = false
	self.content.Parent = self._lib.contentContainer
	local layout = Instance.new("UIListLayout"); layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0,s(10)); layout.Parent = self.content
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.content.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+s(16))
	end)
end

function Tab:_show()
	if self.isActive then return end
	if self._lib.activeTab then self._lib.activeTab:_hide() end
	self._lib.activeTab = self; self.isActive = true
	local theme = self._lib:_theme()
	Tween(self.btn,{BackgroundTransparency=0.86}); Tween(self.btnStroke,{Transparency=0.60})
	Tween(self.btnIcon,{ImageColor3=Color3.fromRGB(255,255,255)}); Tween(self.btnText,{TextColor3=Color3.fromRGB(255,255,255)})
	if not self.btnGrad then self.btnGrad = Instance.new("UIGradient"); self.btnGrad.Parent = self.btn end
	UpdateGradient(self.btnGrad, theme.accent1, theme.accent2)
	self.content.Visible = true
	self._lib:_applySearch()
end

function Tab:_hide()
	if not self.isActive then return end; self.isActive = false
	Tween(self.btn,{BackgroundTransparency=1}); Tween(self.btnStroke,{Transparency=1})
	Tween(self.btnIcon,{ImageColor3=Color3.fromRGB(140,140,165)}); Tween(self.btnText,{TextColor3=Color3.fromRGB(140,140,165)})
	if self.btnGrad then self.btnGrad:Destroy(); self.btnGrad=nil end
	self.content.Visible = false
end

function Tab:_updateTheme(theme)
	if self.isActive and self.btnGrad then UpdateGradient(self.btnGrad,theme.accent1,theme.accent2) end
	if self._badge then Tween(self._badge,{BackgroundColor3=theme.accent1}) end
	for _,sec in ipairs(self.sections) do sec:_updateTheme(theme) end
end

function Tab:AddSection(name)
	local sec = Section._new(self, name); table.insert(self.sections, sec); return sec
end

function Section._new(tab, name)
	local self = setmetatable({}, Section)
	self._tab = tab; self.name = name; self._elements = {}; self._collapsed = false
	self:_build(); return self
end

function Section:_build()
	self.container = Instance.new("Frame"); self.container.Name = self.name.."Sec"
	self.container.Size = UDim2.new(1,0,0,0); self.container.BackgroundTransparency = 1
	self.container.Parent = self._tab.content

	local headerH = 0
	if self.name ~= "" then
		headerH = s(30)
		local header = Instance.new("TextButton")
		header.Size = UDim2.new(1,0,0,headerH); header.BackgroundTransparency = 1
		header.Text = ""; header.Parent = self.container
		self._header = header
		local function makeLine(xScale, xOff, wScale, wOff)
			local ln = Instance.new("Frame"); ln.Size = UDim2.new(wScale,wOff,0,1)
			ln.Position = UDim2.new(xScale,xOff,0.5,0); ln.BackgroundColor3 = Color3.fromRGB(255,255,255)
			ln.BackgroundTransparency = 0.85; ln.BorderSizePixel = 0; ln.Parent = header
		end
		makeLine(0,0,0.28,-s(6)); makeLine(0.72,s(6),0.28,-s(6))
		local hTitle = Instance.new("TextLabel"); hTitle.Size = UDim2.new(0.44,0,1,0)
		hTitle.Position = UDim2.new(0.28,0,0,0); hTitle.BackgroundTransparency = 1
		hTitle.Text = self.name; hTitle.TextColor3 = Color3.fromRGB(200,200,215)
		hTitle.TextSize = s(10); hTitle.Font = Enum.Font.GothamBold; hTitle.Parent = header
		local arrow = Instance.new("TextLabel"); arrow.Size = UDim2.new(0,s(16),1,0)
		arrow.Position = UDim2.new(1,-s(18),0,0); arrow.BackgroundTransparency = 1
		arrow.Text = "▾"; arrow.TextColor3 = Color3.fromRGB(160,160,175)
		arrow.TextSize = s(11); arrow.Font = Enum.Font.Gotham; arrow.Parent = header
		self._arrowLbl = arrow
		header.MouseButton1Click:Connect(function()
			self._collapsed = not self._collapsed
			if self._collapsed then
				Tween(arrow, {Rotation = -90})
				Tween(self._elems, {Size = UDim2.new(1,0,0,0)}, 0.22)
				Tween(self.container, {Size = UDim2.new(1,0,0,headerH)}, 0.22)
			else
				Tween(arrow, {Rotation = 0})
				local h = self._elemsLayout.AbsoluteContentSize.Y
				Tween(self._elems, {Size = UDim2.new(1,0,0,h)}, 0.22)
				Tween(self.container, {Size = UDim2.new(1,0,0,headerH+h)}, 0.22)
			end
		end)
	end

	self._elems = Instance.new("Frame"); self._elems.Name = "Elems"
	self._elems.Size = UDim2.new(1,0,0,0); self._elems.Position = UDim2.new(0,0,0,headerH)
	self._elems.BackgroundTransparency = 1; self._elems.Parent = self.container
	self._elemsLayout = Instance.new("UIListLayout"); self._elemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	self._elemsLayout.Padding = UDim.new(0,s(7)); self._elemsLayout.Parent = self._elems
	self._elemsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if not self._collapsed then
			self._elems.Size = UDim2.new(1,0,0,self._elemsLayout.AbsoluteContentSize.Y)
			self.container.Size = UDim2.new(1,0,0,headerH+self._elemsLayout.AbsoluteContentSize.Y)
		end
	end)
	self._headerH = headerH
end

function Section:_applySearch(q)
	for _, el in ipairs(self._elements) do
		if el._frame and el._searchName then
			local visible = q == "" or el._searchName:lower():find(q, 1, true) ~= nil
			el._frame.Visible = visible
		end
	end
end

function Section:_updateTheme(theme)
	for _,el in ipairs(self._elements) do
		if el._updateTheme then el:_updateTheme(theme) end
	end
end

function Section:_lib() return self._tab._lib end

local function makeBaseFrame(parent, h, theme)
	local frame = Instance.new("Frame"); frame.Size = UDim2.new(1,0,0,h)
	frame.BackgroundColor3 = Color3.fromRGB(255,255,255); frame.BackgroundTransparency = 0.94
	frame.BorderSizePixel = 0; frame.Parent = parent; MakeCorner(frame, s(10))
	return frame
end

function Section:AddToggle(name, default, callback)
	local lib=self:_lib(); local theme=lib:_theme()
	local frame=makeBaseFrame(self._elems, s(44), theme)
	local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-s(80),1,0); lbl.Position=UDim2.new(0,s(12),0,0)
	lbl.BackgroundTransparency=1; lbl.Text=name; lbl.TextColor3=theme.text; lbl.TextSize=TS
	lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Font=Enum.Font.GothamMedium; lbl.Parent=frame
	local active=default or false; local tW,tH=s(42),s(20)
	local toggle=Instance.new("TextButton"); toggle.Size=UDim2.new(0,tW,0,tH)
	toggle.Position=UDim2.new(1,-(tW+s(12)),0.5,-tH/2); toggle.BackgroundColor3=active and theme.accent1 or theme.toggleOff
	toggle.BackgroundTransparency=active and 0.15 or 0.4; toggle.BorderSizePixel=0; toggle.Text=""; toggle.Parent=frame; MakeCorner(toggle,s(10))
	local thumbSz=s(14); local thumb=Instance.new("Frame"); thumb.Size=UDim2.new(0,thumbSz,0,thumbSz)
	thumb.Position=active and UDim2.new(0,tW-thumbSz-s(3),0,s(3)) or UDim2.new(0,s(3),0,s(3))
	thumb.BackgroundColor3=Color3.fromRGB(255,255,255); thumb.BorderSizePixel=0; thumb.Parent=toggle; MakeCorner(thumb,thumbSz)
	local grad=nil; if active then grad=MakeGradient(toggle,theme.accent1,theme.accent2) end
	lib:_regTheme(toggle, active and "toggle_on" or "toggle_off", {grad=grad})
	local disabled=false
	toggle.MouseButton1Click:Connect(function()
		if disabled then return end
		active=not active; local t=lib:_theme()
		if active then
			Tween(toggle,{BackgroundColor3=t.accent1,BackgroundTransparency=0.15})
			local existing=toggle:FindFirstChildOfClass("UIGradient")
			if not existing then grad=MakeGradient(toggle,t.accent1,t.accent2) else UpdateGradient(existing,t.accent1,t.accent2); grad=existing end
			lib:_regTheme(toggle,"toggle_on",{grad=grad})
		else
			Tween(toggle,{BackgroundColor3=t.toggleOff,BackgroundTransparency=0.4})
			local g=toggle:FindFirstChildOfClass("UIGradient"); if g then g:Destroy() end; grad=nil
			lib:_regTheme(toggle,"toggle_off",nil)
		end
		TweenService:Create(thumb,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=active and UDim2.new(0,tW-thumbSz-s(3),0,s(3)) or UDim2.new(0,s(3),0,s(3))}):Play()
		if callback then callback(active) end
	end)
	local el = {
		_frame=frame, _searchName=name,
		getValue=function() return active end,
		setValue=function(v)
			if v==active then return end
			active=v
			local t=lib:_theme()
			if active then Tween(toggle,{BackgroundColor3=t.accent1,BackgroundTransparency=0.15}); if not toggle:FindFirstChildOfClass("UIGradient") then MakeGradient(toggle,t.accent1,t.accent2) end
			else Tween(toggle,{BackgroundColor3=t.toggleOff,BackgroundTransparency=0.4}); local g=toggle:FindFirstChildOfClass("UIGradient"); if g then g:Destroy() end end
			TweenService:Create(thumb,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=active and UDim2.new(0,tW-thumbSz-s(3),0,s(3)) or UDim2.new(0,s(3),0,s(3))}):Play()
		end,
		setDisabled=function(v)
			disabled=v
			Tween(frame,{BackgroundTransparency=v and 0.97 or 0.94})
			Tween(lbl,{TextColor3=v and Color3.fromRGB(80,80,100) or lib:_theme().text})
		end,
		_updateTheme=function(_,t) Tween(lbl,{TextColor3=t.text}) end
	}
	table.insert(self._elements, el); return el
end

function Section:AddSlider(name, min, max, default, callback)
	local lib=self:_lib(); local theme=lib:_theme()
	local frame=makeBaseFrame(self._elems, s(56), theme)
	local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-s(70),0,s(18)); lbl.Position=UDim2.new(0,s(12),0,s(7))
	lbl.BackgroundTransparency=1; lbl.Text=name; lbl.TextColor3=theme.text; lbl.TextSize=TS
	lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Font=Enum.Font.GothamMedium; lbl.Parent=frame
	local currentValue=clamp(default or min,min,max)
	local valLbl=Instance.new("TextLabel"); valLbl.Size=UDim2.new(0,s(50),0,s(18)); valLbl.Position=UDim2.new(1,-s(60),0,s(7))
	valLbl.BackgroundTransparency=1; valLbl.Text=tostring(currentValue); valLbl.TextColor3=theme.subtext
	valLbl.TextSize=s(11); valLbl.Font=Enum.Font.GothamBold; valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.Parent=frame
	local track=Instance.new("Frame"); track.Size=UDim2.new(1,-s(28),0,s(5)); track.Position=UDim2.new(0,s(14),0,s(38))
	track.BackgroundColor3=theme.trackBg; track.BackgroundTransparency=0.25; track.BorderSizePixel=0; track.Parent=frame; MakeCorner(track,s(3))
	lib:_regTheme(track,"track",nil)
	local progress=(currentValue-min)/(max-min)
	local fill=Instance.new("Frame"); fill.Size=UDim2.new(progress,0,1,0); fill.BackgroundColor3=theme.accent1; fill.BorderSizePixel=0; fill.Parent=track; MakeCorner(fill,s(3))
	local fillGrad=MakeGradient(fill,theme.accent1,theme.accent2); lib:_regTheme(fill,"fill",{grad=fillGrad})
	local thumb=Instance.new("Frame"); thumb.Size=UDim2.new(0,s(18),0,s(18)); thumb.Position=UDim2.new(progress,-s(9),0.5,-s(9))
	thumb.BackgroundColor3=Color3.fromRGB(255,255,255); thumb.BorderSizePixel=0; thumb.ZIndex=2; thumb.Parent=track; MakeCorner(thumb,s(9))
	local thumbStroke=MakeStroke(thumb,theme.accent1,0.3,2); lib:_regTheme(thumbStroke,"accent_stroke",nil)
	local isDragging=false
	local function updateSlider(input)
		local rel=clamp((input.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
		currentValue=math.floor(min+rel*(max-min))
		Tween(fill,{Size=UDim2.new(rel,0,1,0)},0.08); Tween(thumb,{Position=UDim2.new(rel,-s(9),0.5,-s(9))},0.08)
		valLbl.Text=tostring(currentValue); if callback then callback(currentValue) end
	end
	track.InputBegan:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
			isDragging=true; lib._sliderDrag=true; updateSlider(inp); Tween(thumb,{Size=UDim2.new(0,s(22),0,s(22))},0.1)
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if isDragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then updateSlider(inp) end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if (inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch) and isDragging then
			isDragging=false; lib._sliderDrag=false; Tween(thumb,{Size=UDim2.new(0,s(18),0,s(18))},0.18)
		end
	end)
	local el={_frame=frame,_searchName=name,getValue=function() return currentValue end,_updateTheme=function(_,t) Tween(lbl,{TextColor3=t.text}) end,
		setDisabled=function(v) Tween(frame,{BackgroundTransparency=v and 0.97 or 0.94}); Tween(lbl,{TextColor3=v and Color3.fromRGB(80,80,100) or lib:_theme().text}) end}
	table.insert(self._elements, el); return el
end

function Section:AddDropdown(name, options, default, callback)
	local lib=self:_lib(); local theme=lib:_theme(); local baseH=s(70)
	local frame=makeBaseFrame(self._elems, baseH, theme)
	local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-s(24),0,s(18)); lbl.Position=UDim2.new(0,s(12),0,s(8))
	lbl.BackgroundTransparency=1; lbl.Text=name; lbl.TextColor3=theme.text; lbl.TextSize=TS
	lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Font=Enum.Font.GothamMedium; lbl.Parent=frame
	local currentValue=default or options[1]
	local dropBtn=Instance.new("TextButton"); dropBtn.Size=UDim2.new(1,-s(24),0,s(32)); dropBtn.Position=UDim2.new(0,s(12),0,s(30))
	dropBtn.BackgroundColor3=theme.elementBg; dropBtn.BackgroundTransparency=0.25; dropBtn.BorderSizePixel=0; dropBtn.Text=""; dropBtn.ZIndex=2; dropBtn.Parent=frame
	MakeCorner(dropBtn,s(8)); MakeStroke(dropBtn,Color3.fromRGB(255,255,255),0.85,1); lib:_regTheme(dropBtn,"element_bg",nil)
	local dropText=Instance.new("TextLabel"); dropText.Size=UDim2.new(1,-s(36),1,0); dropText.Position=UDim2.new(0,s(10),0,0)
	dropText.BackgroundTransparency=1; dropText.Text=currentValue; dropText.TextColor3=theme.text; dropText.TextSize=s(12)
	dropText.TextXAlignment=Enum.TextXAlignment.Left; dropText.Font=Enum.Font.Gotham; dropText.Parent=dropBtn
	local arrow=Instance.new("TextLabel"); arrow.Size=UDim2.new(0,s(20),1,0); arrow.Position=UDim2.new(1,-s(26),0,0)
	arrow.BackgroundTransparency=1; arrow.Text="▾"; arrow.TextColor3=theme.subtext; arrow.TextSize=s(12); arrow.Font=Enum.Font.Gotham; arrow.Parent=dropBtn
	local listFrame=Instance.new("Frame"); listFrame.Size=UDim2.new(1,0,0,0); listFrame.Position=UDim2.new(0,0,0,s(34))
	listFrame.BackgroundColor3=Color3.fromRGB(20,20,32); listFrame.BackgroundTransparency=0.04; listFrame.BorderSizePixel=0
	listFrame.Visible=false; listFrame.ZIndex=10; listFrame.Parent=dropBtn; MakeCorner(listFrame,s(8)); MakeStroke(listFrame,Color3.fromRGB(255,255,255),0.85,1)
	local expandedH=#options*s(32)
	for i,opt in ipairs(options) do
		local optBtn=Instance.new("TextButton"); optBtn.Size=UDim2.new(1,-s(10),0,s(28)); optBtn.Position=UDim2.new(0,s(5),0,(i-1)*s(32)+s(2))
		optBtn.BackgroundColor3=Color3.fromRGB(255,255,255); optBtn.BackgroundTransparency=1; optBtn.BorderSizePixel=0
		optBtn.Text=opt; optBtn.TextColor3=theme.text; optBtn.TextSize=s(12); optBtn.TextXAlignment=Enum.TextXAlignment.Left
		optBtn.Font=Enum.Font.Gotham; optBtn.ZIndex=11; optBtn.Parent=listFrame; MakeCorner(optBtn,s(6))
		local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,s(8)); pad.Parent=optBtn
		optBtn.MouseEnter:Connect(function() Tween(optBtn,{BackgroundTransparency=0.88}) end)
		optBtn.MouseLeave:Connect(function() Tween(optBtn,{BackgroundTransparency=1}) end)
		optBtn.MouseButton1Click:Connect(function()
			currentValue=opt; dropText.Text=opt
			Tween(arrow,{Rotation=0}); Tween(listFrame,{Size=UDim2.new(1,0,0,0)},0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
			Tween(frame,{Size=UDim2.new(1,0,0,baseH)},0.18); task.delay(0.18,function() listFrame.Visible=false end)
			if callback then callback(opt) end
		end)
	end
	local isOpen=false
	dropBtn.MouseButton1Click:Connect(function()
		isOpen=not isOpen; Tween(arrow,{Rotation=isOpen and 180 or 0})
		if isOpen then listFrame.Visible=true; Tween(listFrame,{Size=UDim2.new(1,0,0,expandedH)},0.22); Tween(frame,{Size=UDim2.new(1,0,0,baseH+expandedH+s(6))},0.22)
		else Tween(listFrame,{Size=UDim2.new(1,0,0,0)},0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In); Tween(frame,{Size=UDim2.new(1,0,0,baseH)},0.18); task.delay(0.18,function() listFrame.Visible=false end) end
	end)
	local el={_frame=frame,_searchName=name,getValue=function() return currentValue end,
		setDisabled=function(v) Tween(frame,{BackgroundTransparency=v and 0.97 or 0.94}); Tween(lbl,{TextColor3=v and Color3.fromRGB(80,80,100) or lib:_theme().text}) end}
	table.insert(self._elements, el); return el
end

function Section:AddSearchableDropdown(name, options, default, callback)
	local lib=self:_lib(); local theme=lib:_theme(); local baseH=s(70)
	local frame=makeBaseFrame(self._elems, baseH, theme)
	local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-s(24),0,s(18)); lbl.Position=UDim2.new(0,s(12),0,s(8))
	lbl.BackgroundTransparency=1; lbl.Text=name; lbl.TextColor3=theme.text; lbl.TextSize=TS
	lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Font=Enum.Font.GothamMedium; lbl.Parent=frame
	local currentValue=default or options[1]
	local dropBtn=Instance.new("TextButton"); dropBtn.Size=UDim2.new(1,-s(24),0,s(32)); dropBtn.Position=UDim2.new(0,s(12),0,s(30))
	dropBtn.BackgroundColor3=theme.elementBg; dropBtn.BackgroundTransparency=0.25; dropBtn.BorderSizePixel=0; dropBtn.Text=""; dropBtn.ZIndex=2; dropBtn.Parent=frame
	MakeCorner(dropBtn,s(8)); MakeStroke(dropBtn,Color3.fromRGB(255,255,255),0.85,1); lib:_regTheme(dropBtn,"element_bg",nil)
	local dropText=Instance.new("TextLabel"); dropText.Size=UDim2.new(1,-s(36),1,0); dropText.Position=UDim2.new(0,s(10),0,0)
	dropText.BackgroundTransparency=1; dropText.Text=currentValue; dropText.TextColor3=theme.text; dropText.TextSize=s(12)
	dropText.TextXAlignment=Enum.TextXAlignment.Left; dropText.Font=Enum.Font.Gotham; dropText.Parent=dropBtn
	local arrow=Instance.new("TextLabel"); arrow.Size=UDim2.new(0,s(20),1,0); arrow.Position=UDim2.new(1,-s(26),0,0)
	arrow.BackgroundTransparency=1; arrow.Text="▾"; arrow.TextColor3=theme.subtext; arrow.TextSize=s(12); arrow.Font=Enum.Font.Gotham; arrow.Parent=dropBtn
	local listFrame=Instance.new("Frame"); listFrame.Size=UDim2.new(1,0,0,0); listFrame.Position=UDim2.new(0,0,0,s(34))
	listFrame.BackgroundColor3=Color3.fromRGB(20,20,32); listFrame.BackgroundTransparency=0.04; listFrame.BorderSizePixel=0
	listFrame.Visible=false; listFrame.ZIndex=10; listFrame.Parent=dropBtn; MakeCorner(listFrame,s(8)); MakeStroke(listFrame,Color3.fromRGB(255,255,255),0.85,1)
	local searchBox=Instance.new("TextBox"); searchBox.Size=UDim2.new(1,-s(10),0,s(26)); searchBox.Position=UDim2.new(0,s(5),0,s(4))
	searchBox.BackgroundColor3=Color3.fromRGB(255,255,255); searchBox.BackgroundTransparency=0.92; searchBox.BorderSizePixel=0
	searchBox.Text=""; searchBox.PlaceholderText="Search..."; searchBox.PlaceholderColor3=Color3.fromRGB(120,120,140)
	searchBox.TextColor3=theme.text; searchBox.TextSize=s(11); searchBox.Font=Enum.Font.Gotham
	searchBox.TextXAlignment=Enum.TextXAlignment.Left; searchBox.ClearTextOnFocus=false; searchBox.ZIndex=12; searchBox.Parent=listFrame
	MakeCorner(searchBox,s(6)); local sp=Instance.new("UIPadding"); sp.PaddingLeft=UDim.new(0,s(8)); sp.Parent=searchBox
	local optButtons={}
	local function rebuildList(filter)
		filter=filter and filter:lower() or ""
		local visCount=0
		for _,ob in ipairs(optButtons) do
			local matches=filter=="" or ob.Text:lower():find(filter,1,true)~=nil
			ob.Visible=matches; if matches then visCount=visCount+1 end
		end
		local newH=s(34)+visCount*s(30)+s(4)
		Tween(listFrame,{Size=UDim2.new(1,0,0,newH)},0.1)
		Tween(frame,{Size=UDim2.new(1,0,0,baseH+newH+s(6))},0.1)
	end
	for i,opt in ipairs(options) do
		local optBtn=Instance.new("TextButton"); optBtn.Size=UDim2.new(1,-s(10),0,s(28))
		optBtn.Position=UDim2.new(0,s(5),0,s(34)+(i-1)*s(30))
		optBtn.BackgroundColor3=Color3.fromRGB(255,255,255); optBtn.BackgroundTransparency=1; optBtn.BorderSizePixel=0
		optBtn.Text=opt; optBtn.TextColor3=theme.text; optBtn.TextSize=s(12); optBtn.TextXAlignment=Enum.TextXAlignment.Left
		optBtn.Font=Enum.Font.Gotham; optBtn.ZIndex=11; optBtn.Parent=listFrame; MakeCorner(optBtn,s(6))
		local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,s(8)); pad.Parent=optBtn
		optBtn.MouseEnter:Connect(function() Tween(optBtn,{BackgroundTransparency=0.88}) end)
		optBtn.MouseLeave:Connect(function() Tween(optBtn,{BackgroundTransparency=1}) end)
		optBtn.MouseButton1Click:Connect(function()
			currentValue=opt; dropText.Text=opt; Tween(arrow,{Rotation=0})
			Tween(listFrame,{Size=UDim2.new(1,0,0,0)},0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
			Tween(frame,{Size=UDim2.new(1,0,0,baseH)},0.18); task.delay(0.18,function() listFrame.Visible=false end)
			if callback then callback(opt) end
		end)
		table.insert(optButtons, optBtn)
	end
	searchBox:GetPropertyChangedSignal("Text"):Connect(function() rebuildList(searchBox.Text) end)
	local expandedH=s(34)+#options*s(30)+s(4); local isOpen=false
	dropBtn.MouseButton1Click:Connect(function()
		isOpen=not isOpen; Tween(arrow,{Rotation=isOpen and 180 or 0})
		if isOpen then
			searchBox.Text=""; listFrame.Visible=true
			Tween(listFrame,{Size=UDim2.new(1,0,0,expandedH)},0.22); Tween(frame,{Size=UDim2.new(1,0,0,baseH+expandedH+s(6))},0.22)
		else
			Tween(listFrame,{Size=UDim2.new(1,0,0,0)},0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
			Tween(frame,{Size=UDim2.new(1,0,0,baseH)},0.18); task.delay(0.18,function() listFrame.Visible=false end)
		end
	end)
	local el={_frame=frame,_searchName=name,getValue=function() return currentValue end}
	table.insert(self._elements, el); return el
end

function Section:AddMultiDropdown(name, options, defaults, callback)
	local lib=self:_lib(); local theme=lib:_theme(); local baseH=s(70)
	local frame=makeBaseFrame(self._elems, baseH, theme)
	local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-s(24),0,s(18)); lbl.Position=UDim2.new(0,s(12),0,s(8))
	lbl.BackgroundTransparency=1; lbl.Text=name; lbl.TextColor3=theme.text; lbl.TextSize=TS
	lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Font=Enum.Font.GothamMedium; lbl.Parent=frame
	local selected={}
	if defaults then for _,v in ipairs(defaults) do selected[v]=true end end
	local function getLabel()
		local keys={}; for k in pairs(selected) do table.insert(keys,k) end
		if #keys==0 then return "Select..." end
		if #keys==1 then return keys[1] end
		return keys[1].." +"..tostring(#keys-1)
	end
	local dropBtn=Instance.new("TextButton"); dropBtn.Size=UDim2.new(1,-s(24),0,s(32)); dropBtn.Position=UDim2.new(0,s(12),0,s(30))
	dropBtn.BackgroundColor3=theme.elementBg; dropBtn.BackgroundTransparency=0.25; dropBtn.BorderSizePixel=0; dropBtn.Text=""; dropBtn.ZIndex=2; dropBtn.Parent=frame
	MakeCorner(dropBtn,s(8)); MakeStroke(dropBtn,Color3.fromRGB(255,255,255),0.85,1); lib:_regTheme(dropBtn,"element_bg",nil)
	local dropText=Instance.new("TextLabel"); dropText.Size=UDim2.new(1,-s(36),1,0); dropText.Position=UDim2.new(0,s(10),0,0)
	dropText.BackgroundTransparency=1; dropText.Text=getLabel(); dropText.TextColor3=theme.text; dropText.TextSize=s(12)
	dropText.TextXAlignment=Enum.TextXAlignment.Left; dropText.Font=Enum.Font.Gotham; dropText.Parent=dropBtn
	local arrow=Instance.new("TextLabel"); arrow.Size=UDim2.new(0,s(20),1,0); arrow.Position=UDim2.new(1,-s(26),0,0)
	arrow.BackgroundTransparency=1; arrow.Text="▾"; arrow.TextColor3=theme.subtext; arrow.TextSize=s(12); arrow.Font=Enum.Font.Gotham; arrow.Parent=dropBtn
	local listFrame=Instance.new("Frame"); listFrame.Size=UDim2.new(1,0,0,0); listFrame.Position=UDim2.new(0,0,0,s(34))
	listFrame.BackgroundColor3=Color3.fromRGB(20,20,32); listFrame.BackgroundTransparency=0.04; listFrame.BorderSizePixel=0
	listFrame.Visible=false; listFrame.ZIndex=10; listFrame.Parent=dropBtn; MakeCorner(listFrame,s(8)); MakeStroke(listFrame,Color3.fromRGB(255,255,255),0.85,1)
	local expandedH=#options*s(32)
	for i,opt in ipairs(options) do
		local row=Instance.new("TextButton"); row.Size=UDim2.new(1,-s(10),0,s(28)); row.Position=UDim2.new(0,s(5),0,(i-1)*s(32)+s(2))
		row.BackgroundColor3=Color3.fromRGB(255,255,255); row.BackgroundTransparency=1; row.BorderSizePixel=0
		row.Text=""; row.ZIndex=11; row.Parent=listFrame; MakeCorner(row,s(6))
		local chk=Instance.new("Frame"); chk.Size=UDim2.new(0,s(14),0,s(14)); chk.Position=UDim2.new(0,s(8),0.5,-s(7))
		chk.BackgroundColor3=selected[opt] and theme.accent1 or Color3.fromRGB(255,255,255)
		chk.BackgroundTransparency=selected[opt] and 0.2 or 0.88; chk.BorderSizePixel=0; chk.ZIndex=12; chk.Parent=row; MakeCorner(chk,s(4))
		MakeStroke(chk,Color3.fromRGB(255,255,255),0.65,1)
		local chkMark=Instance.new("TextLabel"); chkMark.Size=UDim2.new(1,0,1,0); chkMark.BackgroundTransparency=1
		chkMark.Text=selected[opt] and "✓" or ""; chkMark.TextColor3=Color3.fromRGB(255,255,255)
		chkMark.TextSize=s(10); chkMark.Font=Enum.Font.GothamBold; chkMark.ZIndex=13; chkMark.Parent=chk
		local optLbl=Instance.new("TextLabel"); optLbl.Size=UDim2.new(1,-s(30),1,0); optLbl.Position=UDim2.new(0,s(28),0,0)
		optLbl.BackgroundTransparency=1; optLbl.Text=opt; optLbl.TextColor3=theme.text; optLbl.TextSize=s(12)
		optLbl.TextXAlignment=Enum.TextXAlignment.Left; optLbl.Font=Enum.Font.Gotham; optLbl.ZIndex=12; optLbl.Parent=row
		row.MouseEnter:Connect(function() Tween(row,{BackgroundTransparency=0.88}) end)
		row.MouseLeave:Connect(function() Tween(row,{BackgroundTransparency=1}) end)
		row.MouseButton1Click:Connect(function()
			if selected[opt] then selected[opt]=nil; chkMark.Text=""
				Tween(chk,{BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0.88})
			else selected[opt]=true; chkMark.Text="✓"
				Tween(chk,{BackgroundColor3=lib:_theme().accent1,BackgroundTransparency=0.2})
			end
			dropText.Text=getLabel()
			if callback then local arr={}; for k in pairs(selected) do table.insert(arr,k) end; callback(arr) end
		end)
	end
	local isOpen=false
	dropBtn.MouseButton1Click:Connect(function()
		isOpen=not isOpen; Tween(arrow,{Rotation=isOpen and 180 or 0})
		if isOpen then listFrame.Visible=true; Tween(listFrame,{Size=UDim2.new(1,0,0,expandedH)},0.22); Tween(frame,{Size=UDim2.new(1,0,0,baseH+expandedH+s(6))},0.22)
		else Tween(listFrame,{Size=UDim2.new(1,0,0,0)},0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In); Tween(frame,{Size=UDim2.new(1,0,0,baseH)},0.18); task.delay(0.18,function() listFrame.Visible=false end) end
	end)
	local el={_frame=frame,_searchName=name,getValue=function() local arr={}; for k in pairs(selected) do table.insert(arr,k) end; return arr end}
	table.insert(self._elements, el); return el
end

function Section:AddNumberInput(name, min, max, default, step, callback)
	local lib=self:_lib(); local theme=lib:_theme(); step=step or 1
	local frame=makeBaseFrame(self._elems, s(54), theme)
	local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(0.5,-s(12),0,s(18)); lbl.Position=UDim2.new(0,s(12),0,s(8))
	lbl.BackgroundTransparency=1; lbl.Text=name; lbl.TextColor3=theme.text; lbl.TextSize=TS
	lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Font=Enum.Font.GothamMedium; lbl.Parent=frame
	local currentValue=clamp(default or min, min, max)
	local btnSz=s(28)
	local minusBtn=Instance.new("TextButton"); minusBtn.Size=UDim2.new(0,btnSz,0,btnSz)
	minusBtn.Position=UDim2.new(1,-s(12)-btnSz*3-s(4),0.5,-btnSz/2); minusBtn.BackgroundColor3=Color3.fromRGB(255,255,255)
	minusBtn.BackgroundTransparency=0.88; minusBtn.BorderSizePixel=0; minusBtn.Text="-"
	minusBtn.TextColor3=theme.text; minusBtn.TextSize=s(16); minusBtn.Font=Enum.Font.GothamBold; minusBtn.Parent=frame; MakeCorner(minusBtn,s(7))
	local numBox=Instance.new("TextBox"); numBox.Size=UDim2.new(0,btnSz+s(12),0,btnSz)
	numBox.Position=UDim2.new(1,-s(12)-btnSz*2-s(4),0.5,-btnSz/2); numBox.BackgroundColor3=theme.elementBg
	numBox.BackgroundTransparency=0.3; numBox.BorderSizePixel=0; numBox.Text=tostring(currentValue)
	numBox.TextColor3=theme.text; numBox.TextSize=s(12); numBox.Font=Enum.Font.GothamBold
	numBox.TextXAlignment=Enum.TextXAlignment.Center; numBox.ClearTextOnFocus=false; numBox.Parent=frame; MakeCorner(numBox,s(7))
	local plusBtn=Instance.new("TextButton"); plusBtn.Size=UDim2.new(0,btnSz,0,btnSz)
	plusBtn.Position=UDim2.new(1,-s(12)-btnSz,0.5,-btnSz/2); plusBtn.BackgroundColor3=theme.accent1
	plusBtn.BackgroundTransparency=0.3; plusBtn.BorderSizePixel=0; plusBtn.Text="+"
	plusBtn.TextColor3=Color3.fromRGB(255,255,255); plusBtn.TextSize=s(16); plusBtn.Font=Enum.Font.GothamBold; plusBtn.Parent=frame; MakeCorner(plusBtn,s(7))
	lib:_regTheme(plusBtn,"accent_bg",nil)
	local function set(v)
		currentValue=clamp(v,min,max); numBox.Text=tostring(currentValue)
		if callback then callback(currentValue) end
	end
	minusBtn.MouseButton1Click:Connect(function() set(currentValue-step) end)
	plusBtn.MouseButton1Click:Connect(function() set(currentValue+step) end)
	numBox.FocusLost:Connect(function() local n=tonumber(numBox.Text); if n then set(n) else numBox.Text=tostring(currentValue) end end)
	local el={_frame=frame,_searchName=name,getValue=function() return currentValue end,setValue=function(v) set(v) end,
		setDisabled=function(v) Tween(frame,{BackgroundTransparency=v and 0.97 or 0.94}) end}
	table.insert(self._elements, el); return el
end

function Section:AddProgressBar(name, min, max, default)
	local lib=self:_lib(); local theme=lib:_theme()
	local frame=makeBaseFrame(self._elems, s(54), theme)
	local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-s(70),0,s(18)); lbl.Position=UDim2.new(0,s(12),0,s(8))
	lbl.BackgroundTransparency=1; lbl.Text=name; lbl.TextColor3=theme.text; lbl.TextSize=TS
	lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Font=Enum.Font.GothamMedium; lbl.Parent=frame
	local currentValue=clamp(default or min, min, max)
	local valLbl=Instance.new("TextLabel"); valLbl.Size=UDim2.new(0,s(55),0,s(18)); valLbl.Position=UDim2.new(1,-s(65),0,s(8))
	valLbl.BackgroundTransparency=1; valLbl.Text=currentValue.."/"..max; valLbl.TextColor3=theme.subtext
	valLbl.TextSize=s(11); valLbl.Font=Enum.Font.GothamBold; valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.Parent=frame
	local track=Instance.new("Frame"); track.Size=UDim2.new(1,-s(28),0,s(8)); track.Position=UDim2.new(0,s(14),0,s(34))
	track.BackgroundColor3=theme.trackBg; track.BackgroundTransparency=0.25; track.BorderSizePixel=0; track.Parent=frame; MakeCorner(track,s(4))
	lib:_regTheme(track,"track",nil)
	local progress=(currentValue-min)/(max-min)
	local fill=Instance.new("Frame"); fill.Size=UDim2.new(progress,0,1,0); fill.BackgroundColor3=theme.accent1; fill.BorderSizePixel=0; fill.Parent=track; MakeCorner(fill,s(4))
	local fillGrad=MakeGradient(fill,theme.accent1,theme.accent2); lib:_regTheme(fill,"fill",{grad=fillGrad})
	local el={
		_frame=frame,_searchName=name,
		getValue=function() return currentValue end,
		setValue=function(v)
			currentValue=clamp(v,min,max)
			local p=(currentValue-min)/(max-min)
			Tween(fill,{Size=UDim2.new(p,0,1,0)},0.3)
			valLbl.Text=currentValue.."/"..max
		end,
		_updateTheme=function(_,t) Tween(lbl,{TextColor3=t.text}) end
	}
	table.insert(self._elements, el); return el
end

function Section:AddRichLabel(text, labelType)
	local lib=self:_lib(); local theme=lib:_theme()
	local typeColors={info=Color3.fromRGB(99,102,241),success=Color3.fromRGB(34,197,94),warning=Color3.fromRGB(251,191,36),error=Color3.fromRGB(239,68,68)}
	local typeIcons={info="ℹ ", success="✓ ", warning="⚠ ", error="✕ "}
	local accent=typeColors[labelType]; local icon=typeIcons[labelType] or ""
	local frame=Instance.new("Frame"); frame.Size=UDim2.new(1,0,0,s(36)); frame.BackgroundTransparency=1; frame.BorderSizePixel=0; frame.Parent=self._elems
	if accent then
		frame.BackgroundColor3=accent; frame.BackgroundTransparency=0.88; MakeCorner(frame,s(8))
		local bar=Instance.new("Frame"); bar.Size=UDim2.new(0,s(3),0.7,0); bar.Position=UDim2.new(0,0,0.15,0)
		bar.BackgroundColor3=accent; bar.BorderSizePixel=0; bar.Parent=frame; MakeCorner(bar,s(2))
	end
	local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-s(20),1,0); lbl.Position=UDim2.new(0,s(10),0,0)
	lbl.BackgroundTransparency=1; lbl.Text=icon..text; lbl.TextColor3=accent or theme.subtext
	lbl.TextSize=s(12); lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Font=Enum.Font.GothamMedium
	lbl.TextWrapped=true; lbl.RichText=true; lbl.Parent=frame
	local el={_frame=frame,_searchName=text,setText=function(t) lbl.Text=icon..t end,getText=function() return lbl.Text end}
	table.insert(self._elements, el); return el
end

function Section:AddButton(name, callback)
	local lib=self:_lib(); local theme=lib:_theme()
	local frame=makeBaseFrame(self._elems, s(44), theme)
	local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,-s(24),1,-s(10)); btn.Position=UDim2.new(0,s(12),0,s(5))
	btn.BackgroundColor3=theme.accent1; btn.BackgroundTransparency=0.22; btn.BorderSizePixel=0
	btn.Text=name; btn.TextColor3=Color3.fromRGB(255,255,255); btn.TextSize=s(13); btn.Font=Enum.Font.GothamBold; btn.Parent=frame
	MakeCorner(btn,s(9)); local grad=MakeGradient(btn,theme.accent1,theme.accent2); lib:_regTheme(btn,"accent_bg",{grad=grad})
	btn.MouseButton1Click:Connect(function()
		Tween(btn,{Size=UDim2.new(1,-s(28),1,-s(14))},0.08); task.wait(0.08)
		Tween(btn,{Size=UDim2.new(1,-s(24),1,-s(10))},0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
		if callback then callback() end
	end)
	btn.MouseEnter:Connect(function() Tween(btn,{BackgroundTransparency=0.08}) end)
	btn.MouseLeave:Connect(function() Tween(btn,{BackgroundTransparency=0.22}) end)
	local el={_frame=frame,_searchName=name,setDisabled=function(v) btn.Active=not v; Tween(btn,{BackgroundTransparency=v and 0.6 or 0.22}) end}
	table.insert(self._elements, el); return el
end

function Section:AddLabel(text)
	local lib=self:_lib(); local theme=lib:_theme()
	local frame=Instance.new("Frame"); frame.Size=UDim2.new(1,0,0,s(34)); frame.BackgroundTransparency=1; frame.BorderSizePixel=0; frame.Parent=self._elems
	local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-s(24),1,0); lbl.Position=UDim2.new(0,s(12),0,0)
	lbl.BackgroundTransparency=1; lbl.Text=text or "Label"; lbl.TextColor3=theme.subtext; lbl.TextSize=s(12)
	lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Font=Enum.Font.GothamMedium; lbl.TextWrapped=true; lbl.RichText=true; lbl.Parent=frame
	local el={_frame=frame,_searchName=text,setText=function(t) lbl.Text=t end,getText=function() return lbl.Text end}
	table.insert(self._elements, el); return el
end

function Section:AddInput(name, placeholder, callback)
	local lib=self:_lib(); local theme=lib:_theme()
	local frame=makeBaseFrame(self._elems, s(70), theme)
	local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-s(24),0,s(18)); lbl.Position=UDim2.new(0,s(12),0,s(8))
	lbl.BackgroundTransparency=1; lbl.Text=name; lbl.TextColor3=theme.text; lbl.TextSize=TS
	lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Font=Enum.Font.GothamMedium; lbl.Parent=frame
	local box=Instance.new("TextBox"); box.Size=UDim2.new(1,-s(24),0,s(32)); box.Position=UDim2.new(0,s(12),0,s(30))
	box.BackgroundColor3=theme.elementBg; box.BackgroundTransparency=0.25; box.BorderSizePixel=0
	box.Text=""; box.PlaceholderText=placeholder or "Type..."; box.PlaceholderColor3=Color3.fromRGB(110,110,130)
	box.TextColor3=theme.text; box.TextSize=s(12); box.Font=Enum.Font.Gotham; box.TextXAlignment=Enum.TextXAlignment.Left
	box.ClearTextOnFocus=false; box.Parent=frame; MakeCorner(box,s(8))
	local boxStroke=MakeStroke(box,Color3.fromRGB(255,255,255),0.85,1)
	local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,s(10)); pad.PaddingRight=UDim.new(0,s(10)); pad.Parent=box
	lib:_regTheme(box,"element_bg",nil)
	box.Focused:Connect(function() local t=lib:_theme(); Tween(boxStroke,{Transparency=0.35,Color=t.accent1}) end)
	box.FocusLost:Connect(function(enter) Tween(boxStroke,{Transparency=0.85,Color=Color3.fromRGB(255,255,255)}); if enter and callback then callback(box.Text) end end)
	local el={_frame=frame,_searchName=name,getValue=function() return box.Text end,setValue=function(t) box.Text=t end,
		_updateTheme=function(_,t) Tween(lbl,{TextColor3=t.text}) end}
	table.insert(self._elements, el); return el
end

function Section:AddColorPicker(name, callback)
	local lib=self:_lib(); local theme=lib:_theme()
	local frame=makeBaseFrame(self._elems, s(64), theme)
	local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-s(24),0,s(18)); lbl.Position=UDim2.new(0,s(12),0,s(8))
	lbl.BackgroundTransparency=1; lbl.Text=name; lbl.TextColor3=theme.text; lbl.TextSize=TS
	lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Font=Enum.Font.GothamMedium; lbl.Parent=frame
	local row=Instance.new("Frame"); row.Size=UDim2.new(1,-s(24),0,s(28)); row.Position=UDim2.new(0,s(12),0,s(30))
	row.BackgroundTransparency=1; row.Parent=frame
	local layout=Instance.new("UIListLayout"); layout.FillDirection=Enum.FillDirection.Horizontal; layout.Padding=UDim.new(0,s(8)); layout.Parent=row
	local selectedIdx=_state.themeIndex
	for i=1,#Themes do
		local t=Themes[i]; local cb=Instance.new("TextButton"); cb.Size=UDim2.new(0,s(28),0,s(28))
		cb.BackgroundColor3=t.accent1; cb.BorderSizePixel=0; cb.Text=""; cb.Parent=row; MakeCorner(cb,s(8)); MakeGradient(cb,t.accent1,t.accent2)
		local sel=MakeStroke(cb,Color3.fromRGB(255,255,255),i==selectedIdx and 0.2 or 1,2)
		cb.MouseButton1Click:Connect(function()
			selectedIdx=i
			for _,c in pairs(row:GetChildren()) do
				if c:IsA("TextButton") then local st=c:FindFirstChildOfClass("UIStroke"); if st then Tween(st,{Transparency=1}) end end
			end
			Tween(sel,{Transparency=0.2}); Tween(cb,{Size=UDim2.new(0,s(32),0,s(32))},0.08)
			task.wait(0.1); Tween(cb,{Size=UDim2.new(0,s(28),0,s(28))},0.18)
			lib:_applyTheme(i); if callback then callback(i,t) end
		end)
	end
	table.insert(self._elements, {_frame=frame,_searchName=name}); return {}
end

function Section:AddKeybind(name, defaultKey, callback)
	local lib=self:_lib(); local theme=lib:_theme()
	local frame=makeBaseFrame(self._elems, s(48), theme)
	local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-s(120),1,0); lbl.Position=UDim2.new(0,s(12),0,0)
	lbl.BackgroundTransparency=1; lbl.Text=name; lbl.TextColor3=theme.text; lbl.TextSize=TS
	lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Font=Enum.Font.GothamMedium; lbl.Parent=frame
	local currentKey=defaultKey or Enum.KeyCode.F
	local keyBtn=Instance.new("TextButton"); keyBtn.Size=UDim2.new(0,s(88),0,s(30)); keyBtn.Position=UDim2.new(1,-s(102),0.5,-s(15))
	keyBtn.BackgroundColor3=Color3.fromRGB(35,35,50); keyBtn.BackgroundTransparency=0.25; keyBtn.BorderSizePixel=0
	keyBtn.Text=currentKey.Name; keyBtn.TextColor3=theme.text; keyBtn.TextSize=s(11); keyBtn.Font=Enum.Font.GothamBold; keyBtn.Parent=frame; MakeCorner(keyBtn,s(8))
	local keyStroke=MakeStroke(keyBtn,theme.accent1,0.65,1); lib:_regTheme(keyStroke,"accent_stroke",nil)
	local isBinding=false
	keyBtn.MouseButton1Click:Connect(function() if not isBinding then isBinding=true; keyBtn.Text="..."; Tween(keyStroke,{Transparency=0.20}) end end)
	UserInputService.InputBegan:Connect(function(inp,gp)
		if isBinding and inp.UserInputType==Enum.UserInputType.Keyboard then currentKey=inp.KeyCode; keyBtn.Text=currentKey.Name; isBinding=false; Tween(keyStroke,{Transparency=0.65}) end
		if not gp and inp.KeyCode==currentKey and not isBinding then if callback then callback(currentKey) end end
	end)
	local el={_frame=frame,_searchName=name,getValue=function() return currentKey end,setKey=function(k) currentKey=k; keyBtn.Text=k.Name end,
		_updateTheme=function(_,t) Tween(lbl,{TextColor3=t.text}) end}
	table.insert(self._elements, el); return el
end

return HorizonUI
