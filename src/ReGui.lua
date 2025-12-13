local GlobalEnv = (getgenv and getgenv()) or _G

-- Load Library Asli
local ReGui = loadstring(game:HttpGet('https://raw.githubusercontent.com/depthso/Dear-ReGui/refs/heads/main/ReGui.lua'))()

-- 1. DEFINE THEME (Blue)
ReGui:DefineTheme("Blue", {
    TitleAlign = Enum.TextXAlignment.Center,
    TextDisabled = Color3.fromRGB(100, 100, 120),
    Text = Color3.fromRGB(100, 180, 200),
    FrameBg = Color3.fromRGB(25, 20, 25),
    FrameBgTransparency = 0.4,
    FrameBgActive = Color3.fromRGB(100, 100, 120),
    FrameBgTransparencyActive = 0.4,
    CheckMark = Color3.fromRGB(100, 100, 150),
    SliderGrab = Color3.fromRGB(100, 100, 150),
    ButtonsBg = Color3.fromRGB(100, 100, 150),
    CollapsingHeaderBg = Color3.fromRGB(100, 100, 150),
    CollapsingHeaderText = Color3.fromRGB(100, 180, 200),
    RadioButtonHoveredBg = Color3.fromRGB(100, 100, 150),
    WindowBg = Color3.fromRGB(35, 30, 35),
    TitleBarBg = Color3.fromRGB(35, 30, 35),
    TitleBarBgActive = Color3.fromRGB(50, 45, 50),
    Border = Color3.fromRGB(50, 45, 50),
    ResizeGrab = Color3.fromRGB(50, 45, 50),
    RegionBgTransparency = 1,
})

-- 2. CREATE WINDOW
local Window = ReGui:Window({
	Title = "Hub Script",
    Theme = "Blue",
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

local UI_API = {
    Window = Window,     
    Library = ReGui, 
    CreateTab = CreateTab,
    CreateRegion = CreateRegion 
}

GlobalEnv.HubWindow = UI_API 

return UI_API