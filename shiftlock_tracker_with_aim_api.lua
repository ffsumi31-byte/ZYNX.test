-- SHIFT-LOCK TRACKER (STUDIO ONLY)
-- Put this LocalScript in StarterPlayer > StarterPlayerScripts
-- Select a player, press LeftShift to toggle tracking.
-- Camera stays manual; only the purple reticle follows the target.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

local SHIFT_TRACK_KEY = Enum.KeyCode.LeftShift
local MENU_KEY = Enum.KeyCode.Semicolon

local selectedTarget = nil
local trackingEnabled = false
local menuOpen = true
local listOpen = false

for _, name in ipairs({"ShiftTrackUI","StudioTracker","TargetVisual","VisualTrackerTest"}) do
	local old = playerGui:FindFirstChild(name)
	if old then old:Destroy() end
end

local function tween(object, duration, properties)
	local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local t = TweenService:Create(object, info, properties)
	t:Play()
	return t
end

local function getAimPart()
	if not selectedTarget or not selectedTarget.Character then
		return nil
	end

	local character = selectedTarget.Character
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.Health <= 0 then
		return nil
	end

	return character:FindFirstChild("Head")
		or character:FindFirstChild("HumanoidRootPart")
end

--------------------------------------------------
-- AIM API FOR YOUR OWN STUDIO SKILLS
--------------------------------------------------

local function getTrackedAimPosition()
	if trackingEnabled and selectedTarget then
		local targetPart = getAimPart()

		if targetPart then
			return targetPart.Position
		end
	end

	-- Normal fallback: aim where the camera looks
	return camera.CFrame.Position
		+ camera.CFrame.LookVector * 1000
end

-- Optional helper for raycasts/projectiles
local function getTrackedAimDirection(originPosition)
	local aimPosition = getTrackedAimPosition()
	return (aimPosition - originPosition).Unit
end

-- Example usage inside YOUR OWN skill code:
--
-- local origin = character.HumanoidRootPart.Position
-- local aimPosition = getTrackedAimPosition()
-- local direction = getTrackedAimDirection(origin)
--
-- projectile.AssemblyLinearVelocity = direction * 150
--
-- local result = workspace:Raycast(
--     origin,
--     direction * 1000,
--     raycastParams
-- )
--
-- effect.CFrame = CFrame.lookAt(origin, aimPosition)

local gui = Instance.new("ScreenGui")
gui.Name = "ShiftTrackUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(270, 178)
frame.Position = UDim2.new(0.5, -135, 0.5, -89)
frame.BackgroundColor3 = Color3.fromRGB(15,14,20)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,13)

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1
stroke.Color = Color3.fromRGB(105,68,160)
stroke.Transparency = 0.38
stroke.Parent = frame

local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = frame

local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,44)
header.BackgroundColor3 = Color3.fromRGB(22,19,31)
header.BorderSizePixel = 0
header.Active = true
header.Parent = frame
Instance.new("UICorner", header).CornerRadius = UDim.new(0,13)

local fix = Instance.new("Frame")
fix.Size = UDim2.new(1,0,0,13)
fix.Position = UDim2.new(0,0,1,-13)
fix.BackgroundColor3 = header.BackgroundColor3
fix.BorderSizePixel = 0
fix.Parent = header

local accent = Instance.new("Frame")
accent.Size = UDim2.fromOffset(4,20)
accent.Position = UDim2.fromOffset(12,12)
accent.BackgroundColor3 = Color3.fromRGB(174,101,255)
accent.BorderSizePixel = 0
accent.Parent = header
Instance.new("UICorner", accent).CornerRadius = UDim.new(1,0)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-70,0,20)
title.Position = UDim2.fromOffset(25,5)
title.BackgroundTransparency = 1
title.Text = "SHIFT TRACK"
title.TextColor3 = Color3.fromRGB(246,242,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1,-70,0,14)
subtitle.Position = UDim2.fromOffset(25,23)
subtitle.BackgroundTransparency = 1
subtitle.Text = "manual camera • tracked aim API"
subtitle.TextColor3 = Color3.fromRGB(120,113,140)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 9
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.fromOffset(7,7)
statusDot.AnchorPoint = Vector2.new(0.5,0.5)
statusDot.Position = UDim2.new(1,-17,0.5,0)
statusDot.BackgroundColor3 = Color3.fromRGB(100,96,112)
statusDot.BorderSizePixel = 0
statusDot.Parent = header
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1,0)

