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
