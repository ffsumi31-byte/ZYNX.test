-- OLD-STYLE SHIFTLOCK TRACKER (STUDIO ONLY)
-- Put this LocalScript in:
-- StarterPlayer > StarterPlayerScripts
--
-- Behavior:
-- • Select a player from the UI.
-- • Tracker only controls the camera while Roblox Shift Lock is actually LOCKED.
-- • Unlock Shift Lock -> tracking immediately stops and normal camera returns.
-- • No separate tracking keybind.
-- • ; shows/hides the panel.
--
-- IMPORTANT:
-- Enable Shift Lock in StarterPlayer:
-- StarterPlayer.EnableMouseLockOption = true

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local MENU_KEY = Enum.KeyCode.Semicolon

local PANEL_WIDTH = 290

local CLOSED_HEIGHT = 196
local OPEN_HEIGHT = 300

local CLOSED_STATUS_Y = 103
local OPEN_STATUS_Y = 207

local CLOSED_HINT_Y = 145
local OPEN_HINT_Y = 249

-- false = instant/max tracking
-- true = smooth tracking
local USE_SMOOTHING = false
local TRACK_SPEED = 40

--------------------------------------------------
-- STATE
--------------------------------------------------

local selectedTarget = nil
local playerListOpen = false
local menuOpen = true

local shiftLockActive = false

--------------------------------------------------
-- REMOVE OLD UI
--------------------------------------------------

for _, guiName in ipairs({
	"StudioTracker",
	"ShiftTrackUI",
	"TargetVisual",
	"VisualTrackerTest"
}) do
	local old = playerGui:FindFirstChild(guiName)
	if old then
		old:Destroy()
	end
end

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
-- TARGET HELPERS
--------------------------------------------------

local function getAimPart()
	if not selectedTarget then
		return nil
	end

	local character = selectedTarget.Character

	if not character then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.Health <= 0 then
		return nil
	end

	return character:FindFirstChild("Head")
		or character:FindFirstChild("HumanoidRootPart")
end

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "StudioTracker"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(
	PANEL_WIDTH,
	CLOSED_HEIGHT
)
frame.Position = UDim2.new(
	0.5,
	-PANEL_WIDTH / 2,
	0.5,
	-CLOSED_HEIGHT / 2
)
frame.BackgroundColor3 = Color3.fromRGB(15, 14, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius =
	UDim.new(0, 13)

local frameStroke = Instance.new("UIStroke")
frameStroke.Thickness = 1
frameStroke.Color = Color3.fromRGB(98, 61, 150)
frameStroke.Transparency = 0.4
frameStroke.Parent = frame

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = frame

--------------------------------------------------
-- HEADER
--------------------------------------------------

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Color3.fromRGB(22, 19, 31)
header.BorderSizePixel = 0
header.Active = true
header.Parent = frame

Instance.new("UICorner", header).CornerRadius =
	UDim.new(0, 13)

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 13)
headerFix.Position = UDim2.new(0, 0, 1, -13)
headerFix.BackgroundColor3 = header.BackgroundColor3
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local accent = Instance.new("Frame")
accent.Size = UDim2.fromOffset(4, 20)
accent.Position = UDim2.fromOffset(13, 12)
accent.BackgroundColor3 = Color3.fromRGB(170, 95, 255)
accent.BorderSizePixel = 0
accent.Parent = header

Instance.new("UICorner", accent).CornerRadius =
	UDim.new(1, 0)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 20)
title.Position = UDim2.fromOffset(26, 6)
title.BackgroundTransparency = 1
title.Text = "SHIFTLOCK TRACKER"
title.TextColor3 = Color3.fromRGB(245, 242, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -60, 0, 14)
subtitle.Position = UDim2.fromOffset(26, 24)
subtitle.BackgroundTransparency = 1
subtitle.Text = "tracks only while Shift Lock is locked"
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

Instance.new("UICorner", statusDot).CornerRadius =
	UDim.new(1, 0)

--------------------------------------------------
-- SELECT PLAYER
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

