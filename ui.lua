--[[
    Potassium UI Library - Neverlose.cc Style
    Full 1:1 recreation for Roblox Executors
    Works with: Synapse X, Fluxus, Potassium, Script-Ware, etc.
]]

local Potassium = {}
Potassium.__index = Potassium

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Config
local COLORS = {
    Background = Color3.fromRGB(13, 13, 20),
    BackgroundDark = Color3.fromRGB(11, 11, 18),
    BackgroundLight = Color3.fromRGB(22, 22, 30),
    Surface = Color3.fromRGB(16, 16, 24),
    SurfaceHover = Color3.fromRGB(20, 20, 28),
    Border = Color3.fromRGB(30, 30, 40),
    BorderLight = Color3.fromRGB(40, 40, 55),
    Accent = Color3.fromRGB(129, 140, 248),
    AccentDark = Color3.fromRGB(99, 102, 241),
    AccentDim = Color3.fromRGB(99, 102, 241),
    Text = Color3.fromRGB(196, 196, 204),
    TextDim = Color3.fromRGB(153, 153, 153),
    TextDark = Color3.fromRGB(85, 85, 85),
    TextMuted = Color3.fromRGB(68, 68, 68),
    Success = Color3.fromRGB(34, 197, 94),
    Warning = Color3.fromRGB(245, 158, 11),
    Error = Color3.fromRGB(239, 68, 68),
    ToggleOff = Color3.fromRGB(40, 40, 50),
    ToggleKnobOff = Color3.fromRGB(85, 85, 85),
    SliderTrack = Color3.fromRGB(35, 35, 45),
    Transparent = Color3.fromRGB(0, 0, 0),
}

local FONT = Font.new("rbxasset://fonts/families/GothamSSm.json")
local FONT_BOLD = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
local FONT_SEMI = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
local FONT_MEDIUM = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
local FONT_MONO = Font.new("rbxasset://fonts/families/RobotoMono.json")

-- Utility Functions
local function Create(class, properties, children)
    local inst = Instance.new(class)
    for k, v in pairs(properties or {}) do
        if k ~= "Parent" then
            pcall(function() inst[k] = v end)
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if properties and properties.Parent then
        inst.Parent = properties.Parent
    end
    return inst
end

local function Tween(obj, props, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(obj, tweenInfo, props)
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = parent,
    })
end

local function AddStroke(parent, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color or COLORS.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = parent,
    })
end

local function AddPadding(parent, top, right, bottom, left)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, top or 0),
        PaddingRight = UDim.new(0, right or top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
        PaddingLeft = UDim.new(0, left or right or top or 0),
        Parent = parent,
    })
end

