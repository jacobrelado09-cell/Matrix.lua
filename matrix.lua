----------------------------------------------------
-- HARDENED ANTI-CHEAT BYPASS & SECURITY LAYER
----------------------------------------------------
local getrawmetatable = getrawmetatable or false
local setreadonly = setreadonly or false
local checkcaller = checkcaller or false

if getrawmetatable and setreadonly then
    local gmt = getrawmetatable(game)
    setreadonly(gmt, false) 
    local oldNamecall = gmt.__namecall
    local oldIndex = gmt.__index
    local oldNewIndex = gmt.__newindex
    
    -- Hardened Namecall Hooks
    gmt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if not checkcaller() then
            -- Intercept tracing scans aiming to detect modified hitboxes
            if method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "Raycast" then
                if args[2] and typeof(args[2]) == "table" then
                    table.insert(args[2], Workspace:FindFirstChild("Matrix_MIG"))
                end
            -- Multi-tier string interception against local telemetry kicks
            elseif method == "Kick" or method == "kick" or method == "BreakJoints" then
                return task.wait(9e9)
            end
        end
        return oldNamecall(self, unpack(args))
    end)
    
    -- Anti-Detection Spoofing Layer for UpperTorso Queries
    gmt.__index = newcclosure(function(self, idx)
        if not checkcaller() and (idx == "Size" or idx == "CanCollide" or idx == "Transparency") then
            if self.Name == "UpperTorso" or self.Name == "Torso" then
                -- Spoof original game state configurations if read by security scripts
                if idx == "Size" then return Vector3.new(2, 2, 1) end
                if idx == "CanCollide" then return true end
                if idx == "Transparency" then return 0 end
            end
        end
        return oldIndex(self, idx)
    end)
    
    setreadonly(gmt, true)
end

----------------------------------------------------
-- SYSTEM INITIALIZATION
----------------------------------------------------
local CoreGuiService = game:GetService("CoreGui")
local PlayersService = game:GetService("Players")
local WorkspaceService = game:GetService("Workspace")
local LocalPlayer = PlayersService.LocalPlayer

local existingGui = CoreGuiService:FindFirstChild("Matrix_MIG") or (LocalPlayer and LocalPlayer:WaitForChild("PlayerGui", 5):FindFirstChild("Matrix_MIG"))
if existingGui then existingGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Matrix_MIG"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, _ = pcall(function() ScreenGui.Parent = CoreGuiService end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Configuration States (HITBOX NOW DEFAULTS TO OFF)
_G.HitboxSize = 2
_G.HitboxTransparency = 1
_G.HitboxEnabled = false 

_G.ESP_Names = false
_G.ESP_Distances = false
_G.ESP_Inventory = false

_G.InstantInteract = false
_G.FPSBooster = false

local WhitelistTable = {}
local OppsTable = {}
local originalSettings = {}
local originalHitboxSizes = {}

----------------------------------------------------
-- UI BUILDING ENGINE (MATRIX THEME - BOLD FONT)
----------------------------------------------------
local ToggleMenuButton = Instance.new("TextButton")
ToggleMenuButton.Name = "ToggleMenuButton"
ToggleMenuButton.Size = UDim2.new(0, 50, 0, 50)
ToggleMenuButton.Position = UDim2.new(0, 20, 0, 20)
ToggleMenuButton.BackgroundColor3 = Color3.fromRGB(15, 17, 20)
ToggleMenuButton.BorderSizePixel = 0
ToggleMenuButton.Text = "M"
ToggleMenuButton.TextColor3 = Color3.fromRGB(45, 140, 245)
ToggleMenuButton.Font = Enum.Font.GothamBold
ToggleMenuButton.TextSize = 24
ToggleMenuButton.Active = true
ToggleMenuButton.Draggable = true
ToggleMenuButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleMenuButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 2
ToggleStroke.Color = Color3.fromRGB(45, 140, 245)
ToggleStroke.Parent = ToggleMenuButton

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 540, 0, 380)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local WindowStroke = Instance.new("UIStroke")
WindowStroke.Thickness = 2
WindowStroke.Color = Color3.fromRGB(45, 140, 245)
WindowStroke.Parent = MainFrame

