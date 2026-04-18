local Library = {}

local ASPECT_RATIO = 16 / 9
local MIN_WINDOW_SIZE = Vector2.new(480, 270)
local WINDOW_CORNER_RADIUS = 16
local SIDEBAR_CORNER_RADIUS = math.max(0, WINDOW_CORNER_RADIUS - 8)
local WINDOW_BACKGROUND_IMAGE = "rbxassetid://80999662900595"
local WINDOW_SLICE_CENTER = Rect.new(256, 256, 256, 256)
local WINDOW_SLICE_SCALE = WINDOW_CORNER_RADIUS / 256
local BOTTOM_DRAG_BAR_WIDTH = 160
local BOTTOM_DRAG_BAR_HEIGHT = 4
local BOTTOM_DRAG_BAR_OUTSET = 4
local BOTTOM_DRAG_BAR_IDLE_TRANSPARENCY = 0.8
local BOTTOM_DRAG_BAR_ACTIVE_TRANSPARENCY = 0.35
local RESIZE_HANDLE_OUTSET = 8
local RESIZE_HANDLE_HITBOX_SIZE = 48
local RESIZE_HANDLE_VISUAL_SIZE = 96
local RESIZE_HANDLE_VISUAL_SHIFT = -24
local RESIZE_HANDLE_IDLE_TRANSPARENCY = 0.8
local RESIZE_HANDLE_ACTIVE_TRANSPARENCY = 0.35
local RESIZE_HANDLE_IMAGE = "rbxassetid://120997033468887"
local GROUPBOX_CORNER_RADIUS = 8
local GROUPBOX_TITLE_HEIGHT = 30
local GROUPBOX_PADDING = 8
local GROUPBOX_CHILD_PADDING = 8
local GROUPBOX_COLLAPSE_ANIMATION_TIME = 0.18
local DEFAULT_TAB_NAME = "Main"
local GROUPBOX_DRAG_PLACEHOLDER_INSET = 7
local TOGGLE_ROW_HEIGHT = 20
local TOGGLE_TRACK_WIDTH = 32
local TOGGLE_TRACK_HEIGHT = 16
local TOGGLE_THUMB_SIZE = 12
local TOGGLE_THUMB_PADDING = 2
local TOGGLE_ANIMATION_TIME = 0.15

Library.Theme = {
    Surface = {
        Background = Color3.fromHex("#181818"),
        S0 = Color3.fromHex("#212121"),
        S1 = Color3.fromHex("#282828"),
        S2 = Color3.fromHex("#2e2e2e"),
        S3 = Color3.fromHex("#353535"),
        S4 = Color3.fromHex("#3d3d3d"),
        S5 = Color3.fromHex("#464646"),
    },
    Text = {
        Primary = Color3.fromHex("#ffffff"),
        Secondary = Color3.fromHex("#aaaaaa"),
        Tertiary = Color3.fromHex("#868686"),
        Muted = Color3.fromHex("#6f6f6f"),
    },
    Status = {
        Accent = Color3.fromHex("#5c79fa"),
        Info = Color3.fromHex("#5b96fa"),
        Error = Color3.fromHex("#e76761"),
        Success = Color3.fromHex("#54b66e"),
        Question = Color3.fromHex("#a497ea"),
    }
}

local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local GuiService = cloneref and cloneref(game:GetService("GuiService")) or game:GetService("GuiService")
local UserInputService = cloneref and cloneref(game:GetService("UserInputService")) or game:GetService("UserInputService")
local RunService = cloneref and cloneref(game:GetService("RunService")) or game:GetService("RunService")
local TweenService = cloneref and cloneref(game:GetService("TweenService")) or game:GetService("TweenService")

local Connections = {}

local function TrackConnection(connection)
    table.insert(Connections, connection)
    return connection
end

local function DisconnectConnections()
    for index, connection in ipairs(Connections) do
        if connection and connection.Connected and connection.Disconnect then
            connection:Disconnect()
        end

        Connections[index] = nil
    end
end

local function RemoveArrayValue(list, value)
    for index, item in ipairs(list) do
        if item == value then
            table.remove(list, index)
            return
        end
    end
end

local function SafeDestroy(instance)
    if not instance then
        return
    end

    pcall(function()
        instance:Destroy()
    end)
end

local FastSignalConnection = {}
FastSignalConnection.__index = FastSignalConnection

function FastSignalConnection:Disconnect()
    if not self.Connected then
        return
    end

    self.Connected = false

    local signal = self._signal
    if not signal then
        return
    end

    local previous = self._previous
    local nextItem = self._next

    if previous then
        previous._next = nextItem
    else
        signal._head = nextItem
    end

    if nextItem then
        nextItem._previous = previous
    else
        signal._tail = previous
    end

    self._signal = nil
    self._previous = nil
    self._next = nil
    self._callback = nil
end

local FastSignal = {}
FastSignal.__index = FastSignal

function FastSignal.new()
    return setmetatable({
        _head = nil,
        _tail = nil,
    }, FastSignal)
end

function FastSignal:Connect(callback)
    local connection = setmetatable({
        Connected = true,
        _signal = self,
        _callback = callback,
    }, FastSignalConnection)

    local tail = self._tail
    if tail then
        tail._next = connection
        connection._previous = tail
    else
        self._head = connection
    end

    self._tail = connection
    return connection
end

function FastSignal:Once(callback)
    local connection
    connection = self:Connect(function(...)
        connection:Disconnect()
        callback(...)
    end)
    return connection
end

function FastSignal:Fire(...)
    local connection = self._head
    while connection do
        local nextItem = connection._next
        if connection.Connected and connection._callback then
            connection._callback(...)
        end
        connection = nextItem
    end
end

function FastSignal:Wait()
    local thread = coroutine.running()
    local connection

    connection = self:Connect(function(...)
        connection:Disconnect()
        task.spawn(thread, ...)
    end)

    return coroutine.yield()
end

function FastSignal:DisconnectAll()
    local connection = self._head
    while connection do
        local nextItem = connection._next
        connection:Disconnect()
        connection = nextItem
    end
