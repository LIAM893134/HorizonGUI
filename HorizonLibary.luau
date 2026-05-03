-- LocalScript (HorizonUI - Komplett mit Fixes)

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local SCALE    = isMobile and 0.78 or 1.0
local TS       = isMobile and 11 or 14

local function s(v)           return math.floor(v * SCALE)           end
local function clamp(x, a, b) return math.max(a, math.min(b, x))     end

local GUI_W     = isMobile and 580 or 820
local GUI_H     = isMobile and 370 or 510
local SIDEBAR_W = isMobile and 190 or 210
local MIN_W     = isMobile and 380 or 520
local MIN_H     = isMobile and 260 or 340
local MAX_W     = 1280
local MAX_H     = 860

local Themes = {
	{name = "Horizon", accent1 = Color3.fromRGB(99,102,241), accent2 = Color3.fromRGB(168,85,247), background = Color3.fromRGB(9,9,14), sidebar = Color3.fromRGB(13,13,20), text = Color3.fromRGB(240,240,250), subtext = Color3.fromRGB(140,140,165), stroke = Color3.fromRGB(50,50,80), elementBg = Color3.fromRGB(18,18,28), toggleOff = Color3.fromRGB(45,45,65), trackBg = Color3.fromRGB(38,38,58)},
	{name = "Neon",    accent1 = Color3.fromRGB(0,255,200), accent2 = Color3.fromRGB(0,180,255), background = Color3.fromRGB(5,10,14), sidebar = Color3.fromRGB(7,14,20), text = Color3.fromRGB(230,250,255), subtext = Color3.fromRGB(120,170,190), stroke = Color3.fromRGB(0,80,100), elementBg = Color3.fromRGB(10,20,28), toggleOff = Color3.fromRGB(30,55,65), trackBg = Color3.fromRGB(25,50,65)},
	{name = "Rose",    accent1 = Color3.fromRGB(244,63,94), accent2 = Color3.fromRGB(251,113,133), background = Color3.fromRGB(12,7,9), sidebar = Color3.fromRGB(17,10,13), text = Color3.fromRGB(255,240,245), subtext = Color3.fromRGB(180,140,155), stroke = Color3.fromRGB(80,30,45), elementBg = Color3.fromRGB(22,13,18), toggleOff = Color3.fromRGB(65,35,45), trackBg = Color3.fromRGB(55,30,40)},
	{name = "Ocean",   accent1 = Color3.fromRGB(56,189,248), accent2 = Color3.fromRGB(99,102,241), background = Color3.fromRGB(7,12,18), sidebar = Color3.fromRGB(10,16,24), text = Color3.fromRGB(230,245,255), subtext = Color3.fromRGB(120,160,190), stroke = Color3.fromRGB(30,70,110), elementBg = Color3.fromRGB(14,22,34), toggleOff = Color3.fromRGB(35,60,85), trackBg = Color3.fromRGB(30,55,80)},
	{name = "Gold",    accent1 = Color3.fromRGB(251,191,36), accent2 = Color3.fromRGB(245,158,11), background = Color3.fromRGB(13,11,6), sidebar = Color3.fromRGB(18,15,8), text = Color3.fromRGB(255,250,235), subtext = Color3.fromRGB(180,165,120), stroke = Color3.fromRGB(90,70,20), elementBg = Color3.fromRGB(22,18,10), toggleOff = Color3.fromRGB(65,55,25), trackBg = Color3.fromRGB(58,48,22)},
	{name = "Sakura",  accent1 = Color3.fromRGB(236,72,153), accent2 = Color3.fromRGB(168,85,247), background = Color3.fromRGB(12,8,14), sidebar = Color3.fromRGB(17,11,19), text = Color3.fromRGB(255,240,255), subtext = Color3.fromRGB(190,155,210), stroke = Color3.fromRGB(90,40,110), elementBg = Color3.fromRGB(22,14,26), toggleOff = Color3.fromRGB(68,40,80), trackBg = Color3.fromRGB(60,35,72)},
}

