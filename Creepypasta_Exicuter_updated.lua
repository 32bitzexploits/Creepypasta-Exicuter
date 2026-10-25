--// Creepypasta Executor - client UI update
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local ContentProvider = game:GetService("ContentProvider")
local player = Players.LocalPlayer

local BIG_ID, SMALL_ID = "112427621264874", "76720986665586"
local DISCORD = "https://discord.gg/QrpzmEafXB"
local SAVE_FILE = "1x1x1x1_scripts.json"
local SESSION_FILE = "1x1x1x1_tabs.json"
local KEY, KEY_FILE = "TEST", "1x1x1x1_key.txt"
local CLOUD_URL = "https://scriptblox.com/api/script/search?max=20&q="
local AI_URL = "https://text.pollinations.ai/"
local AI_SYSTEM = "You write Roblox Luau client-side LocalScripts. Reply with ONLY runnable Luau code. No explanations, no markdown."

local C = {
	pill = Color3.fromRGB(30, 30, 34), row = Color3.fromRGB(34, 34, 40),
	btn = Color3.fromRGB(55, 55, 62), white = Color3.new(1, 1, 1),
	dark = Color3.fromRGB(20, 20, 24), gray = Color3.fromRGB(170, 170, 180),
	green = Color3.fromRGB(110, 230, 150), red = Color3.fromRGB(255, 120, 120),
	blue = Color3.fromRGB(50, 110, 200), danger = Color3.fromRGB(200, 55, 65),
}

---------------------------------------------------------------- HELPERS
local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end
local function round(o, r) new("UICorner", { CornerRadius = UDim.new(0, r) }, o) end

-- tap: works for mouse + touch, debounced so it never double fires
local function tap(b, fn)
	local last = 0
	local function fire()
		local t = os.clock()
		if t - last < 0.25 then return end
		last = t
		fn()
	end
	b.Activated:Connect(fire)
	b.MouseButton1Click:Connect(fire)
end

local function button(parent, text, size, bg, fg, ts)
	local b = new("TextButton", {
		Size = size, BackgroundColor3 = bg, Text = text, Font = Enum.Font.GothamMedium,
		TextSize = ts or 13, TextColor3 = fg or C.white, BackgroundTransparency = 0.1,
	}, parent)
	round(b, 10)
	return b
end

local function httpGet(url)
	local req = (syn and syn.request) or request or http_request or (http and http.request)
	if req then
		local ok, res = pcall(req, { Url = url, Method = "GET" })
		if ok and res and res.Body and res.Body ~= "" then return res.Body end
	end
	local ok, body = pcall(function() return game:HttpGet(url) end)
	if ok and body then return body end
	return nil, "HTTP requests not supported here"
end

---------------------------------------------------------------- GUI HOST
local pg = player:WaitForChild("PlayerGui")
local host = pg
pcall(function()
	if gethui then
		local h = gethui()
		if h then host = h end
	end
end)
for _, place in ipairs({ pg, host }) do
	for _, n in ipairs({ "ClientExecutor1x", "ExecKey1x" }) do
		local o = place:FindFirstChild(n)
		if o then o:Destroy() end
	end
end

local gui = new("ScreenGui", {
	Name = "ClientExecutor1x", ResetOnSpawn = false, IgnoreGuiInset = true,
	DisplayOrder = 999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, host)

---------------------------------------------------------------- KEY SYSTEM
gui.Enabled = false
local remembered = false
pcall(function()
	if isfile and isfile(KEY_FILE) and readfile(KEY_FILE) == KEY then remembered = true end
end)

if remembered then
	gui.Enabled = true
else
	local keyGui = new("ScreenGui", { Name = "ExecKey1x", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 1000 }, host)
	local card = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(320, 190), BackgroundColor3 = C.dark }, keyGui)
	round(card, 16)
	new("UIStroke", { Color = C.white, Transparency = 0.7 }, card)
	new("TextLabel", { Size = UDim2.new(1, 0, 0, 40), Position = UDim2.fromOffset(0, 10), BackgroundTransparency = 1, Text = "🔑 Creepypasta Executor Key System", Font = Enum.Font.GothamBold, TextSize = 17, TextColor3 = C.white }, card)
	local input = new("TextBox", { Size = UDim2.new(1, -40, 0, 38), Position = UDim2.fromOffset(20, 58), BackgroundColor3 = C.btn, Text = "", PlaceholderText = "Enter key...", PlaceholderColor3 = C.gray, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = C.white, ClearTextOnFocus = false }, card)
	round(input, 10)
	local msg = new("TextLabel", { Size = UDim2.new(1, -40, 0, 18), Position = UDim2.fromOffset(20, 100), BackgroundTransparency = 1, Text = "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.red }, card)
	local verify = button(card, "Verify", UDim2.new(0.5, -26, 0, 36), C.white, C.dark, 14)
	verify.Position = UDim2.new(0, 20, 1, -50)
	verify.Font = Enum.Font.GothamBold
	local getKey = button(card, "Get Key", UDim2.new(0.5, -26, 0, 36), Color3.fromRGB(88, 101, 242), C.white, 14)
	getKey.Position = UDim2.new(0.5, 6, 1, -50)

	tap(verify, function()
		input:ReleaseFocus()
		task.wait(0.1)
		local typed = input.Text:gsub("%s", "")
		if typed == KEY then
			pcall(function() if writefile then writefile(KEY_FILE, KEY) end end)
			keyGui:Destroy()
			gui.Enabled = true
		else
			msg.TextColor3 = C.red
			msg.Text = "Wrong key"
		end
	end)
	tap(getKey, function()
		local f = setclipboard or toclipboard
		if f then pcall(f, DISCORD) end
		pcall(function() GuiService:OpenBrowserWindow(DISCORD) end)
		msg.TextColor3 = C.green
		msg.Text = "Discord link copied"
	end)
end

---------------------------------------------------------------- STORAGE
local saved = {}
pcall(function()
	if isfile and isfile(SAVE_FILE) then saved = HttpService:JSONDecode(readfile(SAVE_FILE)) end
end)
local function persist()
	pcall(function() if writefile then writefile(SAVE_FILE, HttpService:JSONEncode(saved)) end end)
end

---------------------------------------------------------------- ROOT
local root = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.55, 0, 0.55, 0),
	Size = UDim2.new(0.66, 0, 0.82, 0), BackgroundTransparency = 1,
}, gui)
new("UISizeConstraint", { MinSize = Vector2.new(480, 260), MaxSize = Vector2.new(640, 350) }, root)

