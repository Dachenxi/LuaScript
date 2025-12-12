local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
lib/ImGui.lua
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CharactersFolder = Workspace:FindFirstChild("Characters")

local AimbotEnabled = false
local Aiming = false
local TeamCheck = true    -- PVP Essential
local WallCheck = true    -- PVP Essential
local FOV_Radius = 150
local Smoothness = 3

local HitboxEnabled = false
local HitboxSize = 5 
local HitboxTransparency = 0.7

-- Visuals (ESP)
local ESP_Enabled = false
local ESP_ShowTeam = false -- Tampilkan teman di ESP?
local ColorEnemy = Color3.fromRGB(255, 50, 50)  -- Merah
local ColorTeam = Color3.fromRGB(50, 255, 50)   -- Hijau

-- === VISUAL FOV ===
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOV_Radius
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Visible = false

local CombatTab = CreateTab("Combat", "rbxassetid://12345678")
local VisualTab = CreateTab("Visuals", "rbxassetid://87654321")

-- ===========================
-- TAB: COMBAT
-- ===========================
CombatTab:Label({ Text = "Aimbot" })

CombatTab:Checkbox({
    Label = "Enable Aimbot",
    Value = AimbotEnabled,
    Callback = function(self, bool) AimbotEnabled = bool; FOVCircle.Visible = bool end
})

CombatTab:Checkbox({
    Label = "Team Check (Ignore Friends)",
    Value = TeamCheck,
    Callback = function(self, bool) TeamCheck = bool end
})

CombatTab:Checkbox({
    Label = "Wall Check (Visible Only)",
    Value = WallCheck,
    Callback = function(self, bool) WallCheck = bool end
})

CombatTab:SliderInt({
    Label = "FOV Radius",
    Minimum = 50, Maximum = 800, Value = FOV_Radius,
    Callback = function(self, val) FOV_Radius = val end
})

CombatTab:SliderFloat({
    Label = "Smoothness",
    Minimum = 1.0, Maximum = 10.0, Value = Smoothness, Format = "%.1f",
    Callback = function(self, val) Smoothness = val end
})

CombatTab:Separator()
CombatTab:Label({ Text = "Hitbox Expander" })

CombatTab:Checkbox({
    Label = "Enable Hitbox (Enemy Only)",
    Value = HitboxEnabled,
    Callback = function(self, bool) HitboxEnabled = bool end
})

CombatTab:SliderInt({
    Label = "Hitbox Size",
    Minimum = 2, Maximum = 15, Value = HitboxSize,
    Callback = function(self, val) HitboxSize = val end
})

-- ===========================
-- TAB: VISUALS
-- ===========================
VisualTab:Label({ Text = "ESP Settings" })

VisualTab:Checkbox({
    Label = "Enable Highlight ESP",
    Value = ESP_Enabled,
    Callback = function(self, bool) 
        ESP_Enabled = bool 
        if not bool then -- Cleanup
            for _, v in pairs(Workspace:GetDescendants()) do
                if v.Name == "PVPHighlight" then v:Destroy() end
            end
        end
    end
})

VisualTab:Checkbox({
    Label = "Show Teammates",
    Value = ESP_ShowTeam,
    Callback = function(self, bool) ESP_ShowTeam = bool end
})

VisualTab:Separator()

VisualTab:DragColor3({ Label = "Enemy Color", Value = ColorEnemy, Callback = function(self, val) ColorEnemy = val end })
VisualTab:DragColor3({ Label = "Team Color", Value = ColorTeam, Callback = function(self, val) ColorTeam = val end })

-- ===========================
-- LOGIC: HELPER FUNCTIONS
-- ===========================

-- Cek apakah Model adalah Teman
local function IsTeammate(model)
    local player = Players:GetPlayerFromCharacter(model)
    
    -- Cara 1: Cek via Player Service (Paling Akurat)
    if player then
        return player.Team == LocalPlayer.Team
    end
    
    -- Cara 2: Cek via Properti Model (Backup jika custom character)
    if model:FindFirstChild("TeamColor") and LocalPlayer.TeamColor then
        return model.TeamColor == LocalPlayer.TeamColor
    end
    
    return false -- Default dianggap musuh
end

