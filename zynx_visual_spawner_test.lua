-- VISUAL SPAWNER V3
-- Roblox Studio prototype
-- StarterPlayer > StarterPlayerScripts > LocalScript

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("VisualSpawner")
if old then
	old:Destroy()
end

--==================================================
-- COLORS
--==================================================

local BG = Color3.fromRGB(12, 9, 18)
local PANEL = Color3.fromRGB(21, 16, 30)
local CARD = Color3.fromRGB(30, 23, 43)

local PURPLE = Color3.fromRGB(155, 82, 255)
local TEXT = Color3.fromRGB(245, 241, 255)
local MUTED = Color3.fromRGB(160, 148, 180)

local GREEN = Color3.fromRGB(100, 230, 170)
local RED = Color3.fromRGB(245, 100, 120)

--==================================================
-- PETS
--==================================================

local PETS = {
	"Shadow Dragon",
	"Frost Dragon",
	"Bat Dragon",
	"Giraffe",
	"Owl",
	"Parrot",
	"Crow",
	"Evil Unicorn",
	"Arctic Reindeer",
	"Turtle",
	"Kangaroo",
	"Unicorn",
	"Dragon",
	"Phoenix",
	"Dodo",
	"T-Rex",
	"Cerberus",
	"Axolotl",
	"Shark",
	"Octopus",
	"Queen Bee",
	"King Bee",
	"Golden Penguin"
}

table.sort(PETS)

--==================================================
-- HELPERS
--==================================================

local function create(class, properties, parent)
	local object = Instance.new(class)

	for property, value in pairs(properties or {}) do
		object[property] = value
	end

	if parent then
		object.Parent = parent
	end

	return object
end

local function round(object, amount)
	create("UICorner", {
		CornerRadius = UDim.new(0, amount or 8)
	}, object)
end

local function outline(object, transparency)
	create("UIStroke", {
		Color = PURPLE,
		Thickness = 1,
		Transparency = transparency or 0.7
	}, object)
end

local function makeButton(parent, text)
	local button = create("TextButton", {
		BackgroundColor3 = CARD,
		BorderSizePixel = 0,

		Text = text,
		TextColor3 = MUTED,

		TextSize = 11,
		Font = Enum.Font.GothamBold,

		AutoButtonColor = false
	}, parent)

	round(button, 8)
	outline(button, 0.75)

	return button
end

local function makeLabel(parent, text, size, position, textSize)
	return create("TextLabel", {
		BackgroundTransparency = 1,

		Size = size,
		Position = position,

		Text = text,
		TextColor3 = TEXT,

		TextSize = textSize or 12,
		Font = Enum.Font.GothamMedium,

		TextXAlignment = Enum.TextXAlignment.Left
	}, parent)
end

--==================================================
-- MAIN GUI
--==================================================

local gui = create("ScreenGui", {
	Name = "VisualSpawner",
	ResetOnSpawn = false
}, playerGui)

local window = create("Frame", {
	Name = "Window",

	Size = UDim2.fromOffset(340, 390),
	Position = UDim2.new(0.5, -170, 0.5, -195),

	BackgroundColor3 = BG,
	BorderSizePixel = 0,

	ClipsDescendants = true
}, gui)

round(window, 14)
outline(window, 0.25)

--==================================================
-- TOP BAR
--==================================================

local topBar = create("Frame", {
	Size = UDim2.new(1, 0, 0, 46),

	BackgroundTransparency = 1,

	Active = true
}, window)

local title = makeLabel(
	topBar,
	"VISUAL SPAWNER",
	UDim2.new(1, -60, 1, 0),
	UDim2.fromOffset(15, 0),
	14
)

title.Font = Enum.Font.GothamBold

local close = makeButton(topBar, "×")

close.Size = UDim2.fromOffset(28, 28)
close.Position = UDim2.new(1, -38, 0.5, -14)

close.TextSize = 18

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

--==================================================
-- DRAG WINDOW
--==================================================

local dragging = false
local dragStart
local startPosition

topBar.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = true

		dragStart = input.Position
		startPosition = window.Position
	end
end)

UIS.InputChanged:Connect(function(input)

	if dragging
		and input.UserInputType == Enum.UserInputType.MouseMovement then

		local difference = input.Position - dragStart

		window.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + difference.X,

			startPosition.Y.Scale,
			startPosition.Y.Offset + difference.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

--==================================================
-- RESIZE HANDLE
--==================================================

local resizeHandle = create("TextButton", {

	Size = UDim2.fromOffset(24, 24),

	Position = UDim2.new(
		1,
		-24,
		1,
		-24
	),

	BackgroundTransparency = 1,

	Text = "◢",

	TextColor3 = PURPLE,

	TextSize = 17,

	Font = Enum.Font.GothamBold,

	AutoButtonColor = false

}, window)

resizeHandle.ZIndex = 50

local resizing = false

local resizeStart
local originalSize

resizeHandle.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then

		resizing = true

		resizeStart = input.Position

		originalSize = window.AbsoluteSize
	end
end)

UIS.InputChanged:Connect(function(input)

	if resizing
		and input.UserInputType == Enum.UserInputType.MouseMovement then

		local difference =
			input.Position - resizeStart

		local newWidth =
			math.clamp(
				originalSize.X + difference.X,
				250,
				650
			)

		local newHeight =
			math.clamp(
				originalSize.Y + difference.Y,
				270,
				650
			)

		window.Size =
			UDim2.fromOffset(
				newWidth,
				newHeight
			)
	end
end)

UIS.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = false
	end
end)

--==================================================
-- CONTENT
--==================================================

local content = create("Frame", {

	Size = UDim2.new(
		1,
		-22,
		1,
		-60
	),

	Position = UDim2.fromOffset(
		11,
		48
	),

	BackgroundTransparency = 1

}, window)

--==================================================
-- TABS
--==================================================

local tabs = create("Frame", {

	Size = UDim2.new(
		1,
		0,
		0,
		36
	),

	BackgroundColor3 = PANEL,

	BorderSizePixel = 0

}, content)

round(tabs, 9)

local petsTab =
	makeButton(
		tabs,
		"PETS"
	)

petsTab.Size =
	UDim2.new(
		0.5,
		-5,
		1,
		-8
	)

petsTab.Position =
	UDim2.fromOffset(
		4,
		4
	)

local playersTab =
	makeButton(
		tabs,
		"PLAYERS"
	)

playersTab.Size =
	UDim2.new(
		0.5,
		-5,
		1,
		-8
	)

playersTab.Position =
	UDim2.new(
		0.5,
		1,
		0,
		4
	)

--==================================================
-- PAGES
--==================================================

local pages = create("Frame", {

	Size = UDim2.new(
		1,
		0,
		1,
		-46
	),

	Position =
		UDim2.fromOffset(
			0,
			46
		),

	BackgroundTransparency = 1

}, content)

