local GlobalEnv = (getgenv and getgenv()) or _G
local UI = GlobalEnv.Library

-- Buat Tab & Region
local CombatTab = UI.CreateTab("Main", 12099513436)
local HitboxRegion = UI.CreateRegion(CombatTab, "Hitbox Settings") -- Ganti nama region
local EspTab = UI.CreateTab("ESP", 12099513436)
local EspRegion = UI.CreateRegion(EspTab, "ESP Settings")

--#region Services
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Camera = Workspace.CurrentCamera
local NPCFolder = Workspace:FindFirstChild("NPC Engine")
local NPCContainer = NPCFolder and NPCFolder:FindFirstChild("NPCContainer")
local LocalPlayer = Players.LocalPlayer
--#endregion

--#region Settings Variables
-- Settings Hitbox
local HitboxEnabled = false
local HitboxSize = 5 -- Ukuran default hitbox
local HitboxTransparency = 0.7
local TargetPartName = "HumanoidRootPart" -- Bagian yg diperbesar (RootPart lebih stabil)

-- Settings ESP
local HighlightEnabled = false
local HighlightFillColor = Color3.fromRGB(255, 0, 0)
--#endregion

-- === UI SETUP ===

HitboxRegion:Checkbox({
    Label = "Enable Hitbox Expander",
    Value = HitboxEnabled,
    Callback = function(self, bool)
        HitboxEnabled = bool
        -- Jika dimatikan, kita perlu mereset size NPC di loop nanti
    end
})

HitboxRegion:SliderInt({
    Label = "Hitbox Size",
    Minimum = 2, Maximum = 20, Value = HitboxSize,
    Callback = function(self, val)
        HitboxSize = val
    end
})

HitboxRegion:SliderFloat({
    Label = "Transparency",
    Minimum = 0.1, Maximum = 1.0, Value = HitboxTransparency, Format = "%.1f",
    Callback = function(self, val)
        HitboxTransparency = val
    end
})

EspRegion:Checkbox({
    Label = "Highlight ESP",
    Value = HighlightEnabled,
    Callback = function(self, bool)
        HighlightEnabled = bool
        -- Cleanup saat dimatikan
        if not bool and NPCContainer then
            for _, npc in pairs(NPCContainer:GetChildren()) do
                local hl = npc:FindFirstChild("ZenythHighlight")
                if hl then hl:Destroy() end
            end
        end
    end
})

EspRegion:DragColor3({
    Label = "ESP Color",
    Value = HighlightFillColor,
    Callback = function(self, val) HighlightFillColor = val end
})

-- =================================================================
-- LOGIC FUNCTIONS
-- =================================================================

-- Fungsi untuk mendapatkan bagian yang mau diperbesar
local function GetHitboxPart(model)
    return model:FindFirstChild("Head")
end

-- Validasi Target (Harus Hidup)
local function IsValidTarget(model)
    if not model:IsA("Model") then return false end
    local humanoid = model:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health > 0 then
        return true
    end
    return false
end

-- =================================================================
-- MAIN LOOP
-- =================================================================

RunService.RenderStepped:Connect(function()
    -- Update Folder NPC jika hilang (misal ganti map/round)
    if not NPCContainer then 
        local engine = Workspace:FindFirstChild("NPC Engine")
        NPCContainer = engine and engine:FindFirstChild("NPCContainer")
        return 
    end

    for _, npc in ipairs(NPCContainer:GetChildren()) do
        if IsValidTarget(npc) then
            
            -- === LOGIC HITBOX EXPANDER ===
            local hbPart = GetHitboxPart(npc)
            if hbPart then
                if HitboxEnabled then
                    -- Perbesar Ukuran
                    hbPart.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    hbPart.Transparency = HitboxTransparency
                    hbPart.CanCollide = false -- Biar player tidak nabrak hitbox besar
                else
                    -- Reset ke ukuran normal jika fitur dimatikan (tapi sebelumnya aktif)
                    -- Ukuran normal HumanoidRootPart biasanya 2, 2, 1
                    if hbPart.Size.X == HitboxSize then 
                        hbPart.Size = Vector3.new(2, 2, 1) 
                        hbPart.Transparency = 1
                        hbPart.CanCollide = true
                    end
                end
            end

            -- === LOGIC ESP HIGHLIGHT ===
            if HighlightEnabled then
                local hl = npc:FindFirstChild("ZenythHighlight")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "ZenythHighlight"
                    hl.Adornee = npc
                    hl.Parent = npc
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                end
                hl.FillColor = HighlightFillColor 
            end
        end
    end
end)