local GlobalEnv = (getgenv and getgenv()) or _G
local UI = GlobalEnv.Library

if not UI then return warn("Library UI belum dimuat!") end

-- Buat Tab & Region
local CombatTab = UI.CreateTab("Main", 12099513436)
local HitboxRegion = UI.CreateRegion(CombatTab, "Hitbox & Bring") 
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
local HitboxSize = 5 
local HitboxTransparency = 0.7

-- Settings Bring Mobs
local BringEnabled = false
local BringDistance = 5 

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
    Label = "Hitbox Transparency",
    Minimum = 0.1, Maximum = 1.0, Value = HitboxTransparency, Format = "%.1f",
    Callback = function(self, val)
        HitboxTransparency = val
    end
})

HitboxRegion:Separator()
HitboxRegion:Label({Text = "Bring Mobs Feature"})

HitboxRegion:Checkbox({
    Label = "Enable Bring Mobs",
    Value = BringEnabled,
    Callback = function(self, bool)
        BringEnabled = bool
        -- Reset Massless jika dimatikan (Optional, biasanya dibiarkan saja tidak apa-apa)
    end
})

HitboxRegion:SliderInt({
    Label = "Bring Distance",
    Minimum = 2, Maximum = 15, Value = BringDistance,
    Callback = function(self, val)
        BringDistance = val
    end
})

EspRegion:Checkbox({
    Label = "Highlight ESP",
    Value = HighlightEnabled,
    Callback = function(self, bool)
        HighlightEnabled = bool
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

local function GetHitboxPart(model)
    return model:FindFirstChild("Head") or model:FindFirstChild("Torso")
end

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
    if not NPCContainer then 
        local engine = Workspace:FindFirstChild("NPC Engine")
        NPCContainer = engine and engine:FindFirstChild("NPCContainer")
        return 
    end

    local Character = LocalPlayer.Character
    local MyRoot = Character and Character:FindFirstChild("HumanoidRootPart")

    for _, npc in ipairs(NPCContainer:GetChildren()) do
        if IsValidTarget(npc) then
            local hbPart = GetHitboxPart(npc)

            if hbPart then
                
                -- === LOGIC BRING MOBS + MASSLESS ===
                if BringEnabled and MyRoot then
                    -- 1. Teleport ke depan
                    hbPart.CFrame = MyRoot.CFrame * CFrame.new(0, 0, -BringDistance)
                    
                    -- 2. Reset Velocity (Anti-Fling)
                    hbPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    hbPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
                    
                    -- 3. [BARU] MASSLESS & COLLISION
                    -- Loop semua bagian tubuh musuh
                    for _, part in pairs(npc:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Massless = true         -- Biar ringan (0 massa)
                            part.CanCollide = false      -- Biar bisa nembus tembok/temennya
                            part.Anchored = false        -- Pastikan tidak beku
                        end
                    end
                end

                -- === LOGIC HITBOX EXPANDER ===
                if HitboxEnabled then
                    hbPart.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    hbPart.Transparency = HitboxTransparency
                    hbPart.CanCollide = false 
                else
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