end

function FastSignal:Destroy()
    self:DisconnectAll()
end

local Component = {}
Component.__index = Component

function Component.new(kind)
    return setmetatable({
        Kind = kind,
        Children = {},
        Changed = FastSignal.new(),
        RenderHook = FastSignal.new(),
        _destroyed = false,
    }, Component)
end

function Component:Destroy()
    if self._destroyed then
        return
    end

    self._destroyed = true
    self.RenderHook:Fire("Destroy")
    self.RenderHook:Destroy()
    self.Changed:Destroy()
end

Library.Registry = {
    Components = {},
    Tabs = {},
    GroupBoxes = {},
    Controls = {},
}

local nextRegistryId = 0

local function RegisterComponent(component)
    nextRegistryId = nextRegistryId + 1
    local registryKey = ("%s_%d"):format(component.Kind, nextRegistryId)

    component.RegistryKey = registryKey
    Library.Registry.Components[registryKey] = component

    if component.Kind == "Tab" then
        Library.Registry.Tabs[registryKey] = component
    elseif component.Kind == "GroupBox" then
        Library.Registry.GroupBoxes[registryKey] = component
    else
        Library.Registry.Controls[registryKey] = component
    end
end

local function UnregisterComponent(component)
    if not component or not component.RegistryKey then
        return
    end

    Library.Registry.Components[component.RegistryKey] = nil
    Library.Registry.Tabs[component.RegistryKey] = nil
    Library.Registry.GroupBoxes[component.RegistryKey] = nil
    Library.Registry.Controls[component.RegistryKey] = nil
end

local function NormalizeColumnName(columnName)
    local normalized = string.lower(tostring(columnName or "Left"))
    if normalized == "left" then
        return "Left"
    end

    if normalized == "middle" or normalized == "center" then
        return "Middle"
    end

    if normalized == "right" then
        return "Right"
    end

    error(("invalid column %q; expected Left, Middle, or Right"):format(tostring(columnName)), 3)
end

local Control = {}
Control.__index = Control
setmetatable(Control, Component)

function Control.new(kind, props)
    local self = setmetatable(Component.new(kind), Control)
    self.Props = props or {}
    self.LayoutOrder = 0
    return self
end

function Control:Destroy()
    if self._destroyed then
        return
    end

    if self.Parent then
        RemoveArrayValue(self.Parent.Children, self)
    end

    UnregisterComponent(self)
    Component.Destroy(self)
end

local GroupBox = {}
GroupBox.__index = GroupBox
setmetatable(GroupBox, Component)

function GroupBox.new(tab, name, columnName, layoutOrder)
    local self = setmetatable(Component.new("GroupBox"), GroupBox)
    self.Tab = tab
    self.Name = tostring(name or "GroupBox")
    self.Column = NormalizeColumnName(columnName)
    self.LayoutOrder = layoutOrder or 0
    self._collapsed = false
    self._nextChildLayoutOrder = 1
    return self
end

function GroupBox:_AttachChildControl(control)
    control.Parent = self
    control.LayoutOrder = self._nextChildLayoutOrder
    self._nextChildLayoutOrder = self._nextChildLayoutOrder + 1

    table.insert(self.Children, control)
    RegisterComponent(control)
    self.RenderHook:Fire("ChildAdded", control)

    return control
end

function GroupBox:AddControl(kind, props)
    return self:_AttachChildControl(Control.new(kind, props))
end

function GroupBox:AddLabel(text)
    return self:AddControl("Label", {
        Text = tostring(text or ""),
    })
end

function GroupBox:IsCollapsed()
    return self._collapsed
end

function GroupBox:SetCollapsed(collapsed)
    collapsed = not not collapsed
    if self._collapsed == collapsed then
        return
    end

    self._collapsed = collapsed
    self.Changed:Fire(collapsed)
    self.RenderHook:Fire("CollapsedChanged", collapsed)
end

function GroupBox:ToggleCollapsed()
    self:SetCollapsed(not self._collapsed)
end

function GroupBox:Destroy()
    if self._destroyed then
        return
    end

    for index = #self.Children, 1, -1 do
        self.Children[index]:Destroy()
    end

    if self.Tab then
        RemoveArrayValue(self.Tab.GroupBoxes, self)
    end

    UnregisterComponent(self)
    Component.Destroy(self)
end

local Tab = {}
Tab.__index = Tab
setmetatable(Tab, Component)

function Tab.new(library, name)
    local self = setmetatable(Component.new("Tab"), Tab)
    self.Library = library
    self.Name = tostring(name or DEFAULT_TAB_NAME)
    self.GroupBoxes = {}
    self._nextGroupBoxLayoutOrder = 1
    return self
end

function Tab:AddGroupBox(name, columnName)
    local groupBox = GroupBox.new(self, name, columnName, self._nextGroupBoxLayoutOrder)
    self._nextGroupBoxLayoutOrder = self._nextGroupBoxLayoutOrder + 1

    table.insert(self.GroupBoxes, groupBox)
    RegisterComponent(groupBox)
    self.RenderHook:Fire("GroupBoxAdded", groupBox)

    return groupBox
end

function Tab:Destroy()
    if self._destroyed then
        return
    end

    for index = #self.GroupBoxes, 1, -1 do
        self.GroupBoxes[index]:Destroy()
    end

    UnregisterComponent(self)
    Component.Destroy(self)
end

local function GetScreenSize(gui)
    local absoluteSize = gui.AbsoluteSize
    if absoluteSize.X > 0 and absoluteSize.Y > 0 then
        return absoluteSize
    end

    local currentCamera = workspace.CurrentCamera
    if currentCamera then
        return currentCamera.ViewportSize
    end

    return MIN_WINDOW_SIZE
end

local ScreenGui
local WindowFrame

local function ToScreenGuiSpace(position)
    local guiPosition = Vector2.new(position.X, position.Y)
    if ScreenGui and ScreenGui.IgnoreGuiInset then
        return guiPosition
    end

    local topLeftInset = GuiService:GetGuiInset()
    return guiPosition - topLeftInset