local pages, navBtns = {}, {}
local function setPage(name)
	for n, p in pairs(pages) do p.Visible = (n == name) end
	for n, b in pairs(navBtns) do
		b.BackgroundColor3 = (n == name) and C.white or C.pill
		b.BackgroundTransparency = (n == name) and 0 or 1
		b.TextColor3 = (n == name) and C.dark or C.white
	end
end

-- NAV BAR
local nav = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0),
	Size = UDim2.fromOffset(0, 34), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1,
}, root)
new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, nav)

local closeBtn = button(nav, "✕", UDim2.fromOffset(34, 34), C.pill, C.white, 15)
closeBtn.LayoutOrder = 1
round(closeBtn, 17)

local pillBar = new("Frame", { Size = UDim2.fromOffset(0, 34), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = C.pill, BackgroundTransparency = 0.1, LayoutOrder = 2 }, nav)
round(pillBar, 17)
new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, pillBar)
new("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }, pillBar)

-- Profile pill: person icon, Roblox avatar/name, and live server clock
local profile = new("Frame", {
	Size = UDim2.fromOffset(174, 30), BackgroundColor3 = C.pill,
	BackgroundTransparency = 0.05, LayoutOrder = 0,
}, pillBar)
round(profile, 14)

new("TextLabel", {
	Size = UDim2.fromOffset(22, 28), Position = UDim2.fromOffset(5, 1),
	BackgroundTransparency = 1, Text = "👤", Font = Enum.Font.Gotham,
	TextSize = 16, TextColor3 = C.white,
}, profile)

local avatar = new("ImageLabel", {
	Size = UDim2.fromOffset(24, 24), Position = UDim2.fromOffset(29, 3),
	BackgroundColor3 = C.btn, Image = "", ScaleType = Enum.ScaleType.Crop,
}, profile)
round(avatar, 12)

local profileName = new("TextLabel", {
	Size = UDim2.fromOffset(110, 14), Position = UDim2.fromOffset(57, 1),
	BackgroundTransparency = 1, Text = player.DisplayName or player.Name,
	Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = C.white,
	TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
}, profile)

local serverClock = new("TextLabel", {
	Size = UDim2.fromOffset(110, 13), Position = UDim2.fromOffset(57, 15),
	BackgroundTransparency = 1, Text = "Server: --:--:--",
	Font = Enum.Font.Gotham, TextSize = 9, TextColor3 = C.gray,
	TextXAlignment = Enum.TextXAlignment.Left,
}, profile)

task.spawn(function()
	local ok, image = pcall(function()
		return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	if ok and image then avatar.Image = image end
	while gui.Parent and profile.Parent do
		local success, clockText = pcall(function()
			return DateTime.fromUnixTimestamp(math.floor(workspace:GetServerTimeNow())):FormatLocalTime("HH:mm:ss", "en-us")
		end)
		if success then serverClock.Text = "Server: " .. clockText end
		task.wait(1)
	end
end)

for i, d in ipairs({ { "home", "🏠" }, { "saved", "💾" }, { "cloud", "☁️" }, { "ai", "✨" } }) do
	local b = button(pillBar, d[2], UDim2.fromOffset(42, 28), C.pill, C.white, 16)
	b.LayoutOrder = i
	round(b, 14)
	navBtns[d[1]] = b
	tap(b, function() setPage(d[1]) end)
end

-- INFO ROW (drag handle)
local info = new("Frame", { Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Active = true }, root)

local fpsPill = new("TextLabel", { Size = UDim2.fromOffset(78, 24), Position = UDim2.fromOffset(0, 1), BackgroundColor3 = C.pill, BackgroundTransparency = 0.1, Text = "⚡ -- FPS", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = C.white }, info)
round(fpsPill, 12)

local discordBtn = button(info, "Discord", UDim2.fromOffset(58, 24), Color3.fromRGB(88, 101, 242), C.white, 12)
discordBtn.Position = UDim2.fromOffset(84, 1)
round(discordBtn, 12)

new("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 10, 0.5, 0), Size = UDim2.fromOffset(190, 24), BackgroundTransparency = 1, Text = "Creepypasta Exicuter", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = C.white }, info)

local status = new("TextLabel", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(70, 24), BackgroundTransparency = 1, Text = "Ready", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.green, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd }, info)

-- PANEL with background decal
local panel = new("ImageLabel", {
	Position = UDim2.fromOffset(0, 70), Size = UDim2.new(1, 0, 1, -70),
	Image = "rbxassetid://" .. BIG_ID, ScaleType = Enum.ScaleType.Crop,
	BackgroundColor3 = C.dark, ClipsDescendants = true,
}, root)
round(panel, 16)
local shade = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.4, BorderSizePixel = 0 }, panel)
round(shade, 16)