Instance.new("UICorner", playerSelect).CornerRadius =
	UDim.new(0, 8)

--------------------------------------------------
-- PLAYER LIST
--------------------------------------------------

local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, -24, 0, 0)
playerList.Position = UDim2.fromOffset(12, 96)
playerList.BackgroundColor3 = Color3.fromRGB(21, 19, 28)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 3
playerList.ScrollBarImageColor3 =
	Color3.fromRGB(145, 82, 220)
playerList.CanvasSize = UDim2.new()
playerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerList.ClipsDescendants = true
playerList.Visible = false
playerList.ZIndex = 20
playerList.Parent = frame

Instance.new("UICorner", playerList).CornerRadius =
	UDim.new(0, 8)

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
targetStatus.Size = UDim2.fromOffset(172, 30)
targetStatus.Position = UDim2.fromOffset(
	12,
	CLOSED_STATUS_Y
)
targetStatus.BackgroundColor3 =
	Color3.fromRGB(24, 22, 31)
targetStatus.BorderSizePixel = 0
targetStatus.Text = "TARGET  •  NONE"
targetStatus.TextColor3 =
	Color3.fromRGB(150, 144, 165)
targetStatus.Font = Enum.Font.GothamMedium
targetStatus.TextSize = 10
targetStatus.TextXAlignment =
	Enum.TextXAlignment.Left
targetStatus.Parent = frame

local targetPad = Instance.new("UIPadding")
targetPad.PaddingLeft = UDim.new(0, 9)
targetPad.Parent = targetStatus

Instance.new("UICorner", targetStatus).CornerRadius =
	UDim.new(0, 8)

--------------------------------------------------
-- SHIFTLOCK STATUS
--------------------------------------------------

local lockStatus = Instance.new("TextLabel")
lockStatus.Size = UDim2.fromOffset(88, 30)
lockStatus.Position = UDim2.fromOffset(
	190,
	CLOSED_STATUS_Y
)
lockStatus.BackgroundColor3 =
	Color3.fromRGB(24, 22, 31)
lockStatus.BorderSizePixel = 0
lockStatus.Text = "UNLOCKED"
lockStatus.TextColor3 =
	Color3.fromRGB(145, 140, 155)
lockStatus.Font = Enum.Font.GothamBold
lockStatus.TextSize = 9
lockStatus.Parent = frame

Instance.new("UICorner", lockStatus).CornerRadius =
	UDim.new(0, 8)

--------------------------------------------------
-- HINT
--------------------------------------------------

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, -24, 0, 30)
hint.Position = UDim2.fromOffset(
	12,
	CLOSED_HINT_Y
)
hint.BackgroundColor3 = Color3.fromRGB(22, 20, 29)
hint.BorderSizePixel = 0
hint.Text = "SHIFT LOCK = TRACK     •     ; = MENU"
hint.TextColor3 = Color3.fromRGB(120, 113, 138)
hint.Font = Enum.Font.GothamMedium
hint.TextSize = 8
hint.Parent = frame

Instance.new("UICorner", hint).CornerRadius =
	UDim.new(0, 8)

--------------------------------------------------
-- BUTTON EFFECT
--------------------------------------------------

local function addButtonEffect(button)
	local normal = Color3.fromRGB(25, 22, 33)
	local hover = Color3.fromRGB(38, 31, 50)
	local pressed = Color3.fromRGB(20, 18, 27)

	local originalSize = button.Size

	button.MouseEnter:Connect(function()
		tween(button, 0.1, {
			BackgroundColor3 = hover
		})
	end)

	button.MouseLeave:Connect(function()
		tween(button, 0.1, {
			BackgroundColor3 = normal,
			Size = originalSize
		})
	end)

	button.MouseButton1Down:Connect(function()
		tween(button, 0.06, {
			BackgroundColor3 = pressed,
			Size = UDim2.new(
				originalSize.X.Scale,
				originalSize.X.Offset - 3,
				originalSize.Y.Scale,
				originalSize.Y.Offset - 2
			)
		})
	end)

	button.MouseButton1Up:Connect(function()
		tween(button, 0.08, {
			BackgroundColor3 = hover,
			Size = originalSize
		})
	end)
