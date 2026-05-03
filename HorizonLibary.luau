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
	{
		name       = "Horizon",
		accent1    = Color3.fromRGB(99,  102, 241),
		accent2    = Color3.fromRGB(168,  85, 247),
		background = Color3.fromRGB(9,    9,  14),
		sidebar    = Color3.fromRGB(13,  13,  20),
		text       = Color3.fromRGB(240, 240, 250),
		subtext    = Color3.fromRGB(140, 140, 165),
		stroke     = Color3.fromRGB(50,  50,  80),
		elementBg  = Color3.fromRGB(18,  18,  28),
		toggleOff  = Color3.fromRGB(45,  45,  65),
		trackBg    = Color3.fromRGB(38,  38,  58),
	},
	{
		name       = "Neon",
		accent1    = Color3.fromRGB(0,   255, 200),
		accent2    = Color3.fromRGB(0,   180, 255),
		background = Color3.fromRGB(5,   10,  14),
		sidebar    = Color3.fromRGB(7,   14,  20),
		text       = Color3.fromRGB(230, 250, 255),
		subtext    = Color3.fromRGB(120, 170, 190),
		stroke     = Color3.fromRGB(0,   80, 100),
		elementBg  = Color3.fromRGB(10,  20,  28),
		toggleOff  = Color3.fromRGB(30,  55,  65),
		trackBg    = Color3.fromRGB(25,  50,  65),
	},
	{
		name       = "Rose",
		accent1    = Color3.fromRGB(244,  63,  94),
		accent2    = Color3.fromRGB(251, 113, 133),
		background = Color3.fromRGB(12,   7,   9),
		sidebar    = Color3.fromRGB(17,  10,  13),
		text       = Color3.fromRGB(255, 240, 245),
		subtext    = Color3.fromRGB(180, 140, 155),
		stroke     = Color3.fromRGB(80,  30,  45),
		elementBg  = Color3.fromRGB(22,  13,  18),
		toggleOff  = Color3.fromRGB(65,  35,  45),
		trackBg    = Color3.fromRGB(55,  30,  40),
	},
	{
		name       = "Ocean",
		accent1    = Color3.fromRGB(56,  189, 248),
		accent2    = Color3.fromRGB(99,  102, 241),
		background = Color3.fromRGB(7,   12,  18),
		sidebar    = Color3.fromRGB(10,  16,  24),
		text       = Color3.fromRGB(230, 245, 255),
		subtext    = Color3.fromRGB(120, 160, 190),
		stroke     = Color3.fromRGB(30,  70, 110),
		elementBg  = Color3.fromRGB(14,  22,  34),
		toggleOff  = Color3.fromRGB(35,  60,  85),
		trackBg    = Color3.fromRGB(30,  55,  80),
	},
	{
		name       = "Gold",
		accent1    = Color3.fromRGB(251, 191,  36),
		accent2    = Color3.fromRGB(245, 158,  11),
		background = Color3.fromRGB(13,  11,   6),
		sidebar    = Color3.fromRGB(18,  15,   8),
		text       = Color3.fromRGB(255, 250, 235),
		subtext    = Color3.fromRGB(180, 165, 120),
		stroke     = Color3.fromRGB(90,  70,  20),
		elementBg  = Color3.fromRGB(22,  18,  10),
		toggleOff  = Color3.fromRGB(65,  55,  25),
		trackBg    = Color3.fromRGB(58,  48,  22),
	},
	{
		name       = "Sakura",
		accent1    = Color3.fromRGB(236,  72, 153),
		accent2    = Color3.fromRGB(168,  85, 247),
		background = Color3.fromRGB(12,   8,  14),
		sidebar    = Color3.fromRGB(17,  11,  19),
		text       = Color3.fromRGB(255, 240, 255),
		subtext    = Color3.fromRGB(190, 155, 210),
		stroke     = Color3.fromRGB(90,  40, 110),
		elementBg  = Color3.fromRGB(22,  14,  26),
		toggleOff  = Color3.fromRGB(68,  40,  80),
		trackBg    = Color3.fromRGB(60,  35,  72),
	},
}

local Icons = {
	close    = "rbxassetid://10747384394",
	minimize = "rbxassetid://10734896206",
	home     = "rbxassetid://10723407389",
	settings = "rbxassetid://10734950309",
	plus     = "rbxassetid://10734924532",
	user     = "rbxassetid://10747373176",
	star     = "rbxassetid://10734966248",
}

-- ─────────────────────────────────────────────
--  Helpers
-- ─────────────────────────────────────────────

local function MakeCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or s(10))
	c.Parent = parent
	return c
end

local function MakeStroke(parent, color, transparency, thickness)
	local st = Instance.new("UIStroke")
	st.Color        = color        or Color3.fromRGB(255,255,255)
	st.Transparency = transparency or 0.85
	st.Thickness    = thickness    or 1
	st.Parent = parent
	return st
end

local function MakeGradient(parent, c1, c2)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, c1),
		ColorSequenceKeypoint.new(1, c2),
	})
	g.Parent = parent
	return g
end

local function UpdateGradient(g, c1, c2)
	if not g then return end
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, c1),
		ColorSequenceKeypoint.new(1, c2),
	})
end