local playerSelect = Instance.new("TextButton")
playerSelect.Size = UDim2.new(1,-24,0,35)
playerSelect.Position = UDim2.fromOffset(12,55)
playerSelect.BackgroundColor3 = Color3.fromRGB(25,22,33)
playerSelect.BorderSizePixel = 0
playerSelect.Text = "SELECT PLAYER"
playerSelect.TextColor3 = Color3.fromRGB(210,202,224)
playerSelect.Font = Enum.Font.GothamMedium
playerSelect.TextSize = 10
playerSelect.AutoButtonColor = false
playerSelect.Parent = frame
Instance.new("UICorner", playerSelect).CornerRadius = UDim.new(0,8)

local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1,-24,0,0)
playerList.Position = UDim2.fromOffset(12,95)
playerList.BackgroundColor3 = Color3.fromRGB(21,19,28)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 3
playerList.ScrollBarImageColor3 = Color3.fromRGB(145,82,220)
playerList.CanvasSize = UDim2.new()
playerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerList.ClipsDescendants = true
playerList.Visible = false
playerList.ZIndex = 20
playerList.Parent = frame
Instance.new("UICorner", playerList).CornerRadius = UDim.new(0,8)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,4)
layout.Parent = playerList

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0,5)
padding.PaddingBottom = UDim.new(0,5)
padding.PaddingLeft = UDim.new(0,5)
padding.PaddingRight = UDim.new(0,5)
padding.Parent = playerList

local targetStatus = Instance.new("TextLabel")
targetStatus.Size = UDim2.fromOffset(162,29)
targetStatus.Position = UDim2.fromOffset(12,101)
targetStatus.BackgroundColor3 = Color3.fromRGB(24,22,31)
targetStatus.BorderSizePixel = 0
targetStatus.Text = "TARGET  •  NONE"
targetStatus.TextColor3 = Color3.fromRGB(150,144,165)
targetStatus.Font = Enum.Font.GothamMedium
targetStatus.TextSize = 9
targetStatus.TextXAlignment = Enum.TextXAlignment.Left
targetStatus.Parent = frame
Instance.new("UICorner", targetStatus).CornerRadius = UDim.new(0,8)

local targetPad = Instance.new("UIPadding")
targetPad.PaddingLeft = UDim.new(0,9)
targetPad.Parent = targetStatus

local trackStatus = Instance.new("TextLabel")
trackStatus.Size = UDim2.fromOffset(84,29)
trackStatus.Position = UDim2.fromOffset(174,101)
trackStatus.BackgroundColor3 = Color3.fromRGB(24,22,31)
trackStatus.BorderSizePixel = 0
trackStatus.Text = "SHIFT OFF"
trackStatus.TextColor3 = Color3.fromRGB(145,140,155)
trackStatus.Font = Enum.Font.GothamBold
trackStatus.TextSize = 9
trackStatus.Parent = frame
Instance.new("UICorner", trackStatus).CornerRadius = UDim.new(0,8)

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1,-24,0,29)
hint.Position = UDim2.fromOffset(12,138)
hint.BackgroundColor3 = Color3.fromRGB(22,20,29)
hint.BorderSizePixel = 0
hint.Text = "LEFT SHIFT = TRACK    •    ; = MENU"
hint.TextColor3 = Color3.fromRGB(120,113,138)
hint.Font = Enum.Font.GothamMedium
hint.TextSize = 8
hint.Parent = frame
Instance.new("UICorner", hint).CornerRadius = UDim.new(0,8)

local reticle = Instance.new("Frame")
reticle.Size = UDim2.fromOffset(22,22)
reticle.AnchorPoint = Vector2.new(0.5,0.5)
reticle.BackgroundTransparency = 1
reticle.Visible = false
reticle.ZIndex = 1000
reticle.Parent = gui

