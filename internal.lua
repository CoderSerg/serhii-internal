local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

local C = {
	Base = Color3.fromHex("#1e1e2e"),
	Mantle = Color3.fromHex("#181825"),
	Crust = Color3.fromHex("#11111b"),
	Surface0 = Color3.fromHex("#313244"),
	Surface1 = Color3.fromHex("#45475a"),
	Surface2 = Color3.fromHex("#585b70"),
	Overlay0 = Color3.fromHex("#6c7086"),
	Text = Color3.fromHex("#cdd6f4"),
	Subtext0 = Color3.fromHex("#a6adc8"),
	Subtext1 = Color3.fromHex("#bac2de"),
	Blue = Color3.fromHex("#89b4fa"),
	Green = Color3.fromHex("#a6e3a1"),
	Yellow = Color3.fromHex("#f9e2af"),
	Red = Color3.fromHex("#f38ba8"),
	Lavender = Color3.fromHex("#b4befe"),
	Mauve = Color3.fromHex("#cba6f7"),
	Peach = Color3.fromHex("#fab387"),
}

local CORNER_RADIUS = UDim.new(0, 8)
local CORNER_RADIUS_SM = UDim.new(0, 6)
local FONT = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
local FONT_BOLD = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
local FONT_MONO = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular)
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_NOTIF = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local Lucide
pcall(function()
	Lucide = loadstring(game:HttpGet("https://github.com/latte-soft/lucide-roblox/releases/latest/download/lucide-roblox.luau", false))()
end)

local function nearestIconSize(s)
	if s <= 16 then return 16
	elseif s <= 24 then return 24
	elseif s <= 48 then return 48
	else return 256 end
end

local function makeIcon(parent, name, size, color)
	local img = Instance.new("ImageLabel")
	img.Size = UDim2.new(0, size, 0, size)
	img.BackgroundTransparency = 1
	img.ImageColor3 = color or C.Text
	img.ResampleMode = Enum.ResamplerMode.Pixelated
	img.Parent = parent

	if Lucide then
		local ok, asset = pcall(Lucide.GetAsset, name, nearestIconSize(size))
		if ok and asset then
			img.Image = asset.Url
			if asset.ImageRectOffset then img.ImageRectOffset = asset.ImageRectOffset end
			if asset.ImageRectSize then img.ImageRectSize = asset.ImageRectSize end
		end
	end

	return img
end

local WORKSPACE_DIR = "serhii-internal"

local tabs = {}
local activeTabId = nil
local tabIdCounter = 0
local minimized = false
local customScripts = {}
local SCRIPTS_FILE = WORKSPACE_DIR .. "/scripts.json"

local function saveScripts()
	pcall(function()
		local data = {}
		for _, scr in customScripts do
			table.insert(data, '{"name":"' .. scr.name:gsub('"', '\\"') .. '","code":"' .. scr.code:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\t', '\\t') .. '"}')
		end
		writefile(SCRIPTS_FILE, "[" .. table.concat(data, ",") .. "]")
	end)
end

local function loadScripts()
	pcall(function()
		if not isfile(SCRIPTS_FILE) then return end
		local raw = readfile(SCRIPTS_FILE)
		local HttpService = game:GetService("HttpService")
		local parsed = HttpService:JSONDecode(raw)
		for _, entry in parsed do
			if entry.name and entry.code then
				table.insert(customScripts, { name = entry.name, code = entry.code })
			end
		end
	end)
end

pcall(function()
	if not isfolder(WORKSPACE_DIR) then
		makefolder(WORKSPACE_DIR)
	end
end)

loadScripts()

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ExecutorUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999

pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then
	screenGui.Parent = player:WaitForChild("PlayerGui")
end

local notifContainer = Instance.new("Frame")
notifContainer.Name = "Notifications"
notifContainer.AnchorPoint = Vector2.new(1, 1)
notifContainer.Size = UDim2.new(0, 280, 0, 400)
notifContainer.Position = UDim2.new(1, -16, 1, -80)
notifContainer.BackgroundTransparency = 1
notifContainer.Parent = screenGui

local notifLayout = Instance.new("UIListLayout")
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.Padding = UDim.new(0, 6)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Parent = notifContainer

local function makeCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius or CORNER_RADIUS
	c.Parent = parent
	return c
end

local function makeStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or C.Surface1
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function notify(text, color)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 36)
	frame.BackgroundColor3 = C.Mantle
	frame.BackgroundTransparency = 1
	frame.Parent = notifContainer
	makeCorner(frame, CORNER_RADIUS_SM)
	makeStroke(frame, color or C.Surface1)

	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(0, 3, 0.6, 0)
	accent.Position = UDim2.new(0, 6, 0.2, 0)
	accent.BackgroundColor3 = color or C.Blue
	accent.BorderSizePixel = 0
	accent.Parent = frame
	makeCorner(accent, UDim.new(0, 2))

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -22, 1, 0)
	label.Position = UDim2.new(0, 16, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = C.Text
	label.FontFace = FONT
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = frame

	TweenService:Create(frame, TWEEN_NOTIF, {BackgroundTransparency = 0}):Play()

	task.delay(3, function()
		local t = TweenService:Create(frame, TWEEN_NOTIF, {BackgroundTransparency = 1})
		t:Play()
		t.Completed:Wait()
		frame:Destroy()
	end)
end

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 580, 0, 380)
mainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
mainFrame.BackgroundColor3 = C.Base
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
makeCorner(mainFrame)
makeStroke(mainFrame, C.Surface0)

local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 24, 1, 24)
shadow.Position = UDim2.new(0, -12, 0, -12)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5554236805"
shadow.ImageColor3 = C.Crust
shadow.ImageTransparency = 0.4
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(23, 23, 277, 277)
shadow.ZIndex = 0
shadow.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 34)
titleBar.BackgroundColor3 = C.Mantle
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
makeCorner(titleBar)