end

local function GetWindowTopLeft()
    local screenSize = GetScreenSize(ScreenGui)
    local anchorPosition = Vector2.new(
        (WindowFrame.Position.X.Scale * screenSize.X) + WindowFrame.Position.X.Offset,
        (WindowFrame.Position.Y.Scale * screenSize.Y) + WindowFrame.Position.Y.Offset
    )

    return anchorPosition - Vector2.new(
        WindowFrame.AbsoluteSize.X * WindowFrame.AnchorPoint.X,
        WindowFrame.AbsoluteSize.Y * WindowFrame.AnchorPoint.Y
    )
end

local function ApplyWindowSize(topLeft, width)
    local height = width / ASPECT_RATIO
    local anchorPoint = WindowFrame.AnchorPoint

    WindowFrame.Size = UDim2.fromOffset(width, height)
    WindowFrame.Position = UDim2.fromOffset(
        topLeft.X + (width * anchorPoint.X),
        topLeft.Y + (height * anchorPoint.Y)
    )
end

local function ClampWindowTopLeft(topLeft, width, bottomMargin)
    local screenSize = GetScreenSize(ScreenGui)
    local height = width / ASPECT_RATIO
    local maxX = math.max(0, screenSize.X - width)
    local maxY = math.max(0, screenSize.Y - height - (bottomMargin or 0))

    return Vector2.new(
        math.clamp(topLeft.X, 0, maxX),
        math.clamp(topLeft.Y, 0, maxY)
    )
end

local function BuildResizeHandleIcon(parent)
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Position = UDim2.new(0.5, RESIZE_HANDLE_VISUAL_SHIFT, 0.5, RESIZE_HANDLE_VISUAL_SHIFT)
    icon.Size = UDim2.fromOffset(RESIZE_HANDLE_VISUAL_SIZE, RESIZE_HANDLE_VISUAL_SIZE)
    icon.BackgroundTransparency = 1
    icon.BorderSizePixel = 0
    icon.Image = RESIZE_HANDLE_IMAGE
    icon.ImageColor3 = Library.Theme.Text.Primary
    icon.ImageTransparency = RESIZE_HANDLE_IDLE_TRANSPARENCY
    icon.Parent = parent

    return icon
end

local function CreateGroupBoxSectionFill(parent, name, color, position, size)
    local fill = Instance.new("Frame")
    fill.Name = name
    fill.Position = position
    fill.Size = size
    fill.BackgroundColor3 = color
    fill.BorderSizePixel = 0
    fill.Parent = parent

    return fill
end

local function BuildTopRoundedBar(name, color)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(1, 0, 0, GROUPBOX_TITLE_HEIGHT)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = false

    local roundedSurface = Instance.new("Frame")
    roundedSurface.Name = "Surface"
    roundedSurface.Size = UDim2.fromScale(1, 1)
    roundedSurface.BackgroundColor3 = color
    roundedSurface.BorderSizePixel = 0
    roundedSurface.ZIndex = 1
    roundedSurface.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, GROUPBOX_CORNER_RADIUS)
    corner.Parent = roundedSurface

    local bottomMask = Instance.new("Frame")
    bottomMask.Name = "BottomMask"
    bottomMask.Position = UDim2.new(0, 0, 1, -GROUPBOX_CORNER_RADIUS)
    bottomMask.Size = UDim2.new(1, 0, 0, GROUPBOX_CORNER_RADIUS)
    bottomMask.BackgroundColor3 = color
    bottomMask.BorderSizePixel = 0
    bottomMask.ZIndex = 2
    bottomMask.Parent = frame

    return frame
end

local function BuildBottomRoundedBody(name, color)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, GROUPBOX_CORNER_RADIUS)
    corner.Parent = frame

    CreateGroupBoxSectionFill(
        frame,
        "TopFill",
        color,
        UDim2.new(0, 0, 0, 0),
        UDim2.new(1, 0, 0, GROUPBOX_CORNER_RADIUS)
    )

    return frame
end

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SlateUI_" .. tostring(math.random(1e5, 9e5))
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
end

ScreenGui.Parent = CoreGui
Library.ScreenGui = ScreenGui

WindowFrame = Instance.new("Frame")
WindowFrame.Name = "WindowFrame"
WindowFrame.Size = UDim2.fromOffset(960, 540)
WindowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
WindowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
WindowFrame.BackgroundColor3 = Library.Theme.Surface.Background
WindowFrame.BackgroundTransparency = 1
WindowFrame.BorderSizePixel = 0
WindowFrame.Parent = ScreenGui
Library.WindowFrame = WindowFrame

local BackgroundFrame = Instance.new("ImageLabel")
BackgroundFrame.Name = "BackgroundFrame"
BackgroundFrame.Size = UDim2.fromScale(1, 1)
BackgroundFrame.Position = UDim2.fromScale(0.5, 0.5)
BackgroundFrame.AnchorPoint = Vector2.new(0.5, 0.5)
BackgroundFrame.BackgroundTransparency = 1
BackgroundFrame.BorderSizePixel = 0
BackgroundFrame.ScaleType = Enum.ScaleType.Slice
BackgroundFrame.SliceCenter = WINDOW_SLICE_CENTER
BackgroundFrame.SliceScale = WINDOW_SLICE_SCALE
BackgroundFrame.Image = WINDOW_BACKGROUND_IMAGE
BackgroundFrame.ImageColor3 = Library.Theme.Surface.Background
BackgroundFrame.Parent = WindowFrame
Library.BackgroundFrame = BackgroundFrame

local SidebarFrame = Instance.new("Frame")
SidebarFrame.Name = "sidebarFrame"
SidebarFrame.Size = UDim2.new(0, 60, 1, -16)
SidebarFrame.Position = UDim2.new(0, 8, 0, 8)
SidebarFrame.BackgroundColor3 = Library.Theme.Surface.S0
SidebarFrame.BorderSizePixel = 0
SidebarFrame.Parent = WindowFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, SIDEBAR_CORNER_RADIUS)
SidebarCorner.Parent = SidebarFrame