local petsPage = create("Frame", {

	Size = UDim2.fromScale(1, 1),

	BackgroundTransparency = 1

}, pages)

local playersPage = create("Frame", {

	Size = UDim2.fromScale(1, 1),

	BackgroundTransparency = 1,

	Visible = false

}, pages)

local function switchPage(page)

	local pets =
		page == "pets"

	petsPage.Visible =
		pets

	playersPage.Visible =
		not pets

	petsTab.BackgroundColor3 =
		pets and PURPLE or CARD

	petsTab.TextColor3 =
		pets and TEXT or MUTED

	playersTab.BackgroundColor3 =
		not pets and PURPLE or CARD

	playersTab.TextColor3 =
		not pets and TEXT or MUTED
end

petsTab.MouseButton1Click:Connect(function()
	switchPage("pets")
end)

playersTab.MouseButton1Click:Connect(function()
	switchPage("players")
end)

switchPage("pets")

--==================================================
-- PET SEARCH
--==================================================

local petSearch = create("TextBox", {

	Size =
		UDim2.new(
			1,
			0,
			0,
			38
		),

	BackgroundColor3 = PANEL,

	BorderSizePixel = 0,

	Text = "",

	PlaceholderText =
		"Search pets...",

	TextColor3 = TEXT,

	PlaceholderColor3 =
		MUTED,

	TextSize = 13,

	Font =
		Enum.Font.GothamMedium,

	TextXAlignment =
		Enum.TextXAlignment.Left,

	ClearTextOnFocus = false

}, petsPage)

round(petSearch, 9)
outline(petSearch, 0.75)

create("UIPadding", {

	PaddingLeft =
		UDim.new(
			0,
			12
		)

}, petSearch)

local petList =
	create(
		"ScrollingFrame",
		{

			Size =
			UDim2.new(
				1,
				0,
				1,
				-48
			),

			Position =
			UDim2.fromOffset(
				0,
				48
			),

			BackgroundTransparency = 1,

			BorderSizePixel = 0,

			ScrollBarThickness = 2,

			ScrollBarImageColor3 =
			PURPLE,

			CanvasSize =
			UDim2.new(),

			AutomaticCanvasSize =
			Enum.AutomaticSize.Y

		},

		petsPage
	)

create("UIListLayout", {

	Padding =
		UDim.new(
			0,
			5
		)

}, petList)

--==================================================
-- PET OPTIONS
--==================================================

local petOptions =
	create(
		"Frame",
		{

			Size =
			UDim2.fromScale(
				1,
				1
			),

			BackgroundTransparency = 1,

			Visible = false

		},

		petsPage
	)

local back =
	makeButton(
		petOptions,
		"<"
	)

back.Size =
	UDim2.fromOffset(
		32,
		32
	)

local petTitle =
	makeLabel(
		petOptions,
		"PET",
		UDim2.new(
			1,
			-42,
			0,
			32
		),
		UDim2.fromOffset(
			42,
			0
		),
		15
	)

petTitle.Font =
	Enum.Font.GothamBold

local toggleArea =
	create(
		"Frame",
		{

			Size =
			UDim2.new(
				1,
				0,
				0,
				100
			),

			Position =
			UDim2.fromOffset(
				0,
				48
			),

			BackgroundTransparency = 1

		},

		petOptions
	)

create("UIGridLayout", {

	CellSize =
		UDim2.new(
			0.5,
			-4,
			0,
			44
		),

	CellPadding =
		UDim2.fromOffset(
			8,
			8
		)

}, toggleArea)

local petState = {

	Neon = false,

	Mega = false,

	Fly = false,

	Ride = false

}

local toggleButtons = {}

local function updateToggle(name)

	local button =
		toggleButtons[name]

	if petState[name] then

		button.BackgroundColor3 =
			PURPLE

		button.TextColor3 =
			TEXT

	else

		button.BackgroundColor3 =
			CARD

		button.TextColor3 =
			MUTED
	end
end

for _, name in ipairs({
	"Neon",
	"Mega",
	"Fly",
	"Ride"
	}) do

	local button =
		makeButton(
			toggleArea,
			string.upper(name)
		)

	toggleButtons[name] =
		button

	button.MouseButton1Click:Connect(function()

		petState[name] =
			not petState[name]

		if name == "Neon"
			and petState.Neon then

			petState.Mega =
				false

			updateToggle(
				"Mega"
			)
		end

		if name == "Mega"
			and petState.Mega then

			petState.Neon =
				false

			updateToggle(
				"Neon"
			)
		end

		updateToggle(name)
	end)
end

local spawnPet =
	makeButton(
		petOptions,
		"SPAWN PET"
	)

spawnPet.Size =
	UDim2.new(
		1,
		0,
		0,
		44
	)

spawnPet.Position =
	UDim2.fromOffset(
		0,
		164
	)

spawnPet.BackgroundColor3 =
	PURPLE

spawnPet.TextColor3 =
	TEXT

local petStatus =
	makeLabel(
		petOptions,
		"",
		UDim2.new(
			1,
			0,
			0,
			35
		),
		UDim2.fromOffset(
			0,
			218
		),
		11
	)

local selectedPet

local petButtons = {}

local function selectPet(name)

	selectedPet =
		name

	petTitle.Text =
		string.upper(name)

	petSearch.Visible =
		false

	petList.Visible =
		false

	petOptions.Visible =
		true

	for option in pairs(petState) do

		petState[option] =
			false

		updateToggle(option)
	end

	petStatus.Text =
		""
end

for _, petName in ipairs(PETS) do

	local button =
		makeButton(
			petList,
			petName
		)

	button.Size =
		UDim2.new(
			1,
			-2,
			0,
			38
		)

	button.TextColor3 =
		TEXT

	button.MouseButton1Click:Connect(function()

		selectPet(
			petName
		)
	end)

	petButtons[petName] =
		button
end

petSearch:GetPropertyChangedSignal(
	"Text"
):Connect(function()

	local query =
		string.lower(
			petSearch.Text
		)

	for name, button
		in pairs(petButtons) do

		button.Visible =
			query == ""
			or string.find(
				string.lower(name),
				query,
				1,
				true
			) ~= nil
	end
end)

back.MouseButton1Click:Connect(function()

	petOptions.Visible =
		false

	petSearch.Visible =
		true

	petList.Visible =
		true

	selectedPet =
		nil
end)

spawnPet.MouseButton1Click:Connect(function()

	if not selectedPet then
		return
	end

	petStatus.Text =
		"Added "
		.. selectedPet
		.. " to local visual state."

	petStatus.TextColor3 =
		GREEN

	print(
		"PET:",
		selectedPet,

		"Neon:",
		petState.Neon,

		"Mega:",
		petState.Mega,

		"Fly:",
		petState.Fly,

		"Ride:",
		petState.Ride
	)
end)

