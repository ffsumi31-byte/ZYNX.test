local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

--------------------------------------------------
-- REMOVE OLD UI
--------------------------------------------------

local old = playerGui:FindFirstChild("StudioTracker")
if old then
	old:Destroy()
end

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local MENU_KEY = Enum.KeyCode.Semicolon
local AIM_KEY = Enum.KeyCode.T

local TOGGLE_MODE = true
local USE_SMOOTHING = false
local TRACK_SPEED = 40

--------------------------------------------------
-- STATE
--------------------------------------------------

local selectedTarget = nil
local aimEnabled = false
local menuOpen = true
local waitingForKeybind = false
local playerListOpen = false

--------------------------------------------------
-- TWEEN
--------------------------------------------------

local function tween(object, duration, properties)
	local info = TweenInfo.new(
		duration,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	local t = TweenService:Create(
		object,
		info,
		properties
	)

	t:Play()
	return t
end

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "StudioTracker"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

--------------------------------------------------
-- MAIN
--------------------------------------------------

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(290, 236)
frame.Position = UDim2.new(0.5, -145, 0.5, -118)
frame.BackgroundColor3 = Color3.fromRGB(15, 14, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 13)

local frameStroke = Instance.new("UIStroke")
frameStroke.Thickness = 1
frameStroke.Color = Color3.fromRGB(98, 61, 150)
frameStroke.Transparency = 0.4
frameStroke.Parent = frame

local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = frame

--------------------------------------------------
-- HEADER
--------------------------------------------------

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Color3.fromRGB(22, 19, 31)
header.BorderSizePixel = 0
header.Active = true
header.Parent = frame

Instance.new("UICorner", header).CornerRadius = UDim.new(0, 13)

local fix = Instance.new("Frame")
fix.Size = UDim2.new(1, 0, 0, 13)
fix.Position = UDim2.new(0, 0, 1, -13)
fix.BackgroundColor3 = header.BackgroundColor3
fix.BorderSizePixel = 0
fix.Parent = header

local accent = Instance.new("Frame")
accent.Size = UDim2.fromOffset(4, 20)
accent.Position = UDim2.fromOffset(13, 12)
accent.BackgroundColor3 = Color3.fromRGB(170, 95, 255)
accent.BorderSizePixel = 0
accent.Parent = header

Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 20)
title.Position = UDim2.fromOffset(26, 6)
title.BackgroundTransparency = 1
title.Text = "TRACKER"
title.TextColor3 = Color3.fromRGB(245, 242, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -60, 0, 14)
subtitle.Position = UDim2.fromOffset(26, 24)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Studio test"
subtitle.TextColor3 = Color3.fromRGB(120, 113, 140)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 9
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.fromOffset(7, 7)
statusDot.AnchorPoint = Vector2.new(0.5, 0.5)
statusDot.Position = UDim2.new(1, -17, 0.5, 0)
statusDot.BackgroundColor3 = Color3.fromRGB(105, 100, 115)
statusDot.BorderSizePixel = 0
statusDot.Parent = header

Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

--------------------------------------------------
-- PLAYER SELECT BUTTON
--------------------------------------------------

local playerSelect = Instance.new("TextButton")
playerSelect.Size = UDim2.new(1, -24, 0, 36)
playerSelect.Position = UDim2.fromOffset(12, 56)
playerSelect.BackgroundColor3 = Color3.fromRGB(25, 22, 33)
playerSelect.BorderSizePixel = 0
playerSelect.Text = "SELECT PLAYER"
playerSelect.TextColor3 = Color3.fromRGB(205, 198, 220)
playerSelect.Font = Enum.Font.GothamMedium
playerSelect.TextSize = 11
playerSelect.AutoButtonColor = false
playerSelect.Parent = frame

Instance.new("UICorner", playerSelect).CornerRadius = UDim.new(0, 8)

--------------------------------------------------
-- PLAYER DROPDOWN
--------------------------------------------------

local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, -24, 0, 0)
playerList.Position = UDim2.fromOffset(12, 96)
playerList.BackgroundColor3 = Color3.fromRGB(21, 19, 28)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 3
playerList.CanvasSize = UDim2.new()
playerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerList.Visible = false
playerList.ClipsDescendants = true
playerList.Parent = frame

Instance.new("UICorner", playerList).CornerRadius = UDim.new(0, 8)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = playerList

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 5)
listPadding.PaddingBottom = UDim.new(0, 5)
listPadding.PaddingLeft = UDim.new(0, 5)
listPadding.PaddingRight = UDim.new(0, 5)
listPadding.Parent = playerList

--------------------------------------------------
-- TARGET STATUS
--------------------------------------------------

