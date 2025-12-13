local GlobalEnv = (getgenv and getgenv()) or _G
local UI = GlobalEnv.Library

local CombatTab = UI.CreateTab("Main", 12099513436)
local AimbotRegion = UI.CreateRegion(CombatTab, "Aimbot Settings")
local EspTab = UI.CreateTab("ESP", 12099513436)
local EspRegion = UI.CreateRegion(EspTab, "ESP Settings")

--#region Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

--game:GetService("Workspace")["NPC Engine"].NPCContainer

local Camera = Workspace.CurrentCamera
local NPCFolder = Workspace:FindFirstChild("NPC Engine")
local NPCContainer = NPCFolder and NPCFolder:FindFirstChild("NPCContainer")
local LocalPlayer = Players.LocalPlayer
--#endregion

--#region Settings Variables
local AimbotEnabled = false
local Aiming = false
local AimMethod = "Mouse"
local FOV_Radius = 150
local Smoothness = 1.5

local HighlightEnabled = false
local HighlightFillColor = Color3.fromRGB(255, 0, 0)

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOV_Radius
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Visible = false
--#endregion

AimbotRegion:Checkbox({
    Label = "Enable Aimbot",
    Value = AimbotEnabled,
    Callback = function(self, bool)
        AimbotEnabled = bool;
        FOVCircle.Visible = bool 
    end
})

AimbotRegion:Combo({
    Label = "Aim Method",
    Selected = AimMethod,
    Items = { "Mouse", "CFrame" },
    Callback = function(self, val) AimMethod = val end
})

AimbotRegion:SliderFloat({
    Label = "Smoothness (Mouse Only)",
    Minimum = 1.0, Maximum = 10.0, Value = Smoothness, Format = "%.1f",
    Callback = function(self, val)
        Smoothness = val
    end
})

AimbotRegion:SliderInt({
    Label = "FOV Radius",
    Minimum = 50, Maximum = 500, Value = FOV_Radius,
    Callback = function(self, val)
        FOV_Radius = val
        FOVCircle.Radius = FOV_Radius
    end
})

EspRegion:Checkbox({
    Label = "Highlight ESP",
    Value = HighlightEnabled,
    Callback = function(self, bool)
        HighlightEnabled = bool
        if not bool and NPCContainer then
            for _, npc in pairs(NPCContainer:GetChildren()) do
                if npc:FindFirstChildWhichIsA("Highlight") then
                    npc:FindFirstChildWhichIsA("Highlight"):Destroy()
                end
            end
        end
    end
})
local function GetTargetPart(model)
    return model:FindFirstChild("Head")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("HumanoidRootPart")
end

-- Fungsi untuk mengecek apakah NPC masih hidup/valid
local function IsValidTarget(model)
    if not model:IsA("Model") then return false end
    
    local humanoid = model:FindFirstChild("Humanoid")
    local rootPart = model:FindFirstChild("HumanoidRootPart")
    
    -- Pastikan punya Humanoid, RootPart, dan Darah > 0
    if humanoid and rootPart and humanoid.Health > 0 then
        return true
    end
    return false
end

-- =================================================================
-- MAIN LOOP (RENDER STEPPED)
-- =================================================================

RunService.RenderStepped:Connect(function()
    -- 1. Pastikan Folder NPC Ada
    if not NPCContainer then 
        local engine = Workspace:FindFirstChild("NPC Engine")
        NPCContainer = engine and engine:FindFirstChild("NPCContainer")
        return 
    end

    -- 2. Update Posisi Lingkaran FOV
    FOVCircle.Position = VectorInputService:GetMouseLocation() -- Ikuti posisi mouse
    FOVCircle.Radius = FOV_Radius
    FOVCircle.Visible = AimbotEnabled

    -- Variabel untuk Aimbot
    local bestTarget = nil
    local shortestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    -- 3. LOOPING SEMUA NPC
    for _, npc in ipairs(NPCContainer:GetChildren()) do
        if IsValidTarget(npc) then
            local targetPart = GetTargetPart(npc)

            if targetPart then
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
                    -- Update Warna jika perlu (biar tetap merah kalau respawn)
                    hl.FillColor = HighlightFillColor 
                    hl.Enabled = true
                else
                    -- Matikan highlight jika fitur dimatikan tapi object masih ada
                    local hl = npc:FindFirstChild("ZenythHighlight")
                    if hl then hl:Destroy() end
                end

                -- === LOGIC PENCARI AIMBOT ===
                if AimbotEnabled then
                    -- Konversi posisi 3D dunia ke 2D Layar
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    
                    if onScreen then
                        -- Hitung jarak antara Mouse dan Kepala NPC
                        local dist = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                        
                        -- Cek apakah masuk radius FOV dan apakah dia yang terdekat sejauh ini
                        if dist <= FOV_Radius and dist < shortestDist then
                            shortestDist = dist
                            bestTarget = targetPart
                        end
                    end
                end
            end
        end
    end

    -- 4. EKSEKUSI AIMBOT (JIKA ADA TARGET)
    if AimbotEnabled and Aiming and bestTarget then
        
        -- MODE 1: CFrame (Camera Lock - Hard/Kasar)
        if AimMethod == "CFrame" then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, bestTarget.Position)
        
        -- MODE 2: Mouse (Movement - Smooth/Legit)
        elseif AimMethod == "Mouse" then
            local pos = Camera:WorldToViewportPoint(bestTarget.Position)
            local dx = (pos.X - mousePos.X) / Smoothness
            local dy = (pos.Y - mousePos.Y) / Smoothness
            
            -- Panggil fungsi executor mousemoverel
            if mousemoverel then
                mousemoverel(dx, dy)
            end
        end
    end
end)

-- =================================================================
-- INPUT HANDLING (KLIK KANAN)
-- =================================================================

UserInputService.InputBegan:Connect(function(input)
    -- Deteksi Klik Kanan ditekan
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    -- Deteksi Klik Kanan dilepas
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aiming = false
    end
end)