--==================================================
-- PLAYERS
--==================================================

local usernameBox =
	create(
		"TextBox",
		{

			Size =
			UDim2.new(
				1,
				-88,
				0,
				38
			),

			BackgroundColor3 =
			PANEL,

			BorderSizePixel = 0,

			Text = "",

			PlaceholderText =
			"Roblox username...",

			TextColor3 =
			TEXT,

			PlaceholderColor3 =
			MUTED,

			TextSize = 13,

			Font =
			Enum.Font.GothamMedium,

			TextXAlignment =
			Enum.TextXAlignment.Left,

			ClearTextOnFocus =
			false

		},

		playersPage
	)

round(usernameBox, 9)
outline(usernameBox, 0.75)

create("UIPadding", {

	PaddingLeft =
		UDim.new(
			0,
			12
		)

}, usernameBox)

local addPlayer =
	makeButton(
		playersPage,
		"ADD"
	)

addPlayer.Size =
	UDim2.fromOffset(
		80,
		38
	)

addPlayer.Position =
	UDim2.new(
		1,
		-80,
		0,
		0
	)

addPlayer.BackgroundColor3 =
	PURPLE

addPlayer.TextColor3 =
	TEXT

local playerStatus =
	makeLabel(
		playersPage,
		"",
		UDim2.new(
			1,
			0,
			0,
			22
		),
		UDim2.fromOffset(
			0,
			43
		),
		10
	)

local playerList =
	create(
		"ScrollingFrame",
		{

			Size =
			UDim2.new(
				1,
				0,
				1,
				-68
			),

			Position =
			UDim2.fromOffset(
				0,
				68
			),

			BackgroundTransparency = 1,

			BorderSizePixel = 0,

			ScrollBarThickness = 2,

			ScrollBarImageColor3 =
			PURPLE,

			CanvasSize =
			UDim2.new(),

			AutomaticCanvasSize =
			Enum.AutomaticSize.Y

		},

		playersPage
	)

create("UIListLayout", {

	Padding =
		UDim.new(
			0,
			7
		)

}, playerList)

local spawnedPlayers = {}

local function getMyRoot()

	local character =
		player.Character

	if not character then
		return nil
	end

	return character:FindFirstChild(
		"HumanoidRootPart"
	)
end

local function makePlayerCard(
	username,
	model
)

	local card =
		create(
			"Frame",
			{

				Size =
				UDim2.new(
					1,
					-2,
					0,
					112
				),

				BackgroundColor3 =
				PANEL,

				BorderSizePixel = 0

			},

			playerList
		)

	round(card, 10)
	outline(card, 0.8)

	local name =
		makeLabel(
			card,
			username,
			UDim2.new(
				1,
				-16,
				0,
				28
			),
			UDim2.fromOffset(
				9,
				5
			),
			13
		)

	name.Font =
		Enum.Font.GothamBold

	local controls =
		create(
			"Frame",
			{

				Size =
				UDim2.new(
					1,
					-16,
					0,
					66
				),

				Position =
				UDim2.fromOffset(
					8,
					38
				),

				BackgroundTransparency = 1

			},

			card
		)

	create("UIGridLayout", {

		CellSize =
			UDim2.new(
				0.25,
				-5,
				0,
				29
			),

		CellPadding =
			UDim2.fromOffset(
				6,
				6
			)

	}, controls)

	local function humanoid()

		return model:FindFirstChildOfClass(
			"Humanoid"
		)
	end

	local function root()

		return model:FindFirstChild(
			"HumanoidRootPart"
		)
	end

	local function action(
		text,
		callback
	)

		local button =
			makeButton(
				controls,
				text
			)

		button.MouseButton1Click:Connect(
			callback
		)
	end

	action("HERE", function()

		local myRoot =
			getMyRoot()

		if myRoot then

			model:PivotTo(
				myRoot.CFrame
					* CFrame.new(
						3,
						0,
						-3
					)
			)
		end
	end)

	action("FOLLOW", function()

		model:SetAttribute(
			"Mode",
			"Follow"
		)

		task.spawn(function()

			while model.Parent
				and model:GetAttribute(
					"Mode"
				) == "Follow" do

				local hum =
					humanoid()

				local myRoot =
					getMyRoot()

				if hum
					and myRoot then

					hum:MoveTo(
						(
							myRoot.CFrame
								* CFrame.new(
									3,
									0,
									3
								)
						).Position
					)
				end

				task.wait(
					0.3
				)
			end
		end)
	end)

	action("JUMP", function()

		local hum =
			humanoid()

		if hum then
			hum.Jump =
				true
		end
	end)

	action("SIT", function()

		local hum =
			humanoid()

		if hum then
			hum.Sit =
				true
		end
	end)

	action("WANDER", function()

		model:SetAttribute(
			"Mode",
			"Wander"
		)

		task.spawn(function()

			while model.Parent
				and model:GetAttribute(
					"Mode"
				) == "Wander" do

				local hum =
					humanoid()

				local rootPart =
					root()

				if hum
					and rootPart then

					hum:MoveTo(
						rootPart.Position
							+ Vector3.new(
								math.random(
									-18,
									18
								),
								0,
								math.random(
									-18,
									18
								)
							)
					)
				end

				task.wait(
					math.random(
						2,
						4
					)
				)
			end
		end)
	end)

	action("STOP", function()

		model:SetAttribute(
			"Mode",
			"Stop"
		)

		local hum =
			humanoid()

		local rootPart =
			root()

		if hum
			and rootPart then

			hum:MoveTo(
				rootPart.Position
			)
		end
	end)

	action("REMOVE", function()

		spawnedPlayers[username] =
			nil

		model:Destroy()

		card:Destroy()
	end)
end

--==================================================
-- ADD PLAYER
--==================================================