local columnSize = UDim2.new(1 / 3, -(100 / 3), 1, -16)

local LeftColumn = Instance.new("Frame")
LeftColumn.Name = "leftColumn"
LeftColumn.Size = columnSize
LeftColumn.Position = UDim2.new(0, 76, 0, 8)
LeftColumn.BackgroundTransparency = 1
LeftColumn.BorderSizePixel = 0
LeftColumn.Parent = WindowFrame

local MiddleColumn = Instance.new("Frame")
MiddleColumn.Name = "middleColumn"
MiddleColumn.Size = columnSize
MiddleColumn.Position = UDim2.new(1 / 3, 84 - (100 / 3), 0, 8)
MiddleColumn.BackgroundTransparency = 1
MiddleColumn.BorderSizePixel = 0
MiddleColumn.Parent = WindowFrame

local RightColumn = Instance.new("Frame")
RightColumn.Name = "rightColumn"
RightColumn.Size = columnSize
RightColumn.Position = UDim2.new(2 / 3, 92 - (200 / 3), 0, 8)
RightColumn.BackgroundTransparency = 1
RightColumn.BorderSizePixel = 0
RightColumn.Parent = WindowFrame

local ColumnFrames = {
    Left = LeftColumn,
    Middle = MiddleColumn,
    Right = RightColumn,
}

Library.Columns = ColumnFrames

local function ConfigureColumn(frame)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, GROUPBOX_CHILD_PADDING)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = frame
end

ConfigureColumn(LeftColumn)
ConfigureColumn(MiddleColumn)
ConfigureColumn(RightColumn)

local BottomDragBar = Instance.new("ImageLabel")
BottomDragBar.Name = "BottomDragBar"
BottomDragBar.AnchorPoint = Vector2.new(0.5, 0)
BottomDragBar.Position = UDim2.new(0.5, 0, 1, BOTTOM_DRAG_BAR_OUTSET)
BottomDragBar.Size = UDim2.fromOffset(BOTTOM_DRAG_BAR_WIDTH, BOTTOM_DRAG_BAR_HEIGHT)
BottomDragBar.BackgroundTransparency = 1
BottomDragBar.BorderSizePixel = 0
BottomDragBar.ScaleType = Enum.ScaleType.Slice
BottomDragBar.SliceCenter = WINDOW_SLICE_CENTER
BottomDragBar.SliceScale = 99 / 256
BottomDragBar.Image = WINDOW_BACKGROUND_IMAGE
BottomDragBar.ImageColor3 = Library.Theme.Text.Primary
BottomDragBar.ImageTransparency = BOTTOM_DRAG_BAR_IDLE_TRANSPARENCY
BottomDragBar.Parent = WindowFrame
Library.BottomDragBar = BottomDragBar

local BottomDragBarInteract = Instance.new("TextButton")
BottomDragBarInteract.Name = "Interact"
BottomDragBarInteract.AnchorPoint = Vector2.new(0.5, 0.5)
BottomDragBarInteract.Position = UDim2.fromScale(0.5, 0.5)
BottomDragBarInteract.Size = UDim2.new(1, 12, 1, 12)
BottomDragBarInteract.BackgroundTransparency = 1
BottomDragBarInteract.BorderSizePixel = 0
BottomDragBarInteract.Text = ""
BottomDragBarInteract.AutoButtonColor = false
BottomDragBarInteract.Active = true
BottomDragBarInteract.Parent = BottomDragBar

local ResizeHandle = Instance.new("Frame")
ResizeHandle.Name = "ResizeHandle"
ResizeHandle.Size = UDim2.fromOffset(RESIZE_HANDLE_HITBOX_SIZE, RESIZE_HANDLE_HITBOX_SIZE)
ResizeHandle.Position = UDim2.new(1, RESIZE_HANDLE_OUTSET, 1, RESIZE_HANDLE_OUTSET)
ResizeHandle.AnchorPoint = Vector2.new(0.5, 0.5)
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.BorderSizePixel = 0
ResizeHandle.Active = true
ResizeHandle.Parent = WindowFrame
Library.ResizeHandle = ResizeHandle

local ResizeHandleIcon = BuildResizeHandleIcon(ResizeHandle)

local BeginGroupBoxDrag

local Renderer = {
    GroupBoxes = {},
    Controls = {},
    ControlFactories = {},
}

Library.Renderer = Renderer

function Library:RegisterControlRenderer(kind, factory)
    self.Renderer.ControlFactories[kind] = factory
end

local function ResolveColumnFrame(columnName)
    return ColumnFrames[NormalizeColumnName(columnName)]
end

local function DestroyControlView(control)
    local state = Renderer.Controls[control]
    if not state then
        return
    end

    Renderer.Controls[control] = nil
    SafeDestroy(state.Root)
end

local function DestroyGroupBoxView(groupBox)
    local state = Renderer.GroupBoxes[groupBox]
    if not state then
        return
    end

    Renderer.GroupBoxes[groupBox] = nil

    if state.CollapseTween then
        state.CollapseTween:Cancel()
    end

    if state.TitleMaskTween then
        state.TitleMaskTween:Cancel()
    end

    SafeDestroy(state.TitleBar)
    SafeDestroy(state.BodyContainer)
    SafeDestroy(state.Root)
end

local function GetGroupBoxTitleBottomMaskTransparency(collapsed)
    return collapsed and 1 or 0
end

local function SetGroupBoxTitleBarCollapsedVisual(state, collapsed)
    state.TitleBottomMask.BackgroundTransparency = GetGroupBoxTitleBottomMaskTransparency(collapsed)
end