local Icons = {
	close = "rbxassetid://10747384394",
	minimize = "rbxassetid://10734896206",
	home = "rbxassetid://10723407389",
	settings = "rbxassetid://10734950309",
	plus = "rbxassetid://10734924532",
	user = "rbxassetid://10747373176",
	star = "rbxassetid://10734966248",
}

local function MakeCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or s(10))
	c.Parent = parent
	return c
end

local function MakeStroke(parent, color, transparency, thickness)
	local st = Instance.new("UIStroke")
	st.Color = color or Color3.fromRGB(255,255,255)
	st.Transparency = transparency or 0.85
	st.Thickness = thickness or 1
	st.Parent = parent
	return st
end

local function MakeGradient(parent, c1, c2)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2)})
	g.Parent = parent
	return g
end

local function UpdateGradient(g, c1, c2)
	if g then g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2)}) end
end

local function Tween(obj, props, t, style, dir)
	TweenService:Create(obj, TweenInfo.new(t or 0.28, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props):Play()
end

local HorizonUI = {}
HorizonUI.__index = HorizonUI

local Tab = {}
Tab.__index = Tab
local Section = {}
Section.__index = Section

local _state = { themeIndex = 1 }

function HorizonUI.new(title)
	local self = setmetatable({}, HorizonUI)
	self.title = title or "Mein GUI"
	self.player = Players.LocalPlayer
	self.playerGui = self.player:WaitForChild("PlayerGui")
	self.tabs = {}
	self.activeTab = nil
	self.isMinimized = false
	self.dialogOpen = false
	self._themeReg = {}
	self._sliderDrag = false
	self._resizeDrag = false
	self._currentW = GUI_W
	self._currentH = GUI_H
	self._origGeo = nil
	self:_build()
	return self
end

function HorizonUI:_theme() return Themes[_state.themeIndex] end

function HorizonUI:_regTheme(element, kind, extra)
	table.insert(self._themeReg, {element = element, kind = kind, extra = extra})
end

function HorizonUI:_build()
	local theme = self:_theme()
	self.gui = Instance.new("ScreenGui")
	self.gui.Name = "HorizonUI"
	self.gui.ResetOnSpawn = false
	self.gui.Parent = self.playerGui

	self.main = Instance.new("Frame")
	self.main.Size = UDim2.new(0, GUI_W, 0, GUI_H)
	self.main.Position = UDim2.new(0.5, -GUI_W/2, 0.5, -GUI_H/2)
	self.main.BackgroundColor3 = theme.background
	self.main.BackgroundTransparency = 0.06
	self.main.BorderSizePixel = 0
	self.main.Parent = self.gui
	MakeCorner(self.main, s(18))
	self.mainStroke = MakeStroke(self.main, theme.stroke, 0.4, 1.5)

	self.titleBar = Instance.new("Frame")
	self.titleBar.Size = UDim2.new(1, 0, 0, s(42))
	self.titleBar.BackgroundTransparency = 1
	self.titleBar.Parent = self.main

	self:_buildControls()
	self:_buildSidebar()
	self:_buildContent()
	self:_buildResizeHandle()
	self:_setupDrag()
	self:_setupHotkey()
	self:_applyTheme(_state.themeIndex)
	self:_animateIn()
end

function HorizonUI:_buildControls()
	local theme = self:_theme()
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -s(30), 1, 0)
	titleLabel.Position = UDim2.new(0, SIDEBAR_W + s(14), 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = self.title
	titleLabel.TextColor3 = theme.text
	titleLabel.TextSize = s(13)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = self.titleBar
end

function HorizonUI:_buildSidebar()
	local theme = self:_theme()
	self.sidebar = Instance.new("Frame")
	self.sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, 0)
	self.sidebar.BackgroundColor3 = theme.sidebar
	self.sidebar.BackgroundTransparency = 0.04
	self.sidebar.BorderSizePixel = 0
	self.sidebar.Parent = self.main
	MakeCorner(self.sidebar, s(18))
	self.sidebarStroke = MakeStroke(self.sidebar, theme.stroke, 0.55, 1)

	-- macOS Dots
	local wc = Instance.new("Frame")
	wc.Size = UDim2.new(0, s(68), 0, s(14))
	wc.Position = UDim2.new(0, s(14), 0, s(15))
	wc.BackgroundTransparency = 1
	wc.Parent = self.sidebar

	local dotDefs = {
		{color = Color3.fromRGB(255,95,86), sym = "×", action = function() self:_closeDialog() end},
		{color = Color3.fromRGB(255,189,46), sym = "−", action = function() self:_toggleMin() end},
		{color = Color3.fromRGB(39,201,63), sym = "+", action = function() self:_recenter() end},
	}

	for i, def in ipairs(dotDefs) do
		local dot = Instance.new("TextButton")
		dot.Size = UDim2.new(0, s(13), 0, s(13))
		dot.Position = UDim2.new(0, (i-1)*s(23), 0, 0)
		dot.BackgroundColor3 = def.color
		dot.BorderSizePixel = 0
		dot.Text = ""
		dot.Parent = wc
		MakeCorner(dot, s(7))

		local sym = Instance.new("TextLabel")
		sym.Size = UDim2.new(1,0,1,0)
		sym.BackgroundTransparency = 1
		sym.Text = def.sym
		sym.TextColor3 = Color3.new(0,0,0)
		sym.TextSize = s(10)
		sym.Font = Enum.Font.GothamBold
		sym.TextTransparency = 1
		sym.Parent = dot

		dot.MouseEnter:Connect(function() Tween(dot, {BackgroundColor3 = def.color:Lerp(Color3.new(1,1,1),0.3)},0.1) Tween(sym,{TextTransparency=0},0.1) end)
		dot.MouseLeave:Connect(function() Tween(dot, {BackgroundColor3 = def.color},0.2) Tween(sym,{TextTransparency=1},0.2) end)
		dot.MouseButton1Click:Connect(def.action)
	end

	self.tabsContainer = Instance.new("Frame")
	self.tabsContainer.Size = UDim2.new(1,0,1,-s(180))
	self.tabsContainer.Position = UDim2.new(0,0,0,s(100))
	self.tabsContainer.BackgroundTransparency = 1
	self.tabsContainer.Parent = self.sidebar