addPlayer.MouseButton1Click:Connect(function()

	local username =
		usernameBox.Text

	username =
		username:gsub(
			"^%s+",
			""
		)

	username =
		username:gsub(
			"%s+$",
			""
		)

	if username == "" then

		playerStatus.Text =
			"Enter a username."

		playerStatus.TextColor3 =
			RED

		return
	end

	if spawnedPlayers[username] then

		playerStatus.Text =
			"Player already added."

		playerStatus.TextColor3 =
			RED

		return
	end

	playerStatus.Text =
		"Loading avatar..."

	playerStatus.TextColor3 =
		MUTED

	task.spawn(function()

		local success,
		userId =
			pcall(function()

				return Players:GetUserIdFromNameAsync(
					username
				)
			end)

		if not success then

			playerStatus.Text =
				"Username not found."

			playerStatus.TextColor3 =
				RED

			return
		end

		local descriptionSuccess,
		description =
			pcall(function()

				return Players:GetHumanoidDescriptionFromUserId(
					userId
				)
			end)

		if not descriptionSuccess then

			playerStatus.Text =
				"Avatar failed to load."

			playerStatus.TextColor3 =
				RED

			return
		end

		local modelSuccess,
		model =
			pcall(function()

				return Players:CreateHumanoidModelFromDescription(
					description,
					Enum.HumanoidRigType.R15
				)
			end)

		if not modelSuccess
			or not model then

			playerStatus.Text =
				"Couldn't create player."

			playerStatus.TextColor3 =
				RED

			return
		end

		model.Name =
			"Visual_"
			.. username

		model.Parent =
			workspace

		model:SetAttribute(
			"Mode",
			"Stop"
		)

		local myRoot =
			getMyRoot()

		if myRoot then

			model:PivotTo(
				myRoot.CFrame
					* CFrame.new(
						5,
						0,
						-5
					)
			)
		end

		spawnedPlayers[username] =
			model

		makePlayerCard(
			username,
			model
		)

		playerStatus.Text =
			username
			.. " added."

		playerStatus.TextColor3 =
			GREEN

		usernameBox.Text =
			""
	end)
end)
--==================================================
-- TRADE TAB
-- LOCAL TRADE SIMULATOR
--==================================================

-- Make existing tabs 1/3 width
petsTab.Size = UDim2.new(1/3, -5, 1, -8)

playersTab.Size = UDim2.new(1/3, -5, 1, -8)
playersTab.Position = UDim2.new(1/3, 2, 0, 4)

local tradeTab = makeButton(
	tabs,
	"TRADE"
)

tradeTab.Size = UDim2.new(
	1/3,
	-5,
	1,
	-8
)

tradeTab.Position = UDim2.new(
	2/3,
	1,
	0,
	4
)

local tradePage = create("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Visible = false
}, pages)

-- Replace old page switch
local function switchMainPage(page)

	petsPage.Visible =
		page == "pets"

	playersPage.Visible =
		page == "players"

	tradePage.Visible =
		page == "trade"

	petsTab.BackgroundColor3 =
		page == "pets"
		and PURPLE
		or CARD

	playersTab.BackgroundColor3 =
		page == "players"
		and PURPLE
		or CARD

	tradeTab.BackgroundColor3 =
		page == "trade"
		and PURPLE
		or CARD

	petsTab.TextColor3 =
		page == "pets"
		and TEXT
		or MUTED

	playersTab.TextColor3 =
		page == "players"
		and TEXT
		or MUTED

	tradeTab.TextColor3 =
		page == "trade"
		and TEXT
		or MUTED
end

-- Override button behavior
petsTab.MouseButton1Click:Connect(function()
	switchMainPage("pets")
end)

playersTab.MouseButton1Click:Connect(function()
	switchMainPage("players")
end)

tradeTab.MouseButton1Click:Connect(function()
	switchMainPage("trade")
end)

--==================================================
-- TRADE DATA
--==================================================

local tradeData = {

	target = nil,

	yourPet = nil,

	theirPet = nil,

	requiredPet = nil,

	yourAccepted = false,

	theirAccepted = false,

	acceptMode = "Required"
}

--==================================================
-- TARGET PLAYER
--==================================================

local targetButton =
	makeButton(
		tradePage,
		"SELECT PLAYER"
	)

targetButton.Size =
	UDim2.new(
		1,
		0,
		0,
		36
	)

local playerSelector =
	create(
		"Frame",
		{
			Size =
			UDim2.new(
				1,
				0,
				0,
				0
			),

			Position =
			UDim2.fromOffset(
				0,
				41
			),

			BackgroundColor3 =
			PANEL,

			BorderSizePixel = 0,

			Visible = false,

			ClipsDescendants = true,

			ZIndex = 20
		},
		tradePage
	)

round(playerSelector, 8)
outline(playerSelector, 0.7)

local playerSelectorLayout =
	create(
		"UIListLayout",
		{
			Padding =
			UDim.new(
				0,
				4
			)
		},
		playerSelector
	)

local function refreshTradePlayers()

	for _, object
		in ipairs(
			playerSelector:GetChildren()
		) do

		if object:IsA(
			"TextButton"
			) then
			object:Destroy()
		end
	end

	local count = 0

	for username
		in pairs(
			spawnedPlayers
		) do

		count += 1

		local name =
			username

		local button =
			makeButton(
				playerSelector,
				name
			)

		button.Size =
			UDim2.new(
				1,
				-8,
				0,
				30
			)

		button.ZIndex = 21

		button.MouseButton1Click:Connect(
			function()

				tradeData.target =
					name

				targetButton.Text =
					"TRADING WITH: "
					.. name

				playerSelector.Visible =
					false
			end
		)
	end

	playerSelector.Size =
		UDim2.new(
			1,
			0,
			0,
			math.min(
				count * 34 + 8,
				150
			)
		)
end

targetButton.MouseButton1Click:Connect(
	function()

		refreshTradePlayers()

		playerSelector.Visible =
			not playerSelector.Visible
	end
)

--==================================================
-- OFFERS
--==================================================

local offerArea =
	create(
		"Frame",
		{
			Size =
			UDim2.new(
				1,
				0,
				0,
				105
			),

			Position =
			UDim2.fromOffset(
				0,
				47
			),

			BackgroundTransparency = 1
		},
		tradePage
	)

local yourOffer =
	create(
		"Frame",
		{
			Size =
			UDim2.new(
				0.5,
				-4,
				1,
				0
			),

			BackgroundColor3 =
			PANEL,

			BorderSizePixel = 0
		},
		offerArea
	)

round(yourOffer, 9)
outline(yourOffer, 0.8)

local theirOffer =
	create(
		"Frame",
		{
			Size =
			UDim2.new(
				0.5,
				-4,
				1,
				0
			),

			Position =
			UDim2.new(
				0.5,
				4,
				0,
				0
			),

			BackgroundColor3 =
			PANEL,

			BorderSizePixel = 0
		},
		offerArea
	)

round(theirOffer, 9)
outline(theirOffer, 0.8)

local yourTitle =
	makeLabel(
		yourOffer,
		"YOUR OFFER",
		UDim2.new(
			1,
			-12,
			0,
			25
		),
		UDim2.fromOffset(
			8,
			5
		),
		10
	)

yourTitle.Font =
	Enum.Font.GothamBold

local theirTitle =
	makeLabel(
		theirOffer,
		"THEIR OFFER",
		UDim2.new(
			1,
			-12,
			0,
			25
		),
		UDim2.fromOffset(
			8,
			5
		),
		10
	)

theirTitle.Font =
	Enum.Font.GothamBold

local yourPetButton =
	makeButton(
		yourOffer,
		"+ ADD PET"
	)