for _, n in ipairs({ "home", "saved", "cloud", "ai" }) do
	pages[n] = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, ClipsDescendants = true }, panel)
end

-- TOAST: shows full result/error messages so you can see exactly why something failed
local toast = new("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -54), Size = UDim2.new(1, -24, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.dark, BackgroundTransparency = 0.1,
	Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = C.green, TextWrapped = true, Text = "",
	Visible = false, ZIndex = 20,
}, panel)
round(toast, 8)
new("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, toast)

local toastId = 0
local function setStatus(t, ok)
	t = tostring(t)
	local good = (ok ~= false)
	status.Text = t
	status.TextColor3 = good and C.green or C.red
	toast.Text = t:sub(1, 240)
	toast.TextColor3 = good and C.green or C.red
	toast.Visible = true
	toastId += 1
	local id = toastId
	task.delay(good and 2.5 or 7, function()
		if id == toastId then toast.Visible = false end
	end)
end

-- list helpers
local function listFrame(parent, pos, size)
	local sf = new("ScrollingFrame", { Position = pos, Size = size, BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y }, parent)
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, sf)
	return sf
end
local function clearList(sf) for _, c in ipairs(sf:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end end
local function makeRow(list, h)
	local f = new("Frame", { Size = UDim2.new(1, -6, 0, h), BackgroundColor3 = C.row, BackgroundTransparency = 0.1 }, list)
	round(f, 10)
	return f
end
local function rowBtn(f, text, right, w, color)
	local b = new("TextButton", { Size = UDim2.fromOffset(w, 28), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -right, 0.5, 0), Text = text, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.white, BackgroundColor3 = color }, f)
	round(b, 8)
	return b
end

---------------------------------------------------------------- RUN CODE
local function getLoader()
	return loadstring or (getgenv and getgenv().loadstring) or load
end
local function run(code)
	code = code or ""
	if code:match("^%s*$") then return setStatus("Nothing to execute", false) end
	local ls = getLoader()
	if not ls then
		return setStatus("loadstring is unavailable in this executor; enable it in the executor or use a supported environment", false)
	end
	local okC, fn, err = pcall(ls, code, "=CreepypastaExecutor")
	if not okC then return setStatus("Compile failed: " .. tostring(fn), false) end
	if not fn then return setStatus("Syntax: " .. tostring(err), false) end
	setStatus("Running...", true)
	task.spawn(function()
		local ok, e = xpcall(fn, function(m) return tostring(m) end)
		setStatus(ok and "Executed ✓" or ("Error: " .. tostring(e)), ok)
	end)
end
local function getClip()
	local f = getclipboard or readclipboard
	if not f then return nil end
	local ok, v = pcall(f)
	return ok and v or nil
end

---------------------------------------------------------------- HOME
local home = pages.home
local tabs = { { name = "New Script", code = "" } }
pcall(function()
	if isfile and isfile(SESSION_FILE) then
		local t = HttpService:JSONDecode(readfile(SESSION_FILE))
		if type(t) == "table" and #t > 0 then tabs = t end
	end
end)
local active = 1
local saveQueued = false
local function saveTabs()
	if saveQueued then return end
	saveQueued = true
	task.delay(1, function()
		saveQueued = false
		pcall(function() if writefile then writefile(SESSION_FILE, HttpService:JSONEncode(tabs)) end end)
	end)
end

local tabStrip = new("ScrollingFrame", { Position = UDim2.fromOffset(10, 8), Size = UDim2.new(1, -20, 0, 34), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollingDirection = Enum.ScrollingDirection.X }, home)
new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, tabStrip)