-- Default easing upgraded to Quint for a silkier feel
local function Tween(obj, props, t, style, dir)
	TweenService:Create(
		obj,
		TweenInfo.new(t or 0.28, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
		props
	):Play()
end

local function MakeIcon(parent, asset, size, color)
	local img = Instance.new("ImageLabel")
	img.Size                   = UDim2.new(0, size or s(14), 0, size or s(14))
	img.AnchorPoint            = Vector2.new(0.5, 0.5)
	img.Position               = UDim2.new(0.5, 0, 0.5, 0)
	img.BackgroundTransparency = 1
	img.Image                  = asset or ""
	img.ImageColor3            = color or Color3.fromRGB(255,255,255)
	img.Parent = parent
	return img
end

-- ─────────────────────────────────────────────
--  Core class
-- ─────────────────────────────────────────────

local HorizonUI = {}
HorizonUI.__index = HorizonUI

local Tab     = {}
Tab.__index   = Tab
local Section = {}
Section.__index = Section

local _state = { themeIndex = 1 }

function HorizonUI.new(title)
	local self          = setmetatable({}, HorizonUI)
	self.title          = title or "Horizon"
	self.player         = Players.LocalPlayer
	self.playerGui      = self.player:WaitForChild("PlayerGui")
	self.tabs           = {}
	self.activeTab      = nil
	self.isMinimized    = false
	self.dialogOpen     = false
	self._themeReg      = {}
	self._sliderDrag    = false
	self._resizeDrag    = false
	self._currentW      = GUI_W
	self._currentH      = GUI_H
	self:_build()
	return self
end

function HorizonUI:_theme()
	return Themes[_state.themeIndex]
end

function HorizonUI:_regTheme(element, kind, extra)
	table.insert(self._themeReg, { element = element, kind = kind, extra = extra })
end

function HorizonUI:_build()
	local theme = self:_theme()

	self.gui = Instance.new("ScreenGui")
	self.gui.Name           = "HorizonUI"
	self.gui.ResetOnSpawn   = false
	self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.gui.Parent         = self.playerGui

	self.main = Instance.new("Frame")
	self.main.Name                   = "Main"
	self.main.Size                   = UDim2.new(0, GUI_W, 0, GUI_H)
	self.main.Position               = UDim2.new(0.5, -GUI_W/2, 0.5, -GUI_H/2)
	self.main.BackgroundColor3       = theme.background
	self.main.BackgroundTransparency = 0.06
	self.main.BorderSizePixel        = 0
	self.main.Parent                 = self.gui
	MakeCorner(self.main, s(18))
	self.mainStroke = MakeStroke(self.main, theme.stroke, 0.4, 1.5)

	self.titleBar = Instance.new("Frame")
	self.titleBar.Name               = "TitleBar"
	self.titleBar.Size               = UDim2.new(1, 0, 0, s(42))
	self.titleBar.BackgroundTransparency = 1
	self.titleBar.Parent             = self.main

	self:_buildControls()
	self:_buildSidebar()
	self:_buildContent()
	self:_buildResizeHandle()
	self:_setupDrag()
	self:_setupHotkey()
	self:_applyTheme(_state.themeIndex)
	self:_animateIn()
end

-- ─────────────────────────────────────────────
--  Title bar  (just the label now — mac dots own the controls)
-- ─────────────────────────────────────────────

function HorizonUI:_buildControls()
	local theme = self:_theme()

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size               = UDim2.new(1, -s(30), 1, 0)
	titleLabel.Position           = UDim2.new(0, SIDEBAR_W + s(14), 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text               = self.title
	titleLabel.TextColor3         = theme.text
	titleLabel.TextSize           = s(13)
	titleLabel.Font               = Enum.Font.GothamBold
	titleLabel.TextXAlignment     = Enum.TextXAlignment.Left
	titleLabel.Parent             = self.titleBar
	self._titleLabel = titleLabel
end

-- ─────────────────────────────────────────────
--  Sidebar
-- ─────────────────────────────────────────────

function HorizonUI:_buildSidebar()
	local theme = self:_theme()

	self.sidebar = Instance.new("Frame")
	self.sidebar.Name               = "Sidebar"
	self.sidebar.Size               = UDim2.new(0, SIDEBAR_W, 1, 0)
	self.sidebar.BackgroundColor3   = theme.sidebar
	self.sidebar.BackgroundTransparency = 0.04
	self.sidebar.BorderSizePixel    = 0
	self.sidebar.Parent             = self.main
	MakeCorner(self.sidebar, s(18))
	self.sidebarStroke = MakeStroke(self.sidebar, theme.stroke, 0.55, 1)

	-- ── macOS traffic-light dots ──────────────────────
	local wc = Instance.new("Frame")
	wc.Size               = UDim2.new(0, s(68), 0, s(14))
	wc.Position           = UDim2.new(0, s(14), 0, s(15))
	wc.BackgroundTransparency = 1
	wc.Parent             = self.sidebar

	-- red = close  |  yellow = minimize  |  green = re-center
	local dotDefs = {
		{ color = Color3.fromRGB(255, 95,  86),  sym = "×", symColor = Color3.fromRGB(100, 25, 20), action = function() if not self.dialogOpen then self:_closeDialog() end end },
		{ color = Color3.fromRGB(255, 189, 46),  sym = "−", symColor = Color3.fromRGB(100, 72,  0), action = function() if not self.dialogOpen then self:_toggleMin()    end end },
		{ color = Color3.fromRGB(39,  201, 63),  sym = "+", symColor = Color3.fromRGB(10,  80, 15), action = function() self:_recenter()                                    end },
	}

	for i, def in ipairs(dotDefs) do
		local dot = Instance.new("TextButton")
		dot.Size             = UDim2.new(0, s(13), 0, s(13))
		dot.Position         = UDim2.new(0, (i-1) * s(23), 0, 0)
		dot.BackgroundColor3 = def.color
		dot.BorderSizePixel  = 0
		dot.Text             = ""
		dot.AutoButtonColor  = false
		dot.Parent           = wc
		MakeCorner(dot, s(7))

		-- symbol that fades in on hover
		local sym = Instance.new("TextLabel")
		sym.Size              = UDim2.new(1, 0, 1, 0)
		sym.BackgroundTransparency = 1
		sym.Text              = def.sym
		sym.TextColor3        = def.symColor
		sym.TextSize          = s(10)
		sym.Font              = Enum.Font.GothamBold
		sym.TextTransparency  = 1
		sym.Parent            = dot

		dot.MouseEnter:Connect(function()
			Tween(dot, {BackgroundColor3 = def.color:Lerp(Color3.fromRGB(255,255,255), 0.28)}, 0.12)
			Tween(sym, {TextTransparency = 0}, 0.12)
		end)
		dot.MouseLeave:Connect(function()
			Tween(dot, {BackgroundColor3 = def.color}, 0.18)
			Tween(sym, {TextTransparency = 1}, 0.15)
		end)
		dot.MouseButton1Click:Connect(def.action)
	end

	-- ── Logo area ─────────────────────────────────────
	local logoArea = Instance.new("Frame")
	logoArea.Size               = UDim2.new(1, -s(24), 0, s(52))
	logoArea.Position           = UDim2.new(0, s(12), 0, s(38))
	logoArea.BackgroundTransparency = 1
	logoArea.Parent             = self.sidebar

	local accentBar = Instance.new("Frame")
	accentBar.Size             = UDim2.new(0, s(3), 0, s(18))
	accentBar.Position         = UDim2.new(0, 0, 0.5, -s(9))
	accentBar.BorderSizePixel  = 0
	accentBar.BackgroundColor3 = theme.accent1
	accentBar.Parent           = logoArea
	MakeCorner(accentBar, s(4))
	self._accentBarGrad = MakeGradient(accentBar, theme.accent1, theme.accent2)

	local logoLabel = Instance.new("TextLabel")
	logoLabel.Size              = UDim2.new(1, -s(12), 1, 0)
	logoLabel.Position          = UDim2.new(0, s(10), 0, 0)
	logoLabel.BackgroundTransparency = 1
	logoLabel.Text              = self.title
	logoLabel.TextColor3        = theme.text
	logoLabel.TextSize          = s(19)
	logoLabel.Font              = Enum.Font.GothamBold
	logoLabel.TextXAlignment    = Enum.TextXAlignment.Left
	logoLabel.Parent            = logoArea
	self._logoLabel = logoLabel

	self.tabsContainer = Instance.new("Frame")
	self.tabsContainer.Name              = "Tabs"
	self.tabsContainer.Size              = UDim2.new(1, 0, 1, -s(200))
	self.tabsContainer.Position          = UDim2.new(0, 0, 0, s(104))
	self.tabsContainer.BackgroundTransparency = 1
	self.tabsContainer.Parent           = self.sidebar

	self:_buildUserCard()
end

function HorizonUI:_buildUserCard()
	local theme  = self:_theme()
	local player = self.player

	local card = Instance.new("Frame")
	card.Size               = UDim2.new(1, -s(24), 0, s(62))
	card.Position           = UDim2.new(0, s(12), 1, -s(76))
	card.BackgroundColor3   = Color3.fromRGB(255,255,255)
	card.BackgroundTransparency = 0.93
	card.BorderSizePixel    = 0
	card.Parent             = self.sidebar
	MakeCorner(card, s(12))
	self._userCardStroke = MakeStroke(card, theme.stroke, 0.55, 1)

	local avatarSize = s(38)

	local avatar = Instance.new("ImageLabel")
	avatar.Size             = UDim2.new(0, avatarSize, 0, avatarSize)
	avatar.Position         = UDim2.new(0, s(10), 0.5, -avatarSize/2)
	avatar.BackgroundColor3 = theme.elementBg
	avatar.BorderSizePixel  = 0
	avatar.Image            = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	avatar.Parent           = card
	MakeCorner(avatar, avatarSize)

	-- thin accent ring around avatar
	local ring = Instance.new("Frame")
	ring.Size               = UDim2.new(0, avatarSize + s(4), 0, avatarSize + s(4))
	ring.Position           = UDim2.new(0, s(10) - s(2), 0.5, -(avatarSize/2 + s(2)))
	ring.BackgroundTransparency = 1
	ring.BorderSizePixel    = 0
	ring.Parent             = card
	MakeCorner(ring, avatarSize + s(4))
	local ringStroke = MakeStroke(ring, theme.accent1, 0.35, 1.5)
	self:_regTheme(ringStroke, "accent_stroke", nil)

	local nameX = avatarSize + s(14)

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size              = UDim2.new(1, -(nameX + s(8)), 0, s(18))
	nameLabel.Position          = UDim2.new(0, nameX, 0, s(12))
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text              = player.DisplayName
	nameLabel.TextColor3        = theme.text
	nameLabel.TextSize          = s(13)
	nameLabel.Font              = Enum.Font.GothamBold
	nameLabel.TextXAlignment    = Enum.TextXAlignment.Left
	nameLabel.TextTruncate      = Enum.TextTruncate.AtEnd
	nameLabel.Parent            = card

	self._statusLabel = Instance.new("TextLabel")
	self._statusLabel.Size              = UDim2.new(1, -(nameX + s(8)), 0, s(16))
	self._statusLabel.Position          = UDim2.new(0, nameX, 0, s(30))
	self._statusLabel.BackgroundTransparency = 1
	self._statusLabel.Text              = "@" .. player.Name
	self._statusLabel.TextColor3        = theme.subtext
	self._statusLabel.TextSize          = s(11)
	self._statusLabel.Font              = Enum.Font.GothamMedium
	self._statusLabel.TextXAlignment    = Enum.TextXAlignment.Left
	self._statusLabel.TextTruncate      = Enum.TextTruncate.AtEnd
	self._statusLabel.Parent            = card
end

function HorizonUI:_buildContent()
	self.contentArea = Instance.new("Frame")
	self.contentArea.Name               = "Content"
	self.contentArea.Size               = UDim2.new(1, -SIDEBAR_W, 1, -s(42))
	self.contentArea.Position           = UDim2.new(0, SIDEBAR_W, 0, s(42))
	self.contentArea.BackgroundTransparency = 1
	self.contentArea.BorderSizePixel    = 0
	self.contentArea.Parent             = self.main

	self.contentContainer = Instance.new("Frame")
	self.contentContainer.Name               = "Container"
	self.contentContainer.Size               = UDim2.new(1, 0, 1, 0)
	self.contentContainer.BackgroundTransparency = 1
	self.contentContainer.Parent           = self.contentArea
end

-- ─────────────────────────────────────────────
--  Resize handle  (bottom-right corner)
-- ─────────────────────────────────────────────

function HorizonUI:_buildResizeHandle()
	local area = Instance.new("Frame")
	area.Name                  = "ResizeHandle"
	area.Size                  = UDim2.new(0, s(22), 0, s(22))
	area.Position              = UDim2.new(1, -s(22), 1, -s(22))
	area.BackgroundTransparency = 1
	area.ZIndex                = 8
	area.Parent                = self.main

	-- three diagonal tick marks
	for i = 1, 3 do
		local tick = Instance.new("Frame")
		local len  = s(3 + i * 3)
		tick.Size             = UDim2.new(0, s(1.5), 0, len)
		tick.AnchorPoint      = Vector2.new(0.5, 1)
		tick.Position         = UDim2.new(1, -s(3 + (3-i) * 5), 1, -s(3 + (3-i) * 5))
		tick.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		tick.BackgroundTransparency = 0.72
		tick.BorderSizePixel  = 0
		tick.Rotation         = 45
		tick.ZIndex           = 9
		tick.Parent           = area
		MakeCorner(tick, s(1))
	end

	-- invisible button that captures input
	local btn = Instance.new("TextButton")
	btn.Size               = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text               = ""
	btn.ZIndex             = 10
	btn.Parent             = area

	local resizing = false
	local resizeStart, startSize

	btn.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing         = true
			self._resizeDrag = true
			self._sliderDrag = true
			resizeStart      = inp.Position
			startSize        = Vector2.new(self.main.AbsoluteSize.X, self.main.AbsoluteSize.Y)
		end
	end)

	UserInputService.InputChanged:Connect(function(inp)
		if resizing and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local d    = inp.Position - resizeStart
			local newW = clamp(startSize.X + d.X, MIN_W, MAX_W)
			local newH = clamp(startSize.Y + d.Y, MIN_H, MAX_H)
			self._currentW = newW
			self._currentH = newH
			self.main.Size = UDim2.new(0, newW, 0, newH)
		end
	end)

	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 and resizing then
			resizing         = false
			self._resizeDrag = false
			self._sliderDrag = false
			-- keep _origGeo in sync so minimize/restore snaps to the new size
			self._origGeo = { Size = self.main.Size, Position = self.main.Position }
		end
	end)

	-- subtle glow on hover
	btn.MouseEnter:Connect(function()
		for _, c in pairs(area:GetChildren()) do
			if c:IsA("Frame") then Tween(c, {BackgroundTransparency = 0.3}, 0.14) end
		end
	end)
	btn.MouseLeave:Connect(function()
		for _, c in pairs(area:GetChildren()) do
			if c:IsA("Frame") then Tween(c, {BackgroundTransparency = 0.72}, 0.2) end
		end
	end)