end

addButtonEffect(playerSelect)

--------------------------------------------------
-- SHIFTLOCK VISUAL
--------------------------------------------------

local function updateLockVisual(locked)
	if locked then
		lockStatus.Text = "LOCKED"
		lockStatus.TextColor3 =
			Color3.fromRGB(220, 180, 255)

		tween(lockStatus, 0.1, {
			BackgroundColor3 =
				Color3.fromRGB(55, 34, 78)
		})

		tween(statusDot, 0.1, {
			BackgroundColor3 =
				Color3.fromRGB(180, 100, 255),
			Size = UDim2.fromOffset(10, 10)
		})

		task.delay(0.1, function()
			tween(statusDot, 0.1, {
				Size = UDim2.fromOffset(7, 7)
			})
		end)
	else
		lockStatus.Text = "UNLOCKED"
		lockStatus.TextColor3 =
			Color3.fromRGB(145, 140, 155)

		tween(lockStatus, 0.1, {
			BackgroundColor3 =
				Color3.fromRGB(24, 22, 31)
		})

		tween(statusDot, 0.1, {
			BackgroundColor3 =
				Color3.fromRGB(105, 100, 115),
			Size = UDim2.fromOffset(7, 7)
		})
	end
end

--------------------------------------------------
-- PLAYER LIST HELPERS
--------------------------------------------------

local function clearPlayerButtons()
	for _, child in ipairs(playerList:GetChildren()) do
		if child:IsA("TextButton")
			or child.Name == "EmptyLabel" then

			child:Destroy()
		end
	end
end

local function closePlayerList()
	playerListOpen = false

	tween(playerList, 0.12, {
		Size = UDim2.new(1, -24, 0, 0)
	})

	tween(frame, 0.14, {
		Size = UDim2.fromOffset(
			PANEL_WIDTH,
			CLOSED_HEIGHT
		)
	})

	tween(targetStatus, 0.14, {
		Position = UDim2.fromOffset(
			12,
			CLOSED_STATUS_Y
		)
	})

	tween(lockStatus, 0.14, {
		Position = UDim2.fromOffset(
			190,
			CLOSED_STATUS_Y
		)
	})

	tween(hint, 0.14, {
		Position = UDim2.fromOffset(
			12,
			CLOSED_HINT_Y
		)
	})

	task.delay(0.13, function()
		if not playerListOpen then
			playerList.Visible = false
		end
	end)
end