local function AddListLayout(parent, direction, padding, hAlign, vAlign, sortOrder)
    return Create("UIListLayout", {
        FillDirection = direction or Enum.FillDirection.Vertical,
        Padding = UDim.new(0, padding or 0),
        HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left,
        VerticalAlignment = vAlign or Enum.VerticalAlignment.Top,
        SortOrder = sortOrder or Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

local function Ripple(button)
    -- subtle hover effect
end

local function DestroyExisting()
    local existing = CoreGui:FindFirstChild("PotassiumUI")
    if existing then existing:Destroy() end
end

-- =============================================
-- MAIN LIBRARY
-- =============================================

function Potassium:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Potassium"
    local size = config.Size or UDim2.new(0, 1050, 0, 620)
    local menuKey = config.MenuKey or Enum.KeyCode.Insert

    DestroyExisting()

    local Library = {}
    Library.Pages = {}
    Library.ActivePage = nil
    Library.Toggled = true
    Library.Flags = {}
    Library.Connections = {}
    Library.Notifications = {}

    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "PotassiumUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 999,
    })

    -- Try to parent to CoreGui, fallback to PlayerGui
    pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- ==================
    -- MAIN WINDOW FRAME
    -- ==================
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
        BackgroundColor3 = COLORS.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui,
    })
    AddCorner(MainFrame, 12)
    AddStroke(MainFrame, COLORS.Border, 1)

    -- Drop Shadow
    local Shadow = Create("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0, -30, 0, -30),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.3,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 0,
        Parent = MainFrame,
    })

    -- ==================
    -- TITLEBAR
    -- ==================
    local Titlebar = Create("Frame", {
        Name = "Titlebar",
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = COLORS.BackgroundDark,
        BorderSizePixel = 0,
        Parent = MainFrame,
    })
    AddCorner(Titlebar, 12)
    -- Fix bottom corners
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = COLORS.BackgroundDark,
        BorderSizePixel = 0,
        Parent = Titlebar,
    })
    -- Titlebar bottom border
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = COLORS.Border,
        BorderSizePixel = 0,
        Parent = Titlebar,
    })

    -- Logo icon (hexagon shape via text)
    local LogoFrame = Create("Frame", {
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Parent = Titlebar,
    })

    local LogoIcon = Create("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 0, 0.5, -9),
        BackgroundColor3 = COLORS.Accent,
        BorderSizePixel = 0,
        Parent = LogoFrame,
    })
    AddCorner(LogoIcon, 4)

    local LogoInner = Create("Frame", {
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(0.5, -4, 0.5, -4),
        BackgroundColor3 = COLORS.BackgroundDark,
        BorderSizePixel = 0,
        Parent = LogoIcon,
    })
    AddCorner(LogoInner, 2)

    local LogoText = Create("TextLabel", {
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(0, 26, 0, 0),
        BackgroundTransparency = 1,
        Text = string.upper(title),
        TextColor3 = COLORS.Text,
        FontFace = FONT_SEMI,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = LogoFrame,
    })

    -- Window Controls
    local Controls = Create("Frame", {
        Size = UDim2.new(0, 90, 1, 0),
        Position = UDim2.new(1, -100, 0, 0),
        BackgroundTransparency = 1,
        Parent = Titlebar,
    })
    AddListLayout(Controls, Enum.FillDirection.Horizontal, 2, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

    local function CreateTitleBtn(name, color)
        local btn = Create("TextButton", {
            Name = name,
            Size = UDim2.new(0, 28, 0, 28),
            BackgroundColor3 = COLORS.BackgroundLight,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Parent = Controls,
        })
        AddCorner(btn, 4)

        local dot = Create("Frame", {
            Size = UDim2.new(0, 10, 0, 2),
            Position = UDim2.new(0.5, -5, 0.5, -1),
            BackgroundColor3 = COLORS.TextDark,
            BorderSizePixel = 0,
            Parent = btn,
        })
        AddCorner(dot, 1)

        if name == "Close" then
            dot.Size = UDim2.new(0, 10, 0, 10)
            dot.Position = UDim2.new(0.5, -5, 0.5, -5)
            dot.BackgroundTransparency = 1

            local x1 = Create("Frame", {
                Size = UDim2.new(0, 12, 0, 1.5),
                Position = UDim2.new(0.5, -6, 0.5, -0.75),
                BackgroundColor3 = COLORS.TextDark,
                BorderSizePixel = 0,
                Rotation = 45,
                Parent = dot,
            })
            local x2 = Create("Frame", {
                Size = UDim2.new(0, 12, 0, 1.5),
                Position = UDim2.new(0.5, -6, 0.5, -0.75),
                BackgroundColor3 = COLORS.TextDark,
                BorderSizePixel = 0,
                Rotation = -45,
                Parent = dot,
            })
        elseif name == "Maximize" then
            dot.Size = UDim2.new(0, 9, 0, 9)
            dot.Position = UDim2.new(0.5, -4.5, 0.5, -4.5)
            dot.BackgroundTransparency = 1
            AddStroke(dot, COLORS.TextDark, 1.5)
            AddCorner(dot, 2)
        end

        btn.MouseEnter:Connect(function()
            if name == "Close" then
                Tween(btn, {BackgroundTransparency = 0, BackgroundColor3 = COLORS.Error}, 0.15)
            else
                Tween(btn, {BackgroundTransparency = 0}, 0.15)
            end
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundTransparency = 1}, 0.15)
        end)

        return btn
    end

    local MinBtn = CreateTitleBtn("Minimize")
    local MaxBtn = CreateTitleBtn("Maximize")
    local CloseBtn = CreateTitleBtn("Close")

    CloseBtn.MouseButton1Click:Connect(function()
        Library.Toggled = false
        Tween(MainFrame, {Size = UDim2.new(0, size.X.Offset, 0, 0), BackgroundTransparency = 1}, 0.3)
        task.delay(0.35, function()
            MainFrame.Visible = false
        end)
    end)

    -- ==================
    -- DRAGGING
    -- ==================
    do
        local dragging, dragStart, startPos
        Titlebar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
            end
        end)
        Titlebar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    -- ==================
    -- BODY CONTAINER
    -- ==================
    local Body = Create("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -38 - 28),
        Position = UDim2.new(0, 0, 0, 38),
        BackgroundTransparency = 1,
        Parent = MainFrame,
    })

    -- ==================
    -- SIDEBAR
    -- ==================
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 58, 1, 0),
        BackgroundColor3 = COLORS.BackgroundDark,
        BorderSizePixel = 0,
        Parent = Body,
    })
    -- Border right
    Create("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = COLORS.Border,
        BorderSizePixel = 0,
        Parent = Sidebar,
    })

    local SidebarNav = Create("Frame", {
        Name = "Nav",
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundTransparency = 1,
        Parent = Sidebar,
    })
    AddListLayout(SidebarNav, Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Center)

    local SidebarButtons = {}

    local function CreateSidebarIcon(name, iconId, layoutOrder)
        local btn = Create("TextButton", {
            Name = name,
            Size = UDim2.new(0, 42, 0, 42),
            BackgroundColor3 = COLORS.Accent,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = layoutOrder,
            Parent = SidebarNav,
        })
        AddCorner(btn, 8)

        local icon = Create("ImageLabel", {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0.5, -10, 0.5, -10),
            BackgroundTransparency = 1,
            Image = iconId,
            ImageColor3 = COLORS.TextDark,
            Parent = btn,
        })

        -- Active indicator bar (left)
        local indicator = Create("Frame", {
            Name = "Indicator",
            Size = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, -8, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = COLORS.Accent,
            BorderSizePixel = 0,
            Parent = btn,
        })
        AddCorner(indicator, 2)

        btn.MouseEnter:Connect(function()
            if not btn:GetAttribute("Active") then
                Tween(icon, {ImageColor3 = COLORS.TextDim}, 0.15)
            end
        end)
        btn.MouseLeave:Connect(function()
            if not btn:GetAttribute("Active") then
                Tween(icon, {ImageColor3 = COLORS.TextDark}, 0.15)
            end
        end)

        SidebarButtons[name] = {Button = btn, Icon = icon, Indicator = indicator}
        return btn
    end

    local function SetActiveSidebar(name)
        for n, data in pairs(SidebarButtons) do
            if n == name then
                data.Button:SetAttribute("Active", true)
                Tween(data.Icon, {ImageColor3 = COLORS.Accent}, 0.2)
                Tween(data.Button, {BackgroundTransparency = 0.88}, 0.2)
                Tween(data.Indicator, {Size = UDim2.new(0, 3, 0, 20)}, 0.2)
            else
                data.Button:SetAttribute("Active", false)
                Tween(data.Icon, {ImageColor3 = COLORS.TextDark}, 0.2)
                Tween(data.Button, {BackgroundTransparency = 1}, 0.2)
                Tween(data.Indicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.2)
            end
        end
    end

    -- Sidebar separator
    local function CreateSidebarSeparator(order)
        local sep = Create("Frame", {
            Size = UDim2.new(0, 26, 0, 1),
            BackgroundColor3 = COLORS.Border,
            BorderSizePixel = 0,
            LayoutOrder = order,
            Parent = SidebarNav,
        })
        return sep
    end

    -- Create sidebar buttons with Roblox asset icons
    -- Using common free icon IDs
    CreateSidebarIcon("Rage", "rbxassetid://7733960981", 1)         -- crosshair
    CreateSidebarIcon("Legit", "rbxassetid://7734053495", 2)        -- eye
    CreateSidebarIcon("Visuals", "rbxassetid://7734009498", 3)      -- image
    CreateSidebarIcon("Misc", "rbxassetid://7733756006", 4)         -- clock
    CreateSidebarSeparator(5)
    CreateSidebarIcon("Scripts", "rbxassetid://7733658504", 6)      -- code
    CreateSidebarIcon("Executor", "rbxassetid://7734077849", 7)     -- terminal
    CreateSidebarSeparator(8)
    CreateSidebarIcon("Configs", "rbxassetid://7733717858", 9)      -- file
    CreateSidebarIcon("Settings", "rbxassetid://7734099087", 10)    -- settings gear

    -- ==================
    -- CONTENT AREA
    -- ==================
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -58, 1, 0),
        Position = UDim2.new(0, 58, 0, 0),
        BackgroundTransparency = 1,
        Parent = Body,
    })

    -- ==================
    -- STATUS BAR
    -- ==================
    local StatusBar = Create("Frame", {
        Name = "StatusBar",
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 1, -28),
        BackgroundColor3 = COLORS.BackgroundDark,
        BorderSizePixel = 0,
        Parent = MainFrame,
    })
    AddCorner(StatusBar, 12)
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = COLORS.BackgroundDark,
        BorderSizePixel = 0,
        Parent = StatusBar,
    })
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = COLORS.Border,
        BorderSizePixel = 0,
        Parent = StatusBar,
    })

    -- Status content
    local StatusContent = Create("Frame", {
        Size = UDim2.new(1, -28, 0, 28),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Parent = StatusBar,
    })
    AddListLayout(StatusContent, Enum.FillDirection.Horizontal, 16, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

    -- Status dot
    local StatusDotFrame = Create("Frame", {
        Size = UDim2.new(0, 70, 0, 28),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Parent = StatusContent,
    })
    local StatusDot = Create("Frame", {
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0, 0, 0.5, -3),
        BackgroundColor3 = COLORS.Success,
        BorderSizePixel = 0,
        Parent = StatusDotFrame,
    })
    AddCorner(StatusDot, 3)
    Create("TextLabel", {
        Size = UDim2.new(0, 60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "Connected",
        TextColor3 = COLORS.Success,
        FontFace = FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = StatusDotFrame,
    })

    local UptimeLabel = Create("TextLabel", {
        Size = UDim2.new(0, 120, 0, 28),
        BackgroundTransparency = 1,
        Text = "Uptime: 00:00:00",
        TextColor3 = COLORS.TextMuted,
        FontFace = FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        Parent = StatusContent,
    })

    local GameLabel = Create("TextLabel", {
        Size = UDim2.new(0, 100, 0, 28),
        BackgroundTransparency = 1,
        Text = "Game: " .. game.PlaceId,
        TextColor3 = COLORS.TextMuted,
        FontFace = FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 3,
        Parent = StatusContent,
    })

    -- Right side status
    local StatusRight = Create("Frame", {
        Size = UDim2.new(0, 200, 0, 28),
        Position = UDim2.new(1, -214, 0, 0),
        BackgroundTransparency = 1,
        Parent = StatusBar,
    })
    AddListLayout(StatusRight, Enum.FillDirection.Horizontal, 16, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

    local PlayerCount = Create("TextLabel", {
        Size = UDim2.new(0, 70, 0, 28),
        BackgroundTransparency = 1,
        Text = #Players:GetPlayers() .. " Players",
        TextColor3 = COLORS.TextMuted,
        FontFace = FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        LayoutOrder = 1,
        Parent = StatusRight,
    })

    local FPSLabel = Create("TextLabel", {
        Size = UDim2.new(0, 50, 0, 28),
        BackgroundTransparency = 1,
        Text = "FPS: 60",
        TextColor3 = COLORS.TextMuted,
        FontFace = FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        LayoutOrder = 2,
        Parent = StatusRight,
    })

    -- Uptime & FPS counters
    local startTime = tick()
    local fpsCounter = 0
    local lastFpsUpdate = tick()

    RunService.RenderStepped:Connect(function()
        fpsCounter += 1
        if tick() - lastFpsUpdate >= 1 then
            FPSLabel.Text = "FPS: " .. fpsCounter
            fpsCounter = 0
            lastFpsUpdate = tick()
        end

        local elapsed = tick() - startTime
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = math.floor(elapsed % 60)
        UptimeLabel.Text = string.format("Uptime: %02d:%02d:%02d", h, m, s)

        PlayerCount.Text = #Players:GetPlayers() .. " Players"
    end)

    -- ==================
    -- PAGE SYSTEM
    -- ==================

    function Library:CreatePage(config)
        config = config or {}
        local pageName = config.Name or "Page"
        local pageIcon = config.Icon or ""

        local Page = {}
        Page.Name = pageName
        Page.Tabs = {}
        Page.ActiveTab = nil

        -- Page container
        local PageFrame = Create("Frame", {
            Name = pageName,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = ContentArea,
        })

        -- Tab header
        local TabHeader = Create("Frame", {
            Name = "TabHeader",
            Size = UDim2.new(1, 0, 0, 46),
            BackgroundColor3 = COLORS.Background,
            BorderSizePixel = 0,
            Parent = PageFrame,
        })
        Create("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = COLORS.Border,
            BorderSizePixel = 0,
            Parent = TabHeader,
        })

        local TabContainer = Create("Frame", {
            Size = UDim2.new(1, -220, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Parent = TabHeader,
        })
        AddListLayout(TabContainer, Enum.FillDirection.Horizontal, 0, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

        -- Search bar
        local SearchFrame = Create("Frame", {
            Size = UDim2.new(0, 200, 0, 30),
            Position = UDim2.new(1, -210, 0.5, -15),
            BackgroundColor3 = COLORS.Surface,
            BorderSizePixel = 0,
            Parent = TabHeader,
        })
        AddCorner(SearchFrame, 6)
        AddStroke(SearchFrame, COLORS.Border, 1)

        local SearchIcon = Create("ImageLabel", {
            Size = UDim2.new(0, 13, 0, 13),
            Position = UDim2.new(0, 10, 0.5, -6.5),
            BackgroundTransparency = 1,
            Image = "rbxassetid://7733756006",
            ImageColor3 = COLORS.TextMuted,
            Parent = SearchFrame,
        })

        local SearchBox = Create("TextBox", {
            Size = UDim2.new(1, -36, 1, 0),
            Position = UDim2.new(0, 32, 0, 0),
            BackgroundTransparency = 1,
            Text = "",
            PlaceholderText = "Search settings...",
            PlaceholderColor3 = COLORS.TextMuted,
            TextColor3 = COLORS.TextDim,
            FontFace = FONT,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            Parent = SearchFrame,
        })

        -- Tab content area
        local TabContent = Create("ScrollingFrame", {
            Name = "TabContent",
            Size = UDim2.new(1, 0, 1, -46),
            Position = UDim2.new(0, 0, 0, 46),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = COLORS.BorderLight,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BorderSizePixel = 0,
            Parent = PageFrame,
        })
        AddPadding(TabContent, 16, 16, 16, 16)

        local ColumnsFrame = Create("Frame", {
            Name = "Columns",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = TabContent,
        })
        AddListLayout(ColumnsFrame, Enum.FillDirection.Horizontal, 16)

        -- ==================
        -- TAB SYSTEM
        -- ==================
        function Page:CreateTab(tabConfig)
            tabConfig = tabConfig or {}
            local tabName = tabConfig.Name or "Tab"
            local tabIcon = tabConfig.Icon or ""

            local Tab = {}
            Tab.Name = tabName
            Tab.Sections = {}

            -- Tab button
            local TabBtn = Create("TextButton", {
                Name = tabName,
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                Parent = TabContainer,
            })
            AddPadding(TabBtn, 0, 18, 0, 18)

            local TabBtnContent = Create("Frame", {
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Parent = TabBtn,
            })
            AddListLayout(TabBtnContent, Enum.FillDirection.Horizontal, 7, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

            if tabIcon ~= "" then
                Create("ImageLabel", {
                    Size = UDim2.new(0, 14, 0, 14),
                    BackgroundTransparency = 1,
                    Image = tabIcon,
                    ImageColor3 = COLORS.TextDark,
                    LayoutOrder = 1,
                    Parent = TabBtnContent,
                })
            end

            local TabLabel = Create("TextLabel", {
                Size = UDim2.new(0, 0, 0, 14),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Text = tabName,
                TextColor3 = COLORS.TextDark,
                FontFace = FONT_MEDIUM,
                TextSize = 12,
                LayoutOrder = 2,
                Parent = TabBtnContent,
            })

            -- Tab underline indicator
            local TabIndicator = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 2),
                Position = UDim2.new(0, 0, 1, -2),
                BackgroundColor3 = COLORS.Accent,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = TabBtn,
            })

            -- Column containers for this tab
            local LeftColumn = Create("Frame", {
                Name = tabName .. "_Left",
                Size = UDim2.new(0.5, -8, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Visible = false,
                LayoutOrder = 1,
                Parent = ColumnsFrame,
            })
            AddListLayout(LeftColumn, Enum.FillDirection.Vertical, 12)

            local RightColumn = Create("Frame", {
                Name = tabName .. "_Right",
                Size = UDim2.new(0.5, -8, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Visible = false,
                LayoutOrder = 2,
                Parent = ColumnsFrame,
            })
            AddListLayout(RightColumn, Enum.FillDirection.Vertical, 12)

            local function ActivateTab()
                for _, t in ipairs(Page.Tabs) do
                    t._label.TextColor3 = COLORS.TextDark
                    t._indicator.BackgroundTransparency = 1
                    t._leftCol.Visible = false
                    t._rightCol.Visible = false
                    if t._icon then
                        t._icon.ImageColor3 = COLORS.TextDark
                    end
                end
                TabLabel.TextColor3 = COLORS.Text
                TabIndicator.BackgroundTransparency = 0
                LeftColumn.Visible = true
                RightColumn.Visible = true
                if tabIcon ~= "" then
                    TabBtnContent:FindFirstChildWhichIsA("ImageLabel").ImageColor3 = COLORS.Text
                end
                Page.ActiveTab = Tab
            end

            TabBtn.MouseButton1Click:Connect(ActivateTab)
            TabBtn.MouseEnter:Connect(function()
                if Page.ActiveTab ~= Tab then
                    Tween(TabLabel, {TextColor3 = COLORS.TextDim}, 0.15)
                end
            end)
            TabBtn.MouseLeave:Connect(function()
                if Page.ActiveTab ~= Tab then
                    Tween(TabLabel, {TextColor3 = COLORS.TextDark}, 0.15)
                end
            end)

            Tab._label = TabLabel
            Tab._indicator = TabIndicator
            Tab._leftCol = LeftColumn
            Tab._rightCol = RightColumn
            Tab._icon = tabIcon ~= "" and TabBtnContent:FindFirstChildWhichIsA("ImageLabel") or nil

            -- ==================
            -- SECTION SYSTEM
            -- ==================
            function Tab:CreateSection(sectionConfig)
                sectionConfig = sectionConfig or {}
                local sectionName = sectionConfig.Name or "Section"
                local sectionSide = sectionConfig.Side or "Left"
                local sectionIcon = sectionConfig.Icon or ""

                local Section = {}
                Section.Name = sectionName

                local parentCol = sectionSide == "Right" and RightColumn or LeftColumn

                local SectionFrame = Create("Frame", {
                    Name = sectionName,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = COLORS.Surface,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    Parent = parentCol,
                })
                AddCorner(SectionFrame, 8)
                AddStroke(SectionFrame, COLORS.Border, 1)

                -- Section Header
                local SectionHeader = Create("Frame", {
                    Name = "Header",
                    Size = UDim2.new(1, 0, 0, 40),
                    BackgroundTransparency = 1,
                    Parent = SectionFrame,
                })

                if sectionIcon ~= "" then
                    Create("ImageLabel", {
                        Size = UDim2.new(0, 15, 0, 15),
                        Position = UDim2.new(0, 16, 0.5, -7.5),
                        BackgroundTransparency = 1,
                        Image = sectionIcon,
                        ImageColor3 = COLORS.Accent,
                        Parent = SectionHeader,
                    })
                end

                Create("TextLabel", {
                    Size = UDim2.new(1, -80, 1, 0),
                    Position = UDim2.new(0, sectionIcon ~= "" and 38 or 16, 0, 0),
                    BackgroundTransparency = 1,
                    Text = string.upper(sectionName),
                    TextColor3 = COLORS.Text,
                    FontFace = FONT_SEMI,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SectionHeader,
                })

                -- Collapse button
                local CollapseBtn = Create("TextButton", {
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -30, 0.5, -10),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = SectionHeader,
                })
                local CollapseArrow = Create("ImageLabel", {
                    Size = UDim2.new(0, 10, 0, 10),
                    Position = UDim2.new(0.5, -5, 0.5, -5),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://7734042953",
                    ImageColor3 = COLORS.TextDark,
                    Rotation = 0,
                    Parent = CollapseBtn,
                })

                -- Header bottom border
                Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0, 0, 1, -1),
                    BackgroundColor3 = COLORS.Border,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    Parent = SectionHeader,
                })

                -- Section Body
                local SectionBody = Create("Frame", {
                    Name = "Body",
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 40),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Parent = SectionFrame,
                })
                AddPadding(SectionBody, 6, 0, 6, 0)
                AddListLayout(SectionBody, Enum.FillDirection.Vertical, 0)

                local collapsed = false
                CollapseBtn.MouseButton1Click:Connect(function()
                    collapsed = not collapsed
                    if collapsed then
                        Tween(CollapseArrow, {Rotation = -90}, 0.2)
                        SectionBody.Visible = false
                    else
                        Tween(CollapseArrow, {Rotation = 0}, 0.2)
                        SectionBody.Visible = true
                    end
                end)

                -- ==================
                -- CONTROL: TOGGLE
                -- ==================
                function Section:AddToggle(toggleConfig)
                    toggleConfig = toggleConfig or {}
                    local tName = toggleConfig.Name or "Toggle"
                    local tDefault = toggleConfig.Default or false
                    local tFlag = toggleConfig.Flag or tName
                    local tCallback = toggleConfig.Callback or function() end

                    Library.Flags[tFlag] = tDefault

                    local Row = Create("Frame", {
                        Size = UDim2.new(1, 0, 0, 36),
                        BackgroundTransparency = 1,
                        Parent = SectionBody,
                    })

                    Row.MouseEnter:Connect(function()
                        Tween(Row, {BackgroundTransparency = 0.95, BackgroundColor3 = COLORS.SurfaceHover}, 0.1)
                    end)
                    Row.MouseLeave:Connect(function()
                        Tween(Row, {BackgroundTransparency = 1}, 0.1)
                    end)

                    Create("TextLabel", {
                        Size = UDim2.new(1, -70, 1, 0),
                        Position = UDim2.new(0, 16, 0, 0),
                        BackgroundTransparency = 1,
                        Text = tName,
                        TextColor3 = COLORS.TextDim,
                        FontFace = FONT,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Row,
                    })

                    local ToggleFrame = Create("Frame", {
                        Size = UDim2.new(0, 36, 0, 20),
                        Position = UDim2.new(1, -52, 0.5, -10),
                        BackgroundColor3 = tDefault and COLORS.AccentDim or COLORS.ToggleOff,
                        BackgroundTransparency = tDefault and 0.6 or 0,
                        BorderSizePixel = 0,
                        Parent = Row,
                    })
                    AddCorner(ToggleFrame, 10)

                    local ToggleKnob = Create("Frame", {
                        Size = UDim2.new(0, 14, 0, 14),
                        Position = tDefault and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
                        BackgroundColor3 = tDefault and COLORS.Accent or COLORS.ToggleKnobOff,
                        BorderSizePixel = 0,
                        Parent = ToggleFrame,
                    })
                    AddCorner(ToggleKnob, 7)

                    local ToggleBtn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = "",
                        Parent = Row,
                    })

                    local state = tDefault

                    local function UpdateToggle()
                        if state then
                            Tween(ToggleFrame, {BackgroundColor3 = COLORS.AccentDim, BackgroundTransparency = 0.6}, 0.2)
                            Tween(ToggleKnob, {Position = UDim2.new(1, -17, 0.5, -7), BackgroundColor3 = COLORS.Accent}, 0.2)
                        else
                            Tween(ToggleFrame, {BackgroundColor3 = COLORS.ToggleOff, BackgroundTransparency = 0}, 0.2)
                            Tween(ToggleKnob, {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = COLORS.ToggleKnobOff}, 0.2)
                        end
                    end

                    ToggleBtn.MouseButton1Click:Connect(function()
                        state = not state
                        Library.Flags[tFlag] = state
                        UpdateToggle()
                        pcall(tCallback, state)
                    end)

                    local ToggleObj = {}
                    function ToggleObj:Set(val)
                        state = val
                        Library.Flags[tFlag] = state
                        UpdateToggle()
                        pcall(tCallback, state)
                    end
                    function ToggleObj:Get()
                        return state
                    end

                    return ToggleObj
                end

                -- ==================
                -- CONTROL: SLIDER
                -- ==================
                function Section:AddSlider(sliderConfig)
                    sliderConfig = sliderConfig or {}
                    local sName = sliderConfig.Name or "Slider"
                    local sMin = sliderConfig.Min or 0
                    local sMax = sliderConfig.Max or 100
                    local sDefault = sliderConfig.Default or sMin
                    local sIncrement = sliderConfig.Increment or 1
                    local sSuffix = sliderConfig.Suffix or ""
                    local sFlag = sliderConfig.Flag or sName
                    local sCallback = sliderConfig.Callback or function() end

                    Library.Flags[sFlag] = sDefault

                    local Row = Create("Frame", {
                        Size = UDim2.new(1, 0, 0, 50),
                        BackgroundTransparency = 1,
                        Parent = SectionBody,
                    })

                    Row.MouseEnter:Connect(function()
                        Tween(Row, {BackgroundTransparency = 0.95, BackgroundColor3 = COLORS.SurfaceHover}, 0.1)
                    end)
                    Row.MouseLeave:Connect(function()
                        Tween(Row, {BackgroundTransparency = 1}, 0.1)
                    end)

                    Create("TextLabel", {
                        Size = UDim2.new(1, -90, 0, 20),
                        Position = UDim2.new(0, 16, 0, 6),
                        BackgroundTransparency = 1,
                        Text = sName,
                        TextColor3 = COLORS.TextDim,
                        FontFace = FONT,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Row,
                    })

                    -- Value display
                    local ValueBg = Create("Frame", {
                        Size = UDim2.new(0, 0, 0, 20),
                        AutomaticSize = Enum.AutomaticSize.X,
                        Position = UDim2.new(1, -16, 0, 6),
                        AnchorPoint = Vector2.new(1, 0),
                        BackgroundColor3 = COLORS.Accent,
                        BackgroundTransparency = 0.9,
                        BorderSizePixel = 0,
                        Parent = Row,
                    })
                    AddCorner(ValueBg, 4)
                    AddPadding(ValueBg, 2, 8, 2, 8)

                    local ValueLabel = Create("TextLabel", {
                        Size = UDim2.new(0, 0, 0, 16),
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundTransparency = 1,
                        Text = tostring(sDefault) .. sSuffix,
                        TextColor3 = COLORS.Accent,
                        FontFace = FONT_SEMI,
                        TextSize = 11,
                        Parent = ValueBg,
                    })

                    -- Slider track
                    local TrackFrame = Create("Frame", {
                        Size = UDim2.new(1, -32, 0, 4),
                        Position = UDim2.new(0, 16, 0, 34),
                        BackgroundColor3 = COLORS.SliderTrack,
                        BorderSizePixel = 0,
                        Parent = Row,
                    })
                    AddCorner(TrackFrame, 2)

                    local FillFrame = Create("Frame", {
                        Size = UDim2.new((sDefault - sMin) / (sMax - sMin), 0, 1, 0),
                        BackgroundColor3 = COLORS.Accent,
                        BorderSizePixel = 0,
                        Parent = TrackFrame,
                    })
                    AddCorner(FillFrame, 2)
                    -- Gradient on fill
                    Create("UIGradient", {
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, COLORS.Accent),
                            ColorSequenceKeypoint.new(1, COLORS.AccentDark),
                        }),
                        Parent = FillFrame,
                    })

                    local Thumb = Create("Frame", {
                        Size = UDim2.new(0, 12, 0, 12),
                        Position = UDim2.new(1, -6, 0.5, -6),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderSizePixel = 0,
                        ZIndex = 3,
                        Parent = FillFrame,
                    })
                    AddCorner(Thumb, 6)

                    -- Slider interaction
                    local sliderBtn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 20),
                        Position = UDim2.new(0, 0, 0, 26),
                        BackgroundTransparency = 1,
                        Text = "",
                        Parent = Row,
                    })

                    local value = sDefault
                    local sliding = false

                    local function UpdateSlider(input)
                        local trackAbsPos = TrackFrame.AbsolutePosition.X
                        local trackAbsSize = TrackFrame.AbsoluteSize.X
                        local mouseX = input.Position.X
                        local ratio = math.clamp((mouseX - trackAbsPos) / trackAbsSize, 0, 1)
                        local rawVal = sMin + (sMax - sMin) * ratio
                        value = math.floor(rawVal / sIncrement + 0.5) * sIncrement
                        value = math.clamp(value, sMin, sMax)

                        -- Round display
                        local displayVal
                        if sIncrement >= 1 then
                            displayVal = tostring(math.floor(value))
                        else
                            local decimals = #tostring(sIncrement):match("%.(%d+)") or 0
                            displayVal = string.format("%." .. decimals .. "f", value)
                        end

                        ValueLabel.Text = displayVal .. sSuffix
                        Library.Flags[sFlag] = value
                        FillFrame.Size = UDim2.new((value - sMin) / (sMax - sMin), 0, 1, 0)
                    end

                    sliderBtn.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliding = true
                            UpdateSlider(input)
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                            UpdateSlider(input)
                        end
                    end)

                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and sliding then
                            sliding = false
                            pcall(sCallback, value)
                        end
                    end)

                    local SliderObj = {}
                    function SliderObj:Set(val)
                        value = math.clamp(val, sMin, sMax)
                        Library.Flags[sFlag] = value
                        local displayVal
                        if sIncrement >= 1 then
                            displayVal = tostring(math.floor(value))
                        else
                            local decimals = #tostring(sIncrement):match("%.(%d+)") or 0
                            displayVal = string.format("%." .. decimals .. "f", value)
                        end
                        ValueLabel.Text = displayVal .. sSuffix
                        FillFrame.Size = UDim2.new((value - sMin) / (sMax - sMin), 0, 1, 0)
                        pcall(sCallback, value)
                    end
                    function SliderObj:Get()
                        return value
                    end

                    return SliderObj
                end

                -- ==================
                -- CONTROL: DROPDOWN
                -- ==================
                function Section:AddDropdown(dropConfig)
                    dropConfig = dropConfig or {}
                    local dName = dropConfig.Name or "Dropdown"
                    local dOptions = dropConfig.Options or {"Option 1", "Option 2"}
                    local dDefault = dropConfig.Default or dOptions[1]
                    local dFlag = dropConfig.Flag or dName
                    local dCallback = dropConfig.Callback or function() end

                    Library.Flags[dFlag] = dDefault

                    local Row = Create("Frame", {
                        Size = UDim2.new(1, 0, 0, 36),
                        BackgroundTransparency = 1,
                        Parent = SectionBody,
                    })

                    Row.MouseEnter:Connect(function()
                        Tween(Row, {BackgroundTransparency = 0.95, BackgroundColor3 = COLORS.SurfaceHover}, 0.1)
                    end)
                    Row.MouseLeave:Connect(function()
                        Tween(Row, {BackgroundTransparency = 1}, 0.1)
                    end)

                    Create("TextLabel", {
                        Size = UDim2.new(1, -180, 1, 0),
                        Position = UDim2.new(0, 16, 0, 0),
                        BackgroundTransparency = 1,
                        Text = dName,
                        TextColor3 = COLORS.TextDim,
                        FontFace = FONT,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Row,
                    })

                    local DropBtn = Create("TextButton", {
                        Size = UDim2.new(0, 160, 0, 28),
                        Position = UDim2.new(1, -176, 0.5, -14),
                        BackgroundColor3 = COLORS.Surface,
                        BorderSizePixel = 0,
                        Text = "",
                        AutoButtonColor = false,
                        Parent = Row,
                    })
                    AddCorner(DropBtn, 6)
                    AddStroke(DropBtn, COLORS.Border, 1)

                    local DropLabel = Create("TextLabel", {
                        Size = UDim2.new(1, -30, 1, 0),
                        Position = UDim2.new(0, 10, 0, 0),
                        BackgroundTransparency = 1,
                        Text = tostring(dDefault),
                        TextColor3 = COLORS.TextDim,
                        FontFace = FONT,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = DropBtn,
                    })

                    local DropArrow = Create("ImageLabel", {
                        Size = UDim2.new(0, 10, 0, 10),
                        Position = UDim2.new(1, -18, 0.5, -5),
                        BackgroundTransparency = 1,
                        Image = "rbxassetid://7734042953",
                        ImageColor3 = COLORS.TextDark,
                        Rotation = 0,
                        Parent = DropBtn,
                    })

                    -- Dropdown menu
                    local DropMenu = Create("Frame", {
                        Size = UDim2.new(0, 160, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Position = UDim2.new(1, -176, 0, 36),
                        BackgroundColor3 = COLORS.BackgroundLight,
                        BorderSizePixel = 0,
                        Visible = false,
                        ZIndex = 50,
                        ClipsDescendants = true,
                        Parent = Row,
                    })
                    AddCorner(DropMenu, 6)
                    AddStroke(DropMenu, COLORS.Border, 1)
                    AddPadding(DropMenu, 4, 4, 4, 4)
                    AddListLayout(DropMenu, Enum.FillDirection.Vertical, 0)

                    local isOpen = false
                    local selected = dDefault

                    local function CreateOption(optText)
                        local opt = Create("TextButton", {
                            Size = UDim2.new(1, 0, 0, 28),
                            BackgroundColor3 = COLORS.Accent,
                            BackgroundTransparency = optText == selected and 0.92 or 1,
                            Text = "",
                            AutoButtonColor = false,
                            ZIndex = 51,
                            Parent = DropMenu,
                        })
                        AddCorner(opt, 4)

                        local optLabel = Create("TextLabel", {
                            Size = UDim2.new(1, -20, 1, 0),
                            Position = UDim2.new(0, 10, 0, 0),
                            BackgroundTransparency = 1,
                            Text = optText,
                            TextColor3 = optText == selected and COLORS.Accent or COLORS.TextDim,
                            FontFace = FONT,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 51,
                            Parent = opt,
                        })

                        opt.MouseEnter:Connect(function()
                            if optText ~= selected then
                                Tween(opt, {BackgroundTransparency = 0.94}, 0.1)
                                Tween(optLabel, {TextColor3 = COLORS.Text}, 0.1)
                            end
                        end)
                        opt.MouseLeave:Connect(function()
                            if optText ~= selected then
                                Tween(opt, {BackgroundTransparency = 1}, 0.1)
                                Tween(optLabel, {TextColor3 = COLORS.TextDim}, 0.1)
                            end
                        end)

                        opt.MouseButton1Click:Connect(function()
                            selected = optText
                            Library.Flags[dFlag] = selected
                            DropLabel.Text = selected
                            isOpen = false
                            DropMenu.Visible = false
                            Tween(DropArrow, {Rotation = 0}, 0.2)

                            -- Update all options
                            for _, child in ipairs(DropMenu:GetChildren()) do
                                if child:IsA("TextButton") then
                                    local lbl = child:FindFirstChildWhichIsA("TextLabel")
                                    if lbl then
                                        if lbl.Text == selected then
                                            child.BackgroundTransparency = 0.92
                                            lbl.TextColor3 = COLORS.Accent
                                        else
                                            child.BackgroundTransparency = 1
                                            lbl.TextColor3 = COLORS.TextDim
                                        end
                                    end
                                end
                            end

                            pcall(dCallback, selected)
                        end)

                        return opt
                    end

                    for _, opt in ipairs(dOptions) do
                        CreateOption(opt)
                    end

                    DropBtn.MouseButton1Click:Connect(function()
                        isOpen = not isOpen
                        DropMenu.Visible = isOpen
                        Tween(DropArrow, {Rotation = isOpen and 180 or 0}, 0.2)
                    end)

                    local DropObj = {}
                    function DropObj:Set(val)
                        selected = val
                        Library.Flags[dFlag] = val
                        DropLabel.Text = val
                        pcall(dCallback, val)
                    end
                    function DropObj:Get()
                        return selected
                    end
                    function DropObj:Refresh(newOptions, newDefault)
                        for _, child in ipairs(DropMenu:GetChildren()) do
                            if child:IsA("TextButton") then child:Destroy() end
                        end
                        dOptions = newOptions
                        selected = newDefault or newOptions[1]
                        Library.Flags[dFlag] = selected
                        DropLabel.Text = selected
                        for _, opt in ipairs(newOptions) do
                            CreateOption(opt)
                        end
                    end

                    return DropObj
                end

                -- ==================
                -- CONTROL: KEYBIND
                -- ==================
                function Section:AddKeybind(kbConfig)
                    kbConfig = kbConfig or {}
                    local kbName = kbConfig.Name or "Keybind"
                    local kbDefault = kbConfig.Default or Enum.KeyCode.Unknown
                    local kbFlag = kbConfig.Flag or kbName
                    local kbCallback = kbConfig.Callback or function() end

                    Library.Flags[kbFlag] = kbDefault

                    local Row = Create("Frame", {
                        Size = UDim2.new(1, 0, 0, 36),
                        BackgroundTransparency = 1,
                        Parent = SectionBody,
                    })

                    Row.MouseEnter:Connect(function()
                        Tween(Row, {BackgroundTransparency = 0.95, BackgroundColor3 = COLORS.SurfaceHover}, 0.1)
                    end)
                    Row.MouseLeave:Connect(function()
                        Tween(Row, {BackgroundTransparency = 1}, 0.1)
                    end)

                    Create("TextLabel", {
                        Size = UDim2.new(1, -80, 1, 0),
                        Position = UDim2.new(0, 16, 0, 0),
                        BackgroundTransparency = 1,
                        Text = kbName,
                        TextColor3 = COLORS.TextDim,
                        FontFace = FONT,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Row,
                    })

                    local KbBtn = Create("TextButton", {
                        Size = UDim2.new(0, 50, 0, 26),
                        Position = UDim2.new(1, -66, 0.5, -13),
                        BackgroundColor3 = COLORS.Surface,
                        BorderSizePixel = 0,
                        Text = "",
                        AutoButtonColor = false,
                        Parent = Row,
                    })
                    AddCorner(KbBtn, 5)
                    AddStroke(KbBtn, COLORS.Border, 1)

                    local KbLabel = Create("TextLabel", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = kbDefault == Enum.KeyCode.Unknown and "-" or kbDefault.Name,
                        TextColor3 = COLORS.TextDark,
                        FontFace = FONT_MEDIUM,
                        TextSize = 10,
                        Parent = KbBtn,
                    })

                    local kbStroke = KbBtn:FindFirstChildWhichIsA("UIStroke")
                    local listening = false
                    local currentKey = kbDefault

                    KbBtn.MouseButton1Click:Connect(function()
                        if listening then return end
                        listening = true
                        KbLabel.Text = "..."
                        KbLabel.TextColor3 = COLORS.Accent
                        if kbStroke then kbStroke.Color = COLORS.Accent end

                        local conn
                        conn = UserInputService.InputBegan:Connect(function(input, gpe)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                if input.KeyCode == Enum.KeyCode.Escape then
                                    currentKey = Enum.KeyCode.Unknown
                                    KbLabel.Text = "-"
                                else
                                    currentKey = input.KeyCode
                                    KbLabel.Text = currentKey.Name
                                end
                                Library.Flags[kbFlag] = currentKey
                                KbLabel.TextColor3 = COLORS.TextDark
                                if kbStroke then kbStroke.Color = COLORS.Border end
                                listening = false
                                conn:Disconnect()
                                pcall(kbCallback, currentKey)
                            end
                        end)
                    end)

                    -- Listen for key press
                    UserInputService.InputBegan:Connect(function(input, gpe)
                        if gpe then return end
                        if not listening and input.KeyCode == currentKey and currentKey ~= Enum.KeyCode.Unknown then
                            pcall(kbCallback, currentKey)
                        end
                    end)

                    local KbObj = {}
                    function KbObj:Set(key)
                        currentKey = key
                        Library.Flags[kbFlag] = key
                        KbLabel.Text = key == Enum.KeyCode.Unknown and "-" or key.Name
                    end
                    function KbObj:Get()
                        return currentKey
                    end

                    return KbObj
                end

                -- ==================
                -- CONTROL: BUTTON
                -- ==================
                function Section:AddButton(btnConfig)
                    btnConfig = btnConfig or {}
                    local bName = btnConfig.Name or "Button"
                    local bStyle = btnConfig.Style or "Default"
                    local bCallback = btnConfig.Callback or function() end

                    local Row = Create("Frame", {
                        Size = UDim2.new(1, 0, 0, 44),
                        BackgroundTransparency = 1,
                        Parent = SectionBody,
                    })

                    local accentColor = COLORS.Accent
                    if bStyle == "Success" then
                        accentColor = COLORS.Success
                    elseif bStyle == "Danger" then
                        accentColor = COLORS.Error
                    end

                    local Btn = Create("TextButton", {
                        Size = UDim2.new(1, -32, 0, 32),
                        Position = UDim2.new(0, 16, 0.5, -16),
                        BackgroundColor3 = accentColor,
                        BackgroundTransparency = 0.85,
                        Text = "",
                        AutoButtonColor = false,
                        Parent = Row,
                    })
                    AddCorner(Btn, 6)
                    AddStroke(Btn, accentColor, 1, 0.8)

                    Create("TextLabel", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = bName,
                        TextColor3 = accentColor,
                        FontFace = FONT_SEMI,
                        TextSize = 12,
                        Parent = Btn,
                    })

                    Btn.MouseEnter:Connect(function()
                        Tween(Btn, {BackgroundTransparency = 0.75}, 0.15)
                    end)
                    Btn.MouseLeave:Connect(function()
                        Tween(Btn, {BackgroundTransparency = 0.85}, 0.15)
                    end)

                    Btn.MouseButton1Click:Connect(function()
                        pcall(bCallback)
                        -- Click animation
                        Tween(Btn, {BackgroundTransparency = 0.6}, 0.05)
                        task.delay(0.1, function()
                            Tween(Btn, {BackgroundTransparency = 0.85}, 0.15)
                        end)
                    end)

                    return Btn
                end

                -- ==================
                -- CONTROL: LABEL
                -- ==================
                function Section:AddLabel(text)
                    local Row = Create("Frame", {
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundTransparency = 1,
                        Parent = SectionBody,
                    })

                    local lbl = Create("TextLabel", {
                        Size = UDim2.new(1, -32, 1, 0),
                        Position = UDim2.new(0, 16, 0, 0),
                        BackgroundTransparency = 1,
                        Text = text or "",
                        TextColor3 = COLORS.TextDim,
                        FontFace = FONT,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Row,
                    })

                    local LabelObj = {}
                    function LabelObj:Set(newText)
                        lbl.Text = newText
                    end
                    return LabelObj
                end

                -- ==================
                -- CONTROL: TEXTBOX
                -- ==================
                function Section:AddTextbox(tbConfig)
                    tbConfig = tbConfig or {}
                    local tbName = tbConfig.Name or "Textbox"
                    local tbDefault = tbConfig.Default or ""
                    local tbPlaceholder = tbConfig.Placeholder or "Type here..."
                    local tbFlag = tbConfig.Flag or tbName
                    local tbCallback = tbConfig.Callback or function() end

                    Library.Flags[tbFlag] = tbDefault

                    local Row = Create("Frame", {
                        Size = UDim2.new(1, 0, 0, 36),
                        BackgroundTransparency = 1,
                        Parent = SectionBody,
                    })

                    Create("TextLabel", {
                        Size = UDim2.new(1, -180, 1, 0),
                        Position = UDim2.new(0, 16, 0, 0),
                        BackgroundTransparency = 1,
                        Text = tbName,
                        TextColor3 = COLORS.TextDim,
                        FontFace = FONT,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Row,
                    })

                    local TbFrame = Create("Frame", {
                        Size = UDim2.new(0, 160, 0, 28),
                        Position = UDim2.new(1, -176, 0.5, -14),
                        BackgroundColor3 = COLORS.Surface,
                        BorderSizePixel = 0,
                        Parent = Row,
                    })
                    AddCorner(TbFrame, 6)
                    AddStroke(TbFrame, COLORS.Border, 1)

                    local Tb = Create("TextBox", {
                        Size = UDim2.new(1, -20, 1, 0),
                        Position = UDim2.new(0, 10, 0, 0),
                        BackgroundTransparency = 1,
                        Text = tbDefault,
                        PlaceholderText = tbPlaceholder,
                        PlaceholderColor3 = COLORS.TextMuted,
                        TextColor3 = COLORS.TextDim,
                        FontFace = FONT,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ClearTextOnFocus = false,
                        Parent = TbFrame,
                    })

                    local tbStroke = TbFrame:FindFirstChildWhichIsA("UIStroke")

                    Tb.Focused:Connect(function()
                        if tbStroke then
                            Tween(tbStroke, {Color = COLORS.Accent, Transparency = 0.7}, 0.2)
                        end
                    end)
                    Tb.FocusLost:Connect(function(enterPressed)
                        if tbStroke then
                            Tween(tbStroke, {Color = COLORS.Border, Transparency = 0}, 0.2)
                        end
                        Library.Flags[tbFlag] = Tb.Text
                        pcall(tbCallback, Tb.Text, enterPressed)
                    end)

                    local TbObj = {}
                    function TbObj:Set(val)
                        Tb.Text = val
                        Library.Flags[tbFlag] = val
                    end
                    function TbObj:Get()
                        return Tb.Text
                    end

                    return TbObj
                end

                -- ==================
                -- CONTROL: COLOR PICKER
                -- ==================
                function Section:AddColorPicker(cpConfig)
                    cpConfig = cpConfig or {}
                    local cpName = cpConfig.Name or "Color"
                    local cpDefault = cpConfig.Default or COLORS.Accent
                    local cpFlag = cpConfig.Flag or cpName
                    local cpCallback = cpConfig.Callback or function() end

                    Library.Flags[cpFlag] = cpDefault

                    local Row = Create("Frame", {
                        Size = UDim2.new(1, 0, 0, 36),
                        BackgroundTransparency = 1,
                        Parent = SectionBody,
                    })

                    Row.MouseEnter:Connect(function()
                        Tween(Row, {BackgroundTransparency = 0.95, BackgroundColor3 = COLORS.SurfaceHover}, 0.1)
                    end)
                    Row.MouseLeave:Connect(function()
                        Tween(Row, {BackgroundTransparency = 1}, 0.1)
                    end)

                    Create("TextLabel", {
                        Size = UDim2.new(1, -60, 1, 0),
                        Position = UDim2.new(0, 16, 0, 0),
                        BackgroundTransparency = 1,
                        Text = cpName,
                        TextColor3 = COLORS.TextDim,
                        FontFace = FONT,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Row,
                    })

                    local ColorPreview = Create("Frame", {
                        Size = UDim2.new(0, 26, 0, 26),
                        Position = UDim2.new(1, -42, 0.5, -13),
                        BackgroundColor3 = cpDefault,
                        BorderSizePixel = 0,
                        Parent = Row,
                    })
                    AddCorner(ColorPreview, 5)
                    AddStroke(ColorPreview, COLORS.BorderLight, 2)

                    local CpObj = {}
                    function CpObj:Set(color)
                        Library.Flags[cpFlag] = color
                        ColorPreview.BackgroundColor3 = color
                        pcall(cpCallback, color)
                    end
                    function CpObj:Get()
                        return Library.Flags[cpFlag]
                    end

                    return CpObj
                end

                table.insert(Tab.Sections, Section)
                return Section
            end

            table.insert(Page.Tabs, Tab)

            -- Auto-activate first tab
            if #Page.Tabs == 1 then
                ActivateTab()
            end

            return Tab
        end

        Page._frame = PageFrame

        -- Connect sidebar button
        if SidebarButtons[pageName] then
            SidebarButtons[pageName].Button.MouseButton1Click:Connect(function()
                SetActiveSidebar(pageName)
                for _, p in ipairs(Library.Pages) do
                    p._frame.Visible = false
                end
                PageFrame.Visible = true
                Library.ActivePage = Page
            end)
        end

        table.insert(Library.Pages, Page)

        -- Auto show first page
        if #Library.Pages == 1 then
            SetActiveSidebar(pageName)
            PageFrame.Visible = true
            Library.ActivePage = Page
        end

        return Page
    end

    -- ==================
    -- NOTIFICATION SYSTEM
    -- ==================
    function Library:Notify(config)
        config = config or {}
        local nTitle = config.Title or "Notification"
        local nText = config.Text or ""
        local nDuration = config.Duration or 3
        local nType = config.Type or "Info"

        local accentColor = COLORS.Accent
        if nType == "Success" then accentColor = COLORS.Success
        elseif nType == "Warning" then accentColor = COLORS.Warning
        elseif nType == "Error" then accentColor = COLORS.Error end

        local NotifFrame = Create("Frame", {
            Size = UDim2.new(0, 300, 0, 60),
            Position = UDim2.new(1, 320, 1, -70 - (#Library.Notifications * 68)),
            BackgroundColor3 = COLORS.BackgroundLight,
            BorderSizePixel = 0,
            Parent = ScreenGui,
        })
        AddCorner(NotifFrame, 8)
        AddStroke(NotifFrame, COLORS.Border, 1)

        -- Left accent bar
        Create("Frame", {
            Size = UDim2.new(0, 3, 1, -12),
            Position = UDim2.new(0, 0, 0, 6),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            Parent = NotifFrame,
        })

        Create("TextLabel", {
            Size = UDim2.new(1, -24, 0, 20),
            Position = UDim2.new(0, 16, 0, 10),
            BackgroundTransparency = 1,
            Text = nTitle,
            TextColor3 = COLORS.Text,
            FontFace = FONT_SEMI,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = NotifFrame,
        })

        Create("TextLabel", {
            Size = UDim2.new(1, -24, 0, 20),
            Position = UDim2.new(0, 16, 0, 30),
            BackgroundTransparency = 1,
            Text = nText,
            TextColor3 = COLORS.TextDim,
            FontFace = FONT,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = NotifFrame,
        })

        table.insert(Library.Notifications, NotifFrame)

        -- Slide in
        Tween(NotifFrame, {Position = UDim2.new(1, -316, 1, -70 - ((#Library.Notifications - 1) * 68))}, 0.3, Enum.EasingStyle.Back)

        -- Auto remove
        task.delay(nDuration, function()
            Tween(NotifFrame, {Position = UDim2.new(1, 320, NotifFrame.Position.Y.Scale, NotifFrame.Position.Y.Offset)}, 0.3)
            task.delay(0.35, function()
                local idx = table.find(Library.Notifications, NotifFrame)
                if idx then table.remove(Library.Notifications, idx) end
                NotifFrame:Destroy()
            end)
        end)
    end

    -- ==================
    -- MENU TOGGLE
    -- ==================
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == menuKey then
            Library.Toggled = not Library.Toggled
            if Library.Toggled then
                MainFrame.Visible = true
                MainFrame.Size = size
                Tween(MainFrame, {BackgroundTransparency = 0}, 0.2)
            else
                Tween(MainFrame, {BackgroundTransparency = 1}, 0.2)
                task.delay(0.25, function()
                    if not Library.Toggled then
                        MainFrame.Visible = false
                    end
                end)
            end
        end
    end)

    function Library:Destroy()
        ScreenGui:Destroy()
    end

    Library.Notify = function(self, ...) Library:Notify(...) end

    return Library
end

return Potassium