end

-- ─────────────────────────────────────────────
--  Drag  (title bar)
-- ─────────────────────────────────────────────

function HorizonUI:_setupDrag()
	local dragging, dragStart, startPos = false, nil, nil
	UserInputService.InputBegan:Connect(function(inp)
		local t = inp.UserInputType
		if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
		local pos = t == Enum.UserInputType.Touch and inp.Position
			or (UserInputService:GetMouseLocation() - game:GetService("GuiService"):GetGuiInset())
		local tbp = self.titleBar.AbsolutePosition
		local tbs = self.titleBar.AbsoluteSize
		if pos.X >= tbp.X and pos.X <= tbp.X + tbs.X
			and pos.Y >= tbp.Y and pos.Y <= tbp.Y + tbs.Y then
			if not self._sliderDrag and not self._resizeDrag and not self.dialogOpen then
				dragging  = true
				dragStart = inp.Position
				startPos  = self.main.Position
			end
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if dragging and not self._sliderDrag and not self._resizeDrag then
			local t = inp.UserInputType
			if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
				local d = inp.Position - dragStart
				self.main.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + d.X,
					startPos.Y.Scale, startPos.Y.Offset + d.Y
				)
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		local t = inp.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			if dragging then
				dragging = false
				-- keep origGeo position in sync after a drag too
				if self._origGeo then
					self._origGeo.Position = self.main.Position
				end
			end
		end
	end)
end

-- ─────────────────────────────────────────────
--  Insert hotkey
-- ─────────────────────────────────────────────

function HorizonUI:_setupHotkey()
	UserInputService.InputBegan:Connect(function(inp, gp)
		if gp then return end
		if inp.KeyCode == Enum.KeyCode.Insert then
			local w = self._currentW
			local h = self._currentH
			if self.gui.Enabled then
				Tween(self.main, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)},
					0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
				task.wait(0.4)
				self.gui.Enabled = false
			else
				self.gui.Enabled   = true
				self.main.Size     = UDim2.new(0, 0, 0, 0)
				self.main.Position = UDim2.new(0.5, 0, 0.5, 0)
				Tween(self.main,
					{Size = UDim2.new(0,w,0,h), Position = UDim2.new(0.5,-w/2,0.5,-h/2)},
					0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			end
		end
	end)
end

-- ─────────────────────────────────────────────
--  Animate in
-- ─────────────────────────────────────────────

function HorizonUI:_animateIn()
	self.main.Size     = UDim2.new(0, 0, 0, 0)
	self.main.Position = UDim2.new(0.5, 0, 0.5, 0)
	Tween(self.main,
		{Size = UDim2.new(0,GUI_W,0,GUI_H), Position = UDim2.new(0.5,-GUI_W/2,0.5,-GUI_H/2)},
		0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

-- ─────────────────────────────────────────────
--  Minimize / restore
-- ─────────────────────────────────────────────

function HorizonUI:_toggleMin()
	if self._minAnim then return end
	self.isMinimized = not self.isMinimized

	-- always snapshot current geometry before minimizing
	if not self._origGeo or not self.isMinimized then
		self._origGeo = { Size = self.main.Size, Position = self.main.Position }
	end

	if self.isMinimized then
		self._minAnim = true
		-- collapse to pill
		local tw = TweenService:Create(self.main,
			TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Size     = UDim2.new(0, s(230), 0, s(40)),
				Position = UDim2.new(
					self.main.Position.X.Scale,
					self.main.Position.X.Offset + (self._currentW/2 - s(115)),
					self.main.Position.Y.Scale,
					self.main.Position.Y.Offset
				),
			})
		tw:Play()
		tw.Completed:Connect(function()
			if self.sidebar     then self.sidebar.Visible     = false end
			if self.contentArea then self.contentArea.Visible = false end
			self._minAnim = false
		end)
	else
		self._minAnim = true
		if self.sidebar     then self.sidebar.Visible     = true  end
		if self.contentArea then self.contentArea.Visible = true  end
		local tw = TweenService:Create(self.main,
			TweenInfo.new(0.48, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size     = self._origGeo.Size,
				Position = self._origGeo.Position,
			})
		tw:Play()
		tw.Completed:Connect(function() self._minAnim = false end)
	end