----------------------------------------------------
-- PASSWORD KEY SYSTEM INTERFACE
----------------------------------------------------
local PasswordFrame = Instance.new("Frame")
PasswordFrame.Name = "PasswordFrame"
PasswordFrame.Size = UDim2.new(0, 350, 0, 200)
PasswordFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
PasswordFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 20)
PasswordFrame.BorderSizePixel = 0
PasswordFrame.Active = true
PasswordFrame.Draggable = true
PasswordFrame.Parent = ScreenGui

local PassCorner = Instance.new("UICorner")
PassCorner.CornerRadius = UDim.new(0, 10)
PassCorner.Parent = PasswordFrame

local PassStroke = Instance.new("UIStroke")
PassStroke.Thickness = 2
PassStroke.Color = Color3.fromRGB(45, 140, 245)
PassStroke.Parent = PasswordFrame

local PassTitle = Instance.new("TextLabel")
PassTitle.Size = UDim2.new(1, 0, 0, 40)
PassTitle.BackgroundTransparency = 1
PassTitle.Text = "ENTER SYSTEM KEY"
PassTitle.TextColor3 = Color3.fromRGB(45, 140, 245)
PassTitle.Font = Enum.Font.GothamBold
PassTitle.TextSize = 14
PassTitle.Parent = PasswordFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0, 280, 0, 40)
KeyInput.Position = UDim2.new(0.5, -140, 0.4, -20)
KeyInput.BackgroundColor3 = Color3.fromRGB(25, 27, 30)
KeyInput.BorderSizePixel = 0
KeyInput.Text = ""
KeyInput.PlaceholderText = "Enter Password Here..."
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Font = Enum.Font.GothamMedium
KeyInput.TextSize = 12
KeyInput.Parent = PasswordFrame
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0, 150, 0, 35)
SubmitBtn.Position = UDim2.new(0.5, -75, 0.75, -10)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(45, 140, 245)
SubmitBtn.Text = "Verify Key"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 12
SubmitBtn.Parent = PasswordFrame
Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 6)

local ErrorLabel = Instance.new("TextLabel")
ErrorLabel.Size = UDim2.new(1, 0, 0, 20)
ErrorLabel.Position = UDim2.new(0, 0, 0.6, 0)
ErrorLabel.BackgroundTransparency = 1
ErrorLabel.Text = ""
ErrorLabel.TextColor3 = Color3.fromRGB(240, 100, 110)
ErrorLabel.Font = Enum.Font.GothamSemibold
ErrorLabel.TextSize = 11
ErrorLabel.Parent = PasswordFrame

----------------------------------------------------
-- NAVIGATION & PAGES INFRASTRUCTURE
----------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 45)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "MATRIX"
TitleLabel.TextColor3 = Color3.fromRGB(45, 140, 245)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.Parent = Sidebar

local NavContainer = Instance.new("Frame")
NavContainer.Size = UDim2.new(1, 0, 1, -100)
NavContainer.Position = UDim2.new(0, 0, 0, 45)
NavContainer.BackgroundTransparency = 1
NavContainer.Parent = Sidebar

local NavLayout = Instance.new("UIListLayout")
NavLayout.Parent = NavContainer
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Padding = UDim.new(0, 4)
NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createNavButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 115, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(25, 27, 30)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 185, 190)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.LayoutOrder = order
    btn.Parent = NavContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local CombatTabBtn = createNavButton("Combat", 1)
local VisualsTabBtn = createNavButton("Visuals", 2)
local WhitelistTabBtn = createNavButton("Whitelist", 3)
local OppsTabBtn = createNavButton("OPPS", 4)
local OPTabBtn = createNavButton("OP Features", 5)
local MiscTabBtn = createNavButton("Misc", 6)

local ExitButton = Instance.new("TextButton")
ExitButton.Size = UDim2.new(0, 115, 0, 32)
ExitButton.Position = UDim2.new(0.5, -57, 1, -40)
ExitButton.BackgroundColor3 = Color3.fromRGB(55, 20, 25)
ExitButton.BorderSizePixel = 0
ExitButton.Text = "Exit"
ExitButton.TextColor3 = Color3.fromRGB(240, 100, 110)
ExitButton.Font = Enum.Font.GothamBold
ExitButton.TextSize = 12
ExitButton.Parent = Sidebar
Instance.new("UICorner", ExitButton).CornerRadius = UDim.new(0, 6)