-- Cek Tembok (Raycast)
local function CheckVisibility(part, model)
    if not WallCheck then return true end
    
    local origin = Camera.CFrame.Position
    local destination = part.Position
    local direction = (destination - origin)

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera, CharactersFolder} -- Ignore semua karakter agar tidak saling block

    local result = Workspace:Raycast(origin, direction, params)
    
    -- Jika raycast kena sesuatu (tembok), return false
    -- Jika result nil, berarti line of sight bersih
    if result then 
        return false 
    end
    return true
end

-- Cek apakah Model Valid untuk di-Aim/ESP
local function IsValidTarget(model)
    if not model:IsA("Model") then return false end
    if model.Name == LocalPlayer.Name then return false end -- Jangan target diri sendiri
    
    -- Cek Darah
    local hum = model:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    return true
end

local function GetTargetPart(model)
    return model:FindFirstChild("Head") or model:FindFirstChild("Torso") or model:FindFirstChild("HumanoidRootPart")
end

-- ===========================
-- MAIN LOOP
-- ===========================

RunService.RenderStepped:Connect(function()
    if not CharactersFolder then CharactersFolder = Workspace:FindFirstChild("Characters") end
    
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = FOV_Radius
    FOVCircle.Visible = AimbotEnabled

    if not CharactersFolder then return end

    local bestTarget = nil
    local shortestDist = math.huge
    local mouseLoc = UserInputService:GetMouseLocation()

    for _, char in ipairs(CharactersFolder:GetChildren()) do
        if IsValidTarget(char) then
            
            local isTeam = IsTeammate(char)
            local targetPart = GetTargetPart(char)

            if targetPart then
                
                -- === 1. HITBOX EXPANDER ===
                -- Hanya perbesar hitbox jika dia MUSUH
                if HitboxEnabled and not isTeam then
                    if targetPart.Name == "Head" then
                        targetPart.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                        targetPart.Transparency = HitboxTransparency
                        targetPart.CanCollide = false
                    end
                elseif targetPart.Name == "Head" then
                    -- Reset ke normal (2,1,1) jika teman atau fitur mati
                    targetPart.Size = Vector3.new(2, 1, 1) 
                    targetPart.Transparency = 0
                end

                -- === 2. ESP HIGHLIGHT ===
                if ESP_Enabled then
                    -- Logic: Tampilkan jika Musuh, ATAU jika Teman tapi "Show Teammates" nyala
                    if not isTeam or (isTeam and ESP_ShowTeam) then
                        local hl = char:FindFirstChild("PVPHighlight")
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "PVPHighlight"
                            hl.Adornee = char
                            hl.Parent = char
                            hl.FillTransparency = 0.5
                            hl.OutlineTransparency = 0
                        end
                        -- Update Warna (Merah vs Hijau)
                        hl.FillColor = isTeam and ColorTeam or ColorEnemy
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.Enabled = true
                    else
                        -- Sembunyikan jika teman dan setting hide nyala
                        local hl = char:FindFirstChild("PVPHighlight")
                        if hl then hl.Enabled = false end
                    end
                else
                     -- Cleanup jika ESP master mati
                    local hl = char:FindFirstChild("PVPHighlight")
                    if hl then hl:Destroy() end
                end

                -- === 3. AIMBOT CALCULATION ===
                -- Syarat Aimbot: Nyala, Bukan Teman, dan Terlihat (Wallcheck)
                if AimbotEnabled and not isTeam then
                    -- Cek Visibility
                    if CheckVisibility(targetPart, char) then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local dist = (Vector2.new(mouseLoc.X, mouseLoc.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                            if dist <= FOV_Radius and dist < shortestDist then
                                shortestDist = dist
                                bestTarget = targetPart
                            end
                        end
                    end
                end

            end
        end
    end

    -- EXECUTE AIM
    if AimbotEnabled and Aiming and bestTarget then
        local pos = Camera:WorldToViewportPoint(bestTarget.Position)
        local dx = (pos.X - mouseLoc.X) / Smoothness
        local dy = (pos.Y - mouseLoc.Y) / Smoothness
        if mousemoverel then
            mousemoverel(dx, dy)
        end
    end
end)

-- INPUT
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then Aiming = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then Aiming = false end
end)