end

-- ─────────────────────────────────────────────
--  Re-center  (green dot)
-- ─────────────────────────────────────────────

function HorizonUI:_recenter()
	if self.isMinimized then return end
	local w = self._currentW
	local h = self._currentH
	local newPos = UDim2.new(0.5, -w/2, 0.5, -h/2)
	Tween(self.main, {Position = newPos}, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	-- keep origGeo up to date
	self._origGeo = { Size = self.main.Size, Position = newPos }
end

-- ─────────────────────────────────────────────
--  Close confirmation dialog
-- ─────────────────────────────────────────────

function HorizonUI:_closeDialog()
	self.dialogOpen = true
	local theme = self:_theme()

	local overlay = Instance.new("Frame")
	overlay.Size               = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3   = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 0.45
	overlay.BorderSizePixel    = 0
	overlay.ZIndex             = 100
	overlay.Parent             = self.main
	MakeCorner(overlay, s(18))

	local dW, dH = s(300), s(130)

	local dialog = Instance.new("Frame")
	dialog.Size               = UDim2.new(0, 0, 0, 0)
	dialog.Position           = UDim2.new(0.5, -dW/2, 0.5, -dH/2)
	dialog.BackgroundColor3   = Color3.fromRGB(18, 18, 26)
	dialog.BackgroundTransparency = 0.04
	dialog.BorderSizePixel    = 0
	dialog.ZIndex             = 101
	dialog.Parent             = overlay
	MakeCorner(dialog, s(14))
	MakeStroke(dialog, theme.stroke, 0.45, 1)

	local function makeLabel(text, yOff, sz, color, bold)
		local lbl             = Instance.new("TextLabel")
		lbl.Size              = UDim2.new(1, -s(36), 0, s(24))
		lbl.Position          = UDim2.new(0, s(18), 0, yOff)
		lbl.BackgroundTransparency = 1
		lbl.Text              = text
		lbl.TextColor3        = color or Color3.fromRGB(255, 255, 255)
		lbl.TextSize          = sz or s(13)
		lbl.Font              = bold and Enum.Font.GothamBold or Enum.Font.Gotham
		lbl.TextXAlignment    = Enum.TextXAlignment.Left
		lbl.TextWrapped       = true
		lbl.ZIndex            = 102
		lbl.Parent            = dialog
	end
	makeLabel("UI'yi kapat?", s(12), s(16), nil, true)
	makeLabel("Emin misin?",  s(38), s(12), Color3.fromRGB(160, 160, 175), false)

	local bW, bH = s(116), s(30)
	local function makeBtn(xOff, text, bgColor, bgTrans)
		local btn               = Instance.new("TextButton")
		btn.Size               = UDim2.new(0, bW, 0, bH)
		btn.Position           = UDim2.new(0, xOff, 1, -s(40))
		btn.BackgroundColor3   = bgColor
		btn.BackgroundTransparency = bgTrans
		btn.BorderSizePixel    = 0
		btn.Text               = text
		btn.TextColor3         = Color3.fromRGB(255, 255, 255)
		btn.TextSize           = s(12)
		btn.Font               = Enum.Font.GothamBold
		btn.ZIndex             = 102
		btn.Parent             = dialog
		MakeCorner(btn, s(9))
		return btn
	end

	local cancelBtn  = makeBtn(s(18),      "İptal", Color3.fromRGB(255,255,255), 0.88)
	local confirmBtn = makeBtn(bW + s(24), "Kapat", Color3.fromRGB(220,40,40),   0.18)

	cancelBtn.MouseButton1Click:Connect(function()
		Tween(overlay, {BackgroundTransparency = 1}, 0.2)
		Tween(dialog,  {Size = UDim2.new(0,0,0,0)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		task.wait(0.22)
		overlay:Destroy()
		self.dialogOpen = false
	end)
	confirmBtn.MouseButton1Click:Connect(function() self:Destroy() end)

	cancelBtn.MouseEnter:Connect(function()  Tween(cancelBtn,  {BackgroundTransparency = 0.80}) end)
	cancelBtn.MouseLeave:Connect(function()  Tween(cancelBtn,  {BackgroundTransparency = 0.88}) end)
	confirmBtn.MouseEnter:Connect(function() Tween(confirmBtn, {BackgroundTransparency = 0.08}) end)
	confirmBtn.MouseLeave:Connect(function() Tween(confirmBtn, {BackgroundTransparency = 0.18}) end)

	-- pop in
	TweenService:Create(dialog, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = UDim2.new(0, dW, 0, dH)}):Play()
end

-- ─────────────────────────────────────────────
--  Theme application
-- ─────────────────────────────────────────────

function HorizonUI:_applyTheme(idx)
	local theme = Themes[idx] or Themes[1]
	_state.themeIndex = idx

	local function tw(obj, props)
		if obj and obj.Parent then Tween(obj, props, 0.32) end
	end

	tw(self.main,            {BackgroundColor3 = theme.background})
	tw(self.mainStroke,      {Color = theme.stroke})
	tw(self.sidebar,         {BackgroundColor3 = theme.sidebar})
	tw(self.sidebarStroke,   {Color = theme.stroke})
	tw(self._userCardStroke, {Color = theme.stroke})
	tw(self._statusLabel,    {TextColor3 = theme.subtext})
	tw(self._titleLabel,     {TextColor3 = theme.text})
	tw(self._logoLabel,      {TextColor3 = theme.text})
	if self._accentBarGrad then UpdateGradient(self._accentBarGrad, theme.accent1, theme.accent2) end

	for _, tab in ipairs(self.tabs) do tab:_updateTheme(theme) end

	for _, reg in ipairs(self._themeReg) do
		if reg.element and reg.element.Parent then
			local k = reg.kind
			if k == "accent_bg" then
				tw(reg.element, {BackgroundColor3 = theme.accent1})
				if reg.extra and reg.extra.grad then UpdateGradient(reg.extra.grad, theme.accent1, theme.accent2) end
			elseif k == "accent_stroke" then
				tw(reg.element, {Color = theme.accent1})
			elseif k == "toggle_on" then
				tw(reg.element, {BackgroundColor3 = theme.accent1})
				if reg.extra and reg.extra.grad then UpdateGradient(reg.extra.grad, theme.accent1, theme.accent2) end
			elseif k == "toggle_off" then
				tw(reg.element, {BackgroundColor3 = theme.toggleOff})
			elseif k == "track" then
				tw(reg.element, {BackgroundColor3 = theme.trackBg})
			elseif k == "fill" then
				tw(reg.element, {BackgroundColor3 = theme.accent1})
				if reg.extra and reg.extra.grad then UpdateGradient(reg.extra.grad, theme.accent1, theme.accent2) end
			elseif k == "element_bg" then
				tw(reg.element, {BackgroundColor3 = theme.elementBg})
			end
		end
	end
end

function HorizonUI:SetStatus(text)
	if self._statusLabel then self._statusLabel.Text = text end
end

function HorizonUI:Destroy()
	Tween(self.main, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)},
		0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	task.wait(0.42)
	self.gui:Destroy()
end

-- ─────────────────────────────────────────────
--  Tabs
-- ─────────────────────────────────────────────

function HorizonUI:AddTab(name, icon)
	local tab = Tab._new(self, name, icon or Icons.settings)
	table.insert(self.tabs, tab)
	if not self.activeTab then
		self.activeTab = tab
		tab:_show()
	end
	return tab
end

function Tab._new(library, name, icon)
	local self    = setmetatable({}, Tab)
	self._lib     = library
	self.name     = name
	self.icon     = icon
	self.sections = {}
	self.isActive = false
	self:_makeBtn()
	self:_makeContent()
	return self
end

function Tab:_makeBtn()
	local yOff = #self._lib.tabs * s(48)
	local theme = self._lib:_theme()

	self.btn = Instance.new("TextButton")
	self.btn.Size               = UDim2.new(1, -s(24), 0, s(40))
	self.btn.Position           = UDim2.new(0, s(12), 0, yOff)
	self.btn.BackgroundColor3   = Color3.fromRGB(255, 255, 255)
	self.btn.BackgroundTransparency = 1
	self.btn.BorderSizePixel    = 0
	self.btn.Text               = ""
	self.btn.Parent             = self._lib.tabsContainer
	MakeCorner(self.btn, s(10))
	self.btnStroke = MakeStroke(self.btn, Color3.fromRGB(255,255,255), 1, 1)

	self.btnIcon = MakeIcon(self.btn, self.icon, s(15), Color3.fromRGB(140,140,165))
	self.btnIcon.AnchorPoint = Vector2.new(0, 0.5)
	self.btnIcon.Position    = UDim2.new(0, s(12), 0.5, 0)

	self.btnText = Instance.new("TextLabel")
	self.btnText.Size              = UDim2.new(1, -s(40), 1, 0)
	self.btnText.Position          = UDim2.new(0, s(34), 0, 0)
	self.btnText.BackgroundTransparency = 1
	self.btnText.Text              = self.name
	self.btnText.TextColor3        = Color3.fromRGB(140,140,165)
	self.btnText.TextSize          = s(12)
	self.btnText.TextXAlignment    = Enum.TextXAlignment.Left
	self.btnText.Font              = Enum.Font.GothamMedium
	self.btnText.Parent            = self.btn

	self.btn.MouseButton1Click:Connect(function() self:_show() end)
	self.btn.MouseEnter:Connect(function()
		if not self.isActive then
			Tween(self.btn,       {BackgroundTransparency = 0.92}, 0.14)
			Tween(self.btnStroke, {Transparency = 0.82},           0.14)
		end
	end)
	self.btn.MouseLeave:Connect(function()
		if not self.isActive then
			Tween(self.btn,       {BackgroundTransparency = 1},  0.2)
			Tween(self.btnStroke, {Transparency = 1},            0.2)
		end
	end)
end

function Tab:_makeContent()
	self.content = Instance.new("ScrollingFrame")
	self.content.Name               = self.name .. "Content"
	self.content.Size               = UDim2.new(1, -s(24), 1, -s(14))
	self.content.Position           = UDim2.new(0, s(12), 0, s(7))
	self.content.BackgroundTransparency = 1
	self.content.BorderSizePixel    = 0
	self.content.ScrollBarThickness = isMobile and 2 or 3
	self.content.ScrollBarImageColor3 = Color3.fromRGB(255,255,255)
	self.content.ScrollBarImageTransparency = 0.75
	self.content.CanvasSize         = UDim2.new(0, 0, 0, 0)
	self.content.Visible            = false
	self.content.Parent             = self._lib.contentContainer

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding   = UDim.new(0, s(10))
	layout.Parent    = self.content
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + s(16))
	end)