yourPetButton.Size =
	UDim2.new(
		1,
		-14,
		0,
		48
	)

yourPetButton.Position =
	UDim2.fromOffset(
		7,
		39
	)

local theirPetButton =
	makeButton(
		theirOffer,
		"+ ADD PET"
	)

theirPetButton.Size =
	UDim2.new(
		1,
		-14,
		0,
		48
	)

theirPetButton.Position =
	UDim2.fromOffset(
		7,
		39
	)

--==================================================
-- PET PICKER
--==================================================

local picker =
	create(
		"Frame",
		{
			Size =
			UDim2.new(
				1,
				0,
				1,
				0
			),

			BackgroundColor3 =
			BG,

			BorderSizePixel = 0,

			Visible = false,

			ZIndex = 50
		},
		tradePage
	)

round(picker, 10)
outline(picker, 0.4)

local pickerTitle =
	makeLabel(
		picker,
		"SELECT PET",
		UDim2.new(
			1,
			-50,
			0,
			36
		),
		UDim2.fromOffset(
			12,
			4
		),
		13
	)

pickerTitle.Font =
	Enum.Font.GothamBold

pickerTitle.ZIndex = 51

local pickerClose =
	makeButton(
		picker,
		"×"
	)

pickerClose.Size =
	UDim2.fromOffset(
		28,
		28
	)

pickerClose.Position =
	UDim2.new(
		1,
		-36,
		0,
		6
	)

pickerClose.ZIndex = 51

local pickerSearch =
	create(
		"TextBox",
		{
			Size =
			UDim2.new(
				1,
				-16,
				0,
				34
			),

			Position =
			UDim2.fromOffset(
				8,
				42
			),

			BackgroundColor3 =
			PANEL,

			BorderSizePixel = 0,

			Text = "",

			PlaceholderText =
			"Search pet...",

			TextColor3 =
			TEXT,

			PlaceholderColor3 =
			MUTED,

			TextSize = 12,

			Font =
			Enum.Font.GothamMedium,

			ZIndex = 51
		},
		picker
	)

round(pickerSearch, 8)

local pickerList =
	create(
		"ScrollingFrame",
		{
			Size =
			UDim2.new(
				1,
				-16,
				1,
				-88
			),

			Position =
			UDim2.fromOffset(
				8,
				82
			),

			BackgroundTransparency = 1,

			BorderSizePixel = 0,

			ScrollBarThickness = 2,

			ScrollBarImageColor3 =
			PURPLE,

			CanvasSize =
			UDim2.new(),

			AutomaticCanvasSize =
			Enum.AutomaticSize.Y,

			ZIndex = 51
		},
		picker
	)

create(
	"UIListLayout",
	{
		Padding =
			UDim.new(
				0,
				5
			)
	},
	pickerList
)

local pickerButtons = {}

local pickerMode =
	"your"

local function updateOfferText()

	yourPetButton.Text =
		tradeData.yourPet
		and tradeData.yourPet
		or "+ ADD PET"

	theirPetButton.Text =
		tradeData.theirPet
		and tradeData.theirPet
		or "+ ADD PET"
end

local function chooseTradePet(
	petName
)

	if pickerMode ==
		"your" then

		tradeData.yourPet =
			petName

	elseif pickerMode ==
		"their" then

		tradeData.theirPet =
			petName

	elseif pickerMode ==
		"required" then

		tradeData.requiredPet =
			petName
	end

	updateOfferText()

	picker.Visible =
		false
end

for _, petName
	in ipairs(PETS) do

	local name =
		petName

	local button =
		makeButton(
			pickerList,
			name
		)

	button.Size =
		UDim2.new(
			1,
			-2,
			0,
			34
		)

	button.TextColor3 =
		TEXT

	button.ZIndex = 52

	button.MouseButton1Click:Connect(
		function()

			chooseTradePet(
				name
			)
		end
	)

	pickerButtons[name] =
		button
end

pickerSearch:GetPropertyChangedSignal(
	"Text"
):Connect(function()

	local query =
		string.lower(
			pickerSearch.Text
		)

	for petName,
		button
		in pairs(
			pickerButtons
		) do

		button.Visible =
			query == ""
			or string.find(
				string.lower(
					petName
				),
				query,
				1,
				true
			) ~= nil
	end
end)

pickerClose.MouseButton1Click:Connect(
	function()

		picker.Visible =
			false
	end
)

local function openPicker(mode)

	pickerMode =
		mode

	pickerSearch.Text =
		""

	picker.Visible =
		true
end

yourPetButton.MouseButton1Click:Connect(
	function()

		openPicker(
			"your"
		)
	end
)

theirPetButton.MouseButton1Click:Connect(
	function()

		openPicker(
			"their"
		)
	end
)

--==================================================
-- REQUIRED TRADE
--==================================================

local requiredButton =
	makeButton(
		tradePage,
		"REQUIRED FROM YOU: NONE"
	)

requiredButton.Size =
	UDim2.new(
		1,
		0,
		0,
		34
	)

requiredButton.Position =
	UDim2.fromOffset(
		0,
		162
	)

requiredButton.MouseButton1Click:Connect(
	function()

		openPicker(
			"required"
		)
	end
)

-- Update required text after selecting
local oldChoose =
	chooseTradePet

chooseTradePet =
	function(petName)

		oldChoose(
			petName
		)

		if pickerMode ==
			"required" then

			requiredButton.Text =
			"REQUIRED FROM YOU: "
			.. petName
		end
	end

-- Reconnect picker buttons to new function
for petName,
	button
	in pairs(
		pickerButtons
	) do

	local name =
		petName

	button.MouseButton1Click:Connect(
		function()

			if pickerMode ==
				"required" then

				tradeData.requiredPet =
					name

				requiredButton.Text =
					"REQUIRED FROM YOU: "
					.. name

				picker.Visible =
					false
			end
		end
	)
end

--==================================================
-- FAKE PLAYER ACCEPT MODE
--==================================================

local modeButton =
	makeButton(
		tradePage,
		"THEIR ACCEPT: REQUIRED OFFER"
	)

modeButton.Size =
	UDim2.new(
		1,
		0,
		0,
		34
	)

modeButton.Position =
	UDim2.fromOffset(
		0,
		202
	)

local modes = {
	"Required",
	"Manual",
	"Never"
}

local modeIndex = 1

modeButton.MouseButton1Click:Connect(
	function()

		modeIndex += 1

		if modeIndex >
			#modes then

			modeIndex =
				1
		end

		tradeData.acceptMode =
			modes[
		modeIndex
		]

		if tradeData.acceptMode ==
			"Required" then

			modeButton.Text =
				"THEIR ACCEPT: REQUIRED OFFER"

		elseif tradeData.acceptMode ==
			"Manual" then

			modeButton.Text =
				"THEIR ACCEPT: MANUAL"

		else

			modeButton.Text =
				"THEIR ACCEPT: NEVER"
		end
	end
)