local titleBarMask = Instance.new("Frame")
titleBarMask.Size = UDim2.new(1, 0, 0, 12)
titleBarMask.Position = UDim2.new(0, 0, 1, -12)
titleBarMask.BackgroundColor3 = C.Mantle
titleBarMask.BorderSizePixel = 0
titleBarMask.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 120, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "executor"
titleLabel.TextColor3 = C.Subtext0
titleLabel.FontFace = FONT_BOLD
titleLabel.TextSize = 12
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local dragging, dragStart, startPos

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

titleBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local function makeTitleBtn(iconName, posFromRight, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 28, 0, 24)
	btn.Position = UDim2.new(1, -(posFromRight * 32) - 8, 0, 5)
	btn.BackgroundColor3 = C.Surface0
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = titleBar
	makeCorner(btn, CORNER_RADIUS_SM)

	local icon = makeIcon(btn, iconName, 16, color or C.Subtext0)
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Position = UDim2.new(0.5, 0, 0.5, 0)

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TWEEN_FAST, {BackgroundTransparency = 0}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TWEEN_FAST, {BackgroundTransparency = 1}):Play()
	end)
	return btn
end

local closeBtn = makeTitleBtn("x", 0, C.Red)
local minimizeBtn = makeTitleBtn("minus", 1, C.Yellow)

local dialogOverlay = Instance.new("Frame")
dialogOverlay.Name = "DialogOverlay"
dialogOverlay.Size = UDim2.new(1, 0, 1, 0)
dialogOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
dialogOverlay.BackgroundTransparency = 1
dialogOverlay.Visible = false
dialogOverlay.ZIndex = 50
dialogOverlay.Parent = mainFrame

local function showDialog(title, message, onConfirm, onCancel)
	dialogOverlay.Visible = true
	TweenService:Create(dialogOverlay, TWEEN_FAST, {BackgroundTransparency = 0.5}):Play()

	for _, child in dialogOverlay:GetChildren() do child:Destroy() end

	local dialog = Instance.new("Frame")
	dialog.Size = UDim2.new(0, 280, 0, 140)
	dialog.Position = UDim2.new(0.5, -140, 0.5, -70)
	dialog.BackgroundColor3 = C.Mantle
	dialog.BorderSizePixel = 0
	dialog.ZIndex = 51
	dialog.Parent = dialogOverlay
	makeCorner(dialog)
	makeStroke(dialog, C.Surface1)

	local tLabel = Instance.new("TextLabel")
	tLabel.Size = UDim2.new(1, -24, 0, 24)
	tLabel.Position = UDim2.new(0, 12, 0, 14)
	tLabel.BackgroundTransparency = 1
	tLabel.Text = title
	tLabel.TextColor3 = C.Text
	tLabel.FontFace = FONT_BOLD
	tLabel.TextSize = 14
	tLabel.TextXAlignment = Enum.TextXAlignment.Left
	tLabel.ZIndex = 52
	tLabel.Parent = dialog

	local mLabel = Instance.new("TextLabel")
	mLabel.Size = UDim2.new(1, -24, 0, 36)
	mLabel.Position = UDim2.new(0, 12, 0, 42)
	mLabel.BackgroundTransparency = 1
	mLabel.Text = message
	mLabel.TextColor3 = C.Subtext0
	mLabel.FontFace = FONT
	mLabel.TextSize = 12
	mLabel.TextXAlignment = Enum.TextXAlignment.Left
	mLabel.TextWrapped = true
	mLabel.ZIndex = 52
	mLabel.Parent = dialog

	local function closeDialog()
		TweenService:Create(dialogOverlay, TWEEN_FAST, {BackgroundTransparency = 1}):Play()
		task.delay(0.15, function() dialogOverlay.Visible = false end)
	end

	local confirmBtn = Instance.new("TextButton")
	confirmBtn.Size = UDim2.new(0, 80, 0, 30)
	confirmBtn.Position = UDim2.new(1, -100, 1, -44)
	confirmBtn.BackgroundColor3 = C.Red
	confirmBtn.Text = "Confirm"
	confirmBtn.TextColor3 = C.Crust
	confirmBtn.FontFace = FONT_BOLD
	confirmBtn.TextSize = 12
	confirmBtn.ZIndex = 52
	confirmBtn.Parent = dialog
	makeCorner(confirmBtn, CORNER_RADIUS_SM)

	local cancelBtn = Instance.new("TextButton")
	cancelBtn.Size = UDim2.new(0, 70, 0, 30)
	cancelBtn.Position = UDim2.new(1, -180, 1, -44)
	cancelBtn.BackgroundColor3 = C.Surface0
	cancelBtn.Text = "Cancel"
	cancelBtn.TextColor3 = C.Text
	cancelBtn.FontFace = FONT
	cancelBtn.TextSize = 12
	cancelBtn.ZIndex = 52
	cancelBtn.Parent = dialog
	makeCorner(cancelBtn, CORNER_RADIUS_SM)

	confirmBtn.MouseButton1Click:Connect(function()
		closeDialog()
		if onConfirm then onConfirm() end
	end)
	cancelBtn.MouseButton1Click:Connect(function()
		closeDialog()
		if onCancel then onCancel() end
	end)
end