local editorBox = new("Frame", { Position = UDim2.fromOffset(10, 46), Size = UDim2.new(1, -20, 1, -98), BackgroundColor3 = C.dark, BackgroundTransparency = 0.35 }, home)
round(editorBox, 10)
local editScroll = new("ScrollingFrame", { Position = UDim2.fromOffset(4, 4), Size = UDim2.new(1, -8, 1, -8), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ClipsDescendants = true }, editorBox)
local editor = new("TextBox", {
	Size = UDim2.new(1, -8, 1, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
	MultiLine = true, ClearTextOnFocus = false, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top, Font = Enum.Font.Code, TextSize = 14, TextColor3 = C.white,
	PlaceholderText = "Write or paste Luau here...", PlaceholderColor3 = C.gray, Text = "",
}, editScroll)
new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 4), PaddingRight = UDim.new(0, 6) }, editor)

editor:GetPropertyChangedSignal("Text"):Connect(function()
	tabs[active].code = editor.Text
	saveTabs()
end)

local renderTabs
local function switchTab(i)
	active = i
	editor.Text = tabs[i].code
	renderTabs()
end
local function closeTab(i)
	table.remove(tabs, i)
	if #tabs == 0 then tabs[1] = { name = "New Script", code = "" } end
	if i < active then active -= 1 end
	active = math.clamp(active, 1, #tabs)
	editor.Text = tabs[active].code
	renderTabs()
end
local function newTab(name, code)
	table.insert(tabs, { name = name, code = code or "" })
	active = #tabs
	editor.Text = tabs[active].code
	renderTabs()
	setPage("home")
end

function renderTabs()
	for _, c in ipairs(tabStrip:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
	for i, t in ipairs(tabs) do
		local isA = (i == active)
		local f = new("Frame", { Size = UDim2.fromOffset(122, 30), BackgroundColor3 = isA and C.white or C.pill, BackgroundTransparency = isA and 0 or 0.1, LayoutOrder = i }, tabStrip)
		round(f, 10)
		local props = { Size = UDim2.new(1, -34, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Text = t.name, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = isA and C.dark or C.gray, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }
		if isA then
			props.ClearTextOnFocus = false
			local tb = new("TextBox", props, f)
			tb.FocusLost:Connect(function()
				t.name = (tb.Text ~= "" and tb.Text) or "Script"
				saveTabs()
			end)
		else
			local tbtn = new("TextButton", props, f)
			tap(tbtn, function() switchTab(i) end)
		end
		local x = new("TextButton", { Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, -26, 0.5, -12), BackgroundTransparency = 1, Text = "✕", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = isA and C.dark or C.gray }, f)
		tap(x, function() closeTab(i) end)
	end
	local plus = button(tabStrip, "+", UDim2.fromOffset(34, 30), C.pill, C.white, 18)
	plus.LayoutOrder = #tabs + 1
	tap(plus, function() newTab("New Script", "") end)
	saveTabs()
end

local refreshSaved -- defined below

local bar = new("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -8), Size = UDim2.new(1, -20, 0, 38), BackgroundTransparency = 1 }, home)
new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6) }, bar)
local clearBtn = button(bar, "Clear", UDim2.fromOffset(60, 36), C.btn)
local pasteBtn = button(bar, "📋 Paste", UDim2.fromOffset(74, 36), C.btn)
local execClipBtn = button(bar, "📋 Exec Clipboard", UDim2.fromOffset(130, 36), C.btn)
local saveBtn = button(bar, "Save", UDim2.fromOffset(60, 36), C.blue)
local execBtn = button(bar, "▶ Execute", UDim2.fromOffset(94, 36), C.white, C.dark)
execBtn.Font = Enum.Font.GothamBold

tap(execBtn, function()
	editor:ReleaseFocus()
	task.wait(0.1) -- lets mobile keyboard commit the text first
	local code = editor.Text
	if code == "" then code = tabs[active].code end
	run(code)
end)
tap(clearBtn, function() editor.Text = "" setStatus("Cleared", true) end)
tap(pasteBtn, function()
	local c = getClip()
	if not c then return setStatus("Clipboard read unsupported - long-press the box to paste", false) end
	editor.Text = editor.Text .. c
	setStatus("Pasted", true)
end)
tap(execClipBtn, function()
	local c = getClip()
	if not c then return setStatus("Clipboard read unsupported", false) end
	run(c)
end)
tap(saveBtn, function()
	editor:ReleaseFocus()
	task.wait(0.1)
	local t = tabs[active]
	if t.code:match("^%s*$") then return setStatus("Nothing to save", false) end
	for _, s in ipairs(saved) do
		if s.name == t.name then
			s.code = t.code
			persist()
			refreshSaved()
			return setStatus("Updated " .. t.name, true)
		end
	end
	table.insert(saved, { name = t.name, code = t.code })
	persist()
	refreshSaved()
	setStatus(writefile and ("Saved " .. t.name) or "Saved (this session only)", true)
end)

---------------------------------------------------------------- SAVED
local savedPage = pages.saved
new("TextLabel", { Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 24), BackgroundTransparency = 1, Text = "Saved Scripts", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = C.white, TextXAlignment = Enum.TextXAlignment.Left }, savedPage)
local savedList = listFrame(savedPage, UDim2.fromOffset(10, 36), UDim2.new(1, -20, 1, -46))