local ring = Instance.new("Frame")
ring.Size = UDim2.fromScale(1,1)
ring.BackgroundTransparency = 1
ring.BorderSizePixel = 0
ring.Parent = reticle
Instance.new("UICorner", ring).CornerRadius = UDim.new(1,0)

local ringStroke = Instance.new("UIStroke")
ringStroke.Thickness = 1.5
ringStroke.Color = Color3.fromRGB(178,102,255)
ringStroke.Parent = ring

local centerDot = Instance.new("Frame")
centerDot.Size = UDim2.fromOffset(4,4)
centerDot.AnchorPoint = Vector2.new(0.5,0.5)
centerDot.Position = UDim2.fromScale(0.5,0.5)
centerDot.BackgroundColor3 = Color3.fromRGB(221,177,255)
centerDot.BorderSizePixel = 0
centerDot.ZIndex = 1001
centerDot.Parent = reticle
Instance.new("UICorner", centerDot).CornerRadius = UDim.new(1,0)

local function makeTick(size, position)
	local tick = Instance.new("Frame")
	tick.Size = size
	tick.AnchorPoint = Vector2.new(0.5,0.5)
	tick.Position = position
	tick.BackgroundColor3 = Color3.fromRGB(188,116,255)
	tick.BorderSizePixel = 0
	tick.ZIndex = 1001
	tick.Parent = reticle
end

makeTick(UDim2.fromOffset(1,4), UDim2.new(0.5,0,0,-1))
makeTick(UDim2.fromOffset(1,4), UDim2.new(0.5,0,1,1))
makeTick(UDim2.fromOffset(4,1), UDim2.new(0,-1,0.5,0))
makeTick(UDim2.fromOffset(4,1), UDim2.new(1,1,0.5,0))

local function setTracking(enabled)
	trackingEnabled = enabled

	if enabled then
		-- Let Roblox's built-in Shift Lock control MouseBehavior.
		-- We only hide the normal cursor and enable our tracker visual.
		UserInputService.MouseIconEnabled = false

		trackStatus.Text = "SHIFT ON"
		trackStatus.TextColor3 = Color3.fromRGB(220,180,255)
		trackStatus.BackgroundColor3 = Color3.fromRGB(55,34,78)

		statusDot.BackgroundColor3 = Color3.fromRGB(180,100,255)
	else
		UserInputService.MouseIconEnabled = true

		reticle.Visible = false

		trackStatus.Text = "SHIFT OFF"
		trackStatus.TextColor3 = Color3.fromRGB(145,140,155)
		trackStatus.BackgroundColor3 = Color3.fromRGB(24,22,31)

		statusDot.BackgroundColor3 = Color3.fromRGB(100,96,112)
	end
end

local function clearPlayerButtons()
	for _, child in ipairs(playerList:GetChildren()) do
		if child:IsA("TextButton") or child.Name == "EmptyLabel" then
			child:Destroy()
		end
	end
end

local function closePlayerList()
	listOpen = false

	tween(playerList,0.12,{Size = UDim2.new(1,-24,0,0)})
	tween(frame,0.14,{Size = UDim2.fromOffset(270,178)})
	tween(targetStatus,0.14,{Position = UDim2.fromOffset(12,101)})
	tween(trackStatus,0.14,{Position = UDim2.fromOffset(174,101)})
	tween(hint,0.14,{Position = UDim2.fromOffset(12,138)})

	task.delay(0.13,function()
		if not listOpen then
			playerList.Visible = false
		end
	end)
end

local function createPlayerButton(targetPlayer)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1,0,0,31)
	button.BackgroundColor3 = Color3.fromRGB(29,25,38)
	button.BorderSizePixel = 0
	button.Text = targetPlayer.DisplayName .. "   @" .. targetPlayer.Name
	button.TextColor3 = Color3.fromRGB(205,198,220)
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 9
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.AutoButtonColor = false
	button.ZIndex = 21
	button.Parent = playerList
	Instance.new("UICorner",button).CornerRadius = UDim.new(0,7)

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0,9)
	pad.Parent = button

	button.MouseButton1Click:Connect(function()
		selectedTarget = targetPlayer
		playerSelect.Text = targetPlayer.DisplayName
		targetStatus.Text = "TARGET  •  " .. targetPlayer.DisplayName
		targetStatus.TextColor3 = Color3.fromRGB(195,150,255)
		closePlayerList()
	end)