local function showInputDialog(title, placeholder, default, onSubmit)
	dialogOverlay.Visible = true
	TweenService:Create(dialogOverlay, TWEEN_FAST, {BackgroundTransparency = 0.5}):Play()

	for _, child in dialogOverlay:GetChildren() do child:Destroy() end

	local dialog = Instance.new("Frame")
	dialog.Size = UDim2.new(0, 300, 0, 140)
	dialog.Position = UDim2.new(0.5, -150, 0.5, -70)
	dialog.BackgroundColor3 = C.Mantle
	dialog.BorderSizePixel = 0
	dialog.ZIndex = 51
	dialog.Parent = dialogOverlay
	makeCorner(dialog)
	makeStroke(dialog, C.Surface1)

	local tLabel = Instance.new("TextLabel")
	tLabel.Size = UDim2.new(1, -24, 0, 24)
	tLabel.Position = UDim2.new(0, 12, 0, 14)
	tLabel.BackgroundTransparency = 1
	tLabel.Text = title
	tLabel.TextColor3 = C.Text
	tLabel.FontFace = FONT_BOLD
	tLabel.TextSize = 14
	tLabel.TextXAlignment = Enum.TextXAlignment.Left
	tLabel.ZIndex = 52
	tLabel.Parent = dialog

	local inputFrame = Instance.new("Frame")
	inputFrame.Size = UDim2.new(1, -24, 0, 32)
	inputFrame.Position = UDim2.new(0, 12, 0, 44)
	inputFrame.BackgroundColor3 = C.Base
	inputFrame.BorderSizePixel = 0
	inputFrame.ZIndex = 52
	inputFrame.Parent = dialog
	makeCorner(inputFrame, CORNER_RADIUS_SM)
	makeStroke(inputFrame, C.Surface1)

	local input = Instance.new("TextBox")
	input.Size = UDim2.new(1, -16, 1, 0)
	input.Position = UDim2.new(0, 10, 0, 0)
	input.BackgroundTransparency = 1
	input.Text = default or ""
	input.PlaceholderText = placeholder or ""
	input.PlaceholderColor3 = C.Surface2
	input.TextColor3 = C.Text
	input.FontFace = FONT
	input.TextSize = 12
	input.TextXAlignment = Enum.TextXAlignment.Left
	input.ClearTextOnFocus = false
	input.ZIndex = 53
	input.Parent = inputFrame

	local function closeDialog()
		TweenService:Create(dialogOverlay, TWEEN_FAST, {BackgroundTransparency = 1}):Play()
		task.delay(0.15, function() dialogOverlay.Visible = false end)
	end

	local submitBtn = Instance.new("TextButton")
	submitBtn.Size = UDim2.new(0, 80, 0, 30)
	submitBtn.Position = UDim2.new(1, -100, 1, -44)
	submitBtn.BackgroundColor3 = C.Blue
	submitBtn.Text = "Save"
	submitBtn.TextColor3 = C.Crust
	submitBtn.FontFace = FONT_BOLD
	submitBtn.TextSize = 12
	submitBtn.ZIndex = 52
	submitBtn.Parent = dialog
	makeCorner(submitBtn, CORNER_RADIUS_SM)

	local cancelBtn = Instance.new("TextButton")
	cancelBtn.Size = UDim2.new(0, 70, 0, 30)
	cancelBtn.Position = UDim2.new(1, -180, 1, -44)
	cancelBtn.BackgroundColor3 = C.Surface0
	cancelBtn.Text = "Cancel"
	cancelBtn.TextColor3 = C.Text
	cancelBtn.FontFace = FONT
	cancelBtn.TextSize = 12
	cancelBtn.ZIndex = 52
	cancelBtn.Parent = dialog
	makeCorner(cancelBtn, CORNER_RADIUS_SM)

	local function submit()
		local value = input.Text
		if value == "" then return end
		closeDialog()
		if onSubmit then onSubmit(value) end
	end

	submitBtn.MouseButton1Click:Connect(submit)
	input.FocusLost:Connect(function(enter)
		if enter then submit() end
	end)
	cancelBtn.MouseButton1Click:Connect(closeDialog)

	task.defer(function() input:CaptureFocus() end)
end

local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, 0, 1, -34)
contentFrame.Position = UDim2.new(0, 0, 0, 34)
contentFrame.BackgroundTransparency = 1
contentFrame.ClipsDescendants = true
contentFrame.Parent = mainFrame

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, 0, 0, 30)
tabBar.BackgroundColor3 = C.Crust
tabBar.BorderSizePixel = 0
tabBar.Parent = contentFrame

local tabScroll = Instance.new("ScrollingFrame")
tabScroll.Size = UDim2.new(1, -32, 1, 0)
tabScroll.Position = UDim2.new(0, 0, 0, 0)
tabScroll.BackgroundTransparency = 1
tabScroll.ScrollBarThickness = 0
tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
tabScroll.ScrollingDirection = Enum.ScrollingDirection.X
tabScroll.Parent = tabBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 1)
tabLayout.Parent = tabScroll

local addTabBtn = Instance.new("TextButton")
addTabBtn.Size = UDim2.new(0, 30, 1, 0)
addTabBtn.Position = UDim2.new(1, -30, 0, 0)
addTabBtn.BackgroundColor3 = C.Crust
addTabBtn.BackgroundTransparency = 1
addTabBtn.Text = ""
addTabBtn.AutoButtonColor = false
addTabBtn.BorderSizePixel = 0
addTabBtn.Parent = tabBar

local addTabIcon = makeIcon(addTabBtn, "plus", 14, C.Overlay0)
addTabIcon.AnchorPoint = Vector2.new(0.5, 0.5)
addTabIcon.Position = UDim2.new(0.5, 0, 0.5, 0)

addTabBtn.MouseEnter:Connect(function()
	TweenService:Create(addTabIcon, TWEEN_FAST, {ImageColor3 = C.Text}):Play()
end)
addTabBtn.MouseLeave:Connect(function()
	TweenService:Create(addTabIcon, TWEEN_FAST, {ImageColor3 = C.Overlay0}):Play()
end)