function refreshSaved()
	clearList(savedList)
	if #saved == 0 then
		local r = makeRow(savedList, 36)
		new("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "Nothing saved yet - press Save on Home", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.gray }, r)
	end
	for i, s in ipairs(saved) do
		local r = makeRow(savedList, 38)
		new("TextLabel", { Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -170, 1, 0), BackgroundTransparency = 1, Text = s.name, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = C.white, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, r)
		tap(rowBtn(r, "Open", 98, 52, C.blue), function() newTab(s.name, s.code) end)
		tap(rowBtn(r, "Run", 42, 50, Color3.fromRGB(40, 160, 90)), function() run(s.code) end)
		tap(rowBtn(r, "✕", 6, 30, C.danger), function()
			table.remove(saved, i)
			persist()
			refreshSaved()
		end)
	end
end

---------------------------------------------------------------- CLOUD
local cloud = pages.cloud
local searchBox = new("TextBox", { Position = UDim2.fromOffset(10, 8), Size = UDim2.new(1, -100, 0, 32), BackgroundColor3 = C.dark, BackgroundTransparency = 0.3, Text = "", PlaceholderText = "Search published scripts...", PlaceholderColor3 = C.gray, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = C.white, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left }, cloud)
round(searchBox, 10)
new("UIPadding", { PaddingLeft = UDim.new(0, 10) }, searchBox)
local searchBtn = button(cloud, "Search", UDim2.fromOffset(74, 32), C.blue)
searchBtn.Position = UDim2.new(1, -84, 0, 8)
local cloudList = listFrame(cloud, UDim2.fromOffset(10, 46), UDim2.new(1, -20, 1, -56))

local function getSource(s, cb)
	if type(s.script) == "string" and s.script ~= "" then return cb(s.script) end
	task.spawn(function()
		local body = httpGet("https://scriptblox.com/api/script/" .. tostring(s.slug))
		local ok, d = pcall(function() return HttpService:JSONDecode(body) end)
		local src = ok and type(d) == "table" and d.result and d.result.script and d.result.script.script
		if src then cb(src) else setStatus("Couldn't fetch script", false) end
	end)
end

local function cloudSearch(q)
	clearList(cloudList)
	setStatus("Searching...", true)
	task.spawn(function()
		local body, err = httpGet(CLOUD_URL .. HttpService:UrlEncode(q))
		if not body then return setStatus(err or "Request failed", false) end
		local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
		local list = ok and type(data) == "table" and data.result and data.result.scripts
		if not list or #list == 0 then return setStatus("No results", false) end
		for _, s in ipairs(list) do
			local r = makeRow(cloudList, 46)
			new("TextLabel", { Position = UDim2.fromOffset(10, 4), Size = UDim2.new(1, -120, 0, 20), BackgroundTransparency = 1, Text = tostring(s.title), Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = C.white, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, r)
			new("TextLabel", { Position = UDim2.fromOffset(10, 24), Size = UDim2.new(1, -120, 0, 16), BackgroundTransparency = 1, Text = (s.game and s.game.name) or "Universal", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.gray, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, r)
			tap(rowBtn(r, "Open", 56, 52, C.blue), function() getSource(s, function(src) newTab(tostring(s.title):sub(1, 14), src) end) end)
			tap(rowBtn(r, "Run", 4, 48, Color3.fromRGB(40, 160, 90)), function() getSource(s, run) end)
		end
		setStatus(#list .. " results", true)
	end)
end
tap(searchBtn, function() if searchBox.Text ~= "" then cloudSearch(searchBox.Text) end end)
searchBox.FocusLost:Connect(function(enter) if enter and searchBox.Text ~= "" then cloudSearch(searchBox.Text) end end)

---------------------------------------------------------------- AI (built-in)
local ai = pages.ai
new("TextLabel", { Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 24), BackgroundTransparency = 1, Text = "✨ Describe the script you want", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = C.white, TextXAlignment = Enum.TextXAlignment.Left }, ai)
local promptBox = new("TextBox", { Position = UDim2.fromOffset(10, 36), Size = UDim2.new(1, -20, 0, 90), BackgroundColor3 = C.dark, BackgroundTransparency = 0.3, Text = "", PlaceholderText = "e.g. speed 80, fly, noclip, esp, fullbright, infinite jump", PlaceholderColor3 = C.gray, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = C.white, MultiLine = true, TextWrapped = true, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top }, ai)
round(promptBox, 10)
new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingTop = UDim.new(0, 8), PaddingRight = UDim.new(0, 10) }, promptBox)
local genBtn = button(ai, "✨ Generate", UDim2.fromOffset(130, 36), C.white, C.dark)
genBtn.Font = Enum.Font.GothamBold
genBtn.Position = UDim2.fromOffset(10, 134)
new("TextLabel", { Position = UDim2.fromOffset(150, 134), Size = UDim2.new(1, -160, 0, 36), BackgroundTransparency = 1, Text = "Result opens in a new tab on Home.", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.gray, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left }, ai)

local TEMPLATES = {
	{ { "infinite jump", "inf jump", "multi jump" }, "InfJump", [==[
game:GetService("UserInputService").JumpRequest:Connect(function()
	local h = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end)]==] },
	{ { "speed", "fast", "walkspeed" }, "Speed", [==[
local h = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")
h.WalkSpeed = %NUM%
h:GetPropertyChangedSignal("WalkSpeed"):Connect(function() h.WalkSpeed = %NUM% end)]==], 50 },
	{ { "jump power", "high jump", "jump" }, "JumpPower", [==[
local h = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")
h.UseJumpPower = true
h.JumpPower = %NUM%]==], 100 },
	{ { "fly", "flight" }, "Fly", [==[
local RS = game:GetService("RunService")
local lp = game.Players.LocalPlayer
local speed, up, down = %NUM%, false, false
local gui = Instance.new("ScreenGui") gui.ResetOnSpawn = false gui.Parent = lp.PlayerGui
local conn
local function mk(t, y, f)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(64, 46) b.Position = UDim2.new(0, 16, 0.5, y) b.Text = t b.Parent = gui
	b.MouseButton1Down:Connect(function() f(true) end)
	b.MouseButton1Up:Connect(function() f(false) end)
	return b
end
mk("UP", -100, function(v) up = v end)
mk("DOWN", -50, function(v) down = v end)
mk("STOP", 0, function(v) if v then conn:Disconnect() gui:Destroy() end end)
conn = RS.RenderStepped:Connect(function()
	local ch = lp.Character
	local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end
	local d = hum.MoveDirection * speed
	hrp.AssemblyLinearVelocity = Vector3.new(d.X, (up and speed or 0) - (down and speed or 0), d.Z)
end)]==], 50 },
	{ { "noclip", "walk through" }, "Noclip", [==[
game:GetService("RunService").Stepped:Connect(function()
	local ch = game.Players.LocalPlayer.Character
	if ch then for _, p in ipairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
end)]==] },
	{ { "esp", "highlight", "see players" }, "ESP", [==[
local Players = game:GetService("Players")
local function add(p)
	if p == Players.LocalPlayer then return end
	local function apply(ch)
		local old = ch:FindFirstChild("ESP_HL") if old then old:Destroy() end
		local h = Instance.new("Highlight") h.Name = "ESP_HL"
		h.FillTransparency = 0.5 h.Parent = ch
	end
	if p.Character then apply(p.Character) end
	p.CharacterAdded:Connect(apply)
end
for _, p in ipairs(Players:GetPlayers()) do add(p) end
Players.PlayerAdded:Connect(add)]==] },
	{ { "fullbright", "bright", "no dark" }, "Fullbright", [==[
local L = game:GetService("Lighting")
L.Brightness = 2 L.ClockTime = 14 L.FogEnd = 1e6
L.GlobalShadows = false L.Ambient = Color3.new(1, 1, 1)]==] },
	{ { "gravity" }, "Gravity", "workspace.Gravity = %NUM%", 50 },
	{ { "fov", "field of view", "zoom" }, "FOV", "workspace.CurrentCamera.FieldOfView = %NUM%", 90 },
	{ { "spin" }, "Spin", [==[
local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local s = Instance.new("BodyAngularVelocity")
s.MaxTorque = Vector3.new(0, math.huge, 0) s.AngularVelocity = Vector3.new(0, %NUM%, 0) s.Parent = hrp]==], 20 },
	{ { "chat spam", "say hello" }, "Chat", [==[
local ch = game:GetService("TextChatService").TextChannels:FindFirstChild("RBXGeneral")
if ch then ch:SendAsync("Hello from Creepypasta Exicuter!") end]==] },
}

local function generate(prompt)
	local p = prompt:lower()
	local num = p:match("%d+%.?%d*")
	for _, t in ipairs(TEMPLATES) do
		for _, kw in ipairs(t[1]) do
			if p:find(kw, 1, true) then
				local code = t[3]:gsub("%%NUM%%", num or tostring(t[4] or 0))
				return t[2], "-- generated by Creepypasta Exicuter AI: " .. prompt .. "\n" .. code
			end
		end
	end
end

tap(genBtn, function()
	promptBox:ReleaseFocus()
	task.wait(0.1)
	local prompt = promptBox.Text
	if prompt:match("^%s*$") then return setStatus("Type what you want first", false) end
	local name, code = generate(prompt)
	if code then
		newTab("AI: " .. name, code)
		return setStatus("Generated ✓", true)
	end
	setStatus("No template, asking online AI...", true)
	task.spawn(function()
		local url = AI_URL .. HttpService:UrlEncode(prompt) .. "?system=" .. HttpService:UrlEncode(AI_SYSTEM)
		local body = httpGet(url)
		if not body or body == "" then return setStatus("Try: speed 80, fly, noclip, esp, fullbright", false) end
		newTab("AI: " .. prompt:sub(1, 10), body:match("```%a*\n(.-)```") or body)
		setStatus("Generated ✓", true)
	end)
end)

---------------------------------------------------------------- DISCORD
tap(discordBtn, function()
	local f = setclipboard or toclipboard
	if f then pcall(f, DISCORD) end
	pcall(function() GuiService:OpenBrowserWindow(DISCORD) end)
	setStatus(f and "Discord link copied" or "Opening Discord...", true)
end)

---------------------------------------------------------------- FPS
local frames, last = 0, os.clock()
local fpsConn = RunService.RenderStepped:Connect(function()
	frames += 1
	local now = os.clock()
	if now - last >= 0.5 then
		fpsPill.Text = "⚡ " .. math.floor(frames / (now - last) + 0.5) .. " FPS"
		frames, last = 0, now
	end
end)
gui.Destroying:Connect(function() fpsConn:Disconnect() end)

---------------------------------------------------------------- MINI SQUARE + SCREEN CLAMPING
local mini = new("ImageButton", { Size = UDim2.fromOffset(60, 60), Image = "rbxassetid://" .. SMALL_ID, ScaleType = Enum.ScaleType.Crop, BackgroundColor3 = C.dark, Visible = false, AutoButtonColor = false, ZIndex = 5 }, gui)
round(mini, 12)
new("UIStroke", { Color = C.white, Transparency = 0.6, Thickness = 1.5 }, mini)

---------------------------------------------------------------- CREEPYPASTA THEME SETTINGS
local themePresets = {
    ["1x1x1x1"] = { small = "76720986665586", big = "112427621264874" },
    ["cool kids"] = { small = "71404637467499", big = "91293098164023" },
    ["guest666"] = { small = "121671109746048", big = "85213993302801" },
    ["John doe"] = { small = "101032828830999", big = "129815468922060" },
    ["azure"] = { small = "79806526654629", big = "128966672723085" },
    ["monster"] = { small = "99601230897179", big = "121426224377710" },
}
local activeTheme = "1x1x1x1"
local themeButton = button(info, "⚙", UDim2.fromOffset(28, 24), C.btn, C.white, 16)
themeButton.Position = UDim2.new(1, -108, 0, 1)
round(themeButton, 8)

local themePanel = new("Frame", {
    Name = "CreepypastaThemeSettings", AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -8, 0, 70), Size = UDim2.fromOffset(240, 330),
    BackgroundColor3 = C.dark, BorderSizePixel = 0, Visible = false, ZIndex = 30,
}, gui)
round(themePanel, 12)
new("UIStroke", { Color = C.gray, Transparency = 0.45, Thickness = 1 }, themePanel)
new("TextLabel", { Size = UDim2.new(1, -16, 0, 28), Position = UDim2.fromOffset(8, 4), BackgroundTransparency = 1,
    Text = "CREEPYPASTA THEMES", TextColor3 = C.white, Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 31 }, themePanel)
