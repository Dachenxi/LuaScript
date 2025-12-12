local ReGui = loadstring(game:HttpGet('https://raw.githubusercontent.com/depthso/Dear-ReGui/refs/heads/main/ReGui.lua'))()
ReGui:DefineTheme("OneDarkPro", {
    -- Pengaturan Teks
    TitleAlign = Enum.TextXAlignment.Center,
    Text = Color3.fromRGB(171, 178, 191),       -- Putih Abu-abu (Foreground)
    TextDisabled = Color3.fromRGB(92, 99, 112), -- Abu-abu Gelap (Comment color)

    -- Warna Background Utama (Window)
    WindowBg = Color3.fromRGB(40, 44, 52),      -- #282c34 (Main Dark)
    TitleBarBg = Color3.fromRGB(33, 37, 43),    -- Sedikit lebih gelap dari Window
    TitleBarBgActive = Color3.fromRGB(40, 44, 52), 

    -- Warna Input/Frame
    FrameBg = Color3.fromRGB(33, 37, 43),       -- Background input gelap
    FrameBgTransparency = 0.2,                  -- Sedikit transparan agar menyatu
    FrameBgActive = Color3.fromRGB(60, 66, 78), -- Lebih terang saat aktif
    FrameBgTransparencyActive = 0.2,

    -- Warna Aksen (Biru One Dark Pro)
    CheckMark = Color3.fromRGB(97, 175, 239),   -- #61afef (Blue Accent)
    SliderGrab = Color3.fromRGB(97, 175, 239),  
    ButtonsBg = Color3.fromRGB(97, 175, 239),   
    RadioButtonHoveredBg = Color3.fromRGB(97, 175, 239),

    -- Header & Collapsible
    CollapsingHeaderBg = Color3.fromRGB(97, 175, 239),
    CollapsingHeaderText = Color3.fromRGB(255, 255, 255),

    -- Border & Resize
    Border = Color3.fromRGB(24, 26, 31),        -- Hampir hitam untuk outline tajam
    ResizeGrab = Color3.fromRGB(97, 175, 239),
    RegionBgTransparency = 1,
})

--// Tabs
local Window = ReGui:Window({
	Title = "One Dark Pro Theme Example",
	Theme = "OneDarkPro",
	NoClose = true,
	Size = UDim2.new(0, 600, 0, 400),
}):Center()

local Group = Window:List({
	UiPadding = 2,
	HorizontalFlex = Enum.UIFlexAlignment.Fill,
})

local TabsBar = Group:List({
	Border = true,
	UiPadding = 5,
	BorderColor = Window:GetThemeKey("Border"),
	BorderThickness = 1,
	HorizontalFlex = Enum.UIFlexAlignment.Fill,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	AutomaticSize = Enum.AutomaticSize.None,
	FlexMode = Enum.UIFlexMode.None,
	Size = UDim2.new(0, 40, 1, 0),
	CornerRadius = UDim.new(0, 5)
})
local TabSelector = Group:TabSelector({
	NoTabsBar = true,
	Size = UDim2.fromScale(0.5, 1)
})

local function CreateTab(Name: string, Icon)
	local Tab = TabSelector:CreateTab({
		Name = Name
	})

	local List = Tab:List({
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
		UiPadding = 1,
		Spacing = 10
	})

	local Button = TabsBar:Image({
		Image = Icon,
		Ratio = 1,
		RatioAxis = Enum.DominantAxis.Width,
		Size = UDim2.fromScale(1, 1),
		Callback = function(self)
			TabSelector:SetActiveTab(Tab)
		end,
	})

	ReGui:SetItemTooltip(Button, function(Canvas)
		Canvas:Label({
			Text = Name
		})
	end)

	return List
end

local function CreateRegion(Parent, Title)
	local Region = Parent:Region({
		Border = true,
		BorderColor = Window:GetThemeKey("Border"),
		BorderThickness = 1,
		CornerRadius = UDim.new(0, 5)
	})

	Region:Label({
		Text = Title
	})

	return Region
end

local General = CreateTab("General", 139650104834071)
local Settings = CreateTab("Settings", ReGui.Icons.Settings)

