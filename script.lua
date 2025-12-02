-- BARON GUI (Draggable + Infinite Jump + Speed + ESP)
local player = game.Players.LocalPlayer

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BaronGUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 230)
Frame.Position = UDim2.new(0.5, -130, 0.4, -115)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Draggable
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

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - mousePos
		Frame.Position = framePos + UDim2.new(0, delta.X, 0, delta.Y)
	end
end)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "BARON"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 28
Title.Parent = Frame

-- Button function
local function NewBtn(text, y, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 230, 0, 35)
	btn.Position = UDim2.new(0, 15, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 20
	btn.Text = text
	btn.Parent = Frame
	btn.MouseButton1Click:Connect(callback)
end

-----------------------------------------------------------
-- Infinite Jump
local infiniteJump = false
NewBtn("Toggle Infinite Jump", 50, function()
	infiniteJump = not infiniteJump
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
	if infiniteJump then
		local h = player.Character:FindFirstChildOfClass("Humanoid")
		if h then h:ChangeState("Jumping") end
	end
end)

-----------------------------------------------------------
-- Speed Hack
local speedOn = false
local speedValue = 50

NewBtn("Toggle Speed Hack", 90, function()
	speedOn = not speedOn
	local h = player.Character and player.Character:FindFirstChild("Humanoid")
	if h then
		h.WalkSpeed = speedOn and speedValue or 16
	end
end)

-----------------------------------------------------------
-- ESP SYSTEM
local espOn = false

local function createESP(plr)
	if plr == player then return end
	if not plr.Character then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "ESP_HIGHLIGHT"
	highlight.FillTransparency = 1
	highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
	highlight.Parent = plr.Character
end

local function removeESP(plr)
	if plr.Character and plr.Character:FindFirstChild("ESP_HIGHLIGHT") then
		plr.Character.ESP_HIGHLIGHT:Destroy()
	end
end

NewBtn("Toggle ESP", 130, function()
	espOn = not espOn
	for _, plr in ipairs(game.Players:GetPlayers()) do
		if espOn then
			createESP(plr)
		else
			removeESP(plr)
		end
	end
end)

game.Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		if espOn then
			wait(1)
			createESP(plr)
		end
	end)
end)

-- Border
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 2
UIStroke.Parent = Frame
