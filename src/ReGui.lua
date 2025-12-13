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
    Theme = "Blue",
    Size = UDim2.new(0, 600, 0, 400),
}):Center()

-- 3. LAYOUTING (SIDEBAR SYSTEM)
local Group = Window:List({
    UiPadding = 2,
    HorizontalFlex = Enum.UIFlexAlignment.Fill,
    FillDirection = Enum.FillDirection.Horizontal -- Penting: Biar sidebar di kiri, konten di kanan
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
    Size = UDim2.new(0, 50, 1, 0), -- Lebar sidebar sedikit diperbesar
    CornerRadius = UDim.new(0, 5)
})

local TabSelector = Group:TabSelector({
    NoTabsBar = true,
    Size = UDim2.fromScale(1, 1), -- Mengisi sisa ruang
    FlexMode = Enum.UIFlexMode.Fill -- Penting agar konten mengisi ruang kosong
})

-- 4. HELPER FUNCTIONS (API KITA)

-- Fungsi untuk membuat Tab dengan Icon
local function CreateTab(Name, Icon)
    local Tab = TabSelector:CreateTab({
        Name = Name
    })

    -- Container utama di dalam tab
    local List = Tab:List({
        HorizontalFlex = Enum.UIFlexAlignment.Fill,
        UiPadding = 8,
        Spacing = 10
    })

    -- Tombol Icon di Sidebar
    local Button = TabsBar:Image({
        Image = Icon or "rbxassetid://7734068321", -- Default Icon (Kotak)
        Ratio = 1,
        RatioAxis = Enum.DominantAxis.Width,
        Size = UDim2.fromScale(1, 0), -- Tinggi otomatis ikut ratio
        Callback = function(self)
            TabSelector:SetActiveTab(Tab)
        end,
    })

    -- Tooltip saat hover icon
    ReGui:SetItemTooltip(Button, function(Canvas)
        Canvas:Label({ Text = Name })
    end)

    return List -- Kita return 'List' agar elemen UI dimasukkan ke sini
end

-- Fungsi untuk membuat Region (Kotak Group)
local function CreateRegion(Parent, Title)
    local Region = Parent:Region({
        Border = true,
        BorderColor = Window:GetThemeKey("Border"),
        BorderThickness = 1,
        CornerRadius = UDim.new(0, 5),
        UiPadding = 10
    })
    
    -- Header Region
    if Title then
        Region:Label({ Text = Title })
        Region:Separator()
    end

    return Region
end

-- 5. TAB SETTINGS (DEFAULT)
local SettingsContent = CreateTab("Settings", 7734053495) -- Icon Gear
local SettingsRegion = CreateRegion(SettingsContent, "Interface")

SettingsRegion:Combo({
    Label = "Theme",
    Selected = Window.Theme,
    Items = ReGui:GetThemeNames(),
    Callback = function(self, val)
        Window:SetTheme(val)
    end
})

SettingsRegion:SliderFloat({
    Label = "Transparency",
    Minimum = 0.0, Maximum = 1.0, Value = Window.Transparency, Format = "%.2f",
    Callback = function(self, val)
        Window.Transparency = val
    end
})

SettingsRegion:Button({
    Text = "Unload Script",
    Callback = function()
        -- Hapus UI dari layar
        if game:GetService("CoreGui"):FindFirstChild("DearReGui") then
            game:GetService("CoreGui").DearReGui:Destroy()
        end
    end
})


-- 6. PACKAGING (MENYIAPKAN UNTUK EXPORT)
-- Kita buat table API khusus
local UI_API = {
    Window = Window,      -- Object window asli
    Library = ReGui,      -- Library ReGui asli
    CreateTab = CreateTab,       -- Fungsi custom tab kita
    CreateRegion = CreateRegion  -- Fungsi custom region kita
}

-- Simpan ke Global agar bisa diakses darimana saja
GlobalEnv.HubWindow = UI_API 

return UI_API