--// General Tab
local AimbotSection = CreateRegion(General, "Aimbot")
local ESPSection = CreateRegion(General, "ESP")

AimbotSection:Checkbox({
	Label = "Enabled",
	Value = false,
	Callback = function(self, Value)
		--Aimbot_Settings.Enabled = Value
	end
})

AimbotSection:Combo({
	Label = "Update Mode",
	Items = {"RenderStepped", "Stepped", "Heartbeat"},
	Selected = 1,
	Callback = function(self, Value)
		--Aimbot_DeveloperSettings.UpdateMode = Value
	end
})

AimbotSection:Combo({
	Label = "Team Check Option",
	Items = {"TeamColor", "Team"},
	Selected = 1,
	Callback = function(self, Value)
		--Aimbot_DeveloperSettings.TeamCheckOption = Value
	end
})

AimbotSection:SliderInt({
	Label = "Rainbow Speed",
	Default = 1.5 * 10,
	Minimum = 5,
	Maximum = 30,
	Callback = function(self, Value)
		--Aimbot_DeveloperSettings.RainbowSpeed = Value / 10
	end
})

AimbotSection:Button({
	Text = "Refresh",
	Callback = function(self)
		--Aimbot.Restart()
	end
})

AimbotSection:Separator({
	Text = "Properties"
})

AimbotSection:Combo({
	Label = "Lock Mode",
	Items = {"CFrame", "mousemoverel"},
	Selected = 1,
	Callback = function(self, Value)

	end
})

AimbotSection:Combo({
	Label = "Lock Part",
	Items = {"Head", "Torso", "Random"},
	Selected = 1,
	Callback = function(self, Value)

	end
})

AimbotSection:Keybind({
	Label = "Trigger Key",
	Value = Enum.KeyCode.MouseRightButton,
	IgnoreGameProcessed = true,
	Callback = function(self, KeyCode)

	end,
})

AimbotSection:SliderInt({
	Label = "Field Of View",
	Value = 100,
	Minimum = 0,
	Maximum = 720,
	Callback = function(self, Value)

	end
})

AimbotSection:SliderInt({
	Label = "Transparency",
	Value = 1,
	Minimum = 1,
	Maximum = 10,
	Callback = function(self, Value)

	end
})

AimbotSection:SliderInt({
	Label = "Thickness",
	Minimum = 1,
	Maximum = 5,
	Callback = function(self, Value)

	end
})

ESPSection:Combo({
	Label = "Update Mode",
	Items = {"RenderStepped", "Stepped", "Heartbeat"},
	Selected = 1,
	Callback = function(self, Value)
		--ESP_DeveloperSettings.UpdateMode = Value
	end
})

ESPSection:Combo({
	Label = "Team Check Option",
	Items = {"TeamColor", "Team"},
	Selected = 1,
	Callback = function(self, Value)
		--ESP_DeveloperSettings.TeamCheckOption = Value
	end
})

ESPSection:SliderInt({
	Label = "Rainbow Speed",
	Value = 1 * 10,
	Minimum = 5,
	Maximum = 30,
	Callback = function(self, Value)
		--ESP_DeveloperSettings.RainbowSpeed = Value / 10
	end
})

ESPSection:SliderInt({
	Label = "Width Boundary",
	Value = 1.5 * 10,
	Minimum = 5,
	Maximum = 30,
	Callback = function(self, Value)
		--ESP_DeveloperSettings.WidthBoundary = Value / 10
	end
})

ESPSection:Button({
	Text = "Refresh",
	Callback = function(self)
		--ESP:Restart()
	end
})

--// Settings
local OptionsSection = CreateRegion(Settings, "Options")
local ConfigSection = CreateRegion(Settings, "Configurations")

OptionsSection:Keybind({
	Label = "Show / Hide GUI",
	Value = Enum.KeyCode.RightShift,
	Callback = function(_, NewKeybind)
		local IsVisible = Window.Visible
		Window:SetVisible(not IsVisible)
	end
})

OptionsSection:Button({
	Text = "Unload Script",
	Callback = function()
		Window:Close()
	end
})

--// Configurations
ConfigSection:Combo({
	Label = "Config",
	Items = {
		"Legit",
		"Rage",
		"Blatant"
	},
	Selected = 1,
})