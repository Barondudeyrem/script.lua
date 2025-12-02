-- BARON FULL EXECUTOR SCRIPT (Scrollable + New Features)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ======= GUI CREATION =======
local function createGUI()
    if LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("BaronGUI") then
        LocalPlayer.PlayerGui.BaronGUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BaronGUI"
    ScreenGui.Parent = LocalPlayer.PlayerGui

    -- Main Frame
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 280, 0, 400)
    Frame.Position = UDim2.new(-1, 0, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    -- RGB Border
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 2
    UIStroke.Parent = Frame
    RunService.RenderStepped:Connect(function()
        local t = tick() * 2
        UIStroke.Color = Color3.fromHSV(t%1,1,1)
    end)

    -- Scrollable Canvas
    local Scroller = Instance.new("ScrollingFrame")
    Scroller.Size = UDim2.new(1,0,1,0)
    Scroller.Position = UDim2.new(0,0,0,0)
    Scroller.BackgroundTransparency = 1
    Scroller.ScrollBarThickness = 5
    Scroller.CanvasSize = UDim2.new(0,0,0,1000) -- Start big, adjust later
    Scroller.Parent = Frame

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,0,0,40)
    Title.Position = UDim2.new(0,0,0,0)
    Title.BackgroundTransparency = 1
    Title.Text = "BARON"
    Title.TextColor3 = Color3.fromRGB(255,255,255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 28
    Title.Parent = Scroller

    -- Button Creator
    local function NewBtn(text, y, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,220,0,35)
        btn.Position = UDim2.new(0,30,0,y)
        btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 20
        btn.Text = text
        btn.Parent = Scroller
        -- Hover
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn,TweenInfo.new(0.2),{BackgroundColor3 = Color3.fromRGB(70,70,70)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn,TweenInfo.new(0.2),{BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local yPos = 60

    -- ======= BASIC HACKS =======
    local infiniteJump = false
    NewBtn("Toggle Infinite Jump", yPos, function() infiniteJump = not infiniteJump end)
    yPos = yPos + 50
    UIS.JumpRequest:Connect(function()
        if infiniteJump then
            local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState("Jumping") end
        end
    end)

    local speedOn = false
    local speedValue = 50
    NewBtn("Toggle Speed Hack", yPos, function()
        speedOn = not speedOn
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = speedOn and speedValue or 16 end
    end)
    yPos = yPos + 50

    -- Speed Slider
    local slider = Instance.new("TextBox")
    slider.Size = UDim2.new(0,200,0,25)
    slider.Position = UDim2.new(0,30,0,yPos)
    slider.PlaceholderText = "Speed (50)"
    slider.TextColor3 = Color3.fromRGB(255,255,255)
    slider.BackgroundColor3 = Color3.fromRGB(50,50,50)
    slider.Font = Enum.Font.SourceSans
    slider.TextSize = 18
    slider.Parent = Scroller
    slider.FocusLost:Connect(function()
        local val = tonumber(slider.Text)
        if val then
            speedValue = val
            if speedOn then
                local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if h then h.WalkSpeed = speedValue end
            end
        end
    end)
    yPos = yPos + 50

    -- Noclip
    local noclipOn = false
    NewBtn("Toggle Noclip", yPos, function() noclipOn = not noclipOn end)
    yPos = yPos + 50
    RunService.Stepped:Connect(function()
        if noclipOn and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)

    -- ======= FULLBRIGHT =======
    local fullbrightOn = false
    local oldLightingSettings = {Brightness=Lighting.Brightness, ClockTime=Lighting.ClockTime, FogEnd=Lighting.FogEnd, Ambient=Lighting.Ambient}
    NewBtn("Toggle Fullbright", yPos, function()
        fullbrightOn = not fullbrightOn
        if fullbrightOn then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.Ambient = Color3.fromRGB(255,255,255)
        else
            Lighting.Brightness = oldLightingSettings.Brightness
            Lighting.ClockTime = oldLightingSettings.ClockTime
            Lighting.FogEnd = oldLightingSettings.FogEnd
            Lighting.Ambient = oldLightingSettings.Ambient
        end
    end)
    yPos = yPos + 50

    -- ======= TELEPORT TO PLAYER =======
    NewBtn("Teleport to Player", yPos, function()
        local playerName = game:GetService("Players"):GetPlayers()
        local input = game:GetService("Players").LocalPlayer:PromptInput("Enter Player Name:")
        local target = Players:FindFirstChild(input)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
        end
    end)
    yPos = yPos + 50

    -- ======= ESP BOX =======
    local espOn = false
    local boxes = {}
    local function createBox(plr)
        if plr == LocalPlayer then return end
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local box = Drawing.new("Square")
            box.Color = Color3.fromRGB(0,255,0)
            box.Thickness = 2
            box.Filled = false
            boxes[plr] = box
        end
    end
    local function removeBox(plr)
        if boxes[plr] then boxes[plr]:Remove() boxes[plr]=nil end
    end

    NewBtn("Toggle ESP Box", yPos, function()
        espOn = not espOn
        for _, plr in ipairs(Players:GetPlayers()) do
            if espOn then createBox(plr) else removeBox(plr) end
        end
    end)
    yPos = yPos + 50

    RunService.RenderStepped:Connect(function()
        if espOn then
            for plr,box in pairs(boxes) do
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local root = plr.Character.HumanoidRootPart
                    local pos, vis = Camera:WorldToViewportPoint(root.Position)
                    box.Position = Vector2.new(pos.X, pos.Y)
                    box.Size = Vector2.new(50,100)
                    box.Visible = vis
                end
            end
        end
    end)

    -- Adjust Canvas Size for scroll
    Scroller.CanvasSize = UDim2.new(0,0,yPos+50)
end

-- First Time
createGUI()

-- Respawn
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    createGUI()
end)