local targetStatus = Instance.new("TextLabel")
targetStatus.Size = UDim2.fromOffset(174, 29)
targetStatus.Position = UDim2.fromOffset(12, 103)
targetStatus.BackgroundColor3 = Color3.fromRGB(24, 22, 31)
targetStatus.BorderSizePixel = 0
targetStatus.Text = "TARGET  •  NONE"
targetStatus.TextColor3 = Color3.fromRGB(150, 144, 165)
targetStatus.Font = Enum.Font.GothamMedium
targetStatus.TextSize = 10
targetStatus.TextXAlignment = Enum.TextXAlignment.Left
targetStatus.Parent = frame

local targetPadding = Instance.new("UIPadding")
targetPadding.PaddingLeft = UDim.new(0, 9)
targetPadding.Parent = targetStatus

Instance.new("UICorner", targetStatus).CornerRadius = UDim.new(0, 8)

--------------------------------------------------
-- AIM STATUS
--------------------------------------------------

local aimStatus = Instance.new("TextLabel")
aimStatus.Size = UDim2.fromOffset(86, 29)
aimStatus.Position = UDim2.fromOffset(192, 103)
aimStatus.BackgroundColor3 = Color3.fromRGB(24, 22, 31)
aimStatus.BorderSizePixel = 0
aimStatus.Text = "OFF"
aimStatus.TextColor3 = Color3.fromRGB(145, 140, 155)
aimStatus.Font = Enum.Font.GothamBold
aimStatus.TextSize = 10
aimStatus.Parent = frame

Instance.new("UICorner", aimStatus).CornerRadius = UDim.new(0, 8)

--------------------------------------------------
-- CLEAR BUTTON
--------------------------------------------------

local clearButton = Instance.new("TextButton")
clearButton.Size = UDim2.fromOffset(128, 34)
clearButton.Position = UDim2.fromOffset(12, 143)
clearButton.BackgroundColor3 = Color3.fromRGB(31, 28, 39)
clearButton.BorderSizePixel = 0
clearButton.Text = "CLEAR TARGET"
clearButton.TextColor3 = Color3.fromRGB(175, 168, 190)
clearButton.Font = Enum.Font.GothamBold
clearButton.TextSize = 10
clearButton.AutoButtonColor = false
clearButton.Parent = frame

Instance.new("UICorner", clearButton).CornerRadius = UDim.new(0, 8)

--------------------------------------------------
-- KEYBIND BUTTON
--------------------------------------------------

local keybindButton = Instance.new("TextButton")
keybindButton.Size = UDim2.fromOffset(128, 34)
keybindButton.Position = UDim2.fromOffset(150, 143)
keybindButton.BackgroundColor3 = Color3.fromRGB(31, 27, 42)
keybindButton.BorderSizePixel = 0
keybindButton.Text = "KEY  " .. AIM_KEY.Name
keybindButton.TextColor3 = Color3.fromRGB(205, 195, 220)
keybindButton.Font = Enum.Font.GothamBold
keybindButton.TextSize = 10
keybindButton.AutoButtonColor = false
keybindButton.Parent = frame

Instance.new("UICorner", keybindButton).CornerRadius = UDim.new(0, 8)

--------------------------------------------------
-- MENU HINT
--------------------------------------------------

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, -24, 0, 30)
hint.Position = UDim2.fromOffset(12, 188)
hint.BackgroundColor3 = Color3.fromRGB(22, 20, 29)
hint.BorderSizePixel = 0
hint.Text = ";   SHOW / HIDE"
hint.TextColor3 = Color3.fromRGB(120, 113, 138)
hint.Font = Enum.Font.GothamMedium
hint.TextSize = 9
hint.Parent = frame

Instance.new("UICorner", hint).CornerRadius = UDim.new(0, 8)

--------------------------------------------------
-- BUTTON EFFECTS
--------------------------------------------------

local function addButtonEffects(button, normalColor, hoverColor, pressColor)
	local originalSize = button.Size

	button.MouseEnter:Connect(function()
		tween(button, 0.1, {
			BackgroundColor3 = hoverColor
		})
	end)

	button.MouseLeave:Connect(function()
		tween(button, 0.1, {
			BackgroundColor3 = normalColor,
			Size = originalSize
		})
	end)

	button.MouseButton1Down:Connect(function()
		tween(button, 0.06, {
			BackgroundColor3 = pressColor,
			Size = UDim2.new(
				originalSize.X.Scale,
				originalSize.X.Offset - 3,
				originalSize.Y.Scale,
				originalSize.Y.Offset - 2
			)
		})
	end)

	button.MouseButton1Up:Connect(function()
		tween(button, 0.09, {
			BackgroundColor3 = hoverColor,
			Size = originalSize
		})
	end)
