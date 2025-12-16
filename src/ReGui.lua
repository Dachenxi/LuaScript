local ReGui = loadstring(game:HttpGet('https://raw.githubusercontent.com/depthso/Dear-ReGui/refs/heads/main/ReGui.lua'))()
local UI = {}
UI.__index = UI

local Palette = {
	MainDark    = Color3.fromRGB(25, 25, 30),    -- Background Utama (Deep Grey)
	SecondDark  = Color3.fromRGB(35, 35, 40),    -- Header/Title Bar
	ElementBg   = Color3.fromRGB(45, 45, 50),    -- Input/Region
	Accent      = Color3.fromRGB(65, 130, 255),  -- Modern Blue (Vibrant)
	TextWhite   = Color3.fromRGB(240, 240, 240), -- Putih Tulang (Tidak menyilaukan)
	TextGray    = Color3.fromRGB(160, 160, 170), -- Teks non-aktif
	Border      = Color3.fromRGB(60, 60, 65),    -- Garis Tepi Halus
	Error       = Color3.fromRGB(255, 85, 85),   -- Merah Soft
	Success     = Color3.fromRGB(85, 255, 120),  -- Hijau Soft
}

ReGui:DefineTheme("MidnightModern", {
	--// Tipografi Modern
	TextFont = Font.fromName("GothamSSm", Enum.FontWeight.SemiBold),
	Text = Palette.TextWhite,
	TextDisabled = Palette.TextGray,
	ErrorText = Palette.Error,

	--// Elements (Input, Button, dll)
	InputsBg = Palette.ElementBg,
	InputsBgTransparency = 0, -- Dibuat solid agar terlihat flat design
	InputsGrabColor = Palette.Accent,

	ButtonsBg = Palette.Accent, -- Tombol menyala dengan warna aksen

	CollapsingHeaderBg = Palette.SecondDark,
	CollapsingHeaderText = Palette.TextWhite,

	CheckboxBg = Palette.ElementBg,
	CheckboxTick = Palette.Accent,

	RadioButtonSelectedBg = Palette.Accent,

	ComboBg = Palette.ElementBg,

	ResizeGrab = Palette.TextGray,

	HeaderBg = Palette.SecondDark,
	HeaderBgTransparency = 0, -- Solid

	HistogramBar = Palette.Accent,
	ProgressBar = Palette.Accent,

	RegionBg = Palette.ElementBg,
	RegionBgTransparency = 0.5, -- Sedikit transparan untuk membedakan layer

	TabText = Palette.TextGray,
	TabBg = Palette.MainDark, -- Tab mati menyatu dengan background

	ActiveTabText = Palette.Accent, -- Teks tab aktif berwarna aksen
	ActiveTabBg = Palette.SecondDark, -- Background tab aktif sedikit lebih terang

	TabsBarBg = Palette.MainDark,
	TabsBarBgTransparency = 0,

	--// Window (Jendela Utama)
	WindowBg = Palette.MainDark,
	WindowBgTransparency = 0.05, -- Sedikit transparan (Glassmorphism tipis)

	Border = Palette.Border,
	BorderTransparency = 0, -- Border solid tapi warnanya samar

	Title = Palette.TextWhite,
	TitleAlign = Enum.TextXAlignment.Left, -- Rata kiri lebih modern

	TitleBarBg = Palette.SecondDark,
	TitleBarTransparency = 0,

	ActiveTitle = Palette.TextWhite,
	ActiveTitleBarBg = Palette.SecondDark,
	ActiveTitleBarTransparency = 0,
	ActiveBorderTransparency = 0,
})
function UI:CreateWindow(title, size)
	local self = setmetatable({}, UI)

	self.Window = ReGui:TabsWindow({
		Title = title,
		Size = size or UDim2.new(0, 400, 0, 500),
		Theme = "MidnightModern",
		NoResize = true,
		NoClose = true,
		NoMinimize = true,
	}):Center()
	
	task.defer(function()
		self:CreateDefaultSettings()
	end)
	
	return self
end

function UI:AddTab(Title, Icon)
	local ValidIcon = Icon
	if type(Icon) == "number" then
		ValidIcon = "rbxassetid://" .. tostring(Icon)
	end
	local Tab = self.Window:CreateTab({
		Name = Title,
		Icon = Icon or "",
	})
	return Tab	
end

function UI:CreateRegion(tab, name)
	-- Sebaiknya buat List dulu di dalam Tab agar Region tertata rapi
	-- Tapi langsung ke Tab juga bisa tergantung versi ReGui
	local Container = tab:List({
		UiPadding = 5,
		Spacing = 5,
		HorizontalFlex = Enum.UIFlexAlignment.Fill
	})

	local Region = Container:Region({
		Border = true,
		BorderColor = self.Window:GetThemeKey("Border"),
		BorderThickness = 1,
		CornerRadius = UDim.new(0, 5),
		AutomaticSize = Enum.AutomaticSize.Y -- Penting agar region menyesuaikan isi
	})

	Region:Label({
		Text = name
	})
	Region:Separator() -- Garis pemisah biar rapi

	return Region
end

function UI:CreateDefaultSettings()
	-- 1. Buat Tab Settings (Gunakan Icon Gear Default)
	local SettingsTab = self:AddTab("Settings", 116318920728636)

	-- 2. Buat Region UI Config
	local MainRegion = self:CreateRegion(SettingsTab, "Interface")

	-- 3. Tambahkan Tombol Toggle Keybind
	MainRegion:Keybind({
		Label = "Menu Toggle",
		Value = Enum.KeyCode.RightShift,
		Callback = function(self, key)
			self.Window:SetVisible(not self.Window.Visible)
		end
	})

	-- 4. Tambahkan Tombol Unload
	MainRegion:Button({
		Text = "Unload Script",
		Callback = function()
			self.Window:Close()
		end
	})

	-- Tambahan info credit (opsional)
	local InfoRegion = self:CreateRegion(SettingsTab, "Information")
	InfoRegion:Label({Text = "User: " .. game.Players.LocalPlayer.Name})
	InfoRegion:Label({Text = "Game ID: " .. game.PlaceId})
end

return UI