local function TweenGroupBoxTitleBarCollapsedVisual(state, collapsed)
    state.TitleMaskTween = TweenService:Create(
        state.TitleBottomMask,
        TweenInfo.new(GROUPBOX_COLLAPSE_ANIMATION_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { BackgroundTransparency = GetGroupBoxTitleBottomMaskTransparency(collapsed) }
    )
    state.TitleMaskTween:Play()
end

local function ApplyGroupBoxCollapsedState(groupBox, animate)
    local state = Renderer.GroupBoxes[groupBox]
    if not state then
        return
    end

    local collapsed = groupBox:IsCollapsed()
    state._animationId = (state._animationId or 0) + 1

    local animationId = state._animationId
    local currentTween = state.CollapseTween
    if currentTween then
        currentTween:Cancel()
        state.CollapseTween = nil
    end

    local titleMaskTween = state.TitleMaskTween
    if titleMaskTween then
        titleMaskTween:Cancel()
        state.TitleMaskTween = nil
    end

    state.CollapseButton.Text = collapsed and "+" or "-"

    if not animate then
        SetGroupBoxTitleBarCollapsedVisual(state, collapsed)
        state.BodyContainer.AutomaticSize = collapsed and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
        state.BodyContainer.Size = UDim2.new(1, 0, 0, 0)
        state.BodyContainer.ClipsDescendants = false
        state.BodyContainer.Visible = not collapsed
        state.ControlArea.Visible = not collapsed
        return
    end

    local function finishCollapseVisual()
        if not Renderer.GroupBoxes[groupBox] or state._animationId ~= animationId then
            return
        end

        if collapsed then
            state.BodyContainer.Visible = false
            state.ControlArea.Visible = false
            state.BodyContainer.ClipsDescendants = false
        else
            state.BodyContainer.AutomaticSize = Enum.AutomaticSize.Y
            state.BodyContainer.Size = UDim2.new(1, 0, 0, 0)
            state.BodyContainer.ClipsDescendants = false
        end
    end

    if collapsed then
        local startHeight = math.max(state.BodyContainer.AbsoluteSize.Y, state.ControlArea.AbsoluteSize.Y)
        SetGroupBoxTitleBarCollapsedVisual(state, false)
        state.BodyContainer.Visible = true
        state.ControlArea.Visible = true
        state.BodyContainer.AutomaticSize = Enum.AutomaticSize.None
        state.BodyContainer.ClipsDescendants = true
        state.BodyContainer.Size = UDim2.new(1, 0, 0, startHeight)
        TweenGroupBoxTitleBarCollapsedVisual(state, true)
        state.CollapseTween = TweenService:Create(
            state.BodyContainer,
            TweenInfo.new(GROUPBOX_COLLAPSE_ANIMATION_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { Size = UDim2.new(1, 0, 0, 0) }
        )
        state.CollapseTween:Play()
        task.delay(GROUPBOX_COLLAPSE_ANIMATION_TIME, finishCollapseVisual)
        return
    end

    state.BodyContainer.Visible = true
    state.ControlArea.Visible = true
    state.BodyContainer.AutomaticSize = Enum.AutomaticSize.None
    state.BodyContainer.ClipsDescendants = true
    state.BodyContainer.Size = UDim2.new(1, 0, 0, 0)
    SetGroupBoxTitleBarCollapsedVisual(state, true)
    TweenGroupBoxTitleBarCollapsedVisual(state, false)

    task.defer(function()
        if not Renderer.GroupBoxes[groupBox] or state._animationId ~= animationId then
            return
        end

        local targetHeight = state.ControlArea.AbsoluteSize.Y
        state.CollapseTween = TweenService:Create(
            state.BodyContainer,
            TweenInfo.new(GROUPBOX_COLLAPSE_ANIMATION_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { Size = UDim2.new(1, 0, 0, targetHeight) }
        )
        state.CollapseTween:Play()
        task.delay(GROUPBOX_COLLAPSE_ANIMATION_TIME, finishCollapseVisual)
    end)
end

function Renderer:MountControl(groupBox, control)
    local groupBoxState = self.GroupBoxes[groupBox]
    if not groupBoxState then
        return
    end

    local factory = self.ControlFactories[control.Kind]
    if not factory then
        return
    end

    local view = factory(control)
    view.LayoutOrder = control.LayoutOrder or 0
    view.Parent = groupBoxState.ControlArea

    self.Controls[control] = {
        Root = view,
    }

    TrackConnection(control.RenderHook:Connect(function(action)
        if action == "Destroy" then
            DestroyControlView(control)
        end
    end))
end

function Renderer:MountGroupBox(groupBox)
    if self.GroupBoxes[groupBox] then
        return
    end

    local parentColumn = ResolveColumnFrame(groupBox.Column)

    local root = Instance.new("Frame")
    root.Name = groupBox.Name .. "_GroupBox"
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.Size = UDim2.fromScale(1, 0)
    root.AutomaticSize = Enum.AutomaticSize.Y
    root.LayoutOrder = groupBox.LayoutOrder
    root.Parent = parentColumn

    local rootLayout = Instance.new("UIListLayout")
    rootLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rootLayout.Parent = root

    local titleBar = BuildTopRoundedBar("gbTitleBar", Library.Theme.Surface.S2)
    titleBar.LayoutOrder = 1
    titleBar.Parent = root

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.fromScale(1, 1)
    titleLabel.BackgroundTransparency = 1
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = groupBox.Name
    titleLabel.TextColor3 = Library.Theme.Text.Primary
    titleLabel.TextSize = 12
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.ZIndex = 3
    titleLabel.Parent = titleBar

    local collapseButton = Instance.new("TextButton")
    collapseButton.Name = "CollapseButton"
    collapseButton.AnchorPoint = Vector2.new(1, 0.5)
    collapseButton.Position = UDim2.new(1, -GROUPBOX_PADDING, 0.5, 0)
    collapseButton.Size = UDim2.fromOffset(18, 18)
    collapseButton.BackgroundTransparency = 1
    collapseButton.BorderSizePixel = 0
    collapseButton.AutoButtonColor = false
    collapseButton.Text = "-"
    collapseButton.TextColor3 = Library.Theme.Text.Secondary
    collapseButton.TextSize = 14
    collapseButton.Font = Enum.Font.GothamBold
    collapseButton.ZIndex = 4
    collapseButton.Parent = titleBar

    TrackConnection(collapseButton.MouseButton1Click:Connect(function()
        groupBox:ToggleCollapsed()
    end))

    local dragHandle = Instance.new("TextButton")
    dragHandle.Name = "DragHandle"
    dragHandle.Size = UDim2.fromScale(1, 1)
    dragHandle.BackgroundTransparency = 1
    dragHandle.BorderSizePixel = 0
    dragHandle.Text = ""
    dragHandle.AutoButtonColor = false
    dragHandle.ZIndex = 2
    dragHandle.Parent = titleBar

    TrackConnection(dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            BeginGroupBoxDrag(groupBox, input.Position)
        end
    end))

    local bodyContainer = BuildBottomRoundedBody("gbBodyContainer", Library.Theme.Surface.S1)
    bodyContainer.LayoutOrder = 2
    bodyContainer.Parent = root

    local controlArea = Instance.new("Frame")
    controlArea.Name = "gbControlArea"
    controlArea.Size = UDim2.new(1, 0, 0, GROUPBOX_PADDING * 2)
    controlArea.AutomaticSize = Enum.AutomaticSize.Y
    controlArea.BackgroundTransparency = 1
    controlArea.BorderSizePixel = 0
    controlArea.Parent = bodyContainer

    local controlPadding = Instance.new("UIPadding")
    controlPadding.PaddingLeft = UDim.new(0, GROUPBOX_PADDING)
    controlPadding.PaddingRight = UDim.new(0, GROUPBOX_PADDING)
    controlPadding.PaddingTop = UDim.new(0, GROUPBOX_PADDING)
    controlPadding.PaddingBottom = UDim.new(0, GROUPBOX_PADDING)
    controlPadding.Parent = controlArea

    local controlLayout = Instance.new("UIListLayout")
    controlLayout.Padding = UDim.new(0, GROUPBOX_CHILD_PADDING)
    controlLayout.SortOrder = Enum.SortOrder.LayoutOrder
    controlLayout.Parent = controlArea

    self.GroupBoxes[groupBox] = {
        Root = root,
        TitleBar = titleBar,
        TitleBottomMask = titleBar:FindFirstChild("BottomMask"),
        CollapseButton = collapseButton,
        BodyContainer = bodyContainer,
        ControlArea = controlArea,
    }

    ApplyGroupBoxCollapsedState(groupBox, false)

    TrackConnection(groupBox.RenderHook:Connect(function(action, payload)
        if action == "ChildAdded" then
            self:MountControl(groupBox, payload)
            return
        end

        if action == "CollapsedChanged" then
            ApplyGroupBoxCollapsedState(groupBox, true)
            return
        end

        if action == "Destroy" then
            DestroyGroupBoxView(groupBox)
        end
    end))

    for _, child in ipairs(groupBox.Children) do
        self:MountControl(groupBox, child)
    end
end

function Renderer:BindTab(tab)
    TrackConnection(tab.RenderHook:Connect(function(action, payload)
        if action == "GroupBoxAdded" then
            self:MountGroupBox(payload)
            return
        end

        if action == "Destroy" then
            for _, groupBox in ipairs(tab.GroupBoxes) do
                DestroyGroupBoxView(groupBox)
            end
        end
    end))

    for _, groupBox in ipairs(tab.GroupBoxes) do
        self:MountGroupBox(groupBox)
    end
end

Library:RegisterControlRenderer("Label", function(control)
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 14)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Text = control.Props.Text or ""
    label.TextColor3 = Library.Theme.Text.Secondary
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    return label
end)

local ActiveTab = Tab.new(Library, DEFAULT_TAB_NAME)
RegisterComponent(ActiveTab)
Renderer:BindTab(ActiveTab)

Library.ActiveTab = ActiveTab
Library.Tab = ActiveTab

function Library:GetActiveTab()
    return self.ActiveTab
end

function Library:AddGroupBox(name, columnName)
    return self.ActiveTab:AddGroupBox(name, columnName)
end

local draggingResize = false
local draggingWindow = false
local dragTopLeft = Vector2.new(0, 0)
local pointerPosition = Vector2.new(0, 0)
local dragWidthOffset = 0
local windowDragStartTopLeft = Vector2.new(0, 0)
local windowDragStartPointerPosition = Vector2.new(0, 0)
local windowDragPointerPosition = Vector2.new(0, 0)
local cleanedUp = false
local resizeHandleHovered = false
local resizeHandleTween
local bottomDragHovered = false
local bottomDragTween
local gbDragging = false
local gbDragGroupBox = nil
local gbDragPlaceholder = nil
local gbDragOffset = Vector2.new(0, 0)
local gbDragPointer = Vector2.new(0, 0)
local gbDragTargetColumn = nil
local gbDragSourceColumn = nil
local gbDragSnapTween = nil

local function SetResizeHandleTransparency(target, duration)
    if resizeHandleTween then
        resizeHandleTween:Cancel()
    end

    resizeHandleTween = TweenService:Create(
        ResizeHandleIcon,
        TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { ImageTransparency = target }
    )
    resizeHandleTween:Play()
end

local function SetBottomDragBarTransparency(target, duration)
    if bottomDragTween then
        bottomDragTween:Cancel()
    end

    bottomDragTween = TweenService:Create(
        BottomDragBar,
        TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { ImageTransparency = target }
    )
    bottomDragTween:Play()
end

local function UpdateAffordanceHoverState()
    local isActive = draggingResize or draggingWindow or resizeHandleHovered or bottomDragHovered
    local targetTransparency = isActive and RESIZE_HANDLE_ACTIVE_TRANSPARENCY or RESIZE_HANDLE_IDLE_TRANSPARENCY
    local duration = isActive and 0.1 or 0.18

    SetResizeHandleTransparency(targetTransparency, duration)
    SetBottomDragBarTransparency(targetTransparency, duration)
end

local function GetColumnGroupBoxes(columnName, excludeGroupBox)
    local boxes = {}
    for gb, state in pairs(Renderer.GroupBoxes) do
        if gb ~= excludeGroupBox and gb.Column == columnName then
            table.insert(boxes, { gb = gb, state = state })
        end
    end
    table.sort(boxes, function(a, b)
        return a.state.Root.LayoutOrder < b.state.Root.LayoutOrder
    end)
    return boxes
end

local function RenumberColumn(columnName)
    local boxes = GetColumnGroupBoxes(columnName, nil)
    for i, entry in ipairs(boxes) do
        entry.state.Root.LayoutOrder = i
        entry.gb.LayoutOrder = i
    end
end

local function UpdateDragPlaceholder()
    if not gbDragging or not gbDragGroupBox or not gbDragPlaceholder then
        return
    end

    local targetColumn = nil
    local bestDist = math.huge

    for colName, colFrame in pairs(ColumnFrames) do
        local absPos = colFrame.AbsolutePosition
        local absSize = colFrame.AbsoluteSize
        local clampedX = math.clamp(gbDragPointer.X, absPos.X, absPos.X + absSize.X)
        local dist = math.abs(gbDragPointer.X - clampedX)
        if dist < bestDist then
            bestDist = dist
            targetColumn = colName
        end
    end

    if not targetColumn then
        return
    end

    gbDragTargetColumn = targetColumn

    local boxes = GetColumnGroupBoxes(targetColumn, gbDragGroupBox)
    local insertIndex = #boxes + 1

    for i, entry in ipairs(boxes) do
        local midY = entry.state.Root.AbsolutePosition.Y + entry.state.Root.AbsoluteSize.Y / 2
        if gbDragPointer.Y < midY then
            insertIndex = i
            break
        end
    end

    local targetColFrame = ColumnFrames[targetColumn]
    if gbDragPlaceholder.Parent ~= targetColFrame then
        gbDragPlaceholder.Parent = targetColFrame
    end

    local order = 1
    for i, entry in ipairs(boxes) do
        if i == insertIndex then
            gbDragPlaceholder.LayoutOrder = order
            order = order + 1
        end
        entry.state.Root.LayoutOrder = order
        order = order + 1
    end
    if insertIndex > #boxes then
        gbDragPlaceholder.LayoutOrder = order
    end
end

BeginGroupBoxDrag = function(groupBox, inputPosition)
    if gbDragging or draggingWindow or draggingResize then
        return
    end

    local state = Renderer.GroupBoxes[groupBox]
    if not state then
        return
    end

    local root = state.Root
    local absPos = root.AbsolutePosition
    local absSize = root.AbsoluteSize

    gbDragging = true
    gbDragGroupBox = groupBox
    gbDragSourceColumn = groupBox.Column
    gbDragTargetColumn = groupBox.Column
    gbDragPointer = ToScreenGuiSpace(inputPosition)

    local screenGuiPos = ScreenGui.AbsolutePosition
    local localRootX = absPos.X - screenGuiPos.X
    local localRootY = absPos.Y - screenGuiPos.Y

    gbDragOffset = Vector2.new(
        gbDragPointer.X - localRootX,
        gbDragPointer.Y - localRootY
    )

    local placeholderWidth = absSize.X - GROUPBOX_DRAG_PLACEHOLDER_INSET * 2
    local placeholder = Instance.new("Frame")
    placeholder.Name = "GBDragPlaceholder"
    placeholder.Size = UDim2.fromOffset(placeholderWidth, absSize.Y)
    placeholder.BackgroundColor3 = Library.Theme.Status.Accent
    placeholder.BackgroundTransparency = 0.88
    placeholder.BorderSizePixel = 0
    placeholder.LayoutOrder = groupBox.LayoutOrder

    local placeholderStroke = Instance.new("UIStroke")
    placeholderStroke.Color = Library.Theme.Status.Accent
    placeholderStroke.Thickness = 2
    placeholderStroke.Transparency = 0
    placeholderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    placeholderStroke.Parent = placeholder

    local placeholderCorner = Instance.new("UICorner")
    placeholderCorner.CornerRadius = UDim.new(0, GROUPBOX_CORNER_RADIUS)
    placeholderCorner.Parent = placeholder

    gbDragPlaceholder = placeholder
    placeholder.Parent = ColumnFrames[groupBox.Column]

    root.Parent = ScreenGui
    root.Size = UDim2.fromOffset(absSize.X, absSize.Y)
    root.Position = UDim2.fromOffset(localRootX, localRootY)
    root.ZIndex = 10

    UpdateDragPlaceholder()
end

local function EndGroupBoxDrag()
    if not gbDragging then
        return
    end

    gbDragging = false

    local groupBox = gbDragGroupBox
    gbDragGroupBox = nil

    local placeholder = gbDragPlaceholder
    gbDragPlaceholder = nil

    local sourceColumn = gbDragSourceColumn
    gbDragSourceColumn = nil

    if not groupBox then
        SafeDestroy(placeholder)
        return
    end

    local state = Renderer.GroupBoxes[groupBox]
    if not state then
        SafeDestroy(placeholder)
        return
    end

    local root = state.Root
    local targetColumn = gbDragTargetColumn or groupBox.Column
    local targetLayoutOrder = placeholder and placeholder.LayoutOrder or groupBox.LayoutOrder
    local targetColumnFrame = ColumnFrames[targetColumn]
    local placeholderY = placeholder and placeholder.AbsolutePosition.Y or root.AbsolutePosition.Y
    local columnX = targetColumnFrame and targetColumnFrame.AbsolutePosition.X or root.AbsolutePosition.X
    local targetAbsPos = Vector2.new(columnX, placeholderY)

    if gbDragSnapTween then
        gbDragSnapTween:Cancel()
        gbDragSnapTween = nil
    end

    local screenGuiPos = ScreenGui.AbsolutePosition
    local snapTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    gbDragSnapTween = TweenService:Create(
        root,
        snapTweenInfo,
        { Position = UDim2.fromOffset(
            targetAbsPos.X - screenGuiPos.X,
            targetAbsPos.Y - screenGuiPos.Y
        ) }
    )
    gbDragSnapTween:Play()

    if placeholder then
        TweenService:Create(placeholder, snapTweenInfo, { BackgroundTransparency = 1 }):Play()
        local placeholderStroke = placeholder:FindFirstChildOfClass("UIStroke")
        if placeholderStroke then
            TweenService:Create(placeholderStroke, snapTweenInfo, { Transparency = 1 }):Play()
        end
    end

    gbDragSnapTween.Completed:Connect(function(playbackState)
        if playbackState ~= Enum.PlaybackState.Completed then
            return
        end
        if not root or root.Parent ~= ScreenGui then
            SafeDestroy(placeholder)
            return
        end

        groupBox.Column = targetColumn
        root.LayoutOrder = targetLayoutOrder
        root.Size = UDim2.fromScale(1, 0)
        root.ZIndex = 1
        root.Parent = ColumnFrames[targetColumn]

        SafeDestroy(placeholder)

        RenumberColumn(targetColumn)
        if sourceColumn and sourceColumn ~= targetColumn then
            RenumberColumn(sourceColumn)
        end
    end)
end

local function Cleanup()
    if cleanedUp then
        return
    end

    cleanedUp = true
    draggingResize = false
    draggingWindow = false
    dragWidthOffset = 0

    ActiveTab:Destroy()

    if resizeHandleTween then
        resizeHandleTween:Cancel()
        resizeHandleTween = nil
    end

    if bottomDragTween then
        bottomDragTween:Cancel()
        bottomDragTween = nil
    end

    if gbDragSnapTween then
        gbDragSnapTween:Cancel()
        gbDragSnapTween = nil
    end

    SafeDestroy(gbDragPlaceholder)
    gbDragPlaceholder = nil
    gbDragging = false
    gbDragGroupBox = nil

    DisconnectConnections()
end

TrackConnection(BottomDragBarInteract.MouseEnter:Connect(function()
    bottomDragHovered = true
    UpdateAffordanceHoverState()
end))

TrackConnection(BottomDragBarInteract.MouseLeave:Connect(function()
    bottomDragHovered = false
    UpdateAffordanceHoverState()
end))

TrackConnection(BottomDragBarInteract.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 or draggingResize then
        return
    end

    draggingWindow = true
    windowDragStartTopLeft = GetWindowTopLeft()
    windowDragStartPointerPosition = ToScreenGuiSpace(input.Position)
    windowDragPointerPosition = windowDragStartPointerPosition
    UpdateAffordanceHoverState()
end))