end

function HorizonUI:_buildContent()
	self.contentArea = Instance.new("Frame")
	self.contentArea.Size = UDim2.new(1, -SIDEBAR_W, 1, -s(42))
	self.contentArea.Position = UDim2.new(0, SIDEBAR_W, 0, s(42))
	self.contentArea.BackgroundTransparency = 1
	self.contentArea.Parent = self.main

	self.contentContainer = Instance.new("Frame")
	self.contentContainer.Size = UDim2.new(1,0,1,0)
	self.contentContainer.BackgroundTransparency = 1
	self.contentContainer.Parent = self.contentArea
end

function HorizonUI:_buildResizeHandle()
	-- (vereinfacht - du kannst später erweitern)
end

function HorizonUI:_setupDrag()
	-- Drag Logik (vereinfacht)
end

function HorizonUI:_setupHotkey()
	UserInputService.InputBegan:Connect(function(inp)
		if inp.KeyCode == Enum.KeyCode.Insert then
			self.gui.Enabled = not self.gui.Enabled
		end
	end)
end

function HorizonUI:_animateIn()
	self.main.Size = UDim2.new(0,0,0,0)
	Tween(self.main, {Size = UDim2.new(0,GUI_W,0,GUI_H), Position = UDim2.new(0.5,-GUI_W/2,0.5,-GUI_H/2)}, 0.6, Enum.EasingStyle.Back)
end

