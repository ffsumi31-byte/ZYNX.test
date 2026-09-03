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

for _, guiName in ipairs({
	"StudioTracker",
	"VisualTrackerTest",
	"TargetVisual"
}) do
	local old = playerGui:FindFirstChild(guiName)
	if old then
		old:Destroy()
	end
end

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local MENU_KEY = Enum.KeyCode.Semicolon
local AIM_KEY = Enum.KeyCode.T

local TOGGLE_MODE = true
local USE_SMOOTHING = false
local TRACK_SPEED = 40

local PANEL_WIDTH = 290

local CLOSED_HEIGHT = 236
local OPEN_HEIGHT = 340

local CLOSED_TARGET_Y = 103
local OPEN_TARGET_Y = 207

local CLOSED_BUTTON_Y = 143
local OPEN_BUTTON_Y = 247

local CLOSED_HINT_Y = 188
local OPEN_HINT_Y = 292

local TRACK_BIND_NAME = "StudioTrackerCamera"

--------------------------------------------------
-- STATE
--------------------------------------------------

local selectedTarget = nil

local aimEnabled = false
local menuOpen = true

local waitingForKeybind = false
local playerListOpen = false
local menuAnimating = false

--------------------------------------------------
-- TWEEN
--------------------------------------------------

local function tween(object, duration, properties)
	local info = TweenInfo.new(
		duration,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	local animation = TweenService:Create(
		object,
		info,
		properties
	)

	animation:Play()
	return animation
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
-- MAIN FRAME
--------------------------------------------------

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(PANEL_WIDTH, CLOSED_HEIGHT)
frame.Position = UDim2.new(
	0.5,
	-PANEL_WIDTH / 2,
	0.5,
	-CLOSED_HEIGHT / 2
)
frame.BackgroundColor3 = Color3.fromRGB(15, 14, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 13)
frameCorner.Parent = frame

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

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 13)
headerCorner.Parent = header

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

local accentCorner = Instance.new("UICorner")
accentCorner.CornerRadius = UDim.new(1, 0)
accentCorner.Parent = accent

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
subtitle.Text = "Studio tracking test"
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

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = statusDot

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

local playerSelectCorner = Instance.new("UICorner")
playerSelectCorner.CornerRadius = UDim.new(0, 8)
playerSelectCorner.Parent = playerSelect

--------------------------------------------------
-- PLAYER LIST
--------------------------------------------------

local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, -24, 0, 0)
playerList.Position = UDim2.fromOffset(12, 96)
playerList.BackgroundColor3 = Color3.fromRGB(21, 19, 28)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 3
playerList.ScrollBarImageColor3 = Color3.fromRGB(145, 82, 220)
playerList.CanvasSize = UDim2.new()
playerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerList.ClipsDescendants = true
playerList.Visible = false
playerList.ZIndex = 20
playerList.Parent = frame

local playerListCorner = Instance.new("UICorner")
playerListCorner.CornerRadius = UDim.new(0, 8)
playerListCorner.Parent = playerList

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
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
targetStatus.Position = UDim2.fromOffset(12, CLOSED_TARGET_Y)
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

local targetCorner = Instance.new("UICorner")
targetCorner.CornerRadius = UDim.new(0, 8)
targetCorner.Parent = targetStatus

--------------------------------------------------
-- TRACKING STATUS
--------------------------------------------------

local aimStatus = Instance.new("TextLabel")
aimStatus.Size = UDim2.fromOffset(86, 29)
aimStatus.Position = UDim2.fromOffset(192, CLOSED_TARGET_Y)
aimStatus.BackgroundColor3 = Color3.fromRGB(24, 22, 31)
aimStatus.BorderSizePixel = 0
aimStatus.Text = "OFF"
aimStatus.TextColor3 = Color3.fromRGB(145, 140, 155)
aimStatus.Font = Enum.Font.GothamBold
aimStatus.TextSize = 10
aimStatus.Parent = frame

local aimCorner = Instance.new("UICorner")
aimCorner.CornerRadius = UDim.new(0, 8)
aimCorner.Parent = aimStatus

--------------------------------------------------
-- CLEAR BUTTON
--------------------------------------------------

local clearButton = Instance.new("TextButton")
clearButton.Size = UDim2.fromOffset(128, 34)
clearButton.Position = UDim2.fromOffset(12, CLOSED_BUTTON_Y)
clearButton.BackgroundColor3 = Color3.fromRGB(31, 28, 39)
clearButton.BorderSizePixel = 0
clearButton.Text = "CLEAR TARGET"
clearButton.TextColor3 = Color3.fromRGB(175, 168, 190)
clearButton.Font = Enum.Font.GothamBold
clearButton.TextSize = 10
clearButton.AutoButtonColor = false
clearButton.Parent = frame

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 8)
clearCorner.Parent = clearButton