TrackConnection(ResizeHandle.MouseEnter:Connect(function()
    resizeHandleHovered = true
    UpdateAffordanceHoverState()
end))

TrackConnection(ResizeHandle.MouseLeave:Connect(function()
    resizeHandleHovered = false
    UpdateAffordanceHoverState()
end))

TrackConnection(ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 or draggingWindow then
        return
    end

    draggingResize = true
    dragTopLeft = GetWindowTopLeft()
    pointerPosition = ToScreenGuiSpace(input.Position)
    dragWidthOffset = WindowFrame.AbsoluteSize.X - (pointerPosition.X - dragTopLeft.X)
    UpdateAffordanceHoverState()
end))

TrackConnection(UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseMovement then
        return
    end

    local guiPosition = ToScreenGuiSpace(input.Position)

    if draggingResize then
        pointerPosition = guiPosition
    end

    if draggingWindow then
        windowDragPointerPosition = guiPosition
    end

    if gbDragging then
        gbDragPointer = guiPosition
        UpdateDragPlaceholder()
    end
end))

TrackConnection(UserInputService.InputEnded:Connect(function(input)
    local stateChanged = false

    if draggingWindow and input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingWindow = false
        stateChanged = true
    end

    if draggingResize and input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingResize = false
        dragWidthOffset = 0
        stateChanged = true
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        EndGroupBoxDrag()
    end

    if stateChanged then
        UpdateAffordanceHoverState()
    end
end))