local themeList = new("Frame", { Position = UDim2.fromOffset(8, 36), Size = UDim2.new(1, -16, 0, 126), BackgroundTransparency = 1, ZIndex = 31 }, themePanel)
new("UIGridLayout", { CellSize = UDim2.fromOffset(108, 34), CellPadding = UDim2.fromOffset(6, 5), SortOrder = Enum.SortOrder.LayoutOrder }, themeList)
local themeStatus = new("TextLabel", { Position = UDim2.fromOffset(8, 166), Size = UDim2.new(1, -16, 0, 18), BackgroundTransparency = 1,
    Text = "Select a preset or enter custom IDs", TextColor3 = C.gray, TextSize = 10, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 31 }, themePanel)
local smallBox = new("TextBox", { Position = UDim2.fromOffset(8, 188), Size = UDim2.new(1, -16, 0, 30), BackgroundColor3 = C.row,
    Text = "", PlaceholderText = "Custom SMALL decal ID", PlaceholderColor3 = C.gray, TextColor3 = C.white, ClearTextOnFocus = false,
    TextSize = 11, Font = Enum.Font.Gotham, ZIndex = 31 }, themePanel)
round(smallBox, 6)
local bigBox = new("TextBox", { Position = UDim2.fromOffset(8, 224), Size = UDim2.new(1, -16, 0, 30), BackgroundColor3 = C.row,
    Text = "", PlaceholderText = "Custom BIG decal ID", PlaceholderColor3 = C.gray, TextColor3 = C.white, ClearTextOnFocus = false,
    TextSize = 11, Font = Enum.Font.Gotham, ZIndex = 31 }, themePanel)