--------------------------------------------------
-- KEYBIND BUTTON
--------------------------------------------------

local keybindButton = Instance.new("TextButton")
keybindButton.Size = UDim2.fromOffset(128, 34)
keybindButton.Position = UDim2.fromOffset(150, CLOSED_BUTTON_Y)
keybindButton.BackgroundColor3 = Color3.fromRGB(31, 27, 42)
keybindButton.BorderSizePixel = 0
keybindButton.Text = "KEY  " .. AIM_KEY.Name
keybindButton.TextColor3 = Color3.fromRGB(205, 195, 220)
keybindButton.Font = Enum.Font.GothamBold
keybindButton.TextSize = 10
keybindButton.AutoButtonColor = false
keybindButton.Parent = frame

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 8)
keyCorner.Parent = keybindButton

--------------------------------------------------
-- HINT
--------------------------------------------------

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, -24, 0, 30)
hint.Position = UDim2.fromOffset(12, CLOSED_HINT_Y)
hint.BackgroundColor3 = Color3.fromRGB(22, 20, 29)
hint.BorderSizePixel = 0
hint.Text = ";   SHOW / HIDE"
hint.TextColor3 = Color3.fromRGB(120, 113, 138)
hint.Font = Enum.Font.GothamMedium
hint.TextSize = 9
hint.Parent = frame

local hintCorner = Instance.new("UICorner")
hintCorner.CornerRadius = UDim.new(0, 8)
hintCorner.Parent = hint

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
-- TRACKING VISUAL
--------------------------------------------------

local trackingVisualVersion = 0

local function setTrackingVisual(enabled)
	trackingVisualVersion += 1

	local version = trackingVisualVersion

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
			if version ~= trackingVisualVersion then
				return
			end

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
			BackgroundColor3 = Color3.fromRGB(105, 100, 115),
			Size = UDim2.fromOffset(7, 7)
		})
	end
end

--------------------------------------------------
-- CHARACTER / TARGET HELPERS
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

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.Health <= 0 then
		return nil
	end

	return character:FindFirstChild("Head")
		or character:FindFirstChild("HumanoidRootPart")
end

--------------------------------------------------
-- CAMERA TRACKING
--------------------------------------------------

local function updateCamera(dt)
	if not aimEnabled then
		return
	end

	if not selectedTarget then
		return
	end

	local targetPart = getAimPart()

	if not targetPart then
		aimStatus.Text = "WAIT"
		aimStatus.TextColor3 = Color3.fromRGB(255, 190, 100)
		return
	end

	if aimStatus.Text == "WAIT" then
		setTrackingVisual(true)
	end

	local desiredCamera = CFrame.lookAt(
		camera.CFrame.Position,
		targetPart.Position
	)

	if USE_SMOOTHING then
		local alpha = 1 - math.exp(-TRACK_SPEED * dt)

		camera.CFrame = camera.CFrame:Lerp(
			desiredCamera,
			alpha
		)
	else
		camera.CFrame = desiredCamera
	end
end

local function restoreCamera()
	camera.CameraType = Enum.CameraType.Custom

	local character = player.Character

	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			camera.CameraSubject = humanoid
		end
	end
end

local function startTracking()
	if not selectedTarget then
		return
	end

	aimEnabled = true

	setTrackingVisual(true)

	RunService:UnbindFromRenderStep(TRACK_BIND_NAME)

	RunService:BindToRenderStep(
		TRACK_BIND_NAME,
		Enum.RenderPriority.Camera.Value + 1,
		updateCamera
	)
end

local function stopTracking()
	aimEnabled = false

	RunService:UnbindFromRenderStep(TRACK_BIND_NAME)

	setTrackingVisual(false)

	restoreCamera()
end

--------------------------------------------------
-- CLOSE PLAYER LIST
--------------------------------------------------

