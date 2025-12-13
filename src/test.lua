local GlobalEnv = (getgenv and getgenv()) or _G
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Camera = Workspace.CurrentCamera
local ZombiesFolder = Workspace:FindFirstChild("Zombies")
local LocalPlayer = Players.LocalPlayer

local AimbotEnabled = false
local Aiming = false
local AimMethod = "Mouse"
local FOV_Radius = 150
local Smoothness = 3

local TriggerbotEnabled = false
local IsShooting = false -- Status apakah sedang nembak

local HighlightEnabled = false
local HighlightFillColor = Color3.fromRGB(255, 0, 0)

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOV_Radius
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Visible = false

local UI = GlobalEnv.Library

local MainTab = UI.CreateTab({"Main", 12099513436})
local AimbotRegion = MainTab.CreateRegion({MainTab, "Aimbot Settings"})
local TriggerBotRegion = MainTab.CreateRegion({MainTab, "Triggerbot Settings"})
local EspRegion = MainTab.CreateRegion({MainTab, "ESP Settings"})

AimbotRegion:Checkbox({
    Label = "Enable Aimbot",
    Value = AimbotEnabled,
    Callback = function(self, bool) AimbotEnabled = bool; FOVCircle.Visible = bool end
})

TriggerBotRegion:Checkbox({
    Label = "Triggerbot (Auto Shoot)",
    Value = TriggerbotEnabled,
    Callback = function(self, bool)
        TriggerbotEnabled = bool
    end
})

AimbotRegion:Combo({
    Label = "Aim Method",
    Selected = AimMethod,
    Items = { "Mouse", "CFrame" },
    Callback = function(self, val) AimMethod = val end
})

AimbotRegion:SliderInt({
    Label = "FOV Radius",
    Minimum = 50, Maximum = 800, Value = FOV_Radius,
    Callback = function(self, val) FOV_Radius = val end
})

AimbotRegion:SliderFloat({
    Label = "Smoothness (Mouse Only)",
    Minimum = 1.0, Maximum = 10.0, Value = Smoothness, Format = "%.1f",
    Callback = function(self, val) Smoothness = val end
})

EspRegion:Checkbox({
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

EspRegion:DragColor3({
    Label = "ESP Color",
    Value = HighlightFillColor,
    Callback = function(self, val) HighlightFillColor = val end
})

GlobalEnv.Library:LoadSettingsTab(Window)

local function GetTargetPart(model)
    local head = model:FindFirstChild("Head")
    if head then return head end
    local torso = model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("HumanoidRootPart")
    if torso then return torso end
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("BasePart") then return child end
    end
    return nil
end

RunService.RenderStepped:Connect(function()
    if not ZombiesFolder then ZombiesFolder = Workspace:FindFirstChild("Zombies") end

    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = FOV_Radius
    FOVCircle.Visible = AimbotEnabled

    if not ZombiesFolder then return end

    local bestTarget = nil
    local shortestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, zombie in ipairs(ZombiesFolder:GetChildren()) do
        if zombie:IsA("Model") then

            local targetPart = GetTargetPart(zombie)

            if targetPart then

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

    if TriggerbotEnabled then
        local rayOrigin = Camera.CFrame.Position
        local rayDirection = Camera.CFrame.LookVector * 1000

        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {LocalPlayer.Character, Camera, Workspace:FindFirstChild("Ignore")}

        local result = Workspace:Raycast(rayOrigin, rayDirection, params)

        if result and result.Instance and result.Instance:IsDescendantOf(ZombiesFolder) then
            if not IsShooting then
                mouse1press()
                IsShooting = true
            end
        else
            if IsShooting then
                mouse1release()
                IsShooting = false
            end
        end
    end

    if AimbotEnabled and Aiming and bestTarget then
        if AimMethod == "CFrame" then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, bestTarget.Position)
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

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then Aiming = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then Aiming = false end
end)