round(bigBox, 6)
local applyCustom = button(themePanel, "Apply custom decals", UDim2.new(1, -16, 0, 30), C.blue, C.white, 11)
applyCustom.Position = UDim2.fromOffset(8, 260)
applyCustom.ZIndex = 31
round(applyCustom, 6)
local closeThemes = button(themePanel, "Close", UDim2.new(1, -16, 0, 24), C.btn, C.white, 11)
closeThemes.Position = UDim2.fromOffset(8, 296)
closeThemes.ZIndex = 31
round(closeThemes, 6)

local function applyDecals(name, ids)
    activeTheme = name
    BIG_ID, SMALL_ID = tostring(ids.big), tostring(ids.small)
    panel.Image = "rbxassetid://" .. BIG_ID
    mini.Image = "rbxassetid://" .. SMALL_ID
    themeStatus.Text = "Applied: " .. name
    themeStatus.TextColor3 = C.green
end
for name, ids in pairs(themePresets) do
    local b = button(themeList, name, UDim2.fromOffset(108, 34), C.btn, C.white, 11)
    b.ZIndex = 32
    round(b, 7)
    tap(b, function() applyDecals(name, ids) end)
end
tap(themeButton, function() themePanel.Visible = not themePanel.Visible end)
tap(closeThemes, function() themePanel.Visible = false end)
tap(applyCustom, function()
    local small = smallBox.Text:match("^%s*(%d+)%s*$")
    local big = bigBox.Text:match("^%s*(%d+)%s*$")
    if not small or not big then
        themeStatus.Text = "Enter numeric IDs in both fields"
        themeStatus.TextColor3 = C.red
        return
    end
    applyDecals("Custom", { small = small, big = big })
end)

