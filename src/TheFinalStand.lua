-- === LOAD LIBRARY REGUI ===
local ReGui = loadstring(game:HttpGet('https://raw.githubusercontent.com/depthso/Dear-ReGui/refs/heads/main/ReGui.lua'))()

-- === SERVICES ===
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Camera = Workspace.CurrentCamera
local ZombiesFolder = Workspace:FindFirstChild("Zombies")

-- === CONFIG VARIABLES ===
local AimbotEnabled = false
local Aiming = false
local AimMethod = "Mouse" -- Default: Mouse
local FOV_Radius = 150
local Smoothness = 3 -- Hanya berpengaruh pada mode Mouse

-- Hitbox
local HitboxEnabled = false
local HitboxSize = 5 
local HitboxTransparency = 0.7

-- Visuals
local HighlightEnabled = false
local HighlightFillColor = Color3.fromRGB(255, 0, 0)

-- === VISUAL FOV ===
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOV_Radius
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Visible = false

-- === UI SETUP ===
local Window = ReGui:TabsWindow({
    Title = "Zombie Destroyer (CFrame & Mouse)",
    Size = UDim2.fromOffset(420, 520)
})

local MainTab = Window:CreateTab({ Name = "Main" })

-- Label
MainTab:Label({ Text = "Aimbot Configuration" })

-- Toggle Aimbot
MainTab:Checkbox({
    Label = "Enable Aimbot",
    Value = AimbotEnabled,
    Callback = function(self, bool) AimbotEnabled = bool; FOVCircle.Visible = bool end
})

-- [BARU] COMBO BOX PILIH METODE
MainTab:Combo({
    Label = "Aim Method",
    Selected = AimMethod,
    Items = {
        "Mouse",
        "CFrame"
    },
    Callback = function(self, val)
        AimMethod = val
    end
})

MainTab:SliderInt({
    Label = "FOV Radius",
    Minimum = 50, Maximum = 800, Value = FOV_Radius,
    Callback = function(self, val) FOV_Radius = val end
})

MainTab:SliderFloat({
    Label = "Smoothness (Mouse Only)",
    Minimum = 1.0, Maximum = 10.0, Value = Smoothness, Format = "%.1f",
    Callback = function(self, val) Smoothness = val end
})

MainTab:Separator()

-- Toggle ESP
MainTab:Checkbox({
    Label = "Highlight ESP",
    Value = HighlightEnabled,
    Callback = function(self, bool) 
        HighlightEnabled = bool 
        if not bool and ZombiesFolder then
            for _, v in pairs(ZombiesFolder:GetDescendants()) do
                if v.Name == "ZenythHighlight" then v:Destroy() end
            end
        end
    end
})

MainTab:DragColor3({
    Label = "ESP Color",
    Value = HighlightFillColor,
    Callback = function(self, val)
        HighlightFillColor = val
    end
})

local function GetTargetPart(model)
    local head = model:FindFirstChild("Head") 
    if head then return head end
    
    local torso = model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("HumanoidRootPart")
    if torso then return torso end
    
    -- Fallback terakhir: Ambil part apapun
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("BasePart") then return child end
    end
    return nil
end

-- === CORE LOGIC ===
RunService.RenderStepped:Connect(function()
    if not ZombiesFolder then ZombiesFolder = Workspace:FindFirstChild("Zombies") end
    
    -- Update FOV Circle
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = FOV_Radius
    FOVCircle.Visible = AimbotEnabled

    if not ZombiesFolder then return end

    local bestTarget = nil
    local shortestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    -- SCAN ZOMBIES
    for _, zombie in ipairs(ZombiesFolder:GetChildren()) do
        if zombie:IsA("Model") then
            
            local targetPart = GetTargetPart(zombie)

            if targetPart then
                -- 1. HITBOX
                if HitboxEnabled then
                    targetPart.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    targetPart.Transparency = HitboxTransparency
                    targetPart.CanCollide = false
                end

                -- 2. HIGHLIGHT ESP
                if HighlightEnabled then
                    local hl = zombie:FindFirstChild("ZenythHighlight")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "ZenythHighlight"
                        hl.Adornee = zombie
                        hl.Parent = zombie
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                    end
                    hl.FillColor = HighlightFillColor
                end

                -- 3. CARI TARGET TERDEKAT
                if AimbotEnabled then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                        if dist <= FOV_Radius and dist < shortestDist then
                            shortestDist = dist
                            bestTarget = targetPart
                        end
                    end
                end
            end
        end
    end

    -- === EKSEKUSI AIMBOT BERDASARKAN METODE ===
    if AimbotEnabled and Aiming and bestTarget then
        
        -- METODE 1: CFrame (Camera Lock - Hard/Kasar)
        if AimMethod == "CFrame" then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, bestTarget.Position)
        
        -- METODE 2: Mouse (Movement - Smooth/Halus)
        elseif AimMethod == "Mouse" then
            local pos = Camera:WorldToViewportPoint(bestTarget.Position)
            local dx = (pos.X - mousePos.X) / Smoothness
            local dy = (pos.Y - mousePos.Y) / Smoothness
            
            if mousemoverel then
                mousemoverel(dx, dy)
            end
        end
        
    end
end)

-- INPUT HANDLING
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then Aiming = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then Aiming = false end
end)