local editorContainer = Instance.new("Frame")
editorContainer.Name = "Editor"
editorContainer.Size = UDim2.new(1, 0, 1, -68)
editorContainer.Position = UDim2.new(0, 0, 0, 30)
editorContainer.BackgroundColor3 = C.Base
editorContainer.BorderSizePixel = 0
editorContainer.Parent = contentFrame

local lineNumbers = Instance.new("ScrollingFrame")
lineNumbers.Size = UDim2.new(0, 36, 1, 0)
lineNumbers.BackgroundColor3 = C.Mantle
lineNumbers.BorderSizePixel = 0
lineNumbers.ScrollBarThickness = 0
lineNumbers.CanvasSize = UDim2.new(0, 0, 0, 0)
lineNumbers.Parent = editorContainer

local lineNumLabel = Instance.new("TextLabel")
lineNumLabel.Size = UDim2.new(1, -8, 1, 0)
lineNumLabel.Position = UDim2.new(0, 4, 0, 4)
lineNumLabel.BackgroundTransparency = 1
lineNumLabel.Text = "1"
lineNumLabel.TextColor3 = C.Surface2
lineNumLabel.FontFace = FONT_MONO
lineNumLabel.TextSize = 13
lineNumLabel.TextXAlignment = Enum.TextXAlignment.Right
lineNumLabel.TextYAlignment = Enum.TextYAlignment.Top
lineNumLabel.Parent = lineNumbers

local editorScroll = Instance.new("ScrollingFrame")
editorScroll.Size = UDim2.new(1, -36, 1, 0)
editorScroll.Position = UDim2.new(0, 36, 0, 0)
editorScroll.BackgroundColor3 = C.Base
editorScroll.BorderSizePixel = 0
editorScroll.ScrollBarThickness = 4
editorScroll.ScrollBarImageColor3 = C.Surface1
editorScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
editorScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
editorScroll.Parent = editorContainer

local editorBox = Instance.new("TextBox")
editorBox.Size = UDim2.new(1, -12, 1, 0)
editorBox.Position = UDim2.new(0, 8, 0, 4)
editorBox.BackgroundTransparency = 1
editorBox.Text = ""
editorBox.PlaceholderText = ""
editorBox.PlaceholderColor3 = C.Surface2
editorBox.TextColor3 = C.Text
editorBox.TextTransparency = 1
editorBox.FontFace = FONT_MONO
editorBox.TextSize = 13
editorBox.TextXAlignment = Enum.TextXAlignment.Left
editorBox.TextYAlignment = Enum.TextYAlignment.Top
editorBox.ClearTextOnFocus = false
editorBox.MultiLine = true
editorBox.TextWrapped = false
editorBox.ZIndex = 2
editorBox.Parent = editorScroll

local highlightLabel = Instance.new("TextLabel")
highlightLabel.Size = UDim2.new(1, -12, 1, 0)
highlightLabel.Position = UDim2.new(0, 8, 0, 4)
highlightLabel.BackgroundTransparency = 1
highlightLabel.Text = ""
highlightLabel.TextColor3 = C.Text
highlightLabel.FontFace = FONT_MONO
highlightLabel.TextSize = 13
highlightLabel.TextXAlignment = Enum.TextXAlignment.Left
highlightLabel.TextYAlignment = Enum.TextYAlignment.Top
highlightLabel.RichText = true
highlightLabel.Active = false
highlightLabel.Selectable = false
highlightLabel.ZIndex = 1
highlightLabel.Parent = editorScroll

local KEYWORDS = {
	["and"]=true,["break"]=true,["do"]=true,["else"]=true,["elseif"]=true,
	["end"]=true,["for"]=true,["function"]=true,["if"]=true,["in"]=true,
	["local"]=true,["not"]=true,["or"]=true,["repeat"]=true,["return"]=true,
	["then"]=true,["until"]=true,["while"]=true,["continue"]=true,
}
local LITERALS = { ["true"]=true, ["false"]=true, ["nil"]=true }
local BUILTINS = {
	print=true,warn=true,error=true,assert=true,pcall=true,xpcall=true,
	type=true,tostring=true,tonumber=true,pairs=true,ipairs=true,next=true,
	select=true,unpack=true,setmetatable=true,getmetatable=true,rawget=true,
	rawset=true,rawequal=true,rawlen=true,string=true,table=true,math=true,
	os=true,coroutine=true,bit32=true,buffer=true,utf8=true,debug=true,
	game=true,workspace=true,script=true,wait=true,task=true,shared=true,
	loadstring=true,require=true,getgenv=true,getfenv=true,setfenv=true,
	Instance=true,Color3=true,Vector3=true,Vector2=true,UDim=true,UDim2=true,
	CFrame=true,Enum=true,Ray=true,Rect=true,Region3=true,TweenInfo=true,
	BrickColor=true,NumberRange=true,NumberSequence=true,ColorSequence=true,
	addScript=true,removeScript=true,listScripts=true,executor=true,
	loadfile=true,readfile=true,writefile=true,isfile=true,isfolder=true,
	makefolder=true,delfile=true,delfolder=true,listfiles=true,httpget=true,
}

local function htmlEscape(s)
	return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