local ContentWindow = Instance.new("Frame")
ContentWindow.Size = UDim2.new(1, -155, 1, -30)
ContentWindow.Position = UDim2.new(0, 140, 0, 15)
ContentWindow.BackgroundColor3 = Color3.fromRGB(20, 22, 25)
ContentWindow.BorderSizePixel = 0
ContentWindow.Parent = MainFrame

Instance.new("UICorner", ContentWindow).CornerRadius = UDim.new(0, 8)

local SectionTitle = Instance.new("TextLabel")
SectionTitle.Size = UDim2.new(1, -20, 0, 35)
SectionTitle.Position = UDim2.new(0, 15, 0, 10)
SectionTitle.BackgroundTransparency = 1
SectionTitle.Text = "COMBAT CONFIG"
SectionTitle.TextColor3 = Color3.fromRGB(45, 140, 245)
SectionTitle.Font = Enum.Font.GothamBold
SectionTitle.TextSize = 12
SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
SectionTitle.Parent = ContentWindow

-- Canvas Display Pages
local CombatPage = Instance.new("Frame"); CombatPage.Size = UDim2.new(1, -30, 1, -55); CombatPage.Position = UDim2.new(0, 15, 0, 45); CombatPage.BackgroundTransparency = 1; CombatPage.Visible = true; CombatPage.Parent = ContentWindow
local VisualsPage = Instance.new("Frame"); VisualsPage.Size = UDim2.new(1, -30, 1, -55); VisualsPage.Position = UDim2.new(0, 15, 0, 45); VisualsPage.BackgroundTransparency = 1; VisualsPage.Visible = false; VisualsPage.Parent = ContentWindow
local WhitelistPage = Instance.new("ScrollingFrame"); WhitelistPage.Size = UDim2.new(1, -30, 1, -55); WhitelistPage.Position = UDim2.new(0, 15, 0, 45); WhitelistPage.BackgroundTransparency = 1; WhitelistPage.Visible = false; WhitelistPage.ScrollBarThickness = 4; WhitelistPage.CanvasSize = UDim2.new(0,0,0,0); WhitelistPage.Parent = ContentWindow
local OppsPage = Instance.new("ScrollingFrame"); OppsPage.Size = UDim2.new(1, -30, 1, -55); OppsPage.Position = UDim2.new(0, 15, 0, 45); OppsPage.BackgroundTransparency = 1; OppsPage.Visible = false; OppsPage.ScrollBarThickness = 4; OppsPage.CanvasSize = UDim2.new(0,0,0,0); OppsPage.Parent = ContentWindow
local OPPage = Instance.new("Frame"); OPPage.Size = UDim2.new(1, -30, 1, -55); OPPage.Position = UDim2.new(0, 15, 0, 45); OPPage.BackgroundTransparency = 1; OPPage.Visible = false; OPPage.Parent = ContentWindow
local MiscPage = Instance.new("Frame"); MiscPage.Size = UDim2.new(1, -30, 1, -55); MiscPage.Position = UDim2.new(0, 15, 0, 45); MiscPage.BackgroundTransparency = 1; MiscPage.Visible = false; MiscPage.Parent = ContentWindow

local WhiteListLayout = Instance.new("UIListLayout"); WhiteListLayout.Parent = WhitelistPage; WhiteListLayout.Padding = UDim.new(0, 5); WhiteListLayout.SortOrder = Enum.SortOrder.Name
local OppsListLayout = Instance.new("UIListLayout"); OppsListLayout.Parent = OppsPage; OppsListLayout.Padding = UDim.new(0, 5); OppsListLayout.SortOrder = Enum.SortOrder.Name