end

function Tab:_show()
	if self.isActive then return end
	if self._lib.activeTab then self._lib.activeTab:_hide() end
	self._lib.activeTab = self
	self.isActive = true
	local theme = self._lib:_theme()

	Tween(self.btn,       {BackgroundTransparency = 0.87}, 0.25)
	Tween(self.btnStroke, {Transparency = 0.62},           0.25)
	Tween(self.btnIcon,   {ImageColor3 = Color3.fromRGB(255,255,255)}, 0.25)
	Tween(self.btnText,   {TextColor3 = Color3.fromRGB(255,255,255)},  0.25)

	if not self.btnGrad then
		self.btnGrad = Instance.new("UIGradient")
		self.btnGrad.Parent = self.btn
	end
	UpdateGradient(self.btnGrad, theme.accent1, theme.accent2)
	self.content.Visible = true
end

function Tab:_hide()
	if not self.isActive then return end
	self.isActive = false
	Tween(self.btn,       {BackgroundTransparency = 1},   0.25)
	Tween(self.btnStroke, {Transparency = 1},              0.25)
	Tween(self.btnIcon,   {ImageColor3 = Color3.fromRGB(140,140,165)}, 0.25)
	Tween(self.btnText,   {TextColor3 = Color3.fromRGB(140,140,165)},  0.25)
	if self.btnGrad then self.btnGrad:Destroy(); self.btnGrad = nil end
	self.content.Visible = false
end

function Tab:_updateTheme(theme)
	if self.isActive and self.btnGrad then
		UpdateGradient(self.btnGrad, theme.accent1, theme.accent2)
	end
	for _, sec in ipairs(self.sections) do sec:_updateTheme(theme) end
end

function Tab:AddSection(name)
	local sec = Section._new(self, name)
	table.insert(self.sections, sec)
	return sec
end

-- ─────────────────────────────────────────────
--  Sections
-- ─────────────────────────────────────────────

function Section._new(tab, name)
	local self     = setmetatable({}, Section)
	self._tab      = tab
	self.name      = name
	self._elements = {}
	self:_build()
	return self
end

function Section:_build()
	self.container = Instance.new("Frame")
	self.container.Name              = self.name .. "Sec"
	self.container.Size              = UDim2.new(1, 0, 0, 0)
	self.container.BackgroundTransparency = 1
	self.container.Parent           = self._tab.content

	local headerH = 0
	if self.name ~= "" then
		headerH = s(26)
		local header = Instance.new("Frame")
		header.Size               = UDim2.new(1, 0, 0, headerH)
		header.BackgroundTransparency = 1
		header.Parent             = self.container

		local function makeLine(xScale, xOff, wScale, wOff)
			local ln = Instance.new("Frame")
			ln.Size             = UDim2.new(wScale, wOff, 0, 1)
			ln.Position         = UDim2.new(xScale, xOff, 0.5, 0)
			ln.BackgroundColor3 = Color3.fromRGB(255,255,255)
			ln.BackgroundTransparency = 0.85
			ln.BorderSizePixel  = 0
			ln.Parent           = header
		end
		makeLine(0, 0, 0.3, -s(6))
		makeLine(0.7, s(6), 0.3, -s(6))

		local hTitle = Instance.new("TextLabel")
		hTitle.Size              = UDim2.new(0.4, 0, 1, 0)
		hTitle.Position          = UDim2.new(0.3, 0, 0, 0)
		hTitle.BackgroundTransparency = 1
		hTitle.Text              = self.name
		hTitle.TextColor3        = Color3.fromRGB(200, 200, 215)
		hTitle.TextSize          = s(10)
		hTitle.Font              = Enum.Font.GothamBold
		hTitle.Parent            = header
	end

	self._elems = Instance.new("Frame")
	self._elems.Name              = "Elems"
	self._elems.Size              = UDim2.new(1, 0, 0, 0)
	self._elems.Position          = UDim2.new(0, 0, 0, headerH)
	self._elems.BackgroundTransparency = 1
	self._elems.Parent           = self.container

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding   = UDim.new(0, s(7))
	layout.Parent    = self._elems
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self._elems.Size    = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
		self.container.Size = UDim2.new(1, 0, 0, headerH + layout.AbsoluteContentSize.Y)
	end)
	self._headerH = headerH
end

function Section:_updateTheme(theme)
	for _, el in ipairs(self._elements) do
		if el._updateTheme then el:_updateTheme(theme) end
	end
end

function Section:_lib() return self._tab._lib end

-- ─────────────────────────────────────────────
--  Toggle
-- ─────────────────────────────────────────────