TrackConnection(RunService.RenderStepped:Connect(function()
    if gbDragging and gbDragGroupBox then
        local gbState = Renderer.GroupBoxes[gbDragGroupBox]
        if gbState and gbState.Root.Parent == ScreenGui then
            gbState.Root.Position = UDim2.fromOffset(
                gbDragPointer.X - gbDragOffset.X,
                gbDragPointer.Y - gbDragOffset.Y
            )
        end
    end

    if draggingWindow then
        if not ScreenGui.Parent or not WindowFrame.Parent then
            draggingWindow = false
            return
        end

        local delta = windowDragPointerPosition - windowDragStartPointerPosition
        local windowWidth = WindowFrame.AbsoluteSize.X
        local clampedTopLeft = ClampWindowTopLeft(
            windowDragStartTopLeft + delta,
            windowWidth,
            BOTTOM_DRAG_BAR_OUTSET + BOTTOM_DRAG_BAR_HEIGHT
        )

        ApplyWindowSize(clampedTopLeft, windowWidth)
        return
    end

    if not draggingResize then
        return
    end

    if not ScreenGui.Parent or not WindowFrame.Parent then
        draggingResize = false
        return
    end

    local screenSize = GetScreenSize(ScreenGui)
    local maxWidth = math.min(
        math.max(0, screenSize.X - dragTopLeft.X),
        math.max(0, (screenSize.Y - dragTopLeft.Y) * ASPECT_RATIO)
    )

    if maxWidth <= 0 then
        return
    end

    local minWidth = math.min(MIN_WINDOW_SIZE.X, maxWidth)
    local targetWidth = math.clamp((pointerPosition.X - dragTopLeft.X) + dragWidthOffset, minWidth, maxWidth)

    ApplyWindowSize(dragTopLeft, targetWidth)
end))

TrackConnection(ScreenGui.Destroying:Connect(function()
    Cleanup()
end))

function Library:Destroy()
    if self._destroyed then
        return
    end

    self._destroyed = true
    Cleanup()

    if ScreenGui.Parent then
        ScreenGui:Destroy()
    end
end

return Library