end

addButtonEffects(
	playerSelect,
	Color3.fromRGB(25, 22, 33),
	Color3.fromRGB(38, 31, 50),
	Color3.fromRGB(20, 18, 27)
)

addButtonEffects(
	clearButton,
	Color3.fromRGB(31, 28, 39),
	Color3.fromRGB(43, 38, 52),
	Color3.fromRGB(24, 22, 30)
)

addButtonEffects(
	keybindButton,
	Color3.fromRGB(31, 27, 42),
	Color3.fromRGB(46, 36, 61),
	Color3.fromRGB(24, 20, 32)
)

--------------------------------------------------
-- TARGET HELPERS
--------------------------------------------------

local function getCharacter(target)
	if not target then
		return nil
	end

	if target:IsA("Player") then
		return target.Character
	end

	if target:IsA("Model") then
		return target
	end

	return nil
end

local function getAimPart()
	local character = getCharacter(selectedTarget)

	if not character then
		return nil
	end

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.Health <= 0 then
		return nil
	end

	return character:FindFirstChild("Head")
		or character:FindFirstChild("HumanoidRootPart")
end

--------------------------------------------------
-- STATUS VISUAL
--------------------------------------------------

local function setTrackingVisual(enabled)
	if enabled then
		aimStatus.Text = "ON"
		aimStatus.TextColor3 = Color3.fromRGB(220, 180, 255)

		tween(aimStatus, 0.1, {
			BackgroundColor3 = Color3.fromRGB(55, 34, 78)
		})

		tween(statusDot, 0.1, {
			BackgroundColor3 = Color3.fromRGB(180, 100, 255),
			Size = UDim2.fromOffset(10, 10)
		})

		task.delay(0.1, function()
			tween(statusDot, 0.1, {
				Size = UDim2.fromOffset(7, 7)
			})
		end)
	else
		aimStatus.Text = "OFF"
		aimStatus.TextColor3 = Color3.fromRGB(145, 140, 155)

		tween(aimStatus, 0.1, {
			BackgroundColor3 = Color3.fromRGB(24, 22, 31)
		})

		tween(statusDot, 0.1, {
			BackgroundColor3 = Color3.fromRGB(105, 100, 115)
		})
	end
end

--------------------------------------------------
-- PLAYER LIST
--------------------------------------------------

local function clearPlayerButtons()
	for _, child in ipairs(playerList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
end

local function createPlayerButton(targetPlayer)
	local button = Instance.new("TextButton")

	button.Size = UDim2.new(1, 0, 0, 32)
	button.BackgroundColor3 = Color3.fromRGB(29, 25, 38)
	button.BorderSizePixel = 0

	button.Text =
		targetPlayer.DisplayName
		.. "   @"
		.. targetPlayer.Name

	button.TextColor3 =
		Color3.fromRGB(205, 198, 220)

	button.Font = Enum.Font.GothamMedium
	button.TextSize = 10
	button.TextXAlignment = Enum.TextXAlignment.Left

	button.AutoButtonColor = false
	button.Parent = playerList

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 9)
	padding.Parent = button

	Instance.new("UICorner", button).CornerRadius =
		UDim.new(0, 7)

	addButtonEffects(
		button,
		Color3.fromRGB(29, 25, 38),
		Color3.fromRGB(44, 34, 57),
		Color3.fromRGB(24, 20, 31)
	)

	button.MouseButton1Click:Connect(function()
		selectedTarget = targetPlayer

		targetStatus.Text =
			"TARGET  •  "
			.. targetPlayer.DisplayName

		targetStatus.TextColor3 =
			Color3.fromRGB(195, 150, 255)

		playerSelect.Text =
			targetPlayer.DisplayName

		playerListOpen = false

		tween(playerList, 0.12, {
			Size = UDim2.new(1, -24, 0, 0)
		})

		task.delay(0.12, function()
			if not playerListOpen then
				playerList.Visible = false
			end
		end)
	end)
end

local function refreshPlayerList()
	clearPlayerButtons()

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then
			createPlayerButton(targetPlayer)
		end
	end
end

--------------------------------------------------
-- OPEN/CLOSE PLAYER LIST
--------------------------------------------------

playerSelect.MouseButton1Click:Connect(function()
	playerListOpen = not playerListOpen

	if playerListOpen then
		refreshPlayerList()

		playerList.Visible = true

		tween(playerList, 0.14, {
			Size = UDim2.new(1, -24, 0, 104)
		})
	else
		tween(playerList, 0.12, {
			Size = UDim2.new(1, -24, 0, 0)
		})

		task.delay(0.12, function()
			if not playerListOpen then
				playerList.Visible = false
			end
		end)
	end
end)