function Section:AddToggle(name, default, callback)
	local lib   = self:_lib()
	local theme = lib:_theme()

	local frame = Instance.new("Frame")
	frame.Size               = UDim2.new(1, 0, 0, s(44))
	frame.BackgroundColor3   = Color3.fromRGB(255,255,255)
	frame.BackgroundTransparency = 0.94
	frame.BorderSizePixel    = 0
	frame.Parent             = self._elems
	MakeCorner(frame, s(10))

	local lbl = Instance.new("TextLabel")
	lbl.Size              = UDim2.new(1, -s(80), 1, 0)
	lbl.Position          = UDim2.new(0, s(12), 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text              = name
	lbl.TextColor3        = theme.text
	lbl.TextSize          = TS
	lbl.TextXAlignment    = Enum.TextXAlignment.Left
	lbl.Font              = Enum.Font.GothamMedium
	lbl.Parent            = frame

	local active = default or false
	local tW, tH = s(42), s(20)

	local toggle = Instance.new("TextButton")
	toggle.Size               = UDim2.new(0, tW, 0, tH)
	toggle.Position           = UDim2.new(1, -(tW + s(12)), 0.5, -tH/2)
	toggle.BackgroundColor3   = active and theme.accent1 or theme.toggleOff
	toggle.BackgroundTransparency = active and 0.15 or 0.4
	toggle.BorderSizePixel    = 0
	toggle.Text               = ""
	toggle.Parent             = frame
	MakeCorner(toggle, s(10))

	local thumbSz = s(14)
	local thumb   = Instance.new("Frame")
	thumb.Size             = UDim2.new(0, thumbSz, 0, thumbSz)
	thumb.Position         = active
		and UDim2.new(0, tW - thumbSz - s(3), 0, s(3))
		or  UDim2.new(0, s(3), 0, s(3))
	thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
	thumb.BorderSizePixel  = 0
	thumb.Parent           = toggle
	MakeCorner(thumb, thumbSz)

	local grad = nil
	if active then grad = MakeGradient(toggle, theme.accent1, theme.accent2) end
	lib:_regTheme(toggle, active and "toggle_on" or "toggle_off", {grad = grad})

	toggle.MouseButton1Click:Connect(function()
		active = not active
		local t = lib:_theme()
		if active then
			Tween(toggle, {BackgroundColor3 = t.accent1, BackgroundTransparency = 0.15}, 0.25)
			local existing = toggle:FindFirstChildOfClass("UIGradient")
			if not existing then
				grad = MakeGradient(toggle, t.accent1, t.accent2)
			else
				UpdateGradient(existing, t.accent1, t.accent2); grad = existing
			end
			lib:_regTheme(toggle, "toggle_on", {grad = grad})
		else
			Tween(toggle, {BackgroundColor3 = t.toggleOff, BackgroundTransparency = 0.4}, 0.25)
			local g = toggle:FindFirstChildOfClass("UIGradient")
			if g then g:Destroy() end
			grad = nil
			lib:_regTheme(toggle, "toggle_off", nil)
		end
		TweenService:Create(thumb,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = active
					and UDim2.new(0, tW - thumbSz - s(3), 0, s(3))
					or  UDim2.new(0, s(3), 0, s(3))
			}):Play()
		if callback then callback(active) end
	end)

	table.insert(self._elements, { _updateTheme = function(_, t) Tween(lbl, {TextColor3 = t.text}) end })
	return { getValue = function() return active end }
end

-- ─────────────────────────────────────────────
--  Slider
-- ─────────────────────────────────────────────

function Section:AddSlider(name, min, max, default, callback)
	local lib   = self:_lib()
	local theme = lib:_theme()

	local frame = Instance.new("Frame")
	frame.Size               = UDim2.new(1, 0, 0, s(56))
	frame.BackgroundColor3   = Color3.fromRGB(255,255,255)
	frame.BackgroundTransparency = 0.94
	frame.BorderSizePixel    = 0
	frame.Parent             = self._elems
	MakeCorner(frame, s(10))

	local lbl = Instance.new("TextLabel")
	lbl.Size              = UDim2.new(1, -s(70), 0, s(18))
	lbl.Position          = UDim2.new(0, s(12), 0, s(7))
	lbl.BackgroundTransparency = 1
	lbl.Text              = name
	lbl.TextColor3        = theme.text
	lbl.TextSize          = TS
	lbl.TextXAlignment    = Enum.TextXAlignment.Left
	lbl.Font              = Enum.Font.GothamMedium
	lbl.Parent            = frame

	local currentValue = clamp(default or min, min, max)

	local valLbl = Instance.new("TextLabel")
	valLbl.Size              = UDim2.new(0, s(50), 0, s(18))
	valLbl.Position          = UDim2.new(1, -s(60), 0, s(7))
	valLbl.BackgroundTransparency = 1
	valLbl.Text              = tostring(currentValue)
	valLbl.TextColor3        = theme.subtext
	valLbl.TextSize          = s(11)
	valLbl.Font              = Enum.Font.GothamBold
	valLbl.TextXAlignment    = Enum.TextXAlignment.Right
	valLbl.Parent            = frame

	local track = Instance.new("Frame")
	track.Size             = UDim2.new(1, -s(28), 0, s(5))
	track.Position         = UDim2.new(0, s(14), 0, s(38))
	track.BackgroundColor3 = theme.trackBg
	track.BackgroundTransparency = 0.25
	track.BorderSizePixel  = 0
	track.Parent           = frame
	MakeCorner(track, s(3))
	lib:_regTheme(track, "track", nil)

	local progress = (currentValue - min) / (max - min)

	local fill = Instance.new("Frame")
	fill.Size             = UDim2.new(progress, 0, 1, 0)
	fill.BackgroundColor3 = theme.accent1
	fill.BorderSizePixel  = 0
	fill.Parent           = track
	MakeCorner(fill, s(3))
	local fillGrad = MakeGradient(fill, theme.accent1, theme.accent2)
	lib:_regTheme(fill, "fill", {grad = fillGrad})

	local thumb = Instance.new("Frame")
	thumb.Size             = UDim2.new(0, s(18), 0, s(18))
	thumb.Position         = UDim2.new(progress, -s(9), 0.5, -s(9))
	thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
	thumb.BorderSizePixel  = 0
	thumb.ZIndex           = 2
	thumb.Parent           = track
	MakeCorner(thumb, s(9))
	local thumbStroke = MakeStroke(thumb, theme.accent1, 0.3, 2)
	lib:_regTheme(thumbStroke, "accent_stroke", nil)

	local isDragging = false
	local function updateSlider(input)
		local rel = clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		currentValue = math.floor(min + rel * (max - min))
		Tween(fill,  {Size     = UDim2.new(rel, 0, 1, 0)},            0.08)
		Tween(thumb, {Position = UDim2.new(rel, -s(9), 0.5, -s(9))},  0.08)
		valLbl.Text = tostring(currentValue)
		if callback then callback(currentValue) end
	end

	track.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging       = true
			lib._sliderDrag  = true
			updateSlider(inp)
			Tween(thumb, {Size = UDim2.new(0, s(22), 0, s(22))}, 0.12)
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if isDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			updateSlider(inp)
		end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
			isDragging      = false
			lib._sliderDrag = false
			Tween(thumb, {Size = UDim2.new(0, s(18), 0, s(18))}, 0.18)
		end
	end)

	table.insert(self._elements, { _updateTheme = function(_, t) Tween(lbl, {TextColor3 = t.text}) end })
	return { getValue = function() return currentValue end }
end

-- ─────────────────────────────────────────────
--  Dropdown
-- ─────────────────────────────────────────────

