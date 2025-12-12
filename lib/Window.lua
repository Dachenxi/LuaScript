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

local Window = ReGui:Window({
	Title = "Script Hub",
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