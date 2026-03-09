local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

local Window = Rayfield:CreateWindow({
   Name = "Netcheat",
   LoadingTitle = "Netcheat",
   LoadingSubtitle = "Created by goritt & jordan",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "Netcheat",
      FileName = "NetcheatConfig"
   }
})

local MainTab = Window:CreateTab("Main", 4483362458)
local InfoTab = Window:CreateTab("Info", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)

local WalkEnabled = false
local JumpEnabled = false
local WalkSpeedValue = 16
local JumpPowerValue = 50
local AimEnabled = false

local function IsVisible(part)
   local origin = Camera.CFrame.Position
   local direction = part.Position - origin

   local params = RaycastParams.new()
   params.FilterType = Enum.RaycastFilterType.Blacklist
   params.FilterDescendantsInstances = {LocalPlayer.Character}
   params.IgnoreWater = true

   local result = workspace:Raycast(origin, direction, params)

   if result then
      return result.Instance:IsDescendantOf(part.Parent)
   end

   return false
end

local function GetNearestHead()
   local closest = nil
   local distance = math.huge

   for _,player in ipairs(Players:GetPlayers()) do
      if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
         local head = player.Character.Head
         local pos, visible = Camera:WorldToViewportPoint(head.Position)

         if visible and IsVisible(head) then
            local diff = (Vector2.new(pos.X,pos.Y) - Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)).Magnitude

            if diff < distance then
               distance = diff
               closest = head
            end
         end
      end
   end

   return closest
end

RunService.RenderStepped:Connect(function()
   if AimEnabled then
      local head = GetNearestHead()

      if head then
         Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
      end
   end
end)

AimTab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Callback = function(Value)
      AimEnabled = Value
   end
})

MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16,200},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
      WalkSpeedValue = Value

      if WalkEnabled then
         local char = LocalPlayer.Character
         if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
         end
      end
   end
})

MainTab:CreateToggle({
   Name = "Enable WalkSpeed",
   CurrentValue = false,
   Callback = function(Value)
      WalkEnabled = Value
      local char = LocalPlayer.Character

      if char and char:FindFirstChildOfClass("Humanoid") then
         if WalkEnabled then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = WalkSpeedValue
         else
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
         end
      end
   end
})

MainTab:CreateSlider({
   Name = "JumpPower",
   Range = {50,200},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(Value)
      JumpPowerValue = Value

      if JumpEnabled then
         local char = LocalPlayer.Character
         if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").JumpPower = Value
         end
      end
   end
})

MainTab:CreateToggle({
   Name = "Enable JumpPower",
   CurrentValue = false,
   Callback = function(Value)
      JumpEnabled = Value
      local char = LocalPlayer.Character

      if char and char:FindFirstChildOfClass("Humanoid") then
         if JumpEnabled then
            char:FindFirstChildOfClass("Humanoid").JumpPower = JumpPowerValue
         else
            char:FindFirstChildOfClass("Humanoid").JumpPower = 50
         end
      end
   end
})

local ESPEnabled = false
local ESPHighlights = {}

local function AddESP(player)
   if player == LocalPlayer then return end
   if not player.Character then return end

   if ESPHighlights[player] then
      ESPHighlights[player]:Destroy()
   end

   local highlight = Instance.new("Highlight")
   highlight.FillTransparency = 1
   highlight.OutlineColor = Color3.fromRGB(255,0,0)
   highlight.OutlineTransparency = 0
   highlight.Adornee = player.Character
   highlight.Parent = CoreGui

   ESPHighlights[player] = highlight
end

local function RemoveESP(player)
   if ESPHighlights[player] then
      ESPHighlights[player]:Destroy()
      ESPHighlights[player] = nil
   end
end

local function UpdateESP()
   for _,player in ipairs(Players:GetPlayers()) do
      if player ~= LocalPlayer then
         AddESP(player)
      end
   end
end

local function ClearESP()
   for player,_ in pairs(ESPHighlights) do
      RemoveESP(player)
   end
end

Players.PlayerAdded:Connect(function(player)
   player.CharacterAdded:Connect(function()
      if ESPEnabled then
         task.wait(0.5)
         AddESP(player)
      end
   end)
end)

Players.PlayerRemoving:Connect(function(player)
   RemoveESP(player)
end)

for _,player in ipairs(Players:GetPlayers()) do
   if player ~= LocalPlayer then
      player.CharacterAdded:Connect(function()
         if ESPEnabled then
            task.wait(0.5)
            AddESP(player)
         end
      end)
   end
end

MainTab:CreateToggle({
   Name = "Box ESP",
   CurrentValue = false,
   Callback = function(Value)
      ESPEnabled = Value
      if ESPEnabled then
         UpdateESP()
      else
         ClearESP()
      end
   end
})

InfoTab:CreateLabel("Created by goritt & jordan (the one who never helps)")

Rayfield:Notify({
   Title = "Netcheat",
   Content = ".",
   Duration = 5
})