local function highlight(code)
	local out = {}
	local i, n = 1, #code
	while i <= n do
		local two = code:sub(i, i + 1)
		local c = code:sub(i, i)
		if two == "--" then
			if code:sub(i + 2, i + 3) == "[[" then
				local endIdx = code:find("]]", i + 4, true)
				local final = endIdx and (endIdx + 1) or n
				table.insert(out, '<font color="#6c7086">' .. htmlEscape(code:sub(i, final)) .. '</font>')
				i = final + 1
			else
				local endIdx = code:find("\n", i, true) or (n + 1)
				table.insert(out, '<font color="#6c7086">' .. htmlEscape(code:sub(i, endIdx - 1)) .. '</font>')
				i = endIdx
			end
		elseif c == '"' or c == "'" then
			local quote = c
			local j = i + 1
			while j <= n do
				local ch = code:sub(j, j)
				if ch == "\\" then
					j += 2
				elseif ch == quote or ch == "\n" then
					break
				else
					j += 1
				end
			end
			table.insert(out, '<font color="#a6e3a1">' .. htmlEscape(code:sub(i, j)) .. '</font>')
			i = j + 1
		elseif two == "[[" then
			local endIdx = code:find("]]", i + 2, true)
			local final = endIdx and (endIdx + 1) or n
			table.insert(out, '<font color="#a6e3a1">' .. htmlEscape(code:sub(i, final)) .. '</font>')
			i = final + 1
		elseif c:match("%d") then
			local m = code:sub(i):match("^[%d][%w%.]*")
			table.insert(out, '<font color="#fab387">' .. m .. '</font>')
			i += #m
		elseif c:match("[%a_]") then
			local m = code:sub(i):match("^[%a_][%w_]*")
			local color
			if KEYWORDS[m] then
				color = "#cba6f7"
			elseif LITERALS[m] then
				color = "#fab387"
			elseif BUILTINS[m] then
				color = "#89b4fa"
			else
				local after = code:sub(i + #m):match("^%s*(.)")
				if after == "(" then
					color = "#f9e2af"
				end
			end
			if color then
				table.insert(out, '<font color="' .. color .. '">' .. m .. '</font>')
			else
				table.insert(out, htmlEscape(m))
			end
			i += #m
		else
			table.insert(out, htmlEscape(c))
			i += 1
		end
	end
	return table.concat(out)
end

local PLACEHOLDER = "-- hello brother noah"

local function updateLineNumbers()
	local text = editorBox.Text
	local count = 1
	for _ in text:gmatch("\n") do
		count += 1
	end
	local lines = {}
	for i = 1, count do
		table.insert(lines, tostring(i))
	end
	lineNumLabel.Text = table.concat(lines, "\n")
end

local function updateHighlight()
	local text = editorBox.Text
	if text == "" then
		highlightLabel.Text = '<font color="#585b70">' .. PLACEHOLDER .. '</font>'
	else
		highlightLabel.Text = highlight(text)
	end
end

editorBox:GetPropertyChangedSignal("Text"):Connect(function()
	updateLineNumbers()
	updateHighlight()
	if activeTabId and tabs[activeTabId] then
		tabs[activeTabId].content = editorBox.Text
	end
end)

editorBox.Focused:Connect(function()
	editorBox.TextTransparency = 0
	highlightLabel.Visible = false
end)

editorBox.FocusLost:Connect(function()
	editorBox.TextTransparency = 1
	highlightLabel.Visible = true
	updateHighlight()
end)

updateHighlight()

local toolbar = Instance.new("Frame")
toolbar.Name = "Toolbar"
toolbar.Size = UDim2.new(1, 0, 0, 38)
toolbar.Position = UDim2.new(0, 0, 1, -38)
toolbar.BackgroundColor3 = C.Mantle
toolbar.BorderSizePixel = 0
toolbar.Parent = contentFrame

local toolbarLayout = Instance.new("UIListLayout")
toolbarLayout.FillDirection = Enum.FillDirection.Horizontal
toolbarLayout.SortOrder = Enum.SortOrder.LayoutOrder
toolbarLayout.Padding = UDim.new(0, 4)
toolbarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
toolbarLayout.Parent = toolbar

local toolbarPad = Instance.new("UIPadding")
toolbarPad.PaddingLeft = UDim.new(0, 8)
toolbarPad.Parent = toolbar

local function makeToolBtn(text, iconName, color, order)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 0, 0, 28)
	btn.AutomaticSize = Enum.AutomaticSize.X
	btn.BackgroundColor3 = color or C.Surface0
	btn.Text = ""
	btn.LayoutOrder = order or 0
	btn.AutoButtonColor = false
	btn.Parent = toolbar
	makeCorner(btn, CORNER_RADIUS_SM)

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingRight = UDim.new(0, 12)
	pad.Parent = btn

	local row = Instance.new("UIListLayout")
	row.FillDirection = Enum.FillDirection.Horizontal
	row.VerticalAlignment = Enum.VerticalAlignment.Center
	row.SortOrder = Enum.SortOrder.LayoutOrder
	row.Padding = UDim.new(0, 6)
	row.Parent = btn

	local isColored = (color == C.Green or color == C.Blue or color == C.Red or color == C.Yellow or color == C.Mauve)
	local fgColor = isColored and C.Crust or C.Text

	local icon = makeIcon(btn, iconName, 14, fgColor)
	icon.LayoutOrder = 1

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 0, 1, 0)
	label.AutomaticSize = Enum.AutomaticSize.X
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = fgColor
	label.FontFace = FONT_BOLD
	label.TextSize = 11
	label.LayoutOrder = 2
	label.Parent = btn

	btn.MouseEnter:Connect(function()
		local c = color or C.Surface0
		TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = Color3.new(
			math.min(1, c.R + 0.08),
			math.min(1, c.G + 0.08),
			math.min(1, c.B + 0.08)
		)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = color or C.Surface0}):Play()
	end)

	return btn
end