local function closePlayerList()
	if not playerListOpen
		and not playerList.Visible then

		return
	end

	playerListOpen = false

	tween(playerList, 0.13, {
		Size = UDim2.new(
			1,
			-24,
			0,
			0
		)
	})

	tween(frame, 0.16, {
		Size = UDim2.fromOffset(
			PANEL_WIDTH,
			CLOSED_HEIGHT
		)
	})

	tween(targetStatus, 0.16, {
		Position = UDim2.fromOffset(
			12,
			CLOSED_TARGET_Y
		)
	})

	tween(aimStatus, 0.16, {
		Position = UDim2.fromOffset(
			192,
			CLOSED_TARGET_Y
		)
	})

	tween(clearButton, 0.16, {
		Position = UDim2.fromOffset(
			12,
			CLOSED_BUTTON_Y
		)
	})

	tween(keybindButton, 0.16, {
		Position = UDim2.fromOffset(
			150,
			CLOSED_BUTTON_Y
		)
	})

	tween(hint, 0.16, {
		Position = UDim2.fromOffset(
			12,
			CLOSED_HINT_Y
		)
	})

	task.delay(0.14, function()
		if not playerListOpen then
			playerList.Visible = false
		end
	end)
end

--------------------------------------------------
-- PLAYER BUTTONS
--------------------------------------------------

local function clearPlayerButtons()
	for _, child in ipairs(playerList:GetChildren()) do
		if child:IsA("TextButton")
			or child.Name == "EmptyLabel" then

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

	button.TextColor3 = Color3.fromRGB(205, 198, 220)
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 10
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.AutoButtonColor = false
	button.ZIndex = 21
	button.Parent = playerList

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 9)
	padding.Parent = button

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = button

	addButtonEffects(
		button,
		Color3.fromRGB(29, 25, 38),
		Color3.fromRGB(44, 34, 57),
		Color3.fromRGB(24, 20, 31)
	)

	button.MouseButton1Click:Connect(function()
		if aimEnabled then
			stopTracking()
		end

		selectedTarget = targetPlayer

		targetStatus.Text =
			"TARGET  •  "
			.. targetPlayer.DisplayName

		targetStatus.TextColor3 =
			Color3.fromRGB(195, 150, 255)

		playerSelect.Text =
			targetPlayer.DisplayName

		closePlayerList()
	end)
end

--------------------------------------------------
-- REFRESH PLAYER LIST
--------------------------------------------------

local function refreshPlayerList()
	clearPlayerButtons()

	local count = 0

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then
			count += 1

			createPlayerButton(
				targetPlayer
			)
		end
	end

	if count == 0 then
		local empty = Instance.new("TextLabel")

		empty.Name = "EmptyLabel"
		empty.Size = UDim2.new(1, 0, 0, 32)
		empty.BackgroundTransparency = 1
		empty.Text = "NO OTHER PLAYERS"
		empty.TextColor3 = Color3.fromRGB(120, 113, 140)
		empty.Font = Enum.Font.GothamMedium
		empty.TextSize = 9
		empty.ZIndex = 21
		empty.Parent = playerList
	end
end

--------------------------------------------------
-- OPEN PLAYER LIST
--------------------------------------------------

local function openPlayerList()
	playerListOpen = true

	refreshPlayerList()

	playerList.Visible = true

	playerList.Size = UDim2.new(
		1,
		-24,
		0,
		0
	)

	tween(frame, 0.16, {
		Size = UDim2.fromOffset(
			PANEL_WIDTH,
			OPEN_HEIGHT
		)
	})

	tween(playerList, 0.16, {
		Size = UDim2.new(
			1,
			-24,
			0,
			100
		)
	})

	tween(targetStatus, 0.16, {
		Position = UDim2.fromOffset(
			12,
			OPEN_TARGET_Y
		)
	})

	tween(aimStatus, 0.16, {
		Position = UDim2.fromOffset(
			192,
			OPEN_TARGET_Y
		)
	})

	tween(clearButton, 0.16, {
		Position = UDim2.fromOffset(
			12,
			OPEN_BUTTON_Y
		)
	})

	tween(keybindButton, 0.16, {
		Position = UDim2.fromOffset(
			150,
			OPEN_BUTTON_Y
		)
	})

	tween(hint, 0.16, {
		Position = UDim2.fromOffset(
			12,
			OPEN_HINT_Y
		)
	})
end

--------------------------------------------------
-- PLAYER SELECT CLICK
--------------------------------------------------

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
		stopTracking()

		selectedTarget = nil

		targetStatus.Text =
			"TARGET  •  LEFT"

		targetStatus.TextColor3 =
			Color3.fromRGB(
				255,
				125,
				145
			)

		playerSelect.Text =
			"SELECT PLAYER"
	end

	if playerListOpen then
		refreshPlayerList()
	end
end)

--------------------------------------------------
-- CLEAR
--------------------------------------------------