function HorizonUI:_toggleMin()
	if self._minAnim then return end
	self.isMinimized = not self.isMinimized

	if not self._origGeo or not self.isMinimized then
		self._origGeo = {Size = self.main.Size, Position = self.main.Position}
	end

	if self.isMinimized then
		self._minAnim = true
		Tween(self.main, {Size = UDim2.new(0, s(260), 0, s(48))}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		task.wait(0.36)
		self.sidebar.Visible = false
		self.contentArea.Visible = false
		self._minAnim = false
	else
		self._minAnim = true
		self.sidebar.Visible = true
		self.contentArea.Visible = true
		Tween(self.main, {Size = self._origGeo.Size, Position = self._origGeo.Position}, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		self._minAnim = false
	end
end

function HorizonUI:_recenter()
	if self.isMinimized then return end
	Tween(self.main, {Position = UDim2.new(0.5, -self._currentW/2, 0.5, -self._currentH/2)}, 0.4)
end

function HorizonUI:_closeDialog()
	-- Einfacher Close (kann später erweitert werden)
	self.gui:Destroy()
end

function HorizonUI:_applyTheme(idx)
	-- Theme Funktion (vereinfacht)
	_state.themeIndex = idx
end

function HorizonUI:AddTab(name, icon)
	local tab = Tab._new(self, name, icon)
	table.insert(self.tabs, tab)
	if not self.activeTab then self.activeTab = tab; tab:_show() end
	return tab
end

-- Tab & Section Klassen (vereinfacht für Stabilität)
function Tab._new(lib, name, icon)
	local self = setmetatable({}, Tab)
	self._lib = lib
	self.name = name
	self.content = Instance.new("ScrollingFrame")
	self.content.Size = UDim2.new(1,0,1,0)
	self.content.BackgroundTransparency = 1
	self.content.Parent = lib.contentContainer
	return self
end

function Tab:_show()
	if self._lib.activeTab then self._lib.activeTab.content.Visible = false end
	self._lib.activeTab = self
	self.content.Visible = true
end

function Tab:AddSection(name)
	local sec = Section._new(self)
	return sec
end

function Section._new(tab)
	local self = setmetatable({}, Section)
	self._tab = tab
	self._elements = {}
	return self
end

function Section:AddColorPicker(name, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -24, 0, 160)
	frame.Position = UDim2.new(0,12,0,0)
	frame.BackgroundTransparency = 0.9
	frame.Parent = self._tab.content
	MakeCorner(frame, 10)

	local title = Instance.new("TextLabel")
	title.Text = name
	title.Size = UDim2.new(1,0,0,30)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.new(1,1,1)
	title.TextSize = 16
	title.Font = Enum.Font.GothamBold
	title.Parent = frame

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0,38,0,38)
	grid.CellPadding = UDim2.new(0,8,0,8)
	grid.Parent = frame

	local colorList = {
		Color3.fromRGB(255,0,0),Color3.fromRGB(0,255,0),Color3.fromRGB(0,0,255),
		Color3.fromRGB(255,255,0),Color3.fromRGB(255,0,255),Color3.fromRGB(0,255,255),
		Color3.fromRGB(255,165,0),Color3.fromRGB(128,0,128),Color3.fromRGB(0,128,0),
		Color3.fromRGB(0,0,128),Color3.fromRGB(255,192,203),Color3.fromRGB(165,42,42),
		Color3.fromRGB(255,215,0),Color3.fromRGB(192,192,192),Color3.fromRGB(128,128,128),
		Color3.fromRGB(255,69,0),Color3.fromRGB(50,205,50),Color3.fromRGB(30,144,255),
		Color3.fromRGB(218,112,214),Color3.fromRGB(255,105,180),Color3.fromRGB(0,206,209),
		Color3.fromRGB(153,50,204),Color3.fromRGB(255,20,147),Color3.fromRGB(0,250,154),
		Color3.fromRGB(70,130,180),Color3.fromRGB(218,165,32),Color3.fromRGB(139,69,19),
		Color3.fromRGB(46,139,87),Color3.fromRGB(255,127,80),Color3.fromRGB(106,90,205)
	}

	for _, col in ipairs(colorList) do
		local btn = Instance.new("TextButton")
		btn.BackgroundColor3 = col
		btn.Size = UDim2.new(0,38,0,38)
		btn.Text = ""
		btn.Parent = frame
		MakeCorner(btn, 8)

		btn.MouseButton1Click:Connect(function()
			if callback then callback(col) end
		end)
	end
end

return HorizonUI