local execBtn = makeToolBtn("Execute", "play", C.Blue, 1)
local openBtn = makeToolBtn("Open", "folder-open", C.Surface0, 2)
local saveBtn = makeToolBtn("Save", "save", C.Surface0, 3)
local clearBtn = makeToolBtn("Clear", "trash-2", C.Surface0, 4)
local scriptsBtn = makeToolBtn("Scripts", "list", C.Surface0, 5)

local scriptsMenu = Instance.new("Frame")
scriptsMenu.Name = "ScriptsMenu"
scriptsMenu.Size = UDim2.new(0, 180, 0, 0)
scriptsMenu.Position = UDim2.new(0, 0, 0, 0)
scriptsMenu.BackgroundColor3 = C.Mantle
scriptsMenu.BorderSizePixel = 0
scriptsMenu.Visible = false
scriptsMenu.AutomaticSize = Enum.AutomaticSize.Y
scriptsMenu.ZIndex = 40
scriptsMenu.ClipsDescendants = true
scriptsMenu.Parent = mainFrame
makeCorner(scriptsMenu, CORNER_RADIUS_SM)
makeStroke(scriptsMenu, C.Surface1)

local scriptsMenuLayout = Instance.new("UIListLayout")
scriptsMenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
scriptsMenuLayout.Padding = UDim.new(0, 1)
scriptsMenuLayout.Parent = scriptsMenu

local scriptsMenuPad = Instance.new("UIPadding")
scriptsMenuPad.PaddingTop = UDim.new(0, 4)
scriptsMenuPad.PaddingBottom = UDim.new(0, 4)
scriptsMenuPad.Parent = scriptsMenu

local function refreshScriptsMenu()
	for _, child in scriptsMenu:GetChildren() do
		if child:IsA("TextButton") then child:Destroy() end
	end

	if #customScripts == 0 then
		local empty = Instance.new("TextButton")
		empty.Size = UDim2.new(1, 0, 0, 28)
		empty.BackgroundTransparency = 1
		empty.Text = "No scripts added"
		empty.TextColor3 = C.Surface2
		empty.FontFace = FONT
		empty.TextSize = 11
		empty.ZIndex = 41
		empty.Parent = scriptsMenu
		return
	end

	for i, scr in customScripts do
		local item = Instance.new("TextButton")
		item.Size = UDim2.new(1, 0, 0, 28)
		item.BackgroundColor3 = C.Surface0
		item.BackgroundTransparency = 1
		item.Text = "  " .. scr.name
		item.TextColor3 = C.Text
		item.FontFace = FONT
		item.TextSize = 11
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.LayoutOrder = i
		item.ZIndex = 41
		item.Parent = scriptsMenu

		item.MouseEnter:Connect(function()
			TweenService:Create(item, TWEEN_FAST, {BackgroundTransparency = 0}):Play()
		end)
		item.MouseLeave:Connect(function()
			TweenService:Create(item, TWEEN_FAST, {BackgroundTransparency = 1}):Play()
		end)
		item.MouseButton1Click:Connect(function()
			scriptsMenu.Visible = false
			pcall(function()
				loadstring(scr.code)()
			end)
		end)
	end
end

local scriptsMenuOpen = false
scriptsBtn.MouseButton1Click:Connect(function()
	scriptsMenuOpen = not scriptsMenuOpen
	if scriptsMenuOpen then
		refreshScriptsMenu()
		local absPos = scriptsBtn.AbsolutePosition
		local mainAbsPos = mainFrame.AbsolutePosition
		scriptsMenu.Position = UDim2.new(0, absPos.X - mainAbsPos.X, 0, absPos.Y - mainAbsPos.Y - scriptsMenu.AbsoluteSize.Y - 6)
		scriptsMenu.Visible = true
	else
		scriptsMenu.Visible = false
	end
end)

local function renderTabs()
	for _, child in tabScroll:GetChildren() do
		if child:IsA("TextButton") then child:Destroy() end
	end

	for id, tabData in tabs do
		local tab = Instance.new("TextButton")
		tab.Size = UDim2.new(0, 0, 1, 0)
		tab.AutomaticSize = Enum.AutomaticSize.X
		tab.BackgroundColor3 = (id == activeTabId) and C.Base or C.Crust
		tab.Text = ""
		tab.LayoutOrder = tabData.order
		tab.BorderSizePixel = 0
		tab.AutoButtonColor = false
		tab.Parent = tabScroll

		local tabPad = Instance.new("UIPadding")
		tabPad.PaddingLeft = UDim.new(0, 12)
		tabPad.PaddingRight = UDim.new(0, 8)
		tabPad.Parent = tab

		local tabRowLayout = Instance.new("UIListLayout")
		tabRowLayout.FillDirection = Enum.FillDirection.Horizontal
		tabRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		tabRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tabRowLayout.Padding = UDim.new(0, 6)
		tabRowLayout.Parent = tab

		local tabLabel = Instance.new("TextLabel")
		tabLabel.Size = UDim2.new(0, 0, 1, 0)
		tabLabel.AutomaticSize = Enum.AutomaticSize.X
		tabLabel.BackgroundTransparency = 1
		tabLabel.Text = tabData.name
		tabLabel.TextColor3 = (id == activeTabId) and C.Text or C.Overlay0
		tabLabel.FontFace = (id == activeTabId) and FONT_BOLD or FONT
		tabLabel.TextSize = 11
		tabLabel.LayoutOrder = 1
		tabLabel.Parent = tab

		local closeTabBtn = Instance.new("TextButton")
		closeTabBtn.Size = UDim2.new(0, 18, 0, 18)
		closeTabBtn.BackgroundColor3 = C.Surface1
		closeTabBtn.BackgroundTransparency = 1
		closeTabBtn.Text = ""
		closeTabBtn.LayoutOrder = 2
		closeTabBtn.AutoButtonColor = false
		closeTabBtn.Parent = tab
		makeCorner(closeTabBtn, UDim.new(0, 4))

		local closeTabIcon = makeIcon(closeTabBtn, "x", 12, C.Subtext0)
		closeTabIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		closeTabIcon.Position = UDim2.new(0.5, 0, 0.5, 0)

		closeTabBtn.MouseEnter:Connect(function()
			TweenService:Create(closeTabBtn, TWEEN_FAST, {BackgroundTransparency = 0}):Play()
			TweenService:Create(closeTabIcon, TWEEN_FAST, {ImageColor3 = C.Red}):Play()
		end)
		closeTabBtn.MouseLeave:Connect(function()
			TweenService:Create(closeTabBtn, TWEEN_FAST, {BackgroundTransparency = 1}):Play()
			TweenService:Create(closeTabIcon, TWEEN_FAST, {ImageColor3 = C.Subtext0}):Play()
		end)

		closeTabBtn.MouseButton1Click:Connect(function()
			local count = 0
			for _ in tabs do count += 1 end
			if count <= 1 then return end
			tabs[id] = nil
			if activeTabId == id then
				for nextId, _ in tabs do
					activeTabId = nextId
					break
				end
				editorBox.Text = tabs[activeTabId].content
			end
			renderTabs()
			updateLineNumbers()
			updateHighlight()
		end)

		tab.MouseButton1Click:Connect(function()
			activeTabId = id
			editorBox.Text = tabs[activeTabId].content
			renderTabs()
			updateLineNumbers()
			updateHighlight()
		end)
	end
