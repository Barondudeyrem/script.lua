-- BARON GUI (Professional + Fly)
local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- Ensure GUI persists on respawn
local function createGUI()
    if player:FindFirstChild("PlayerGui"):FindFirstChild("BaronGUI") then
        player.PlayerGui.BaronGUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BaronGUI"
    ScreenGui.Parent = player.PlayerGui

    -- Slide Frame
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 280, 1, 0)
    Frame.Position = UDim2.new(-1, 0, 0, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    -- RGB border
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 2
    UIStroke.Parent = Frame
    RunService.RenderStepped:Connect(function()
        local t = tick() * 2
        UIStroke.Color = Color3.fromHSV(t%1,1,1)
    end)

    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 40)
    toggleBtn.Position = UDim2.new(0,0,0,0)
    toggleBtn.Text = "≡"
    toggleBtn.Font = Enum.Font.SourceSansBold
    toggleBtn.TextSize = 24
    toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    toggleBtn.Parent = ScreenGui

    local open = false
    toggleBtn.MouseButton1Click:Connect(function()
        open = not open
        TweenService:Create(Frame, TweenInfo.new(0.4), {Position = open and UDim2.new(0,0,0,0) or UDim2.new(-1,0,0,0)}):Play()
    end)

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,0,0,40)
    Title.BackgroundTransparency = 1
    Title.Text = "BARON"
    Title.TextColor3 = Color3.fromRGB(255,255,255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 28
    Title.Parent = Frame

    -- Button Creator
    local function NewBtn(text, y, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 220, 0, 35)
        btn.Position = UDim2.new(0, 20, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 20
        btn.Text = text
        btn.Parent = Frame
        -- Hover
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70,70,70)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- Infinite Jump
    local infiniteJump = false
    NewBtn("Toggle Infinite Jump", 60, function()
        infiniteJump = not infiniteJump
    end)
    UserInputService.JumpRequest:Connect(function()
        if infiniteJump then
            local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState("Jumping") end
        end
    end)

    -- Speed Hack with Slider
    local speedOn = false
    local speedValue = 50
    local speedBtn = NewBtn("Toggle Speed Hack", 110, function()
        speedOn = not speedOn
        local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = speedOn and speedValue or 16 end
    end)

    local slider = Instance.new("TextBox")
    slider.Size = UDim2.new(0, 200, 0, 25)
    slider.Position = UDim2.new(0, 30, 0, 155)
    slider.PlaceholderText = "Speed (50)"
    slider.Text = ""
    slider.ClearTextOnFocus = false
    slider.TextColor3 = Color3.fromRGB(255,255,255)
    slider.BackgroundColor3 = Color3.fromRGB(50,50,50)
    slider.Font = Enum.Font.SourceSans
    slider.TextSize = 18
    slider.Parent = Frame
    slider.FocusLost:Connect(function()
        local val = tonumber(slider.Text)
        if val then
            speedValue = val
            if speedOn then
                local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if h then h.WalkSpeed = speedValue end
            end
        end
    end)

    -- Noclip
    local noclipOn = false
    NewBtn("Toggle Noclip", 200, function()
        noclipOn = not noclipOn
    end)
    RunService.Stepped:Connect(function()
        if noclipOn and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)

    -- Fly
    local flyOn = false
    local flySpeed = 100
    local flyBody
    NewBtn("Toggle Fly", 240, function()
        flyOn = not flyOn
        local char = player.Character
        if flyOn and char then
            local root = char:FindFirstChild("HumanoidRootPart")
            local h = char:FindFirstChildOfClass("Humanoid")
            if root then
                flyBody = Instance.new("BodyVelocity")
                flyBody.MaxForce = Vector3.new(1e5,1e5,1e5)
                flyBody.Velocity = Vector3.new(0,0,0)
                flyBody.Parent = root
            end
        else
            if flyBody then flyBody:Destroy() end
        end
    end)

    UserInputService.InputBegan:Connect(function(input)
        if flyOn and flyBody then
            flyBody.Velocity = Vector3.new(0,0,0)
        end
    end)

    RunService.RenderStepped:Connect(function()
        if flyOn and flyBody and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local move = Vector3.new(0,0,0)
            local h = player.Character:FindFirstChildOfClass("Humanoid")
            if root and h then
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + (Camera.CFrame.LookVector) end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - (Camera.CFrame.LookVector) end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - (Camera.CFrame.RightVector) end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + (Camera.CFrame.RightVector) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
                flyBody.Velocity = move.Unit * flySpeed
            end
        end
    end)

    -- ESP + Tracers
    local espOn = false
    local lines = {}
    local function createESP(plr)
        if plr == player then return end
        if not plr.Character then return end
        local h = plr.Character:FindFirstChild("Head")
        if h then
            local line = Drawing.new("Line")
            line.Color = Color3.fromRGB(255,0,0)
            line.Thickness = 1.5
            line.Transparency = 1
            lines[plr] = line
        end
    end
    local function removeESP(plr)
        if lines[plr] then lines[plr]:Remove() lines[plr]=nil end
    end
    NewBtn("Toggle ESP", 280, function()
        espOn = not espOn
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if espOn then createESP(plr) else removeESP(plr) end
        end
    end)
    RunService.RenderStepped:Connect(function()
        if espOn then
            for plr,line in pairs(lines) do
                if plr.Character and plr.Character:FindFirstChild("Head") then
                    local pos,vis = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                    line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    line.To = Vector2.new(pos.X,pos.Y)
                    line.Visible = vis
                end
            end
        end
    end)
    game.Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function()
            if espOn then wait(1) createESP(plr) end
        end)
    end)
end

-- First time
createGUI()

-- Respawn
player.CharacterAdded:Connect(function()
    wait(1)
    createGUI()
end)