--------------------------------------------------
-- AUTO REFRESH SERVER PLAYERS
--------------------------------------------------

Players.PlayerAdded:Connect(function()
	if playerListOpen then
		refreshPlayerList()
	end
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
	if selectedTarget == leavingPlayer then
		selectedTarget = nil
		aimEnabled = false

		targetStatus.Text = "TARGET  •  LEFT"
		targetStatus.TextColor3 =
			Color3.fromRGB(255, 125, 145)

		playerSelect.Text = "SELECT PLAYER"

		setTrackingVisual(false)
	end

	if playerListOpen then
		refreshPlayerList()
	end
end)

--------------------------------------------------
-- CLEAR
--------------------------------------------------

clearButton.MouseButton1Click:Connect(function()
	selectedTarget = nil
	aimEnabled = false

	targetStatus.Text = "TARGET  •  NONE"
	targetStatus.TextColor3 =
		Color3.fromRGB(150, 144, 165)

	playerSelect.Text = "SELECT PLAYER"

	setTrackingVisual(false)
end)

--------------------------------------------------
-- KEYBIND
--------------------------------------------------

keybindButton.MouseButton1Click:Connect(function()
	waitingForKeybind = true

	keybindButton.Text = "PRESS KEY..."
	keybindButton.TextColor3 =
		Color3.fromRGB(205, 155, 255)
end)

--------------------------------------------------
-- KEY INPUT
--------------------------------------------------

UserInputService.InputBegan:Connect(function(inputObject, processed)

	if waitingForKeybind then
		if inputObject.UserInputType
			== Enum.UserInputType.Keyboard then

			if inputObject.KeyCode ~= Enum.KeyCode.Unknown
				and inputObject.KeyCode ~= MENU_KEY then

				AIM_KEY = inputObject.KeyCode
				waitingForKeybind = false

				keybindButton.Text =
					"KEY  " .. AIM_KEY.Name

				keybindButton.TextColor3 =
					Color3.fromRGB(205, 195, 220)
			end
		end

		return
	end

	if processed then
		return
	end

	--------------------------------------------------
	-- MENU
	--------------------------------------------------

	if inputObject.KeyCode == MENU_KEY then
		menuOpen = not menuOpen

		if menuOpen then
			frame.Visible = true
			scale.Scale = 0.93

			tween(scale, 0.14, {
				Scale = 1
			})
		else
			tween(scale, 0.1, {
				Scale = 0.94
			})

			task.delay(0.1, function()
				if not menuOpen then
					frame.Visible = false
				end
			end)
		end

		return
	end

	--------------------------------------------------
	-- AIM
	--------------------------------------------------

	if inputObject.KeyCode == AIM_KEY then
		if not selectedTarget then
			return
		end

		if TOGGLE_MODE then
			aimEnabled = not aimEnabled
		else
			aimEnabled = true
		end

		setTrackingVisual(aimEnabled)
	end
end)

--------------------------------------------------
-- HOLD MODE
--------------------------------------------------

UserInputService.InputEnded:Connect(function(inputObject)
	if inputObject.KeyCode == AIM_KEY
		and not TOGGLE_MODE then

		aimEnabled = false
		setTrackingVisual(false)
	end
end)

--------------------------------------------------
-- DRAGGING
--------------------------------------------------

local dragging = false
local dragStart = nil
local startPosition = nil

header.InputBegan:Connect(function(inputObject)
	if inputObject.UserInputType
		== Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = inputObject.Position
		startPosition = frame.Position

		tween(scale, 0.07, {
			Scale = 0.985
		})
	end
end)

UserInputService.InputChanged:Connect(function(inputObject)
	if dragging
		and inputObject.UserInputType
			== Enum.UserInputType.MouseMovement then

		local delta =
			inputObject.Position - dragStart

		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(inputObject)
	if inputObject.UserInputType
		== Enum.UserInputType.MouseButton1
		and dragging then

		dragging = false

		tween(scale, 0.09, {
			Scale = 1
		})
	end
end)

--------------------------------------------------
-- CAMERA TRACKING
--------------------------------------------------

RunService.RenderStepped:Connect(function(dt)

	if not aimEnabled then
		return
	end

	local targetPart = getAimPart()

	if not targetPart then
		aimStatus.Text = "WAIT"
		return
	end

	local desiredCamera = CFrame.lookAt(
		camera.CFrame.Position,
		targetPart.Position
	)

	if USE_SMOOTHING then
		local alpha =
			1 - math.exp(-TRACK_SPEED * dt)

		camera.CFrame =
			camera.CFrame:Lerp(
				desiredCamera,
				alpha
			)
	else
		camera.CFrame = desiredCamera
	end
end)