----------------------------------------------------
-- INTERACTIVE PAGE BUILD DETAILS
----------------------------------------------------
-- Hitbox Master Toggle (Added to Combat Frame)
local CombatHitboxToggle = Instance.new("TextButton")
CombatHitboxToggle.Size = UDim2.new(0, 220, 0, 35)
CombatHitboxToggle.Position = UDim2.new(0, 0, 0, 0)
CombatHitboxToggle.BackgroundColor3 = Color3.fromRGB(150, 35, 45)
CombatHitboxToggle.Text = "HITBOX OVERRIDE: DISABLED"
CombatHitboxToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
CombatHitboxToggle.Font = Enum.Font.GothamBold
CombatHitboxToggle.TextSize = 12
CombatHitboxToggle.Parent = CombatPage
Instance.new("UICorner", CombatHitboxToggle).CornerRadius = UDim.new(0, 6)

local SizeText = Instance.new("TextLabel")
SizeText.Size = UDim2.new(1, 0, 0, 30)
SizeText.Position = UDim2.new(0, 0, 0, 45)
SizeText.BackgroundTransparency = 1
SizeText.Text = "Upper Torso Size: 2 Studs"
SizeText.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeText.Font = Enum.Font.GothamBold
SizeText.TextSize = 13
SizeText.TextXAlignment = Enum.TextXAlignment.Left
SizeText.Parent = CombatPage

local SizeMinus = Instance.new("TextButton")
SizeMinus.Size = UDim2.new(0, 45, 0, 30); SizeMinus.Position = UDim2.new(0, 0, 0, 75); SizeMinus.BackgroundColor3 = Color3.fromRGB(30, 33, 38); SizeMinus.Text = "[ - ]"; SizeMinus.TextColor3 = Color3.fromRGB(255, 255, 255); SizeMinus.Font = Enum.Font.GothamBold; SizeMinus.Parent = CombatPage; Instance.new("UICorner", SizeMinus).CornerRadius = UDim.new(0, 4)

local SizePlus = Instance.new("TextButton")
SizePlus.Size = UDim2.new(0, 45, 0, 30); SizePlus.Position = UDim2.new(0, 55, 0, 75); SizePlus.BackgroundColor3 = Color3.fromRGB(30, 33, 38); SizePlus.Text = "[ + ]"; SizePlus.TextColor3 = Color3.fromRGB(255, 255, 255); SizePlus.Font = Enum.Font.GothamBold; SizePlus.Parent = CombatPage; Instance.new("UICorner", SizePlus).CornerRadius = UDim.new(0, 4)

local TransText = Instance.new("TextLabel")
TransText.Size = UDim2.new(1, 0, 0, 30); TransText.Position = UDim2.new(0, 0, 0, 115); TransText.BackgroundTransparency = 1; TransText.Text = "Hitbox Transparency: 1 / 10"; TransText.TextColor3 = Color3.fromRGB(255, 255, 255); TransText.Font = Enum.Font.GothamBold; TransText.TextSize = 13; TransText.TextXAlignment = Enum.TextXAlignment.Left; TransText.Parent = CombatPage

local TransMinus = Instance.new("TextButton")
TransMinus.Size = UDim2.new(0, 45, 0, 30); TransMinus.Position = UDim2.new(0, 0, 0, 145); TransMinus.BackgroundColor3 = Color3.fromRGB(30, 33, 38); TransMinus.Text = "[ - ]"; TransMinus.TextColor3 = Color3.fromRGB(255, 255, 255); TransMinus.Font = Enum.Font.GothamBold; TransMinus.Parent = CombatPage; Instance.new("UICorner", TransMinus).CornerRadius = UDim.new(0, 4)

local TransPlus = Instance.new("TextButton")
TransPlus.Size = UDim2.new(0, 45, 0, 30); TransPlus.Position = UDim2.new(0, 55, 0, 145); TransPlus.BackgroundColor3 = Color3.fromRGB(30, 33, 38); TransPlus.Text = "[ + ]"; TransPlus.TextColor3 = Color3.fromRGB(255, 255, 255); TransPlus.Font = Enum.Font.GothamBold; TransPlus.Parent = CombatPage; Instance.new("UICorner", TransPlus).CornerRadius = UDim.new(0, 4)