end

local function refreshPlayerList()
	clearPlayerButtons()

	local count = 0

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then
			count += 1
			createPlayerButton(targetPlayer)
		end
	end

	if count == 0 then
		local empty = Instance.new("TextLabel")
		empty.Name = "EmptyLabel"
		empty.Size = UDim2.new(1,0,0,31)
		empty.BackgroundTransparency = 1
		empty.Text = "NO OTHER PLAYERS"
		empty.TextColor3 = Color3.fromRGB(120,113,140)
		empty.Font = Enum.Font.GothamMedium
		empty.TextSize = 9
		empty.ZIndex = 21
		empty.Parent = playerList
	end
end

local function openPlayerList()
	listOpen = true
	refreshPlayerList()

	playerList.Visible = true
	playerList.Size = UDim2.new(1,-24,0,0)

	tween(frame,0.14,{Size = UDim2.fromOffset(270,278)})
	tween(playerList,0.14,{Size = UDim2.new(1,-24,0,94)})
	tween(targetStatus,0.14,{Position = UDim2.fromOffset(12,201)})
	tween(trackStatus,0.14,{Position = UDim2.fromOffset(174,201)})
	tween(hint,0.14,{Position = UDim2.fromOffset(12,238)})
end

playerSelect.MouseButton1Click:Connect(function()
	if listOpen then
		closePlayerList()
	else
		openPlayerList()
	end
end)

Players.PlayerAdded:Connect(function()
	if listOpen then refreshPlayerList() end
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
	if selectedTarget == leavingPlayer then
		selectedTarget = nil
		playerSelect.Text = "SELECT PLAYER"
		targetStatus.Text = "TARGET  •  LEFT"
		targetStatus.TextColor3 = Color3.fromRGB(255,125,145)
		setTracking(false)
	end

	if listOpen then refreshPlayerList() end
end)

RunService.RenderStepped:Connect(function()
	if not trackingEnabled or not selectedTarget then
		reticle.Visible = false
		return
	end

	local targetPart = getAimPart()

	if not targetPart then
		reticle.Visible = false
		return
	end

	local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)

	if onScreen and screenPos.Z > 0 then
		reticle.Visible = true
		reticle.Position = UDim2.fromOffset(screenPos.X,screenPos.Y)
	else
		reticle.Visible = false
	end
end)

UserInputService.InputBegan:Connect(function(inputObject, processed)

	-- IMPORTANT:
	-- Roblox's built-in Shift Lock can mark LeftShift as processed.
	-- Handle LeftShift BEFORE checking `processed`.
	if inputObject.KeyCode == SHIFT_TRACK_KEY then
		if not selectedTarget then
			targetStatus.Text = "TARGET  •  SELECT ONE"
			targetStatus.TextColor3 = Color3.fromRGB(255,145,170)
			return
		end

		setTracking(not trackingEnabled)
		return
	end

	if processed then
		return
	end

	if inputObject.KeyCode == MENU_KEY then
		menuOpen = not menuOpen

		if menuOpen then
			frame.Visible = true
			scale.Scale = 0.93
			tween(scale,0.14,{Scale = 1})
		else
			if listOpen then closePlayerList() end
			tween(scale,0.1,{Scale = 0.94})
			task.delay(0.1,function()
				if not menuOpen then
					frame.Visible = false
				end
			end)
		end

		return
	end
end)

local dragging = false
local dragStart = nil
local startPosition = nil

header.InputBegan:Connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = inputObject.Position
		startPosition = frame.Position
	end
end)

UserInputService.InputChanged:Connect(function(inputObject)
	if dragging and inputObject.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = inputObject.Position - dragStart
		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

gui.AncestryChanged:Connect(function(_,parent)
	if not parent then
		UserInputService.MouseIconEnabled = true
	end
end)
