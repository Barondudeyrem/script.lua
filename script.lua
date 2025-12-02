-- BARON GUI (Professional)
local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BaronGUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 320)
Frame.Position = UDim2.new(0.5, -140, 0.4, -160)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
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

-- Dragging
local dragging, dragInput, mousePos, framePos
Frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		mousePos = input.Position
		framePos = Frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
Frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - mousePos
		Frame.Position = framePos + UDim2.new(0, delta.X, 0, delta.Y)
	end
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
	btn.Size = UDim2.new(0, 240, 0, 35)
	btn.Position = UDim2.new(0, 20, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 20
	btn.Text = text
	btn.Parent = Frame
	-- Hover Animation
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
NewBtn("Toggle Infinite Jump", 50, function()
	infiniteJump = not infiniteJump
end)
UserInputService.JumpRequest:Connect(function()
	if infiniteJump then
		local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if h then h:ChangeState("Jumping") end
	end
end)

-- Speed Hack with slider
local speedOn = false
local speedValue = 50
local speedBtn = NewBtn("Toggle Speed Hack", 90, function()
	speedOn = not speedOn
	local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if h then h.WalkSpeed = speedOn and speedValue or 16 end
end)

-- Speed Slider
local slider = Instance.new("TextBox")
slider.Size = UDim2.new(0, 200, 0, 25)
slider.Position = UDim2.new(0, 40, 0, 135)
slider.PlaceholderText = "Speed (default 50)"
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
NewBtn("Toggle Noclip", 170, function()
	noclipOn = not noclipOn
end)
RunService.Stepped:Connect(function()
	if noclipOn and player.Character then
		for _, part in ipairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
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
	if lines[plr] then
		lines[plr]:Remove()
		lines[plr] = nil
	end
end
NewBtn("Toggle ESP", 210, function()
	espOn = not espOn
	for _, plr in ipairs(game.Players:GetPlayers()) do
		if espOn then createESP(plr) else removeESP(plr) end
	end
end)
RunService.RenderStepped:Connect(function()
	if espOn then
		for plr,line in pairs(lines) do
			if plr.Character and plr.Character:FindFirstChild("Head") then
				local pos,vis = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.Head.Position)
				line.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y)
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