--==================================================
-- ACCEPT
--==================================================

local acceptButton =
	makeButton(
		tradePage,
		"ACCEPT"
	)

acceptButton.Size =
	UDim2.new(
		0.5,
		-4,
		0,
		40
	)

acceptButton.Position =
	UDim2.fromOffset(
		0,
		246
	)

local theirAcceptButton =
	makeButton(
		tradePage,
		"THEY ACCEPT"
	)

theirAcceptButton.Size =
	UDim2.new(
		0.5,
		-4,
		0,
		40
	)

theirAcceptButton.Position =
	UDim2.new(
		0.5,
		4,
		0,
		246
	)

local tradeStatus =
	makeLabel(
		tradePage,
		"",
		UDim2.new(
			1,
			0,
			0,
			28
		),
		UDim2.fromOffset(
			0,
			292
		),
		11
	)

tradeStatus.TextXAlignment =
	Enum.TextXAlignment.Center

local function refreshAccept()

	acceptButton.BackgroundColor3 =
		tradeData.yourAccepted
		and GREEN
		or CARD

	acceptButton.Text =
		tradeData.yourAccepted
		and "ACCEPTED ✓"
		or "ACCEPT"

	theirAcceptButton.BackgroundColor3 =
		tradeData.theirAccepted
		and GREEN
		or CARD

	theirAcceptButton.Text =
		tradeData.theirAccepted
		and "THEY ACCEPTED ✓"
		or "THEY ACCEPT"
end

local function checkTrade()

	if tradeData.acceptMode ==
		"Required" then

		if tradeData.requiredPet
			and tradeData.yourPet ==
			tradeData.requiredPet then

			tradeData.theirAccepted =
				true

		else

			tradeData.theirAccepted =
				false
		end
	end

	refreshAccept()

	if tradeData.yourAccepted
		and tradeData.theirAccepted then

		tradeStatus.Text =
			"BOTH ACCEPTED — CONFIRM TRADE"

		tradeStatus.TextColor3 =
			GREEN
	end
end

acceptButton.MouseButton1Click:Connect(
	function()

		tradeData.yourAccepted =
			not tradeData.yourAccepted

		checkTrade()
	end
)

theirAcceptButton.MouseButton1Click:Connect(
	function()

		if tradeData.acceptMode ~=
			"Manual" then

			tradeStatus.Text =
				"Switch their accept mode to MANUAL."

			tradeStatus.TextColor3 =
				MUTED

			return
		end

		tradeData.theirAccepted =
			not tradeData.theirAccepted

		checkTrade()
	end
)

--==================================================
-- CONFIRM
--==================================================

local confirm =
	makeButton(
		tradePage,
		"CONFIRM TRADE"
	)

confirm.Size =
	UDim2.new(
		1,
		0,
		0,
		40
	)

confirm.Position =
	UDim2.fromOffset(
		0,
		322
	)

confirm.BackgroundColor3 =
	PURPLE

confirm.TextColor3 =
	TEXT

confirm.MouseButton1Click:Connect(
	function()

		if not tradeData.target then

			tradeStatus.Text =
				"Select a player first."

			tradeStatus.TextColor3 =
				RED

			return
		end

		if not tradeData.yourAccepted
			or not tradeData.theirAccepted then

			tradeStatus.Text =
				"Both sides must accept."

			tradeStatus.TextColor3 =
				RED

			return
		end

		tradeStatus.Text =
			"TRADE SUCCESSFUL ✓"

		tradeStatus.TextColor3 =
			GREEN

		print(
			"[LOCAL TRADE]",
			"Target:",
			tradeData.target,
			"Your offer:",
			tradeData.yourPet,
			"Their offer:",
			tradeData.theirPet
		)

		task.delay(
			1.5,
			function()

				tradeData.yourAccepted =
					false

				tradeData.theirAccepted =
					false

				refreshAccept()
			end
		)
	end
)
--==========================================================
-- PLAYERS V2 — HUMANIZED LOCAL CLONES
--==========================================================

local RunService = game:GetService("RunService")

local usernameBox = create("TextBox", {
	Size = UDim2.new(1, -88, 0, 38),
	BackgroundColor3 = PANEL,
	BorderSizePixel = 0,

	Text = "",
	PlaceholderText = "Roblox username...",

	TextColor3 = TEXT,
	PlaceholderColor3 = MUTED,

	TextSize = 13,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left,

	ClearTextOnFocus = false
}, playersPage)

round(usernameBox, 9)
outline(usernameBox, 0.75)

create("UIPadding", {
	PaddingLeft = UDim.new(0, 12)
}, usernameBox)

local addPlayer = makeButton(playersPage, "ADD")

addPlayer.Size = UDim2.fromOffset(80, 38)
addPlayer.Position = UDim2.new(1, -80, 0, 0)
addPlayer.BackgroundColor3 = PURPLE
addPlayer.TextColor3 = TEXT

local playerStatus = makeLabel(
	playersPage,
	"",
	UDim2.new(1, 0, 0, 22),
	UDim2.fromOffset(0, 43),
	10
)

local playerList = create("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, -68),
	Position = UDim2.fromOffset(0, 68),

	BackgroundTransparency = 1,
	BorderSizePixel = 0,

	ScrollBarThickness = 2,
	ScrollBarImageColor3 = PURPLE,

	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y
}, playersPage)

create("UIListLayout", {
	Padding = UDim.new(0, 7)
}, playerList)

-- Keep this name because the TRADE patch uses it.
local spawnedPlayers = {}

--==========================================================
-- CHARACTER HELPERS
--==========================================================

local function getMyRoot()

	local character = player.Character

	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(model)
	return model and model:FindFirstChildOfClass("Humanoid")
end

local function getRoot(model)
	return model and model:FindFirstChild("HumanoidRootPart")
end

local function stopMovement(model)

	if not model then
		return
	end

	model:SetAttribute("Mode", "Idle")

	local humanoid = getHumanoid(model)
	local root = getRoot(model)

	if humanoid and root then

		humanoid.WalkSpeed = 16

		humanoid:MoveTo(
			root.Position
		)
	end
end

--==========================================================
-- ANIMATIONS
--==========================================================

local function installAnimations(model)

	-- Humanoid characters normally need an Animate controller.
	-- For our local dummy, copy the local player's standard Animate
	-- controller when available.

	local character = player.Character

	if not character then
		return
	end

	local sourceAnimate =
		character:FindFirstChild("Animate")

	if not sourceAnimate then
		return
	end

	local old =
		model:FindFirstChild("Animate")

	if old then
		old:Destroy()
	end

	local animate =
		sourceAnimate:Clone()

	animate.Parent =
		model

	-- LocalScripts cloned into a workspace dummy don't behave exactly
	-- like they do inside the real player's Character, so below we also
	-- keep a fallback movement animation controller.