end

local function createTab(name, content)
	tabIdCounter += 1
	local id = tabIdCounter
	tabs[id] = {
		name = name or ("Script " .. id),
		content = content or "",
		order = id,
	}
	activeTabId = id
	editorBox.Text = tabs[id].content
	renderTabs()
	updateLineNumbers()
	return id
end

createTab("Script 1", "")

addTabBtn.MouseButton1Click:Connect(function()
	createTab()
end)

execBtn.MouseButton1Click:Connect(function()
	local code = editorBox.Text
	if code == "" then return end
	local success, err = pcall(function()
		loadstring(code)()
	end)
	if not success then
		notify("Error: " .. tostring(err), C.Red)
	end
end)

openBtn.MouseButton1Click:Connect(function()
	pcall(function()
		local files = listfiles(WORKSPACE_DIR)
		if not files or #files == 0 then
			notify("No files in workspace", C.Yellow)
			return
		end

		local menu = Instance.new("Frame")
		menu.Size = UDim2.new(0, 220, 0, 0)
		menu.Position = UDim2.new(0.5, -110, 0.5, -80)
		menu.BackgroundColor3 = C.Mantle
		menu.BorderSizePixel = 0
		menu.AutomaticSize = Enum.AutomaticSize.Y
		menu.ZIndex = 51
		menu.Parent = dialogOverlay
		makeCorner(menu)
		makeStroke(menu, C.Surface1)

		dialogOverlay.Visible = true
		TweenService:Create(dialogOverlay, TWEEN_FAST, {BackgroundTransparency = 0.5}):Play()

		for _, child in dialogOverlay:GetChildren() do
			if child ~= menu then child:Destroy() end
		end

		local menuPad = Instance.new("UIPadding")
		menuPad.PaddingTop = UDim.new(0, 6)
		menuPad.PaddingBottom = UDim.new(0, 6)
		menuPad.Parent = menu

		local menuLayout = Instance.new("UIListLayout")
		menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
		menuLayout.Padding = UDim.new(0, 1)
		menuLayout.Parent = menu

		local header = Instance.new("TextLabel")
		header.Size = UDim2.new(1, 0, 0, 28)
		header.BackgroundTransparency = 1
		header.Text = "  Open File"
		header.TextColor3 = C.Subtext0
		header.FontFace = FONT_BOLD
		header.TextSize = 12
		header.TextXAlignment = Enum.TextXAlignment.Left
		header.ZIndex = 52
		header.LayoutOrder = 0
		header.Parent = menu

		for i, filePath in files do
			local fileName = filePath:match("([^/\\]+)$") or filePath
			local item = Instance.new("TextButton")
			item.Size = UDim2.new(1, 0, 0, 28)
			item.BackgroundColor3 = C.Surface0
			item.BackgroundTransparency = 1
			item.Text = "  " .. fileName
			item.TextColor3 = C.Text
			item.FontFace = FONT
			item.TextSize = 11
			item.TextXAlignment = Enum.TextXAlignment.Left
			item.LayoutOrder = i
			item.ZIndex = 52
			item.Parent = menu

			item.MouseEnter:Connect(function()
				TweenService:Create(item, TWEEN_FAST, {BackgroundTransparency = 0}):Play()
			end)
			item.MouseLeave:Connect(function()
				TweenService:Create(item, TWEEN_FAST, {BackgroundTransparency = 1}):Play()
			end)
			item.MouseButton1Click:Connect(function()
				local content = readfile(filePath)
				createTab(fileName, content)
				TweenService:Create(dialogOverlay, TWEEN_FAST, {BackgroundTransparency = 1}):Play()
				task.delay(0.15, function() dialogOverlay.Visible = false end)
				notify("Opened file " .. fileName, C.Green)
			end)
		end

		local cancelItem = Instance.new("TextButton")
		cancelItem.Size = UDim2.new(1, 0, 0, 28)
		cancelItem.BackgroundColor3 = C.Surface0
		cancelItem.BackgroundTransparency = 1
		cancelItem.Text = "  Cancel"
		cancelItem.TextColor3 = C.Red
		cancelItem.FontFace = FONT
		cancelItem.TextSize = 11
		cancelItem.TextXAlignment = Enum.TextXAlignment.Left
		cancelItem.LayoutOrder = 999
		cancelItem.ZIndex = 52
		cancelItem.Parent = menu

		cancelItem.MouseButton1Click:Connect(function()
			TweenService:Create(dialogOverlay, TWEEN_FAST, {BackgroundTransparency = 1}):Play()
			task.delay(0.15, function() dialogOverlay.Visible = false end)
		end)
	end)
end)