local function createToggle(text, yPos, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 220, 0, 38)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(150, 35, 45)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local ToggleNameBtn = createToggle("ESP NAME", 10, VisualsPage)
local ToggleDistBtn = createToggle("ESP DISTANCE", 55, VisualsPage)
local ToggleInvBtn = createToggle("ESP INVENTORY", 100, VisualsPage)

local ToggleInteractBtn = createToggle("INSTANT INTERACT", 10, OPPage)
local ToggleFPSBtn = createToggle("FPS BOOSTER", 55, OPPage)

local ToggleStateBtn = Instance.new("TextButton")
ToggleStateBtn.Size = UDim2.new(0, 200, 0, 40)
ToggleStateBtn.Position = UDim2.new(0, 0, 0, 10)
ToggleStateBtn.BackgroundColor3 = Color3.fromRGB(150, 35, 45)
ToggleStateBtn.Text = "SYSTEM STATUS: PAUSED"
ToggleStateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleStateBtn.Font = Enum.Font.GothamBold
ToggleStateBtn.TextSize = 12
ToggleStateBtn.Parent = MiscPage
Instance.new("UICorner", ToggleStateBtn).CornerRadius = UDim.new(0, 6)

----------------------------------------------------
-- INTERACTIVE LIST RENDERING (WHITELIST / OPPS)
----------------------------------------------------
local function updatePlayerLists()
    for _, child in ipairs(WhitelistPage:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, child in ipairs(OppsPage:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    for _, player in ipairs(PlayersService:GetPlayers()) do
        if player ~= LocalPlayer then
            local wBtn = Instance.new("TextButton")
            wBtn.Name = player.Name
            wBtn.Size = UDim2.new(1, -10, 0, 30)
            wBtn.Font = Enum.Font.GothamBold
            wBtn.TextSize = 12
            wBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", wBtn).CornerRadius = UDim.new(0, 4)
            
            if WhitelistTable[player.Name] then
                wBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
                wBtn.Text = player.Name .. " (WHITELISTED)"
            else
                wBtn.BackgroundColor3 = Color3.fromRGB(30, 33, 38)
                wBtn.Text = player.Name .. " (NEUTRAL)"
            end
            wBtn.Parent = WhitelistPage

            wBtn.MouseButton1Click:Connect(function()
                WhitelistTable[player.Name] = not WhitelistTable[player.Name]
                if WhitelistTable[player.Name] then OppsTable[player.Name] = nil end
                updatePlayerLists()
            end)

            local oBtn = Instance.new("TextButton")
            oBtn.Name = player.Name
            oBtn.Size = UDim2.new(1, -10, 0, 30)
            oBtn.Font = Enum.Font.GothamBold
            oBtn.TextSize = 12
            oBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", oBtn).CornerRadius = UDim.new(0, 4)

            if OppsTable[player.Name] then
                oBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 40)
                oBtn.Text = player.Name .. " [OPP]"
            else
                oBtn.BackgroundColor3 = Color3.fromRGB(30, 33, 38)
                oBtn.Text = player.Name .. " (NEUTRAL)"
            end
            oBtn.Parent = OppsPage

            oBtn.MouseButton1Click:Connect(function()
                OppsTable[player.Name] = not OppsTable[player.Name]
                if OppsTable[player.Name] then WhitelistTable[player.Name] = nil end
                updatePlayerLists()
            end)
        end
    end
    WhitelistPage.CanvasSize = UDim2.new(0, 0, 0, WhiteListLayout.AbsoluteContentSize.Y)
    OppsPage.CanvasSize = UDim2.new(0, 0, 0, OppsListLayout.AbsoluteContentSize.Y)
end

PlayersService.PlayerAdded:Connect(updatePlayerLists)
PlayersService.PlayerRemoving:Connect(function(player)
    WhitelistTable[player.Name] = nil
    OppsTable[player.Name] = nil
    updatePlayerLists()
end)

----------------------------------------------------
-- BACKEND LINK MANAGER & UI UTILITIES
----------------------------------------------------
ToggleMenuButton.MouseButton1Click:Connect(function()
    if not PasswordFrame.Visible then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Completed the missing navigation engine function
local function switch