end

--==========================================================
-- FALLBACK ANIMATION CONTROLLER
--==========================================================

local function setupMovementAnimations(model)

	local humanoid =
		getHumanoid(model)

	if not humanoid then
		return
	end

	local animator =
		humanoid:FindFirstChildOfClass(
			"Animator"
		)

	if not animator then

		animator =
			Instance.new("Animator")

		animator.Parent =
			humanoid
	end

	-- Roblox's standard R15 animation assets.
	local animationIds = {

		Idle1 =
			"rbxassetid://507766666",

		Idle2 =
			"rbxassetid://507766951",

		Walk =
			"rbxassetid://507777826",

		Run =
			"rbxassetid://507767714",

		Jump =
			"rbxassetid://507765000",

		Fall =
			"rbxassetid://507767968"
	}

	local tracks = {}

	local function loadTrack(
		name,
		id,
		priority,
		looped
	)

		local animation =
			Instance.new("Animation")

		animation.AnimationId =
			id

		local track =
			animator:LoadAnimation(
				animation
			)

		track.Priority =
			priority

		track.Looped =
			looped

		tracks[name] =
			track

		return track
	end

	loadTrack(
		"Idle1",
		animationIds.Idle1,
		Enum.AnimationPriority.Idle,
		true
	)

	loadTrack(
		"Idle2",
		animationIds.Idle2,
		Enum.AnimationPriority.Idle,
		true
	)

	loadTrack(
		"Walk",
		animationIds.Walk,
		Enum.AnimationPriority.Movement,
		true
	)

	loadTrack(
		"Run",
		animationIds.Run,
		Enum.AnimationPriority.Movement,
		true
	)

	loadTrack(
		"Jump",
		animationIds.Jump,
		Enum.AnimationPriority.Action,
		false
	)

	loadTrack(
		"Fall",
		animationIds.Fall,
		Enum.AnimationPriority.Movement,
		true
	)

	local currentMovement =
		nil

	local currentIdle =
		nil

	local function stopTrack(track)

		if track
			and track.IsPlaying then

			track:Stop(0.18)
		end
	end

	local function playIdle()

		if currentMovement then

			stopTrack(
				currentMovement
			)

			currentMovement =
				nil
		end

		if currentIdle
			and currentIdle.IsPlaying then
			return
		end

		-- Sometimes use the alternate idle.
		if math.random() < 0.25 then

			currentIdle =
				tracks.Idle2

		else

			currentIdle =
				tracks.Idle1
		end

		currentIdle:Play(
			0.25
		)
	end

	local function playWalk(speed)

		stopTrack(
			currentIdle
		)

		currentIdle =
			nil

		local wantedTrack

		if speed > 18 then

			wantedTrack =
				tracks.Run

		else

			wantedTrack =
				tracks.Walk
		end

		if currentMovement
			~= wantedTrack then

			stopTrack(
				currentMovement
			)

			currentMovement =
				wantedTrack

			currentMovement:Play(
				0.18
			)
		end

		if currentMovement then

			if wantedTrack ==
				tracks.Walk then

				currentMovement:AdjustSpeed(
					math.clamp(
						speed / 16,
						0.75,
						1.25
					)
				)

			else

				currentMovement:AdjustSpeed(
					math.clamp(
						speed / 20,
						0.8,
						1.3
					)
				)
			end
		end
	end

	humanoid.Running:Connect(
		function(speed)

			if speed >
				0.75 then

				playWalk(
					humanoid.WalkSpeed
				)

			else

				playIdle()
			end
		end
	)

	humanoid.StateChanged:Connect(
		function(_, state)

			if state ==
				Enum.HumanoidStateType.Jumping then

				tracks.Jump:Play(
					0.12
				)

			elseif state ==
				Enum.HumanoidStateType.Freefall then

				if not tracks.Fall.IsPlaying then

					tracks.Fall:Play(
						0.2
					)
				end

			elseif state ==
				Enum.HumanoidStateType.Landed
				or state ==
				Enum.HumanoidStateType.Running then

				stopTrack(
					tracks.Fall
				)
			end
		end
	)

	playIdle()

	return tracks
end

--==========================================================
-- HUMANIZED WANDERING
--==========================================================

local function startWandering(model)

	model:SetAttribute(
		"Mode",
		"Wander"
	)

	task.spawn(function()

		local humanoid =
			getHumanoid(model)

		while model.Parent
			and model:GetAttribute("Mode")
			== "Wander" do

			local root =
				getRoot(model)

			if not humanoid
				or not root then
				break
			end

			-- Humans don't constantly move.
			local pause =
				math.random(
					8,
					30
				) / 10

			task.wait(pause)

			if model:GetAttribute("Mode")
				~= "Wander" then
				break
			end

			-- Occasionally stay still for noticeably longer.
			if math.random() <
				0.18 then

				task.wait(
					math.random(
						20,
						55
					) / 10
				)
			end

			if model:GetAttribute("Mode")
				~= "Wander" then
				break
			end

			root =
				getRoot(model)

			if not root then
				break
			end

			-- Mostly short walks.
			local distance

			if math.random() <
				0.75 then

				distance =
					math.random(
						6,
						16
					)

			else

				distance =
					math.random(
						17,
						30
					)
			end

			local angle =
				math.rad(
					math.random(
						0,
						359
					)
				)

			local direction =
				Vector3.new(
					math.cos(angle),
					0,
					math.sin(angle)
				)

			local destination =
				root.Position
				+ direction
				* distance

			-- Usually normal speed.
			humanoid.WalkSpeed =
				math.random(
					14,
					17
				)

			-- Rare little hurry.
			if math.random() <
				0.10 then

				humanoid.WalkSpeed =
					math.random(
						18,
						21
					)
			end

			humanoid:MoveTo(
				destination
			)

			-- Wait for arrival, but don't lock forever.
			local finished =
				false

			local connection

			connection =
				humanoid.MoveToFinished:Connect(
					function()

						finished =
						true
					end
				)

			local started =
				os.clock()

			while not finished
				and os.clock() - started
				< 8
				and model.Parent
				and model:GetAttribute("Mode")
				== "Wander" do

				task.wait(
					0.1
				)
			end

			connection:Disconnect()

			-- Very occasional jump.
			if math.random() <
				0.07 then

				humanoid.Jump =
					true
			end
		end

		if humanoid then

			humanoid.WalkSpeed =
				16
		end
	end)
end

--==========================================================
-- BETTER FOLLOW
--==========================================================