saveBtn.MouseButton1Click:Connect(function()
	if not activeTabId or not tabs[activeTabId] then return end
	local tabData = tabs[activeTabId]
	local defaultName = tabData.name
	if not defaultName:match("%.lua$") and not defaultName:match("%.txt$") then
		defaultName = defaultName .. ".lua"
	end
	showInputDialog("Save File", "filename.lua", defaultName, function(fileName)
		if not fileName:match("%.%w+$") then
			fileName = fileName .. ".lua"
		end
		pcall(function()
			writefile(WORKSPACE_DIR .. "/" .. fileName, editorBox.Text)
			tabs[activeTabId].name = fileName
			renderTabs()
			notify("Saved to " .. fileName .. " in workspace", C.Green)
		end)
	end)
end)

clearBtn.MouseButton1Click:Connect(function()
	if editorBox.Text == "" then return end
	showDialog("Clear Editor", "Are you sure you want to clear the editor? This cannot be undone.", function()
		editorBox.Text = ""
		if activeTabId and tabs[activeTabId] then
			tabs[activeTabId].content = ""
		end
		updateLineNumbers()
		notify("Cleared editor", C.Blue)
	end)
end)

local function toggleMinimize()
	minimized = not minimized
	if minimized then
		TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 580, 0, 34)
		}):Play()
		contentFrame.Visible = false
	else
		contentFrame.Visible = true
		TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 580, 0, 380)
		}):Play()
	end
end

minimizeBtn.MouseButton1Click:Connect(toggleMinimize)

closeBtn.MouseButton1Click:Connect(function()
	local hasContent = false
	for _, tabData in tabs do
		if tabData.content ~= "" then
			hasContent = true
			break
		end
	end
	if hasContent then
		showDialog("Close Executor", "You have unsaved work. Are you sure you want to close?", function()
			screenGui:Destroy()
		end)
	else
		screenGui:Destroy()
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if scriptsMenuOpen then
		scriptsMenu.Visible = false
		scriptsMenuOpen = false
	end
end)

getgenv().addScript = function(name, code)
	table.insert(customScripts, { name = name, code = code })
	saveScripts()
end

getgenv().removeScript = function(name)
	for i, scr in customScripts do
		if scr.name == name then
			table.remove(customScripts, i)
			saveScripts()
			return true
		end
	end
	return false
end

getgenv().listScripts = function()
	local names = {}
	for _, scr in customScripts do
		table.insert(names, scr.name)
	end
	return names
end

getgenv().executor = {
	addTab = createTab,

	closeTab = function(id)
		if not tabs[id] then return false end
		local count = 0
		for _ in tabs do count += 1 end
		if count <= 1 then return false end
		tabs[id] = nil
		if activeTabId == id then
			for nextId, _ in tabs do
				activeTabId = nextId
				break
			end
			editorBox.Text = tabs[activeTabId].content
			renderTabs()
			updateLineNumbers()
		end
		renderTabs()
		return true
	end,

	getActiveTab = function()
		if not activeTabId or not tabs[activeTabId] then return nil end
		return { id = activeTabId, name = tabs[activeTabId].name, content = tabs[activeTabId].content }
	end,

	getTabs = function()
		local result = {}
		for id, data in tabs do
			table.insert(result, { id = id, name = data.name, content = data.content })
		end
		return result
	end,

	switchTab = function(id)
		if not tabs[id] then return false end
		activeTabId = id
		editorBox.Text = tabs[id].content
		renderTabs()
		updateLineNumbers()
		return true
	end,

	renameTab = function(id, newName)
		if not tabs[id] then return false end
		tabs[id].name = newName
		renderTabs()
		return true
	end,

	notify = notify,

	getActiveCode = function()
		return editorBox.Text
	end,

	setActiveCode = function(code)
		editorBox.Text = code
		if activeTabId and tabs[activeTabId] then
			tabs[activeTabId].content = code
		end
		updateLineNumbers()
	end,

	execute = function(code)
		local target = code or editorBox.Text
		if target == "" then return false, "empty" end
		local success, err = pcall(function()
			loadstring(target)()
		end)
		if not success then
			notify("Error: " .. tostring(err), C.Red)
		end
		return success, err
	end,

	openFile = function(path)
		local success, result = pcall(function()
			return readfile(path)
		end)
		if not success then
			notify("Failed to open " .. path, C.Red)
			return false
		end
		local fileName = path:match("([^/\\]+)$") or path
		createTab(fileName, result)
		notify("Opened file " .. fileName, C.Green)
		return true
	end,

	saveFile = function(path)
		if not activeTabId or not tabs[activeTabId] then return false end
		local target = path
		if not target then
			local fileName = tabs[activeTabId].name
			if not fileName:match("%.lua$") and not fileName:match("%.txt$") then
				fileName = fileName .. ".lua"
			end
			target = WORKSPACE_DIR .. "/" .. fileName
		end
		local success = pcall(function()
			writefile(target, editorBox.Text)
		end)
		if success then
			local name = target:match("([^/\\]+)$") or target
			notify("Saved to " .. name .. " in workspace", C.Green)
		else
			notify("Failed to save", C.Red)
		end
		return success
	end,

	minimize = toggleMinimize,

	isMinimized = function()
		return minimized
	end,

	destroy = function()
		screenGui:Destroy()
	end,
}