local function createPlayerButton(targetPlayer)
	local button = Instance.new("TextButton")

	button.Size = UDim2.new(1, 0, 0, 32)
	button.BackgroundColor3 =
		Color3.fromRGB(29, 25, 38)
	button.BorderSizePixel = 0
	button.Text =
		targetPlayer.DisplayName
		.. "   @"
		.. targetPlayer.Name
	button.TextColor3 =
		Color3.fromRGB(205, 198, 220)
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 10
	button.TextXAlignment =
		Enum.TextXAlignment.Left
	button.AutoButtonColor = false
	button.ZIndex = 21
	button.Parent = playerList

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 9)
	pad.Parent = button

	Instance.new("UICorner", button).CornerRadius =
		UDim.new(0, 7)

	button.MouseButton1Click:Connect(function()
		selectedTarget = targetPlayer

		playerSelect.Text =
			targetPlayer.DisplayName

		targetStatus.Text =
			"TARGET  •  "
			.. targetPlayer.DisplayName

		targetStatus.TextColor3 =
			Color3.fromRGB(195, 150, 255)

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
		empty.Size = UDim2.new(1, 0, 0, 32)
		empty.BackgroundTransparency = 1
		empty.Text = "NO OTHER PLAYERS"
		empty.TextColor3 =
			Color3.fromRGB(120, 113, 140)
		empty.Font = Enum.Font.GothamMedium
		empty.TextSize = 9
		empty.ZIndex = 21
		empty.Parent = playerList
	end
end

local function openPlayerList()
	playerListOpen = true

	refreshPlayerList()

	playerList.Visible = true
	playerList.Size = UDim2.new(1, -24, 0, 0)

	tween(frame, 0.14, {
		Size = UDim2.fromOffset(
			PANEL_WIDTH,
			OPEN_HEIGHT
		)
	})

	tween(playerList, 0.14, {
		Size = UDim2.new(
			1,
			-24,
			0,
			100
		)
	})

	tween(targetStatus, 0.14, {
		Position = UDim2.fromOffset(
			12,
			OPEN_STATUS_Y
		)
	})

	tween(lockStatus, 0.14, {
		Position = UDim2.fromOffset(
			190,
			OPEN_STATUS_Y
		)
	})

	tween(hint, 0.14, {
		Position = UDim2.fromOffset(
			12,
			OPEN_HINT_Y
		)
	})
end

playerSelect.MouseButton1Click:Connect(function()
	if playerListOpen then
		closePlayerList()
	else
		openPlayerList()
	end
end)

--------------------------------------------------
-- PLAYER JOIN / LEAVE
--------------------------------------------------

Players.PlayerAdded:Connect(function()
	if playerListOpen then
		refreshPlayerList()
	end
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
	if selectedTarget == leavingPlayer then
		selectedTarget = nil
		playerSelect.Text = "SELECT PLAYER"

		targetStatus.Text =
			"TARGET  •  LEFT"

		targetStatus.TextColor3 =
			Color3.fromRGB(255, 125, 145)
	end

	if playerListOpen then
		refreshPlayerList()
	end
end)

--------------------------------------------------
-- CAMERA TRACKING
--------------------------------------------------

RunService:BindToRenderStep(
	"OldShiftLockTracker",
	Enum.RenderPriority.Camera.Value + 1,
	function(dt)

		-- Roblox Shift Lock uses LockCenter.
		local locked =
			UserInputService.MouseBehavior
			== Enum.MouseBehavior.LockCenter

		if locked ~= shiftLockActive then
			shiftLockActive = locked
			updateLockVisual(locked)
		end

		-- No Shift Lock = NO TRACKING.
		if not locked then
			return
		end

		if not selectedTarget then
			return
		end

		local targetPart = getAimPart()

		if not targetPart then
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
	end
)

--------------------------------------------------
-- MENU
--------------------------------------------------

UserInputService.InputBegan:Connect(function(inputObject, processed)
	if processed then
		return
	end

	if inputObject.KeyCode == MENU_KEY then
		menuOpen = not menuOpen

		if menuOpen then
			frame.Visible = true
			uiScale.Scale = 0.93

			tween(uiScale, 0.14, {
				Scale = 1
			})
		else
			if playerListOpen then
				closePlayerList()
			end

			tween(uiScale, 0.1, {
				Scale = 0.94
			})

			task.delay(0.1, function()
				if not menuOpen then
					frame.Visible = false
				end
			end)
		end
	end
end)

--------------------------------------------------
-- DRAG UI
--------------------------------------------------

local dragging = false
local dragStart = nil
local startingPosition = nil

header.InputBegan:Connect(function(inputObject)
	if inputObject.UserInputType
		== Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = inputObject.Position
		startingPosition = frame.Position
	end
end)

UserInputService.InputChanged:Connect(function(inputObject)
	if dragging
		and inputObject.UserInputType
		== Enum.UserInputType.MouseMovement then

		local delta =
			inputObject.Position - dragStart

		frame.Position = UDim2.new(
			startingPosition.X.Scale,
			startingPosition.X.Offset + delta.X,
			startingPosition.Y.Scale,
			startingPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(inputObject)
	if inputObject.UserInputType
		== Enum.UserInputType.MouseButton1 then

		dragging = false
	end
end)

--------------------------------------------------
-- CLEANUP
--------------------------------------------------

gui.AncestryChanged:Connect(function(_, parent)
	if not parent then
		RunService:UnbindFromRenderStep(
			"OldShiftLockTracker"
		)
	end
end)