local function startFollowing(model)

	model:SetAttribute(
		"Mode",
		"Follow"
	)

	task.spawn(function()

		local humanoid =
			getHumanoid(model)

		while model.Parent
			and model:GetAttribute("Mode")
			== "Follow" do

			local root =
				getRoot(model)

			local target =
				getMyRoot()

			if not humanoid
				or not root
				or not target then

				task.wait(
					0.3
				)

				continue
			end

			local distance =
				(
					root.Position
					- target.Position
				).Magnitude

			if distance >
				18 then

				-- Catch up.
				humanoid.WalkSpeed =
					20

			else

				humanoid.WalkSpeed =
					16
			end

			if distance >
				7 then

				-- Follow slightly behind rather than
				-- walking into the player.

				local targetPosition =
					(
						target.CFrame
						* CFrame.new(
							3,
							0,
							4
						)
					).Position

				humanoid:MoveTo(
					targetPosition
				)

			elseif distance <
				4.5 then

				humanoid:MoveTo(
					root.Position
				)
			end

			task.wait(
				math.random(
					20,
					38
				) / 100
			)
		end

		if humanoid then

			humanoid.WalkSpeed =
				16
		end
	end)
end

--==========================================================
-- PLAYER CARD
--==========================================================

local function makePlayerCard(
	username,
	displayName,
	model
)

	local card =
		create("Frame", {

			Size =
			UDim2.new(
				1,
				-2,
				0,
				130
			),

			BackgroundColor3 =
			PANEL,

			BorderSizePixel =
			0

		}, playerList)

	round(card, 10)
	outline(card, 0.8)

	local display =
		makeLabel(
			card,
			displayName,
			UDim2.new(
				1,
				-16,
				0,
				22
			),
			UDim2.fromOffset(
				9,
				5
			),
			13
		)

	display.Font =
		Enum.Font.GothamBold

	local usernameLabel =
		makeLabel(
			card,
			"@" .. username,
			UDim2.new(
				1,
				-16,
				0,
				18
			),
			UDim2.fromOffset(
				9,
				25
			),
			10
		)

	usernameLabel.TextColor3 =
		MUTED

	local controls =
		create("Frame", {

			Size =
			UDim2.new(
				1,
				-16,
				0,
				72
			),

			Position =
			UDim2.fromOffset(
				8,
				49
			),

			BackgroundTransparency =
			1

		}, card)

	create("UIGridLayout", {

		CellSize =
			UDim2.new(
				0.25,
				-5,
				0,
				31
			),

		CellPadding =
			UDim2.fromOffset(
				6,
				6
			)

	}, controls)

	local function action(
		name,
		callback
	)

		local button =
			makeButton(
				controls,
				name
			)

		button.MouseButton1Click:Connect(
			callback
		)
	end

	action("HERE", function()

		stopMovement(model)

		local target =
			getMyRoot()

		if target then

			model:PivotTo(
				target.CFrame
					* CFrame.new(
						4,
						0,
						-4
					)
			)
		end
	end)

	action("FOLLOW", function()

		startFollowing(
			model
		)
	end)

	action("WANDER", function()

		startWandering(
			model
		)
	end)

	action("JUMP", function()

		local humanoid =
			getHumanoid(model)

		if humanoid then

			humanoid.Jump =
				true
		end
	end)

	action("SIT", function()

		stopMovement(model)

		local humanoid =
			getHumanoid(model)

		if humanoid then

			humanoid.Sit =
				true
		end
	end)

	action("STOP", function()

		stopMovement(
			model
		)
	end)

	action("REMOVE", function()

		spawnedPlayers[username] =
			nil

		model:Destroy()
		card:Destroy()
	end)
end

--==========================================================
-- ADD REAL ACCOUNT APPEARANCE
--==========================================================

addPlayer.MouseButton1Click:Connect(function()

	local username =
		usernameBox.Text

	username =
		username:gsub(
			"^%s+",
			""
		):gsub(
		"%s+$",
		""
	)

	if username == "" then

		playerStatus.Text =
			"Enter a username."

		playerStatus.TextColor3 =
			RED

		return
	end

	if spawnedPlayers[username] then

		playerStatus.Text =
			"Already added."

		playerStatus.TextColor3 =
			RED

		return
	end

	playerStatus.Text =
		"Loading @" .. username .. "..."

	playerStatus.TextColor3 =
		MUTED

	task.spawn(function()

		-- Resolve real Roblox account.
		local success,
		userId =
			pcall(function()

				return Players:GetUserIdFromNameAsync(
					username
				)
			end)

		if not success then

			playerStatus.Text =
				"Username not found."

			playerStatus.TextColor3 =
				RED

			return
		end

		-- Grab their current avatar description.
		local descriptionSuccess,
		description =
			pcall(function()

				return Players:GetHumanoidDescriptionFromUserId(
					userId
				)
			end)

		if not descriptionSuccess then

			playerStatus.Text =
				"Couldn't load avatar."

			playerStatus.TextColor3 =
				RED

			return
		end

		-- Resolve display name as well.
		local displayName =
			username

		local infoSuccess,
		info =
			pcall(function()

				return Players:GetNameFromUserIdAsync(
					userId
				)
			end)

		-- Create the local R15 representation.
		local modelSuccess,
		model =
			pcall(function()

				return Players:CreateHumanoidModelFromDescription(
					description,
					Enum.HumanoidRigType.R15
				)
			end)

		if not modelSuccess
			or not model then

			playerStatus.Text =
				"Couldn't create avatar."

			playerStatus.TextColor3 =
				RED

			return
		end

		-- Humanoid.DisplayName normally comes from the
		-- avatar model information when available.
		local humanoid =
			getHumanoid(model)

		if humanoid
			and humanoid.DisplayName ~= "" then

			displayName =
				humanoid.DisplayName
		end

		-- Keep the model itself named as the real username
		model.Name = username

		local humanoid = model:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.DisplayName = displayName
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
			humanoid.NameDisplayDistance = 100
			humanoid.HealthDisplayDistance = 0
		end

		model.Parent =
			workspace

		model:SetAttribute(
			"Mode",
			"Idle"
		)

		if humanoid then

			humanoid.WalkSpeed =
				16

			humanoid.AutoRotate =
				true

			humanoid.DisplayDistanceType =
				Enum.HumanoidDisplayDistanceType.Viewer
		end

		local myRoot =
			getMyRoot()

		if myRoot then

			model:PivotTo(
				myRoot.CFrame
					* CFrame.new(
						5,
						0,
						-5
					)
			)
		end

		installAnimations(
			model
		)

		setupMovementAnimations(
			model
		)

		spawnedPlayers[username] =
			model

		makePlayerCard(
			username,
			displayName,
			model
		)

		playerStatus.Text =
			displayName
			.. " added."

		playerStatus.TextColor3 =
			GREEN

		usernameBox.Text =
			""
	end)
end)