-- keeps a frame fully on screen (position = its anchor point)
local function clampPos(frame, x, y)
	local vp = gui.AbsoluteSize
	local sz = frame.AbsoluteSize
	local ap = frame.AnchorPoint
	local minX, maxX = sz.X * ap.X + 4, vp.X - sz.X * (1 - ap.X) - 4
	local minY, maxY = sz.Y * ap.Y + 4, vp.Y - sz.Y * (1 - ap.Y) - 4
	if maxX < minX then maxX = minX end
	if maxY < minY then maxY = minY end
	x, y = math.clamp(x, minX, maxX), math.clamp(y, minY, maxY)
	-- keep the mini square out from under Roblox's top-left menu buttons
	if frame == mini then
		local left, top = x - sz.X * ap.X, y - sz.Y * ap.Y
		if left < 215 and top < 62 then y = 66 + sz.Y * ap.Y end
	end
	return x, y
end
local function anchorPos(frame)
	local p = frame.AbsolutePosition
	local s = frame.AbsoluteSize
	local a = frame.AnchorPoint
	return p.X + s.X * a.X, p.Y + s.Y * a.Y
end
local function place(frame, x, y)
	x, y = clampPos(frame, x, y)
	frame.Position = UDim2.fromOffset(x, y)
end

local function makeDraggable(frame, handle)
	local dragging, startX, startY, startIn, moved = false, 0, 0, nil, 0
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, moved, startIn = true, 0, i.Position
			startX, startY = anchorPos(frame)
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local dx, dy = i.Position.X - startIn.X, i.Position.Y - startIn.Y
			moved = math.max(moved, math.sqrt(dx * dx + dy * dy))
			place(frame, startX + dx, startY + dy)
		end
	end)
	return function() return moved end
end

makeDraggable(root, info)
local miniMoved = makeDraggable(mini, mini)

-- start with root safely on screen
task.defer(function() place(root, anchorPos(root)) end)

tap(closeBtn, function()
	local p = root.AbsolutePosition
	root.Visible = false
	mini.Visible = true
	place(mini, p.X + 30, p.Y + 30 + 36)
end)
local function restore()
	local cx, cy = anchorPos(mini)
	mini.Visible = false
	root.Visible = true
	place(root, cx + root.AbsoluteSize.X / 2 - 30, cy + root.AbsoluteSize.Y / 2 - 30)
end
mini.Activated:Connect(function()
	if miniMoved() > 8 then return end
	restore()
end)

-- re-clamp if the screen size changes (rotation, window resize)
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	place(root, anchorPos(root))
	place(mini, anchorPos(mini))
end)

-- watchdog: re-attach if the game removes the gui, and rescue anything stuck off screen
task.spawn(function()
	while gui and task.wait(1) do
		if not gui.Parent then pcall(function() gui.Parent = host end) end
		if root.Visible then place(root, anchorPos(root)) end
		if mini.Visible then place(mini, anchorPos(mini)) end
	end
end)

-- PC: RightControl toggles show / hide
UIS.InputBegan:Connect(function(i, gp)
	if gp or i.KeyCode ~= Enum.KeyCode.RightControl then return end
	if root.Visible then
		local p = root.AbsolutePosition
		root.Visible, mini.Visible = false, true
		place(mini, p.X + 30, p.Y + 66)
	else
		restore()
	end
end)

---------------------------------------------------------------- DECAL LOADING
task.spawn(function()
	pcall(function() ContentProvider:PreloadAsync({ panel, mini }) end)
	task.wait(2)
	if not panel.IsLoaded then panel.Image = "rbxthumb://type=Asset&id=" .. BIG_ID .. "&w=420&h=420" end
	if not mini.IsLoaded then mini.Image = "rbxthumb://type=Asset&id=" .. SMALL_ID .. "&w=420&h=420" end
end)

-- start
active = 1
editor.Text = tabs[1].code
renderTabs()
refreshSaved()
setPage("home")