clearButton.MouseButton1Click:Connect(function()
	stopTracking()

	selectedTarget = nil

	playerSelect.Text =
		"SELECT PLAYER"

	targetStatus.Text =
		"TARGET  •  NONE"

	targetStatus.TextColor3 =
		Color3.fromRGB(
			150,
			144,
			165
		)
end)

--------------------------------------------------
-- KEYBIND
--------------------------------------------------

keybindButton.MouseButton1Click:Connect(function()
	waitingForKeybind = true

	keybindButton.Text =
		"PRESS KEY..."

	keybindButton.TextColor3 =
		Color3.fromRGB(
			205,
			155,
			255
		)
end)

--------------------------------------------------
-- KEYBOARD
--------------------------------------------------

UserInputService.InputBegan:Connect(
	function(inputObject, processed)

		if waitingForKeybind then
			if inputObject.UserInputType
				== Enum.UserInputType.Keyboard then

				if inputObject.KeyCode
						~= Enum.KeyCode.Unknown
					and inputObject.KeyCode
						~= MENU_KEY then

					AIM_KEY =
						inputObject.KeyCode

					waitingForKeybind =
						false

					keybindButton.Text =
						"KEY  "
						.. AIM_KEY.Name

					keybindButton.TextColor3 =
						Color3.fromRGB(
							205,
							195,
							220
						)
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

		if inputObject.KeyCode
			== MENU_KEY then

			if menuAnimating then
				return
			end

			menuAnimating = true

			menuOpen =
				not menuOpen

			if menuOpen then
				frame.Visible = true

				scale.Scale = 0.93

				tween(
					scale,
					0.14,
					{
						Scale = 1
					}
				)

				task.delay(
					0.14,
					function()
						menuAnimating = false
					end
				)

			else
				if playerListOpen then
					closePlayerList()
				end

				tween(
					scale,
					0.1,
					{
						Scale = 0.94
					}
				)

				task.delay(
					0.1,
					function()

						if not menuOpen then
							frame.Visible = false
						end

						menuAnimating = false
					end
				)
			end

			return
		end

		--------------------------------------------------
		-- TRACK KEY
		--------------------------------------------------

		if inputObject.KeyCode
			== AIM_KEY then

			if not selectedTarget then
				targetStatus.Text =
					"TARGET  •  SELECT ONE"

				targetStatus.TextColor3 =
					Color3.fromRGB(
						255,
						145,
						170
					)

				return
			end

			if TOGGLE_MODE then
				if aimEnabled then
					stopTracking()
				else
					startTracking()
				end
			else
				startTracking()
			end
		end
	end
)

--------------------------------------------------
-- HOLD MODE
--------------------------------------------------

UserInputService.InputEnded:Connect(
	function(inputObject)

		if inputObject.KeyCode
				== AIM_KEY
			and not TOGGLE_MODE then

			stopTracking()
		end
	end
)

--------------------------------------------------
-- DRAG UI
--------------------------------------------------

local dragging = false
local dragStart = nil
local startingPosition = nil

header.InputBegan:Connect(
	function(inputObject)

		if inputObject.UserInputType
			== Enum.UserInputType.MouseButton1 then

			dragging = true

			dragStart =
				inputObject.Position

			startingPosition =
				frame.Position

			tween(
				scale,
				0.07,
				{
					Scale = 0.985
				}
			)
		end
	end
)

UserInputService.InputChanged:Connect(
	function(inputObject)

		if dragging
			and inputObject.UserInputType
				== Enum.UserInputType.MouseMovement then

			local delta =
				inputObject.Position
				- dragStart

			frame.Position =
				UDim2.new(
					startingPosition.X.Scale,
					startingPosition.X.Offset
						+ delta.X,

					startingPosition.Y.Scale,
					startingPosition.Y.Offset
						+ delta.Y
				)
		end
	end
)

UserInputService.InputEnded:Connect(
	function(inputObject)

		if inputObject.UserInputType
				== Enum.UserInputType.MouseButton1
			and dragging then

			dragging = false

			tween(
				scale,
				0.09,
				{
					Scale = 1
				}
			)
		end
	end
)

--------------------------------------------------
-- CHARACTER RESPAWN
--------------------------------------------------

player.CharacterAdded:Connect(function()
	if not aimEnabled then
		task.defer(restoreCamera)
	end
end)

--------------------------------------------------
-- CLEANUP
--------------------------------------------------

gui.AncestryChanged:Connect(function(_, parent)
	if not parent then
		RunService:UnbindFromRenderStep(TRACK_BIND_NAME)
	end
end)