function Section:AddDropdown(name, options, default, callback)
	local lib   = self:_lib()
	local theme = lib:_theme()
	local baseH = s(70)

	local frame = Instance.new("Frame")
	frame.Size               = UDim2.new(1, 0, 0, baseH)
	frame.BackgroundColor3   = Color3.fromRGB(255,255,255)
	frame.BackgroundTransparency = 0.94
	frame.BorderSizePixel    = 0
	frame.Parent             = self._elems
	MakeCorner(frame, s(10))

	local lbl = Instance.new("TextLabel")
	lbl.Size              = UDim2.new(1, -s(24), 0, s(18))
	lbl.Position          = UDim2.new(0, s(12), 0, s(8))
	lbl.BackgroundTransparency = 1
	lbl.Text              = name
	lbl.TextColor3        = theme.text
	lbl.TextSize          = TS
	lbl.TextXAlignment    = Enum.TextXAlignment.Left
	lbl.Font              = Enum.Font.GothamMedium
	lbl.Parent            = frame

	local currentValue = default or options[1]

	local dropBtn = Instance.new("TextButton")
	dropBtn.Size               = UDim2.new(1, -s(24), 0, s(32))
	dropBtn.Position           = UDim2.new(0, s(12), 0, s(30))
	dropBtn.BackgroundColor3   = theme.elementBg
	dropBtn.BackgroundTransparency = 0.25
	dropBtn.BorderSizePixel    = 0
	dropBtn.Text               = ""
	dropBtn.ZIndex             = 2
	dropBtn.Parent             = frame
	MakeCorner(dropBtn, s(8))
	MakeStroke(dropBtn, Color3.fromRGB(255,255,255), 0.85, 1)
	lib:_regTheme(dropBtn, "element_bg", nil)

	local dropText = Instance.new("TextLabel")
	dropText.Size              = UDim2.new(1, -s(36), 1, 0)
	dropText.Position          = UDim2.new(0, s(10), 0, 0)
	dropText.BackgroundTransparency = 1
	dropText.Text              = currentValue
	dropText.TextColor3        = theme.text
	dropText.TextSize          = s(12)
	dropText.TextXAlignment    = Enum.TextXAlignment.Left
	dropText.Font              = Enum.Font.Gotham
	dropText.Parent            = dropBtn

	local arrow = Instance.new("TextLabel")
	arrow.Size              = UDim2.new(0, s(20), 1, 0)
	arrow.Position          = UDim2.new(1, -s(26), 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text              = "▾"
	arrow.TextColor3        = theme.subtext
	arrow.TextSize          = s(12)
	arrow.Font              = Enum.Font.Gotham
	arrow.Parent            = dropBtn

	local listFrame = Instance.new("Frame")
	listFrame.Size               = UDim2.new(1, 0, 0, 0)
	listFrame.Position           = UDim2.new(0, 0, 0, s(34))
	listFrame.BackgroundColor3   = Color3.fromRGB(20, 20, 32)
	listFrame.BackgroundTransparency = 0.04
	listFrame.BorderSizePixel    = 0
	listFrame.Visible            = false
	listFrame.ZIndex             = 10
	listFrame.Parent             = dropBtn
	MakeCorner(listFrame, s(8))
	MakeStroke(listFrame, Color3.fromRGB(255,255,255), 0.85, 1)

	local expandedH = #options * s(32)
	for i, opt in ipairs(options) do
		local optBtn = Instance.new("TextButton")
		optBtn.Size               = UDim2.new(1, -s(10), 0, s(28))
		optBtn.Position           = UDim2.new(0, s(5), 0, (i-1)*s(32)+s(2))
		optBtn.BackgroundColor3   = Color3.fromRGB(255,255,255)
		optBtn.BackgroundTransparency = 1
		optBtn.BorderSizePixel    = 0
		optBtn.Text               = opt
		optBtn.TextColor3         = theme.text
		optBtn.TextSize           = s(12)
		optBtn.TextXAlignment     = Enum.TextXAlignment.Left
		optBtn.Font               = Enum.Font.Gotham
		optBtn.ZIndex             = 11
		optBtn.Parent             = listFrame
		MakeCorner(optBtn, s(6))
		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, s(8))
		pad.Parent = optBtn

		optBtn.MouseEnter:Connect(function()  Tween(optBtn, {BackgroundTransparency = 0.88}, 0.1) end)
		optBtn.MouseLeave:Connect(function()  Tween(optBtn, {BackgroundTransparency = 1},    0.15) end)
		optBtn.MouseButton1Click:Connect(function()
			currentValue  = opt
			dropText.Text = opt
			Tween(arrow,     {Rotation = 0}, 0.2)
			Tween(listFrame, {Size = UDim2.new(1,0,0,0)}, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			Tween(frame,     {Size = UDim2.new(1,0,0,baseH)}, 0.18)
			task.delay(0.18, function() listFrame.Visible = false end)
			if callback then callback(opt) end
		end)
	end

	local isOpen = false
	dropBtn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		Tween(arrow, {Rotation = isOpen and 180 or 0}, 0.22)
		if isOpen then
			listFrame.Visible = true
			Tween(listFrame, {Size = UDim2.new(1,0,0,expandedH)}, 0.24)
			Tween(frame,     {Size = UDim2.new(1,0,0,baseH + expandedH + s(6))}, 0.24)
		else
			Tween(listFrame, {Size = UDim2.new(1,0,0,0)}, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			Tween(frame,     {Size = UDim2.new(1,0,0,baseH)}, 0.18)
			task.delay(0.18, function() listFrame.Visible = false end)
		end
	end)

	return { getValue = function() return currentValue end }
end

-- ─────────────────────────────────────────────
--  Button
-- ─────────────────────────────────────────────

function Section:AddButton(name, callback)
	local lib   = self:_lib()
	local theme = lib:_theme()

	local frame = Instance.new("Frame")
	frame.Size               = UDim2.new(1, 0, 0, s(44))
	frame.BackgroundColor3   = Color3.fromRGB(255,255,255)
	frame.BackgroundTransparency = 0.94
	frame.BorderSizePixel    = 0
	frame.Parent             = self._elems
	MakeCorner(frame, s(10))

	local btn = Instance.new("TextButton")
	btn.Size               = UDim2.new(1, -s(24), 1, -s(10))
	btn.Position           = UDim2.new(0, s(12), 0, s(5))
	btn.BackgroundColor3   = theme.accent1
	btn.BackgroundTransparency = 0.25
	btn.BorderSizePixel    = 0
	btn.Text               = name
	btn.TextColor3         = Color3.fromRGB(255,255,255)
	btn.TextSize           = s(13)
	btn.Font               = Enum.Font.GothamBold
	btn.Parent             = frame
	MakeCorner(btn, s(9))
	local grad = MakeGradient(btn, theme.accent1, theme.accent2)
	lib:_regTheme(btn, "accent_bg", {grad = grad})

	btn.MouseButton1Click:Connect(function()
		Tween(btn, {Size = UDim2.new(1,-s(28),1,-s(14))}, 0.08)
		task.wait(0.08)
		Tween(btn, {Size = UDim2.new(1,-s(24),1,-s(10))}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		if callback then callback() end
	end)
	btn.MouseEnter:Connect(function() Tween(btn, {BackgroundTransparency = 0.1},  0.15) end)
	btn.MouseLeave:Connect(function() Tween(btn, {BackgroundTransparency = 0.25}, 0.2)  end)
end

-- ─────────────────────────────────────────────
--  Label
-- ─────────────────────────────────────────────

function Section:AddLabel(text)
	local lib   = self:_lib()
	local theme = lib:_theme()

	local frame = Instance.new("Frame")
	frame.Size               = UDim2.new(1, 0, 0, s(34))
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel    = 0
	frame.Parent             = self._elems

	local lbl = Instance.new("TextLabel")
	lbl.Size              = UDim2.new(1, -s(24), 1, 0)
	lbl.Position          = UDim2.new(0, s(12), 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text              = text or "Label"
	lbl.TextColor3        = theme.subtext
	lbl.TextSize          = s(12)
	lbl.TextXAlignment    = Enum.TextXAlignment.Left
	lbl.Font              = Enum.Font.GothamMedium
	lbl.TextWrapped       = true
	lbl.RichText          = true
	lbl.Parent            = frame

	return {
		setText = function(t) lbl.Text = t end,
		getText = function()  return lbl.Text end,
	}
end

-- ─────────────────────────────────────────────
--  Input
-- ─────────────────────────────────────────────

function Section:AddInput(name, placeholder, callback)
	local lib   = self:_lib()
	local theme = lib:_theme()

	local frame = Instance.new("Frame")
	frame.Size               = UDim2.new(1, 0, 0, s(70))
	frame.BackgroundColor3   = Color3.fromRGB(255,255,255)
	frame.BackgroundTransparency = 0.94
	frame.BorderSizePixel    = 0
	frame.Parent             = self._elems
	MakeCorner(frame, s(10))

	local lbl = Instance.new("TextLabel")
	lbl.Size              = UDim2.new(1, -s(24), 0, s(18))
	lbl.Position          = UDim2.new(0, s(12), 0, s(8))
	lbl.BackgroundTransparency = 1
	lbl.Text              = name
	lbl.TextColor3        = theme.text
	lbl.TextSize          = TS
	lbl.TextXAlignment    = Enum.TextXAlignment.Left
	lbl.Font              = Enum.Font.GothamMedium
	lbl.Parent            = frame

	local box = Instance.new("TextBox")
	box.Size               = UDim2.new(1, -s(24), 0, s(32))
	box.Position           = UDim2.new(0, s(12), 0, s(30))
	box.BackgroundColor3   = theme.elementBg
	box.BackgroundTransparency = 0.25
	box.BorderSizePixel    = 0
	box.Text               = ""
	box.PlaceholderText    = placeholder or "Yaz..."
	box.PlaceholderColor3  = Color3.fromRGB(110, 110, 130)
	box.TextColor3         = theme.text
	box.TextSize           = s(12)
	box.Font               = Enum.Font.Gotham
	box.TextXAlignment     = Enum.TextXAlignment.Left
	box.ClearTextOnFocus   = false
	box.Parent             = frame
	MakeCorner(box, s(8))
	local boxStroke = MakeStroke(box, Color3.fromRGB(255,255,255), 0.85, 1)
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft  = UDim.new(0, s(10))
	pad.PaddingRight = UDim.new(0, s(10))
	pad.Parent       = box
	lib:_regTheme(box, "element_bg", nil)

	box.Focused:Connect(function()
		local t = lib:_theme()
		Tween(boxStroke, {Transparency = 0.35, Color = t.accent1}, 0.2)
	end)
	box.FocusLost:Connect(function(enter)
		Tween(boxStroke, {Transparency = 0.85, Color = Color3.fromRGB(255,255,255)}, 0.2)
		if enter and callback then callback(box.Text) end
	end)

	return {
		getValue = function()  return box.Text end,
		setValue = function(t) box.Text = t    end,
	}
end

-- ─────────────────────────────────────────────
--  Color picker  (theme switcher)
-- ─────────────────────────────────────────────

function Section:AddColorPicker(name, callback)
	local lib   = self:_lib()
	local theme = lib:_theme()

	local frame = Instance.new("Frame")
	frame.Size               = UDim2.new(1, 0, 0, s(64))
	frame.BackgroundColor3   = Color3.fromRGB(255,255,255)
	frame.BackgroundTransparency = 0.94
	frame.BorderSizePixel    = 0
	frame.Parent             = self._elems
	MakeCorner(frame, s(10))

	local lbl = Instance.new("TextLabel")
	lbl.Size              = UDim2.new(1, -s(24), 0, s(18))
	lbl.Position          = UDim2.new(0, s(12), 0, s(8))
	lbl.BackgroundTransparency = 1
	lbl.Text              = name
	lbl.TextColor3        = theme.text
	lbl.TextSize          = TS
	lbl.TextXAlignment    = Enum.TextXAlignment.Left
	lbl.Font              = Enum.Font.GothamMedium
	lbl.Parent            = frame

	local row = Instance.new("Frame")
	row.Size               = UDim2.new(1, -s(24), 0, s(28))
	row.Position           = UDim2.new(0, s(12), 0, s(30))
	row.BackgroundTransparency = 1
	row.Parent             = frame
	local layout = Instance.new("UIListLayout")
	layout.FillDirection   = Enum.FillDirection.Horizontal
	layout.Padding         = UDim.new(0, s(8))
	layout.Parent          = row

	local selectedIdx = _state.themeIndex
	for i = 1, #Themes do
		local t  = Themes[i]
		local cb = Instance.new("TextButton")
		cb.Size             = UDim2.new(0, s(28), 0, s(28))
		cb.BackgroundColor3 = t.accent1
		cb.BorderSizePixel  = 0
		cb.Text             = ""
		cb.Parent           = row
		MakeCorner(cb, s(8))
		MakeGradient(cb, t.accent1, t.accent2)
		local sel = MakeStroke(cb, Color3.fromRGB(255,255,255), i == selectedIdx and 0.2 or 1, 2)

		cb.MouseButton1Click:Connect(function()
			selectedIdx = i
			for _, c in pairs(row:GetChildren()) do
				if c:IsA("TextButton") then
					local st = c:FindFirstChildOfClass("UIStroke")
					if st then Tween(st, {Transparency = 1}) end
				end
			end
			Tween(sel, {Transparency = 0.2})
			Tween(cb,  {Size = UDim2.new(0, s(32), 0, s(32))}, 0.08)
			task.wait(0.1)
			Tween(cb,  {Size = UDim2.new(0, s(28), 0, s(28))}, 0.2)
			lib:_applyTheme(i)
			if callback then callback(i, t) end
		end)
	end
end

-- ─────────────────────────────────────────────
--  Keybind
-- ─────────────────────────────────────────────

function Section:AddKeybind(name, defaultKey, callback)
	local lib   = self:_lib()
	local theme = lib:_theme()

	local frame = Instance.new("Frame")
	frame.Size               = UDim2.new(1, 0, 0, s(48))
	frame.BackgroundColor3   = Color3.fromRGB(255,255,255)
	frame.BackgroundTransparency = 0.94
	frame.BorderSizePixel    = 0
	frame.Parent             = self._elems
	MakeCorner(frame, s(10))

	local lbl = Instance.new("TextLabel")
	lbl.Size              = UDim2.new(1, -s(120), 1, 0)
	lbl.Position          = UDim2.new(0, s(12), 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text              = name
	lbl.TextColor3        = theme.text
	lbl.TextSize          = TS
	lbl.TextXAlignment    = Enum.TextXAlignment.Left
	lbl.Font              = Enum.Font.GothamMedium
	lbl.Parent            = frame

	local currentKey = defaultKey or Enum.KeyCode.F

	local keyBtn = Instance.new("TextButton")
	keyBtn.Size               = UDim2.new(0, s(88), 0, s(30))
	keyBtn.Position           = UDim2.new(1, -s(102), 0.5, -s(15))
	keyBtn.BackgroundColor3   = Color3.fromRGB(35, 35, 50)
	keyBtn.BackgroundTransparency = 0.25
	keyBtn.BorderSizePixel    = 0
	keyBtn.Text               = currentKey.Name
	keyBtn.TextColor3         = theme.text
	keyBtn.TextSize           = s(11)
	keyBtn.Font               = Enum.Font.GothamBold
	keyBtn.Parent             = frame
	MakeCorner(keyBtn, s(8))
	local keyStroke = MakeStroke(keyBtn, theme.accent1, 0.65, 1)
	lib:_regTheme(keyStroke, "accent_stroke", nil)

	local isBinding = false
	keyBtn.MouseButton1Click:Connect(function()
		if not isBinding then
			isBinding      = true
			keyBtn.Text    = "..."
			Tween(keyStroke, {Transparency = 0.2}, 0.18)
		end
	end)
	UserInputService.InputBegan:Connect(function(inp, gp)
		if isBinding and inp.UserInputType == Enum.UserInputType.Keyboard then
			currentKey   = inp.KeyCode
			keyBtn.Text  = currentKey.Name
			isBinding    = false
			Tween(keyStroke, {Transparency = 0.65}, 0.2)
		end
		if not gp and inp.KeyCode == currentKey and not isBinding then
			if callback then callback(currentKey) end
		end
	end)

	return {
		getValue = function()  return currentKey              end,
		setKey   = function(k) currentKey = k; keyBtn.Text = k.Name end,
	}
end

return HorizonUI
