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
local CHECKBOX_ROW_HEIGHT = 20
local CHECKBOX_BOX_SIZE = 14
local CHECKBOX_BOX_CORNER_RADIUS = 4
local CHECKBOX_FILL_INSET = 3
local CHECKBOX_ANIMATION_TIME = 0.15
local CONTROL_ADDON_GAP = 6
local DROPDOWN_ROW_HEIGHT = 22
local DROPDOWN_LABEL_HEIGHT = 12
local DROPDOWN_TRIGGER_HEIGHT = 22
local DROPDOWN_CORNER_RADIUS = 6
local DROPDOWN_MENU_PADDING = 6
local DROPDOWN_MENU_GAP = 4
local DROPDOWN_MENU_ITEM_HEIGHT = 20
local DROPDOWN_MENU_ITEM_PADDING = 4
local DROPDOWN_MENU_ITEM_INSET = 2
local DROPDOWN_SEARCH_HEIGHT = 22
local DROPDOWN_MIN_MENU_WIDTH = 140
local DROPDOWN_ANIMATION_TIME = 0.195
local DROPDOWN_CLOSED_HEIGHT = 4
local DROPDOWN_MENU_INSET = 1
local DROPDOWN_LABEL_WIDTH_SCALE = 0.42
local DROPDOWN_LABEL_GAP = 8
local DROPDOWN_INDICATOR_WIDTH = 18
local BUTTON_ROW_HEIGHT = 22
local BUTTON_CORNER_RADIUS = 6
local BUTTON_ANIMATION_TIME = 0.12
local BUTTON_DOUBLE_CLICK_WINDOW_DEFAULT = 0.35
local SLIDER_ROW_HEIGHT = 30
local SLIDER_COMPACT_ROW_HEIGHT = 20
local SLIDER_LABEL_HEIGHT = 14
local SLIDER_TRACK_HEIGHT = 4
local SLIDER_THUMB_SIZE = 10
local SLIDER_THUMB_HITBOX_SIZE = 20
local SLIDER_VALUE_WIDTH = 55
local SLIDER_LABEL_WIDTH_SCALE = 0.38
local SLIDER_LABEL_GAP = 6
local SLIDER_ANIMATION_TIME = 0.1
local INPUT_ROW_HEIGHT = 22
local INPUT_LABEL_WIDTH_SCALE = 0.42
local INPUT_LABEL_GAP = 8
local INPUT_CORNER_RADIUS = 6
local INPUT_ANIMATION_TIME = 0.12
local COLORPICKER_ROW_HEIGHT = 22
local COLORPICKER_SWATCH_SIZE = 14
local COLORPICKER_SV_SIZE = 150
local COLORPICKER_HUE_WIDTH = 14
local COLORPICKER_HUE_GAP = 6
local COLORPICKER_DISPLAY_WIDTH_SCALE = 0.2
local COLORPICKER_POPUP_PADDING = 8
local COLORPICKER_POPUP_GAP = 8
local COLORPICKER_POPUP_EDGE_PADDING = 8
local COLORPICKER_CURSOR_SIZE = 8
local COLORPICKER_HEX_HEIGHT = 22
local COLORPICKER_ANIMATION_TIME = 0.12
local COLORPICKER_ATTACHED_WIDTH = 22
local COLORPICKER_ATTACHED_HEIGHT = 18
local KEYPICKER_ROW_HEIGHT = 22
local KEYPICKER_BUTTON_HEIGHT = 20
local KEYPICKER_BUTTON_MIN_WIDTH = 34
local KEYPICKER_MODE_WIDTH = 52
local KEYPICKER_ATTACHED_HEIGHT = 18
local KEYPICKER_CORNER_RADIUS = 6
local KEYPICKER_ANIMATION_TIME = 0.12
local COLUMN_FADE_HEIGHT = 52
local EXECUTION_REGISTRY_KEY = "__SlateActiveExecution_Library"
local EXECUTION_GUI_PREFIX = "SlateUI_"
local EXECUTION_GUI_ATTRIBUTE = "SlateManagedExecution"

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

local function GetExecutionStore()
    if type(getgenv) == "function" then
        local ok, environment = pcall(getgenv)
        if ok and type(environment) == "table" then
            return environment
        end
    end

    if type(shared) == "table" then
        return shared
    end

    return _G
end

local EXECUTION_STORE = GetExecutionStore()

local function IsManagedSlateGui(gui)
    if not gui or not gui:IsA("ScreenGui") then
        return false
    end

    if gui:GetAttribute(EXECUTION_GUI_ATTRIBUTE) == true then
        return true
    end

    return string.sub(gui.Name, 1, #EXECUTION_GUI_PREFIX) == EXECUTION_GUI_PREFIX
end

local function DestroyPreviousExecution(guiParent)
    if EXECUTION_STORE then
        local previousExecution = EXECUTION_STORE[EXECUTION_REGISTRY_KEY]
        EXECUTION_STORE[EXECUTION_REGISTRY_KEY] = nil

        if type(previousExecution) == "table" and type(previousExecution.Destroy) == "function" then
            local ok, err = pcall(previousExecution.Destroy)
            if not ok then
                warn("[Slate] previous execution cleanup error:", err)
            end
        end
    end

    for _, child in ipairs(guiParent:GetChildren()) do
        if IsManagedSlateGui(child) then
            SafeDestroy(child)
        end
    end
end

local function SafeCallback(callback, ...)
    if type(callback) ~= "function" then
        return
    end

    local args = table.pack(...)
    task.spawn(function()
        local ok, err = pcall(function()
            callback(table.unpack(args, 1, args.n))
        end)

        if not ok then
            warn("[Slate] callback error:", err)
        end
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
    Named = {
        Toggles = {},
        Checkboxes = {},
        Dropdowns = {},
        Sliders = {},
        RangeSliders = {},
        Inputs = {},
        ColorPickers = {},
        KeyPickers = {},
        Options = {},
    },
}

local function CreateRegistryBridge(source)
    return setmetatable({}, {
        __index = function(_, key)
            return source[key]
        end,
        __newindex = function()
            error("registry bridge is read-only", 2)
        end,
        __metatable = "Locked",
    })
end

Library.Toggles = CreateRegistryBridge(Library.Registry.Named.Toggles)
Library.Checkboxes = CreateRegistryBridge(Library.Registry.Named.Checkboxes)
Library.Dropdowns = CreateRegistryBridge(Library.Registry.Named.Dropdowns)
Library.Sliders = CreateRegistryBridge(Library.Registry.Named.Sliders)
Library.RangeSliders = CreateRegistryBridge(Library.Registry.Named.RangeSliders)
Library.Inputs = CreateRegistryBridge(Library.Registry.Named.Inputs)
Library.ColorPickers = CreateRegistryBridge(Library.Registry.Named.ColorPickers)
Library.KeyPickers = CreateRegistryBridge(Library.Registry.Named.KeyPickers)
Library.Options = CreateRegistryBridge(Library.Registry.Named.Options)

local nextRegistryId = 0

local function RegisterComponent(component)
    if component.OptionKey then
        local existingControl = Library.Registry.Named.Options[component.OptionKey]
        if existingControl and existingControl ~= component then
            error(("duplicate control key %q"):format(component.OptionKey), 3)
        end
    end

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

    if component.OptionKey then
        Library.Registry.Named.Options[component.OptionKey] = component
        if component.Kind == "Toggle" then
            Library.Registry.Named.Toggles[component.OptionKey] = component
        elseif component.Kind == "Checkbox" then
            Library.Registry.Named.Checkboxes[component.OptionKey] = component
        elseif component.Kind == "Dropdown" then
            Library.Registry.Named.Dropdowns[component.OptionKey] = component
        elseif component.Kind == "Slider" then
            Library.Registry.Named.Sliders[component.OptionKey] = component
        elseif component.Kind == "RangeSlider" then
            Library.Registry.Named.RangeSliders[component.OptionKey] = component
        elseif component.Kind == "Input" then
            Library.Registry.Named.Inputs[component.OptionKey] = component
        elseif component.Kind == "ColorPicker" then
            Library.Registry.Named.ColorPickers[component.OptionKey] = component
        elseif component.Kind == "KeyPicker" then
            Library.Registry.Named.KeyPickers[component.OptionKey] = component
        end
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

    if component.OptionKey then
        if Library.Registry.Named.Options[component.OptionKey] == component then
            Library.Registry.Named.Options[component.OptionKey] = nil
        end

        if Library.Registry.Named.Toggles[component.OptionKey] == component then
            Library.Registry.Named.Toggles[component.OptionKey] = nil
        end

        if Library.Registry.Named.Checkboxes[component.OptionKey] == component then
            Library.Registry.Named.Checkboxes[component.OptionKey] = nil
        end

        if Library.Registry.Named.Dropdowns[component.OptionKey] == component then
            Library.Registry.Named.Dropdowns[component.OptionKey] = nil
        end

        if Library.Registry.Named.Sliders[component.OptionKey] == component then
            Library.Registry.Named.Sliders[component.OptionKey] = nil
        end

        if Library.Registry.Named.RangeSliders[component.OptionKey] == component then
            Library.Registry.Named.RangeSliders[component.OptionKey] = nil
        end

        if Library.Registry.Named.Inputs[component.OptionKey] == component then
            Library.Registry.Named.Inputs[component.OptionKey] = nil
        end

        if Library.Registry.Named.ColorPickers[component.OptionKey] == component then
            Library.Registry.Named.ColorPickers[component.OptionKey] = nil
        end

        if Library.Registry.Named.KeyPickers[component.OptionKey] == component then
            Library.Registry.Named.KeyPickers[component.OptionKey] = nil
        end
    end
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
    self._nextAddonLayoutOrder = 1
    return self
end

local function CanHostAttachedControls(control)
    return control
        and (control.Kind == "Label" or control.Kind == "Toggle" or control.Kind == "Checkbox")
        and not (control.Kind == "Label" and control.Wrap)
end

function Control:_AttachAddonControl(control)
    if not CanHostAttachedControls(self) then
        error(("%s cannot host attached controls"):format(self.Kind or "Control"), 2)
    end

    control.Parent = self
    control.LayoutOrder = self._nextAddonLayoutOrder
    self._nextAddonLayoutOrder = self._nextAddonLayoutOrder + 1

    table.insert(self.Children, control)
    RegisterComponent(control)

    if control.Kind == "KeyPicker"
        and control.SyncToggleState
        and (self.Kind == "Toggle" or self.Kind == "Checkbox")
        and control._SyncExternalState
    then
        control:_SyncExternalState(self.Value)
    end

    self.RenderHook:Fire("AddonAdded", control)

    return control
end

function Control:Destroy()
    if self._destroyed then
        return
    end

    for index = #self.Children, 1, -1 do
        self.Children[index]:Destroy()
    end

    if self.Parent then
        RemoveArrayValue(self.Parent.Children, self)
    end

    UnregisterComponent(self)
    Component.Destroy(self)
end

local Toggle = {}
Toggle.__index = Toggle
setmetatable(Toggle, Control)

local Checkbox = {}
Checkbox.__index = Checkbox
setmetatable(Checkbox, Control)

local Dropdown = {}
Dropdown.__index = Dropdown
setmetatable(Dropdown, Control)

local Button = {}
Button.__index = Button
setmetatable(Button, Control)

local Label = {}
Label.__index = Label
setmetatable(Label, Control)

local Slider = {}
Slider.__index = Slider
setmetatable(Slider, Control)

local RangeSlider = {}
RangeSlider.__index = RangeSlider
setmetatable(RangeSlider, Control)

local Input = {}
Input.__index = Input
setmetatable(Input, Control)

local ColorPicker = {}
ColorPicker.__index = ColorPicker
setmetatable(ColorPicker, Control)

local KeyPicker = {}
KeyPicker.__index = KeyPicker
setmetatable(KeyPicker, Control)

local CloseActiveDropdown

local function AssertBooleanValue(value, argumentName)
    if type(value) ~= "boolean" then
        error(("%s must be a boolean"):format(argumentName or "value"), 3)
    end
end

local function CloneArray(values)
    local result = {}
    for index, value in ipairs(values or {}) do
        result[index] = value
    end
    return result
end

local function AreArraysEqual(a, b)
    if #a ~= #b then
        return false
    end

    for index = 1, #a do
        if a[index] ~= b[index] then
            return false
        end
    end

    return true
end

local function NormalizeDropdownValues(values, argumentName)
    if values == nil then
        return {}, {}
    end

    if type(values) ~= "table" then
        error(("%s must be a table"):format(argumentName or "Values"), 3)
    end

    local list = {}
    local set = {}

    for _, rawValue in ipairs(values) do
        local value = tostring(rawValue)
        if value ~= "" and not set[value] then
            set[value] = true
            table.insert(list, value)
        end
    end

    return list, set
end

local function NormalizeDropdownDisabledValues(values, validSet)
    local list = {}
    local set = {}

    if type(values) ~= "table" then
        return list, set
    end

    for _, rawValue in ipairs(values) do
        local value = tostring(rawValue)
        if validSet[value] and not set[value] then
            set[value] = true
            table.insert(list, value)
        end
    end

    return list, set
end

local function WarnDisabledDropdownValue(optionKey, value)
    warn(("[Slate] attempted to select disabled dropdown value %q for %s"):format(value, optionKey))
end

local KEYPICKER_MODE_ORDER = {"Always", "Toggle", "Hold"}
local KEYPICKER_MODE_SET = {
    Always = true,
    Toggle = true,
    Hold = true,
}

local KEYPICKER_MOUSE_INPUTS = {
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
}

local KEYPICKER_DISPLAY_NAMES = {
    MB1 = "M1",
    MB2 = "M2",
    MB3 = "M3",
}

local function NormalizeKeyPickerMode(mode)
    local normalized = string.lower(tostring(mode or "Toggle"))
    if normalized == "always" then
        return "Always"
    end

    if normalized == "toggle" then
        return "Toggle"
    end

    if normalized == "hold" then
        return "Hold"
    end

    return "Toggle"
end

local function NormalizeKeyPickerBinding(value)
    if value == nil then
        return "None"
    end

    if typeof(value) == "EnumItem" then
        if value.EnumType == Enum.KeyCode then
            return value.Name
        end

        if value.EnumType == Enum.UserInputType then
            return KEYPICKER_MOUSE_INPUTS[value] or "None"
        end
    end

    if type(value) == "string" then
        local binding = value:gsub("^%s+", ""):gsub("%s+$", "")
        if binding == "" then
            return "None"
        end

        local upperBinding = string.upper(binding)
        if upperBinding == "NONE" then
            return "None"
        end

        if upperBinding == "MOUSELEFT" or upperBinding == "M1" or upperBinding == "MB1" then
            return "MB1"
        end

        if upperBinding == "MOUSERIGHT" or upperBinding == "M2" or upperBinding == "MB2" then
            return "MB2"
        end

        if upperBinding == "MOUSEMIDDLE" or upperBinding == "M3" or upperBinding == "MB3" then
            return "MB3"
        end

        if Enum.KeyCode[binding] then
            return binding
        end

        local titleBinding = binding:sub(1, 1):upper() .. binding:sub(2):lower()
        if Enum.KeyCode[titleBinding] then
            return titleBinding
        end
    end

    return "None"
end

local function GetKeyPickerBindingFromInput(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.Unknown then
            return nil
        end

        return input.KeyCode.Name
    end

    return KEYPICKER_MOUSE_INPUTS[input.UserInputType]
end

local function GetKeyPickerDisplayName(binding)
    return KEYPICKER_DISPLAY_NAMES[binding] or binding
end

local function GetNextKeyPickerMode(mode)
    for index, value in ipairs(KEYPICKER_MODE_ORDER) do
        if value == mode then
            return KEYPICKER_MODE_ORDER[(index % #KEYPICKER_MODE_ORDER) + 1]
        end
    end

    return KEYPICKER_MODE_ORDER[1]
end

local function CreateBooleanControl(class, kind, optionKey, props)
    props = props or {}

    if type(optionKey) ~= "string" or optionKey == "" then
        error(("%s key must be a non-empty string"):format(string.lower(kind)), 3)
    end

    local defaultValue = props.Default
    if defaultValue == nil then
        defaultValue = false
    end
    AssertBooleanValue(defaultValue, "Default")

    local self = setmetatable(Control.new(kind, props), class)
    self.OptionKey = optionKey
    self.Value = defaultValue
    self.Text = tostring(props.Text or optionKey)
    self.Tooltip = props.Tooltip
    self.DisabledTooltip = props.DisabledTooltip
    self.Disabled = not not props.Disabled
    self.Visible = props.Visible ~= false
    self.Risky = not not props.Risky
    self.Callback = props.Callback

    return self
end

local function SyncAttachedBooleanKeyPickers(control, value)
    for _, child in ipairs(control.Children) do
        if child.Kind == "KeyPicker" and child.SyncToggleState and child._SyncExternalState then
            child:_SyncExternalState(value)
        end
    end
end

function Toggle.new(optionKey, props)
    return CreateBooleanControl(Toggle, "Toggle", optionKey, props)
end

function Checkbox.new(optionKey, props)
    return CreateBooleanControl(Checkbox, "Checkbox", optionKey, props)
end

function Dropdown.new(optionKey, props)
    props = props or {}

    if type(optionKey) ~= "string" or optionKey == "" then
        error("dropdown key must be a non-empty string", 2)
    end

    local values, valueSet = NormalizeDropdownValues(props.Values, "Values")
    local disabledValues, disabledValueSet = NormalizeDropdownDisabledValues(props.DisabledValues, valueSet)

    local self = setmetatable(Control.new("Dropdown", props), Dropdown)
    self.OptionKey = optionKey
    self.Text = tostring(props.Text or optionKey)
    self.Tooltip = props.Tooltip
    self.DisabledTooltip = props.DisabledTooltip
    self.Disabled = not not props.Disabled
    self.Risky = not not props.Risky
    self.Visible = props.Visible ~= false
    self.Searchable = not not props.Searchable
    self.Multi = not not props.Multi
    self.Callback = props.Callback
    self.Values = values
    self.ValueSet = valueSet
    self.DisabledValues = disabledValues
    self.DisabledValueSet = disabledValueSet
    self.MaxVisibleDropdownItems = math.max(1, math.floor(tonumber(props.MaxVisibleDropdownItems) or 6))

    local defaultValue = props.Default
    if self.Multi and defaultValue == nil then
        defaultValue = {}
    end

    if self.Multi then
        if type(defaultValue) ~= "table" then
            error("Default must be a table when Multi is enabled", 2)
        end

        local sanitized = {}
        local seen = {}

        for _, rawValue in ipairs(defaultValue) do
            local value = tostring(rawValue)
            if self.ValueSet[value] and not self.DisabledValueSet[value] and not seen[value] then
                seen[value] = true
                table.insert(sanitized, value)
            end
        end

        self.Value = sanitized
    else
        local sanitized = nil

        if defaultValue ~= nil then
            local value = tostring(defaultValue)
            if self.ValueSet[value] and not self.DisabledValueSet[value] then
                sanitized = value
            end
        end

        self.Value = sanitized
    end

    return self
end

local BooleanControlMethods = {}

function BooleanControlMethods:_EmitVisualState(action)
    self.RenderHook:Fire(action)
end

function BooleanControlMethods:RawSet(value)
    AssertBooleanValue(value)
    if self.Value == value then
        return
    end

    self.Value = value
    SyncAttachedBooleanKeyPickers(self, value)
    self:_EmitVisualState("ValueChanged")
end

function BooleanControlMethods:SetValue(value)
    AssertBooleanValue(value)
    if self.Value == value then
        return
    end

    self.Value = value
    SyncAttachedBooleanKeyPickers(self, value)
    self.Changed:Fire(value)
    self:_EmitVisualState("ValueChanged")
    SafeCallback(self.Callback, value)
end

function BooleanControlMethods:Toggle()
    self:SetValue(not self.Value)
end

function BooleanControlMethods:SetDisabled(disabled)
    disabled = not not disabled
    if self.Disabled == disabled then
        return
    end

    self.Disabled = disabled
    for _, child in ipairs(self.Children) do
        if child.Kind == "KeyPicker" then
            child.RenderHook:Fire("VisualStateChanged")
        end
    end
    self:_EmitVisualState("VisualStateChanged")
end

function BooleanControlMethods:SetVisible(visible)
    visible = not not visible
    if self.Visible == visible then
        return
    end

    self.Visible = visible
    self:_EmitVisualState("VisualStateChanged")
end

function BooleanControlMethods:SetText(text)
    text = tostring(text or self.OptionKey)
    if self.Text == text then
        return
    end

    self.Text = text
    self:_EmitVisualState("VisualStateChanged")
end

function BooleanControlMethods:OnChanged(callback)
    return self.Changed:Connect(callback)
end

for name, method in pairs(BooleanControlMethods) do
    Toggle[name] = method
    Checkbox[name] = method
end

function Dropdown:_EmitVisualState(action)
    self.RenderHook:Fire(action)
end

function Dropdown:_GetChangedPayload()
    if self.Multi then
        return CloneArray(self.Value)
    end

    return self.Value
end

function Dropdown:_SanitizeValue(value, warnOnDisabled, errorLevel)
    if self.Multi then
        if value == nil then
            return {}
        end

        if type(value) ~= "table" then
            error("value must be a table when Multi is enabled", errorLevel or 3)
        end

        local sanitized = {}
        local seen = {}

        for _, rawValue in ipairs(value) do
            local nextValue = tostring(rawValue)
            if self.ValueSet[nextValue] then
                if self.DisabledValueSet[nextValue] then
                    if warnOnDisabled then
                        WarnDisabledDropdownValue(self.OptionKey, nextValue)
                    end
                elseif not seen[nextValue] then
                    seen[nextValue] = true
                    table.insert(sanitized, nextValue)
                end
            end
        end

        return sanitized
    end

    if value == nil then
        return nil, nil
    end

    local nextValue = tostring(value)
    if not self.ValueSet[nextValue] then
        return nil, "invalid"
    end

    if self.DisabledValueSet[nextValue] then
        if warnOnDisabled then
            WarnDisabledDropdownValue(self.OptionKey, nextValue)
        end

        return nil, "disabled"
    end

    return nextValue, nil
end

function Dropdown:_CommitValue(nextValue, fireChanged)
    local didChange
    if self.Multi then
        didChange = not AreArraysEqual(self.Value, nextValue)
    else
        didChange = self.Value ~= nextValue
    end

    if not didChange then
        return false
    end

    self.Value = nextValue

    if fireChanged then
        local payload = self:_GetChangedPayload()
        self.Changed:Fire(payload)
        SafeCallback(self.Callback, payload)
    end

    self:_EmitVisualState("ValueChanged")
    return true
end

function Dropdown:_AfterValuesChanged()
    local nextValue = self:_SanitizeValue(self.Value, false, 3)
    local didChange = self:_CommitValue(nextValue, true)

    self:_EmitVisualState("ValuesChanged")

    return didChange
end

function Dropdown:RawSet(value)
    local nextValue, reason = self:_SanitizeValue(value, false, 3)
    if not self.Multi and value ~= nil and reason == "invalid" then
        return
    end

    self:_CommitValue(nextValue, false)
end

function Dropdown:SetValue(value)
    local nextValue, reason = self:_SanitizeValue(value, true, 3)
    if not self.Multi and value ~= nil and reason == "invalid" then
        return
    end

    self:_CommitValue(nextValue, true)
end

function Dropdown:AddValue(value)
    local nextValue = tostring(value or "")
    if nextValue == "" or self.ValueSet[nextValue] then
        return
    end

    self.ValueSet[nextValue] = true
    table.insert(self.Values, nextValue)
    self:_EmitVisualState("ValuesChanged")
end

function Dropdown:RemoveValue(value)
    local nextValue = tostring(value or "")
    if nextValue == "" or not self.ValueSet[nextValue] then
        return
    end

    self.ValueSet[nextValue] = nil
    RemoveArrayValue(self.Values, nextValue)

    if self.DisabledValueSet[nextValue] then
        self.DisabledValueSet[nextValue] = nil
        RemoveArrayValue(self.DisabledValues, nextValue)
    end

    self:_AfterValuesChanged()
end

function Dropdown:RefreshValues(values)
    local nextValues, nextValueSet = NormalizeDropdownValues(values, "newValues")
    local nextDisabledValues, nextDisabledValueSet = NormalizeDropdownDisabledValues(self.DisabledValues, nextValueSet)

    self.Values = nextValues
    self.ValueSet = nextValueSet
    self.DisabledValues = nextDisabledValues
    self.DisabledValueSet = nextDisabledValueSet

    self:_AfterValuesChanged()
end

function Dropdown:SetDisabled(disabled)
    disabled = not not disabled
    if self.Disabled == disabled then
        return
    end

    self.Disabled = disabled
    self:_EmitVisualState("VisualStateChanged")
end

function Dropdown:SetVisible(visible)
    visible = not not visible
    if self.Visible == visible then
        return
    end

    self.Visible = visible
    self:_EmitVisualState("VisualStateChanged")
end

function Dropdown:SetText(text)
    text = tostring(text or self.OptionKey)
    if self.Text == text then
        return
    end

    self.Text = text
    self:_EmitVisualState("VisualStateChanged")
end

function Dropdown:OnChanged(callback)
    return self.Changed:Connect(callback)
end

function Button.new(props)
    props = props or {}

    local self = setmetatable(Control.new("Button", props), Button)
    self.Text = tostring(props.Text or "Button")
    self.ButtonText = tostring(props.ButtonText or "")
    self.Tooltip = props.Tooltip
    self.DisabledTooltip = props.DisabledTooltip
    self.Disabled = not not props.Disabled
    self.Visible = props.Visible ~= false
    self.Risky = not not props.Risky
    self.Func = type(props.Func) == "function" and props.Func or nil
    self.DoubleClick = not not props.DoubleClick
    self.DoubleClickWindow = tonumber(props.DoubleClickWindow) or BUTTON_DOUBLE_CLICK_WINDOW_DEFAULT
    self.OnInvoke = FastSignal.new()
    self._doubleClickPending = false
    self._doubleClickGen = 0
    return self
end

function Button:Invoke()
    if self.Disabled then
        return
    end

    if self.DoubleClick then
        if not self._doubleClickPending then
            self._doubleClickPending = true
            self._doubleClickGen = self._doubleClickGen + 1
            local gen = self._doubleClickGen
            self.RenderHook:Fire("VisualStateChanged")
            task.delay(self.DoubleClickWindow, function()
                if self._doubleClickGen == gen and not self._destroyed then
                    self._doubleClickPending = false
                    self.RenderHook:Fire("VisualStateChanged")
                end
            end)
            return
        end

        self._doubleClickPending = false
        self._doubleClickGen = self._doubleClickGen + 1
    end

    self.RenderHook:Fire("Clicked")

    if self.Func then
        task.spawn(function()
            local ok, err = pcall(self.Func)
            if not ok then
                warn("[Slate] button callback error:", err)
            end
        end)
    end

    self.OnInvoke:Fire()
end

function Button:SetDisabled(disabled)
    disabled = not not disabled
    if self.Disabled == disabled then
        return
    end

    self.Disabled = disabled
    self.RenderHook:Fire("VisualStateChanged")
end

function Button:SetVisible(visible)
    visible = not not visible
    if self.Visible == visible then
        return
    end

    self.Visible = visible
    self.RenderHook:Fire("VisualStateChanged")
end

function Button:SetText(text)
    text = tostring(text or "Button")
    if self.Text == text then
        return
    end

    self.Text = text
    self.RenderHook:Fire("VisualStateChanged")
end

function Button:SetButtonText(text)
    text = tostring(text or "")
    if self.ButtonText == text then
        return
    end

    self.ButtonText = text
    self.RenderHook:Fire("VisualStateChanged")
end

function Button:Destroy()
    if self._destroyed then
        return
    end

    self.OnInvoke:Destroy()
    Control.Destroy(self)
end

function Label.new(text, props)
    props = props or {}
    local self = setmetatable(Control.new("Label", props), Label)
    self.Text = tostring(text or "")
    self.Wrap = not not props.Wrap
    self.Visible = props.Visible ~= false
    return self
end

function Label:SetText(text)
    text = tostring(text or "")
    if self.Text == text then return end
    self.Text = text
    self.RenderHook:Fire("VisualStateChanged")
end

function Label:SetVisible(visible)
    visible = not not visible
    if self.Visible == visible then return end
    self.Visible = visible
    self.RenderHook:Fire("VisualStateChanged")
end

function Slider.new(optionKey, props)
    props = props or {}

    if type(optionKey) ~= "string" or optionKey == "" then
        error("slider key must be a non-empty string", 2)
    end

    local min = tonumber(props.Min) or 0
    local max = tonumber(props.Max) or 100
    if min >= max then
        error("slider Min must be less than Max", 2)
    end

    local self = setmetatable(Control.new("Slider", props), Slider)
    self.OptionKey = optionKey
    self.Text = tostring(props.Text or optionKey)
    self.Suffix = tostring(props.Suffix or "")
    self.Tooltip = props.Tooltip
    self.DisabledTooltip = props.DisabledTooltip
    self.Disabled = not not props.Disabled
    self.Visible = props.Visible ~= false
    self.Compact = not not props.Compact
    self.HideMax = not not props.HideMax
    self.FormatDisplayValue = type(props.FormatDisplayValue) == "function" and props.FormatDisplayValue or nil
    self.Min = min
    self.Max = max
    self.Rounding = math.max(0.001, tonumber(props.Rounding) or 1)
    self.Risky = not not props.Risky
    self.Callback = props.Callback
    self.Value = self:_Clamp(tonumber(props.Default) or min)
    return self
end

function Slider:_Clamp(value)
    local r = self.Rounding
    return math.clamp(math.round(value / r) * r, self.Min, self.Max)
end

function Slider:_FormatValue()
    if self.FormatDisplayValue then
        local ok, result = pcall(self.FormatDisplayValue, self.Value)
        if ok and result ~= nil then
            return tostring(result)
        end
    end

    local r = self.Rounding
    local valueStr
    if r < 1 then
        local decimals = math.max(1, math.ceil(-math.log10(r)))
        valueStr = string.format("%." .. decimals .. "f", self.Value)
    else
        valueStr = tostring(self.Value)
    end

    if self.HideMax then
        return valueStr .. self.Suffix
    end
    return valueStr .. " / " .. tostring(self.Max) .. self.Suffix
end

function Slider:RawSet(value)
    local next = self:_Clamp(tonumber(value) or self.Min)
    if self.Value == next then return end
    self.Value = next
    self.RenderHook:Fire("ValueChanged")
end

function Slider:SetValue(value)
    local next = self:_Clamp(tonumber(value) or self.Min)
    if self.Value == next then return end
    self.Value = next
    self.Changed:Fire(next)
    SafeCallback(self.Callback, next)
    self.RenderHook:Fire("ValueChanged")
end

function Slider:SetDisabled(disabled)
    disabled = not not disabled
    if self.Disabled == disabled then return end
    self.Disabled = disabled
    self.RenderHook:Fire("VisualStateChanged")
end

function Slider:SetVisible(visible)
    visible = not not visible
    if self.Visible == visible then return end
    self.Visible = visible
    self.RenderHook:Fire("VisualStateChanged")
end

function Slider:SetText(text)
    text = tostring(text or self.OptionKey)
    if self.Text == text then return end
    self.Text = text
    self.RenderHook:Fire("VisualStateChanged")
end

function Slider:OnChanged(callback)
    return self.Changed:Connect(callback)
end

function RangeSlider.new(optionKey, props)
    props = props or {}

    if type(optionKey) ~= "string" or optionKey == "" then
        error("range slider key must be a non-empty string", 2)
    end

    local min = tonumber(props.Min) or 0
    local max = tonumber(props.Max) or 100
    if min >= max then
        error("RangeSlider Min must be less than Max", 2)
    end

    local rounding = math.max(0.001, tonumber(props.Rounding) or 1)
    local minDistance = math.max(0, tonumber(props.MinDistance) or 0)

    local self = setmetatable(Control.new("RangeSlider", props), RangeSlider)
    self.OptionKey = optionKey
    self.Text = tostring(props.Text or optionKey)
    self.Suffix = tostring(props.Suffix or "")
    self.Tooltip = props.Tooltip
    self.DisabledTooltip = props.DisabledTooltip
    self.Disabled = not not props.Disabled
    self.Visible = props.Visible ~= false
    self.Min = min
    self.Max = max
    self.Rounding = rounding
    self.MinDistance = minDistance
    self.Callback = props.Callback

    local default = type(props.Default) == "table" and props.Default or {}
    local dLow = tonumber(default.min or default[1]) or min
    local dHigh = tonumber(default.max or default[2]) or max
    local r = rounding
    dLow = math.clamp(math.round(dLow / r) * r, min, max)
    dHigh = math.clamp(math.round(dHigh / r) * r, min, max)
    if dHigh - dLow < minDistance then
        dHigh = math.min(max, dLow + minDistance)
        if dHigh - dLow < minDistance then
            dLow = math.max(min, dHigh - minDistance)
        end
    end
    self.Value = {min = dLow, max = dHigh}
    return self
end

function RangeSlider:_FormatValue()
    local function fmt(v)
        local r = self.Rounding
        if r < 1 then
            local decimals = math.max(1, math.ceil(-math.log10(r)))
            return string.format("%." .. decimals .. "f", v)
        end
        return tostring(v)
    end
    return fmt(self.Value.min) .. " \xe2\x80\x93 " .. fmt(self.Value.max) .. self.Suffix
end

function RangeSlider:_SetLow(raw)
    local r = self.Rounding
    local low = math.clamp(math.round(raw / r) * r, self.Min, math.max(self.Min, self.Value.max - self.MinDistance))
    if self.Value.min == low then return end
    local newValue = {min = low, max = self.Value.max}
    self.Value = newValue
    self.Changed:Fire(newValue)
    SafeCallback(self.Callback, newValue)
    self.RenderHook:Fire("ValueChanged")
end

function RangeSlider:_SetHigh(raw)
    local r = self.Rounding
    local high = math.clamp(math.round(raw / r) * r, math.min(self.Max, self.Value.min + self.MinDistance), self.Max)
    if self.Value.max == high then return end
    local newValue = {min = self.Value.min, max = high}
    self.Value = newValue
    self.Changed:Fire(newValue)
    SafeCallback(self.Callback, newValue)
    self.RenderHook:Fire("ValueChanged")
end

function RangeSlider:SetValue(value)
    if type(value) ~= "table" then return end
    local r = self.Rounding
    local low = math.clamp(math.round((tonumber(value.min or value[1]) or self.Min) / r) * r, self.Min, self.Max)
    local high = math.clamp(math.round((tonumber(value.max or value[2]) or self.Max) / r) * r, self.Min, self.Max)
    if high - low < self.MinDistance then
        high = math.min(self.Max, low + self.MinDistance)
        if high - low < self.MinDistance then
            low = math.max(self.Min, high - self.MinDistance)
        end
    end
    if self.Value.min == low and self.Value.max == high then return end
    local newValue = {min = low, max = high}
    self.Value = newValue
    self.Changed:Fire(newValue)
    SafeCallback(self.Callback, newValue)
    self.RenderHook:Fire("ValueChanged")
end

function RangeSlider:RawSet(value)
    if type(value) ~= "table" then return end
    local r = self.Rounding
    local low = math.clamp(math.round((tonumber(value.min or value[1]) or self.Min) / r) * r, self.Min, self.Max)
    local high = math.clamp(math.round((tonumber(value.max or value[2]) or self.Max) / r) * r, self.Min, self.Max)
    if self.Value.min == low and self.Value.max == high then return end
    self.Value = {min = low, max = high}
    self.RenderHook:Fire("ValueChanged")
end

function RangeSlider:SetDisabled(disabled)
    disabled = not not disabled
    if self.Disabled == disabled then return end
    self.Disabled = disabled
    self.RenderHook:Fire("VisualStateChanged")
end

function RangeSlider:SetVisible(visible)
    visible = not not visible
    if self.Visible == visible then return end
    self.Visible = visible
    self.RenderHook:Fire("VisualStateChanged")
end

function RangeSlider:SetText(text)
    text = tostring(text or self.OptionKey)
    if self.Text == text then return end
    self.Text = text
    self.RenderHook:Fire("VisualStateChanged")
end

function RangeSlider:OnChanged(callback)
    return self.Changed:Connect(callback)
end

function Input.new(optionKey, props)
    props = props or {}

    if type(optionKey) ~= "string" or optionKey == "" then
        error("input key must be a non-empty string", 2)
    end

    local self = setmetatable(Control.new("Input", props), Input)
    self.OptionKey = optionKey
    self.Text = tostring(props.Text or optionKey)
    self.Placeholder = tostring(props.Placeholder or "")
    self.Tooltip = props.Tooltip
    self.DisabledTooltip = props.DisabledTooltip
    self.Disabled = not not props.Disabled
    self.Visible = props.Visible ~= false
    self.Risky = not not props.Risky
    self.Numeric = not not props.Numeric
    self.Password = not not props.Password
    self.Finished = not not props.Finished
    self.MaxLength = math.max(1, math.floor(tonumber(props.MaxLength) or math.huge))
    self.ClearTextOnFocus = not not props.ClearTextOnFocus
    self.Prefix = props.Prefix and tostring(props.Prefix) ~= "" and tostring(props.Prefix) or nil
    self.Callback = props.Callback
    self.Value = self:_Sanitize(tostring(props.Default or ""))
    return self
end

function Input:_FilterNumeric(text)
    local result = ""
    local hasDot = false
    for i = 1, #text do
        local c = string.sub(text, i, i)
        if c >= "0" and c <= "9" then
            result = result .. c
        elseif c == "-" and i == 1 then
            result = result .. c
        elseif c == "." and not hasDot then
            hasDot = true
            result = result .. c
        end
    end
    return result
end

function Input:_Sanitize(text)
    if self.Numeric then
        text = self:_FilterNumeric(text)
    end
    if #text > self.MaxLength then
        text = string.sub(text, 1, self.MaxLength)
    end
    return text
end

function Input:RawSet(value)
    value = self:_Sanitize(tostring(value or ""))
    if self.Value == value then return end
    self.Value = value
    self.RenderHook:Fire("ValueChanged")
end

function Input:SetValue(value)
    value = self:_Sanitize(tostring(value or ""))
    if self.Value == value then return end
    self.Value = value
    self.Changed:Fire(value)
    SafeCallback(self.Callback, value)
    self.RenderHook:Fire("ValueChanged")
end

function Input:SetDisabled(disabled)
    disabled = not not disabled
    if self.Disabled == disabled then return end
    self.Disabled = disabled
    self.RenderHook:Fire("VisualStateChanged")
end

function Input:SetVisible(visible)
    visible = not not visible
    if self.Visible == visible then return end
    self.Visible = visible
    self.RenderHook:Fire("VisualStateChanged")
end

function Input:SetText(text)
    text = tostring(text or self.OptionKey)
    if self.Text == text then return end
    self.Text = text
    self.RenderHook:Fire("VisualStateChanged")
end

function Input:OnChanged(callback)
    return self.Changed:Connect(callback)
end

function ColorPicker.new(optionKey, props)
    props = props or {}

    if type(optionKey) ~= "string" or optionKey == "" then
        error("color picker key must be a non-empty string", 2)
    end

    local self = setmetatable(Control.new("ColorPicker", props), ColorPicker)
    self.OptionKey = optionKey
    self.Text = tostring(props.Text or optionKey)
    self.Title = props.Title and tostring(props.Title) or nil
    self.Tooltip = props.Tooltip
    self.Disabled = not not props.Disabled
    self.Visible = props.Visible ~= false
    self.Callback = props.Callback
    self.AllowTransparency = props.Transparency ~= nil
    self.Transparency = math.clamp(tonumber(props.Transparency) or 0, 0, 1)

    local defaultColor = props.Default
    if typeof(defaultColor) ~= "Color3" then
        defaultColor = Color3.new(1, 1, 1)
    end
    self.Value = defaultColor
    self._hue, self._sat, self._val = defaultColor:ToHSV()
    return self
end

function ColorPicker:SetValue(color)
    if typeof(color) ~= "Color3" then return end
    self._hue, self._sat, self._val = color:ToHSV()
    self.Value = color
    self.Changed:Fire(color)
    SafeCallback(self.Callback, color)
    self.RenderHook:Fire("ValueChanged")
end

function ColorPicker:RawSet(color)
    if typeof(color) ~= "Color3" then return end
    self._hue, self._sat, self._val = color:ToHSV()
    self.Value = color
    self.RenderHook:Fire("ValueChanged")
end

function ColorPicker:SetTransparency(t)
    t = math.clamp(tonumber(t) or 0, 0, 1)
    if self.Transparency == t then return end
    self.Transparency = t
    self.RenderHook:Fire("TransparencyChanged")
end

function ColorPicker:SetDisabled(disabled)
    disabled = not not disabled
    if self.Disabled == disabled then return end
    self.Disabled = disabled
    self.RenderHook:Fire("VisualStateChanged")
end

function ColorPicker:SetVisible(visible)
    visible = not not visible
    if self.Visible == visible then return end
    self.Visible = visible
    self.RenderHook:Fire("VisualStateChanged")
end

function ColorPicker:SetText(text)
    text = tostring(text or self.OptionKey)
    if self.Text == text then return end
    self.Text = text
    self.RenderHook:Fire("VisualStateChanged")
end

function ColorPicker:OnChanged(callback)
    return self.Changed:Connect(callback)
end

local activeKeyPickerListener = nil

function KeyPicker.new(optionKey, props)
    props = props or {}

    if type(optionKey) ~= "string" or optionKey == "" then
        error("key picker key must be a non-empty string", 2)
    end

    local self = setmetatable(Control.new("KeyPicker", props), KeyPicker)
    self.OptionKey = optionKey
    self.Text = tostring(props.Text or optionKey)
    self.Disabled = not not props.Disabled
    self.Visible = props.Visible ~= false
    self.NoUI = not not props.NoUI
    self.WaitForCallback = not not props.WaitForCallback
    self.SyncToggleState = not not props.SyncToggleState
    self.Callback = props.Callback
    self.Clicked = FastSignal.new()
    self.Value = NormalizeKeyPickerBinding(props.Default)
    self.Mode = self.SyncToggleState and "Toggle" or NormalizeKeyPickerMode(props.Mode)
    self._listening = false
    self._state = self.Mode == "Always"
    self._callbackBusy = false

    return self
end

function KeyPicker:GetDisplayValue()
    return GetKeyPickerDisplayName(self.Value)
end

function KeyPicker:GetState()
    if self.Mode == "Always" then
        return true
    end

    return self._state
end

function KeyPicker:_FireChanged()
    self.Changed:Fire(self.Value, self.Mode)
end

function KeyPicker:_FireClicked(state)
    self.Clicked:Fire(state)

    if not self.Callback then
        return
    end

    if self.WaitForCallback then
        if self._callbackBusy then
            return
        end

        self._callbackBusy = true
        task.spawn(function()
            local ok, err = pcall(self.Callback, state, self.Value, self.Mode)
            if not ok then
                warn("[Slate] key picker callback error:", err)
            end
            self._callbackBusy = false
        end)
        return
    end

    SafeCallback(self.Callback, state, self.Value, self.Mode)
end

function KeyPicker:_SyncExternalState(state)
    local nextState = not not state
    if self._state == nextState then
        return
    end

    self._state = nextState
    self.RenderHook:Fire("StateChanged", nextState)
end

function KeyPicker:_SetState(state, fireClicked)
    local nextState = self.Mode == "Always" and true or not not state
    if self._state == nextState then
        return
    end

    self._state = nextState
    self.RenderHook:Fire("StateChanged", nextState)

    if self.SyncToggleState
        and self.Parent
        and (self.Parent.Kind == "Toggle" or self.Parent.Kind == "Checkbox")
        and self.Parent.Value ~= nextState
    then
        self.Parent:SetValue(nextState)
    end

    if fireClicked then
        self:_FireClicked(nextState)
    end
end

function KeyPicker:BeginListening()
    if self.Disabled then
        return
    end

    if activeKeyPickerListener and activeKeyPickerListener ~= self then
        activeKeyPickerListener:EndListening()
    end

    CloseActiveDropdown()

    activeKeyPickerListener = self
    if not self._listening then
        self._listening = true
        self.RenderHook:Fire("ListeningChanged", true)
    end
end

function KeyPicker:EndListening()
    if activeKeyPickerListener == self then
        activeKeyPickerListener = nil
    end

    if not self._listening then
        return
    end

    self._listening = false
    self.RenderHook:Fire("ListeningChanged", false)
end

function KeyPicker:CycleMode()
    if self.SyncToggleState then
        return
    end

    self:SetMode(GetNextKeyPickerMode(self.Mode))
end

function KeyPicker:RawSet(value)
    local nextBinding = self.Value
    local nextMode = self.Mode

    if type(value) == "table" then
        nextBinding = NormalizeKeyPickerBinding(value[1] or value.Key or nextBinding)
        nextMode = self.SyncToggleState and "Toggle" or NormalizeKeyPickerMode(value[2] or value.Mode or nextMode)
    else
        nextBinding = NormalizeKeyPickerBinding(value)
    end

    if self.Value == nextBinding and self.Mode == nextMode then
        return
    end

    self.Value = nextBinding
    self.Mode = nextMode
    self._state = self.Mode == "Always" and true
        or (self.SyncToggleState and self.Parent and (self.Parent.Kind == "Toggle" or self.Parent.Kind == "Checkbox") and self.Parent.Value)
        or false
    self.RenderHook:Fire("VisualStateChanged")
    self.RenderHook:Fire("StateChanged", self:GetState())
end

function KeyPicker:SetValue(value)
    local nextBinding = self.Value
    local nextMode = self.Mode

    if type(value) == "table" then
        nextBinding = NormalizeKeyPickerBinding(value[1] or value.Key or nextBinding)
        nextMode = self.SyncToggleState and "Toggle" or NormalizeKeyPickerMode(value[2] or value.Mode or nextMode)
    else
        nextBinding = NormalizeKeyPickerBinding(value)
    end

    if self.Value == nextBinding and self.Mode == nextMode then
        return
    end

    self.Value = nextBinding
    self.Mode = nextMode
    self._state = self.Mode == "Always" and true
        or (self.SyncToggleState and self.Parent and (self.Parent.Kind == "Toggle" or self.Parent.Kind == "Checkbox") and self.Parent.Value)
        or false
    self:_FireChanged()
    self.RenderHook:Fire("VisualStateChanged")
    self.RenderHook:Fire("StateChanged", self:GetState())
end

function KeyPicker:SetMode(mode)
    local nextMode = self.SyncToggleState and "Toggle" or NormalizeKeyPickerMode(mode)
    if self.Mode == nextMode then
        return
    end

    self.Mode = nextMode
    self._state = self.Mode == "Always" and true
        or (self.SyncToggleState and self.Parent and (self.Parent.Kind == "Toggle" or self.Parent.Kind == "Checkbox") and self.Parent.Value)
        or false
    self:_FireChanged()
    self.RenderHook:Fire("VisualStateChanged")
    self.RenderHook:Fire("StateChanged", self:GetState())
end

function KeyPicker:SetDisabled(disabled)
    disabled = not not disabled
    if self.Disabled == disabled then
        return
    end

    self.Disabled = disabled
    if disabled then
        self:EndListening()
    end
    self.RenderHook:Fire("VisualStateChanged")
end

function KeyPicker:SetVisible(visible)
    visible = not not visible
    if self.Visible == visible then
        return
    end

    self.Visible = visible
    if not visible then
        self:EndListening()
    end
    self.RenderHook:Fire("VisualStateChanged")
end

function KeyPicker:SetText(text)
    text = tostring(text or self.OptionKey)
    if self.Text == text then
        return
    end

    self.Text = text
    self.RenderHook:Fire("VisualStateChanged")
end

function KeyPicker:OnChanged(callback)
    return self.Changed:Connect(callback)
end

function KeyPicker:OnClick(callback)
    return self.Clicked:Connect(callback)
end

function KeyPicker:Destroy()
    if self._destroyed then
        return
    end

    self:EndListening()
    self.Clicked:Destroy()
    Control.Destroy(self)
end

TrackConnection(UserInputService.InputBegan:Connect(function(input, processed)
    local listeningPicker = activeKeyPickerListener
    if listeningPicker and not listeningPicker._destroyed then
        if input.KeyCode == Enum.KeyCode.Escape then
            listeningPicker:SetValue({"None", listeningPicker.Mode})
            listeningPicker:EndListening()
            return
        end

        local binding = GetKeyPickerBindingFromInput(input)
        if binding then
            listeningPicker:SetValue({binding, listeningPicker.Mode})
            listeningPicker:EndListening()
        end
        return
    end

    if processed or UserInputService:GetFocusedTextBox() then
        return
    end

    local binding = GetKeyPickerBindingFromInput(input)
    if not binding then
        return
    end

    for _, keyPicker in pairs(Library.Registry.Named.KeyPickers) do
        if not keyPicker._destroyed and not keyPicker.Disabled and not keyPicker._listening and keyPicker.Value == binding then
            if keyPicker.Mode == "Toggle" then
                keyPicker:_SetState(not keyPicker._state, true)
            elseif keyPicker.Mode == "Hold" then
                keyPicker:_SetState(true, true)
            end
        end
    end
end))

TrackConnection(UserInputService.InputEnded:Connect(function(input)
    if activeKeyPickerListener or UserInputService:GetFocusedTextBox() then
        return
    end

    local binding = GetKeyPickerBindingFromInput(input)
    if not binding then
        return
    end

    for _, keyPicker in pairs(Library.Registry.Named.KeyPickers) do
        if not keyPicker._destroyed
            and not keyPicker.Disabled
            and not keyPicker._listening
            and keyPicker.Mode == "Hold"
            and keyPicker.Value == binding
            and keyPicker._state
        then
            keyPicker:_SetState(false, true)
        end
    end
end))

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

local function AssertUniqueControlKey(optionKey)
    if Library.Registry.Named.Options[optionKey] then
        error(("duplicate control key %q"):format(optionKey), 3)
    end
end

local function AttachColorPickerToHost(host, optionKey, props)
    AssertUniqueControlKey(optionKey)
    return host:_AttachAddonControl(ColorPicker.new(optionKey, props))
end

local function AttachKeyPickerToHost(host, optionKey, props)
    AssertUniqueControlKey(optionKey)
    return host:_AttachAddonControl(KeyPicker.new(optionKey, props))
end

function GroupBox:AddLabel(text, props)
    return self:_AttachChildControl(Label.new(text, props))
end

function GroupBox:AddDivider()
    return self:_AttachChildControl(Control.new("Divider", {}))
end

function GroupBox:AddToggle(optionKey, props)
    AssertUniqueControlKey(optionKey)
    return self:_AttachChildControl(Toggle.new(optionKey, props))
end

function GroupBox:AddCheckbox(optionKey, props)
    AssertUniqueControlKey(optionKey)
    return self:_AttachChildControl(Checkbox.new(optionKey, props))
end

function GroupBox:AddDropdown(optionKey, props)
    AssertUniqueControlKey(optionKey)
    return self:_AttachChildControl(Dropdown.new(optionKey, props))
end

function GroupBox:AddButton(props)
    return self:_AttachChildControl(Button.new(props))
end

function GroupBox:AddSlider(optionKey, props)
    AssertUniqueControlKey(optionKey)
    return self:_AttachChildControl(Slider.new(optionKey, props))
end

function GroupBox:AddRangeSlider(optionKey, props)
    AssertUniqueControlKey(optionKey)
    return self:_AttachChildControl(RangeSlider.new(optionKey, props))
end

function GroupBox:AddInput(optionKey, props)
    AssertUniqueControlKey(optionKey)
    return self:_AttachChildControl(Input.new(optionKey, props))
end

function GroupBox:AddColorPicker(optionKey, props)
    AssertUniqueControlKey(optionKey)
    return self:_AttachChildControl(ColorPicker.new(optionKey, props))
end

function GroupBox:AddKeyPicker(optionKey, props)
    AssertUniqueControlKey(optionKey)
    return self:_AttachChildControl(KeyPicker.new(optionKey, props))
end

function Label:AddColorPicker(optionKey, props)
    return AttachColorPickerToHost(self, optionKey, props)
end

function Label:AddKeyPicker(optionKey, props)
    return AttachKeyPickerToHost(self, optionKey, props)
end

function Toggle:AddColorPicker(optionKey, props)
    return AttachColorPickerToHost(self, optionKey, props)
end

function Toggle:AddKeyPicker(optionKey, props)
    return AttachKeyPickerToHost(self, optionKey, props)
end

function Checkbox:AddColorPicker(optionKey, props)
    return AttachColorPickerToHost(self, optionKey, props)
end

function Checkbox:AddKeyPicker(optionKey, props)
    return AttachKeyPickerToHost(self, optionKey, props)
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

function GroupBox:SetPlacement(columnName, layoutOrder)
    local nextColumn = NormalizeColumnName(columnName or self.Column)
    local nextLayoutOrder = layoutOrder or self.LayoutOrder or 0

    if self.Column == nextColumn and self.LayoutOrder == nextLayoutOrder then
        return
    end

    self.Column = nextColumn
    self.LayoutOrder = nextLayoutOrder
    self.RenderHook:Fire("PlacementChanged", {
        Column = nextColumn,
        LayoutOrder = nextLayoutOrder,
    })
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

local function UnregisterCurrentExecution()
    if not EXECUTION_STORE then
        return
    end

    local currentExecution = EXECUTION_STORE[EXECUTION_REGISTRY_KEY]
    if type(currentExecution) == "table" and currentExecution.ScreenGui == ScreenGui then
        EXECUTION_STORE[EXECUTION_REGISTRY_KEY] = nil
    end
end

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

DestroyPreviousExecution(CoreGui)

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SlateUI_" .. tostring(math.random(1e5, 9e5))
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui:SetAttribute(EXECUTION_GUI_ATTRIBUTE, true)

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

local LeftColumn = Instance.new("ScrollingFrame")
LeftColumn.Name = "leftColumn"
LeftColumn.Size = columnSize
LeftColumn.Position = UDim2.new(0, 76, 0, 8)
LeftColumn.BackgroundTransparency = 1
LeftColumn.BorderSizePixel = 0
LeftColumn.ScrollingDirection = Enum.ScrollingDirection.Y
LeftColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
LeftColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
LeftColumn.ScrollBarThickness = 0
LeftColumn.ElasticBehavior = Enum.ElasticBehavior.Never
LeftColumn.Parent = WindowFrame

local MiddleColumn = Instance.new("ScrollingFrame")
MiddleColumn.Name = "middleColumn"
MiddleColumn.Size = columnSize
MiddleColumn.Position = UDim2.new(1 / 3, 84 - (100 / 3), 0, 8)
MiddleColumn.BackgroundTransparency = 1
MiddleColumn.BorderSizePixel = 0
MiddleColumn.ScrollingDirection = Enum.ScrollingDirection.Y
MiddleColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
MiddleColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
MiddleColumn.ScrollBarThickness = 0
MiddleColumn.ElasticBehavior = Enum.ElasticBehavior.Never
MiddleColumn.Parent = WindowFrame

local RightColumn = Instance.new("ScrollingFrame")
RightColumn.Name = "rightColumn"
RightColumn.Size = columnSize
RightColumn.Position = UDim2.new(2 / 3, 92 - (200 / 3), 0, 8)
RightColumn.BackgroundTransparency = 1
RightColumn.BorderSizePixel = 0
RightColumn.ScrollingDirection = Enum.ScrollingDirection.Y
RightColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
RightColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
RightColumn.ScrollBarThickness = 0
RightColumn.ElasticBehavior = Enum.ElasticBehavior.Never
RightColumn.Parent = WindowFrame

local ColumnFrames = {
    Left = LeftColumn,
    Middle = MiddleColumn,
    Right = RightColumn,
}

Library.Columns = ColumnFrames

do
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
end

do
    local function AddColumnFade(column)
        local fade = Instance.new("Frame")
        fade.Name = "ColumnFade"
        fade.AnchorPoint = Vector2.new(0, 1)
        fade.Position = UDim2.new(
            column.Position.X.Scale,
            column.Position.X.Offset,
            1, -8
        )
        fade.Size = UDim2.new(
            column.Size.X.Scale,
            column.Size.X.Offset,
            0, COLUMN_FADE_HEIGHT
        )
        fade.BackgroundColor3 = Library.Theme.Surface.Background
        fade.BackgroundTransparency = 0
        fade.BorderSizePixel = 0
        fade.ZIndex = 5
        fade.Parent = WindowFrame

        local gradient = Instance.new("UIGradient")
        gradient.Rotation = 90
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.45, 0.75),
            NumberSequenceKeypoint.new(0.8, 0.2),
            NumberSequenceKeypoint.new(1, 0),
        })
        gradient.Parent = fade
    end

    AddColumnFade(LeftColumn)
    AddColumnFade(MiddleColumn)
    AddColumnFade(RightColumn)
end

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

local Renderer = {
    GroupBoxes = {},
    Controls = {},
    ControlFactories = {},
}

Library.Renderer = Renderer
local RendererHelpers = {}
local RuntimeHelpers = {}
RendererHelpers.ActiveDropdownCloser = nil

function CloseActiveDropdown()
    if RendererHelpers.ActiveDropdownCloser then
        local closer = RendererHelpers.ActiveDropdownCloser
        RendererHelpers.ActiveDropdownCloser = nil
        closer()
    end
end

function RendererHelpers.ClaimActiveDropdown(closer)
    if RendererHelpers.ActiveDropdownCloser and RendererHelpers.ActiveDropdownCloser ~= closer then
        RendererHelpers.ActiveDropdownCloser()
    end

    RendererHelpers.ActiveDropdownCloser = closer
end

function RendererHelpers.ReleaseActiveDropdown(closer)
    if RendererHelpers.ActiveDropdownCloser == closer then
        RendererHelpers.ActiveDropdownCloser = nil
    end
end

function Library:RegisterControlRenderer(kind, factory)
    self.Renderer.ControlFactories[kind] = factory
end

function RendererHelpers.ResolveColumnFrame(columnName)
    return ColumnFrames[NormalizeColumnName(columnName)]
end

function RendererHelpers.DestroyControlView(control)
    local state = Renderer.Controls[control]
    if not state then
        return
    end

    Renderer.Controls[control] = nil

    if state.Cleanup then
        state.Cleanup()
    end

    SafeDestroy(state.Root)
end

function RendererHelpers.ResolveControlMountParent(owner)
    if not owner then
        return nil
    end

    if owner.Kind == "GroupBox" then
        local groupBoxState = Renderer.GroupBoxes[owner]
        return groupBoxState and groupBoxState.ControlArea or nil
    end

    local controlState = Renderer.Controls[owner]
    return controlState and controlState.AddonContainer or nil
end

function RendererHelpers.DestroyGroupBoxView(groupBox)
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

function RendererHelpers.GetGroupBoxTitleBottomMaskTransparency(collapsed)
    return collapsed and 1 or 0
end

function RendererHelpers.SetGroupBoxTitleBarCollapsedVisual(state, collapsed)
    state.TitleBottomMask.BackgroundTransparency = RendererHelpers.GetGroupBoxTitleBottomMaskTransparency(collapsed)
end

function RendererHelpers.TweenGroupBoxTitleBarCollapsedVisual(state, collapsed)
    state.TitleMaskTween = TweenService:Create(
        state.TitleBottomMask,
        TweenInfo.new(GROUPBOX_COLLAPSE_ANIMATION_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { BackgroundTransparency = RendererHelpers.GetGroupBoxTitleBottomMaskTransparency(collapsed) }
    )
    state.TitleMaskTween:Play()
end

function RendererHelpers.ApplyGroupBoxCollapsedState(groupBox, animate)
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
        RendererHelpers.SetGroupBoxTitleBarCollapsedVisual(state, collapsed)
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
        RendererHelpers.SetGroupBoxTitleBarCollapsedVisual(state, false)
        state.BodyContainer.Visible = true
        state.ControlArea.Visible = true
        state.BodyContainer.AutomaticSize = Enum.AutomaticSize.None
        state.BodyContainer.ClipsDescendants = true
        state.BodyContainer.Size = UDim2.new(1, 0, 0, startHeight)
        RendererHelpers.TweenGroupBoxTitleBarCollapsedVisual(state, true)
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
    RendererHelpers.SetGroupBoxTitleBarCollapsedVisual(state, true)
    RendererHelpers.TweenGroupBoxTitleBarCollapsedVisual(state, false)

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

function Renderer:MountControl(owner, control)
    local mountParent = RendererHelpers.ResolveControlMountParent(owner)
    if not mountParent then
        return
    end

    local factory = self.ControlFactories[control.Kind]
    if not factory then
        return
    end

    local rendered = factory(control)
    local view = rendered
    local handleAction
    local cleanup

    if type(rendered) == "table" and rendered.Root then
        view = rendered.Root
        handleAction = rendered.HandleAction
        cleanup = rendered.Cleanup
    end

    view.LayoutOrder = control.LayoutOrder or 0
    view.Parent = mountParent

    self.Controls[control] = {
        Root = view,
        HandleAction = handleAction,
        Cleanup = cleanup,
        AddonContainer = type(rendered) == "table" and rendered.AddonContainer or nil,
    }

    TrackConnection(control.RenderHook:Connect(function(action, payload)
        if action == "Destroy" then
            RendererHelpers.DestroyControlView(control)
            return
        end

        if action == "AddonAdded" then
            self:MountControl(control, payload)
            return
        end

        local currentState = self.Controls[control]
        if currentState and currentState.HandleAction then
            currentState.HandleAction(action, payload)
        end
    end))

    for _, child in ipairs(control.Children) do
        self:MountControl(control, child)
    end
end

function Renderer:MountGroupBox(groupBox)
    if self.GroupBoxes[groupBox] then
        return
    end

    local parentColumn = RendererHelpers.ResolveColumnFrame(groupBox.Column)

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
            RuntimeHelpers.BeginGroupBoxDrag(groupBox, input.Position)
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

    RendererHelpers.ApplyGroupBoxCollapsedState(groupBox, false)

    TrackConnection(groupBox.RenderHook:Connect(function(action, payload)
        if action == "ChildAdded" then
            self:MountControl(groupBox, payload)
            return
        end

        if action == "CollapsedChanged" then
            RendererHelpers.ApplyGroupBoxCollapsedState(groupBox, true)
            return
        end

        if action == "PlacementChanged" then
            local state = self.GroupBoxes[groupBox]
            if state then
                state.Root.LayoutOrder = payload.LayoutOrder

                local parentColumn = RendererHelpers.ResolveColumnFrame(payload.Column)
                if state.Root.Parent ~= ScreenGui and state.Root.Parent ~= parentColumn then
                    state.Root.Parent = parentColumn
                end
            end
            return
        end

        if action == "Destroy" then
            RendererHelpers.DestroyGroupBoxView(groupBox)
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
                RendererHelpers.DestroyGroupBoxView(groupBox)
            end
        end
    end))

    for _, groupBox in ipairs(tab.GroupBoxes) do
        self:MountGroupBox(groupBox)
    end
end

Library:RegisterControlRenderer("Label", function(control)
    local root = Instance.new("Frame")
    root.Name = "Label"
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0

    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.TextColor3 = Library.Theme.Text.Secondary
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Parent = root

    local addonContainer = Instance.new("Frame")
    addonContainer.Name = "AddonContainer"
    addonContainer.AnchorPoint = Vector2.new(1, 0)
    addonContainer.Position = UDim2.new(1, 0, 0, 0)
    addonContainer.AutomaticSize = Enum.AutomaticSize.X
    addonContainer.Size = UDim2.new(0, 0, 0, 18)
    addonContainer.BackgroundTransparency = 1
    addonContainer.BorderSizePixel = 0
    addonContainer.Parent = root

    local addonLayout = Instance.new("UIListLayout")
    addonLayout.FillDirection = Enum.FillDirection.Horizontal
    addonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    addonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    addonLayout.Padding = UDim.new(0, CONTROL_ADDON_GAP)
    addonLayout.Parent = addonContainer

    local localConnections = {}

    local function updateLayout()
        local addonWidth = addonContainer.AbsoluteSize.X
        local addonGap = addonWidth > 0 and CONTROL_ADDON_GAP or 0

        if control.Wrap then
            root.Size = UDim2.new(1, 0, 0, 0)
            root.AutomaticSize = Enum.AutomaticSize.Y
            label.Size = UDim2.new(1, -(addonWidth + addonGap), 0, 0)
            label.AutomaticSize = Enum.AutomaticSize.Y
            addonContainer.AnchorPoint = Vector2.new(1, 0)
            addonContainer.Position = UDim2.new(1, 0, 0, 0)
        else
            root.Size = UDim2.new(1, 0, 0, 14)
            root.AutomaticSize = Enum.AutomaticSize.None
            label.Size = UDim2.new(1, -(addonWidth + addonGap), 0, 14)
            label.AutomaticSize = Enum.AutomaticSize.None
            addonContainer.AnchorPoint = Vector2.new(1, 0.5)
            addonContainer.Position = UDim2.new(1, 0, 0.5, 0)
        end
    end

    local function applyVisual()
        root.Visible = control.Visible ~= false
        label.Visible = control.Visible ~= false
        label.Text = control.Text or ""
        label.TextWrapped = control.Wrap or false
        updateLayout()
    end

    table.insert(localConnections, addonContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout))
    table.insert(localConnections, root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if control.Wrap then
            updateLayout()
        end
    end))

    applyVisual()

    return {
        Root = root,
        AddonContainer = addonContainer,
        HandleAction = function(action)
            if action == "VisualStateChanged" then
                applyVisual()
            end
        end,
        Cleanup = function()
            for _, connection in ipairs(localConnections) do
                if connection.Connected then
                    connection:Disconnect()
                end
            end
        end,
    }
end)

Library:RegisterControlRenderer("Divider", function(control)
    local root = Instance.new("Frame")
    root.Name = "Divider"
    root.Size = UDim2.new(1, 0, 0, 9)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0

    local line = Instance.new("Frame")
    line.Name = "Line"
    line.AnchorPoint = Vector2.new(0, 0.5)
    line.Position = UDim2.fromScale(0, 0.5)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.BackgroundColor3 = Library.Theme.Surface.S4
    line.BorderSizePixel = 0
    line.Parent = root

    return root
end)

Library:RegisterControlRenderer("Toggle", function(control)
    local root = Instance.new("TextButton")
    root.Name = "Toggle"
    root.Size = UDim2.new(1, 0, 0, TOGGLE_ROW_HEIGHT)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.AutoButtonColor = false
    root.Text = ""

    local hoverFill = Instance.new("Frame")
    hoverFill.Name = "HoverFill"
    hoverFill.Size = UDim2.fromScale(1, 1)
    hoverFill.BackgroundColor3 = Library.Theme.Surface.S2
    hoverFill.BackgroundTransparency = 1
    hoverFill.BorderSizePixel = 0
    hoverFill.Parent = root

    local hoverCorner = Instance.new("UICorner")
    hoverCorner.CornerRadius = UDim.new(0, 6)
    hoverCorner.Parent = hoverFill

    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.Parent = root

    local rightRail = Instance.new("Frame")
    rightRail.Name = "RightRail"
    rightRail.AnchorPoint = Vector2.new(1, 0.5)
    rightRail.Position = UDim2.new(1, 0, 0.5, 0)
    rightRail.AutomaticSize = Enum.AutomaticSize.X
    rightRail.Size = UDim2.new(0, 0, 0, TOGGLE_ROW_HEIGHT)
    rightRail.BackgroundTransparency = 1
    rightRail.BorderSizePixel = 0
    rightRail.Parent = root

    local rightRailLayout = Instance.new("UIListLayout")
    rightRailLayout.FillDirection = Enum.FillDirection.Horizontal
    rightRailLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    rightRailLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rightRailLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightRailLayout.Padding = UDim.new(0, CONTROL_ADDON_GAP)
    rightRailLayout.Parent = rightRail

    local addonContainer = Instance.new("Frame")
    addonContainer.Name = "AddonContainer"
    addonContainer.AutomaticSize = Enum.AutomaticSize.X
    addonContainer.Size = UDim2.new(0, 0, 0, TOGGLE_ROW_HEIGHT)
    addonContainer.BackgroundTransparency = 1
    addonContainer.BorderSizePixel = 0
    addonContainer.LayoutOrder = 1
    addonContainer.Parent = rightRail

    local addonLayout = Instance.new("UIListLayout")
    addonLayout.FillDirection = Enum.FillDirection.Horizontal
    addonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    addonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    addonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    addonLayout.Padding = UDim.new(0, CONTROL_ADDON_GAP)
    addonLayout.Parent = addonContainer

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.fromOffset(TOGGLE_TRACK_WIDTH, TOGGLE_TRACK_HEIGHT)
    track.BorderSizePixel = 0
    track.LayoutOrder = 2
    track.Parent = rightRail

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, TOGGLE_TRACK_HEIGHT / 2)
    trackCorner.Parent = track

    local trackStroke = Instance.new("UIStroke")
    trackStroke.Thickness = 1
    trackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    trackStroke.Parent = track

    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.AnchorPoint = Vector2.new(0, 0.5)
    thumb.Position = UDim2.fromOffset(TOGGLE_THUMB_PADDING, TOGGLE_TRACK_HEIGHT / 2)
    thumb.Size = UDim2.fromOffset(TOGGLE_THUMB_SIZE, TOGGLE_THUMB_SIZE)
    thumb.BorderSizePixel = 0
    thumb.Parent = track

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(0, TOGGLE_THUMB_SIZE / 2)
    thumbCorner.Parent = thumb

    local activeTweens = {}
    local localConnections = {}
    local hovered = false

    local function cancelTweens()
        for index, tween in ipairs(activeTweens) do
            tween:Cancel()
            activeTweens[index] = nil
        end
    end

    local function tweenProperty(instance, duration, properties)
        if duration <= 0 then
            for key, value in pairs(properties) do
                instance[key] = value
            end
            return
        end

        local tween = TweenService:Create(
            instance,
            TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            properties
        )
        table.insert(activeTweens, tween)
        tween:Play()
    end

    local function updateLayout()
        label.Size = UDim2.new(1, -(rightRail.AbsoluteSize.X + 8), 1, 0)
    end

    local function applyVisual(instant)
        cancelTweens()

        local isOn = control.Value
        local isDisabled = control.Disabled
        local baseTextColor = control.Risky and Library.Theme.Status.Error or Library.Theme.Text.Primary
        local hoverTransparency = hovered and 0.82 or 1
        local duration = instant and 0 or TOGGLE_ANIMATION_TIME
        local thumbX = isOn and (TOGGLE_TRACK_WIDTH - TOGGLE_THUMB_SIZE - TOGGLE_THUMB_PADDING) or TOGGLE_THUMB_PADDING

        root.Visible = control.Visible
        label.Text = control.Text

        tweenProperty(hoverFill, duration, {
            BackgroundTransparency = isDisabled and 1 or hoverTransparency,
        })
        tweenProperty(label, duration, {
            TextColor3 = isDisabled and Library.Theme.Text.Secondary or baseTextColor,
            TextTransparency = isDisabled and 0.45 or 0,
        })
        tweenProperty(track, duration, {
            BackgroundColor3 = isOn and Library.Theme.Status.Accent or Library.Theme.Surface.S4,
            BackgroundTransparency = isDisabled and 0.35 or 0,
        })
        tweenProperty(trackStroke, duration, {
            Color = isOn and Library.Theme.Status.Accent or Library.Theme.Surface.S5,
            Transparency = isDisabled and 0.45 or 0.1,
        })
        tweenProperty(thumb, duration, {
            BackgroundColor3 = isDisabled and Library.Theme.Text.Tertiary or Library.Theme.Text.Primary,
            BackgroundTransparency = isDisabled and 0.2 or 0,
            Position = UDim2.fromOffset(thumbX, TOGGLE_TRACK_HEIGHT / 2),
        })
    end

    table.insert(localConnections, rightRail:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout))

    table.insert(localConnections, root.MouseEnter:Connect(function()
        hovered = true
        applyVisual(false)
    end))

    table.insert(localConnections, root.MouseLeave:Connect(function()
        hovered = false
        applyVisual(false)
    end))

    table.insert(localConnections, root.MouseButton1Click:Connect(function()
        if control.Disabled then
            return
        end

        control:Toggle()
    end))

    updateLayout()
    applyVisual(true)

    return {
        Root = root,
        AddonContainer = addonContainer,
        HandleAction = function(action)
            if action == "ValueChanged" or action == "VisualStateChanged" then
                applyVisual(false)
            end
        end,
        Cleanup = function()
            cancelTweens()
            for _, connection in ipairs(localConnections) do
                if connection.Connected then
                    connection:Disconnect()
                end
            end
        end,
    }
end)

Library:RegisterControlRenderer("Checkbox", function(control)
    local root = Instance.new("TextButton")
    root.Name = "Checkbox"
    root.Size = UDim2.new(1, 0, 0, CHECKBOX_ROW_HEIGHT)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.AutoButtonColor = false
    root.Text = ""

    local hoverFill = Instance.new("Frame")
    hoverFill.Name = "HoverFill"
    hoverFill.Size = UDim2.fromScale(1, 1)
    hoverFill.BackgroundColor3 = Library.Theme.Surface.S2
    hoverFill.BackgroundTransparency = 1
    hoverFill.BorderSizePixel = 0
    hoverFill.Parent = root

    local hoverCorner = Instance.new("UICorner")
    hoverCorner.CornerRadius = UDim.new(0, 6)
    hoverCorner.Parent = hoverFill

    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.Parent = root

    local rightRail = Instance.new("Frame")
    rightRail.Name = "RightRail"
    rightRail.AnchorPoint = Vector2.new(1, 0.5)
    rightRail.Position = UDim2.new(1, 0, 0.5, 0)
    rightRail.AutomaticSize = Enum.AutomaticSize.X
    rightRail.Size = UDim2.new(0, 0, 0, CHECKBOX_ROW_HEIGHT)
    rightRail.BackgroundTransparency = 1
    rightRail.BorderSizePixel = 0
    rightRail.Parent = root

    local rightRailLayout = Instance.new("UIListLayout")
    rightRailLayout.FillDirection = Enum.FillDirection.Horizontal
    rightRailLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    rightRailLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rightRailLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightRailLayout.Padding = UDim.new(0, CONTROL_ADDON_GAP)
    rightRailLayout.Parent = rightRail

    local addonContainer = Instance.new("Frame")
    addonContainer.Name = "AddonContainer"
    addonContainer.AutomaticSize = Enum.AutomaticSize.X
    addonContainer.Size = UDim2.new(0, 0, 0, CHECKBOX_ROW_HEIGHT)
    addonContainer.BackgroundTransparency = 1
    addonContainer.BorderSizePixel = 0
    addonContainer.LayoutOrder = 1
    addonContainer.Parent = rightRail

    local addonLayout = Instance.new("UIListLayout")
    addonLayout.FillDirection = Enum.FillDirection.Horizontal
    addonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    addonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    addonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    addonLayout.Padding = UDim.new(0, CONTROL_ADDON_GAP)
    addonLayout.Parent = addonContainer

    local box = Instance.new("Frame")
    box.Name = "Box"
    box.Size = UDim2.fromOffset(CHECKBOX_BOX_SIZE, CHECKBOX_BOX_SIZE)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.LayoutOrder = 2
    box.Parent = rightRail

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, CHECKBOX_BOX_CORNER_RADIUS)
    boxCorner.Parent = box

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Thickness = 1
    boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    boxStroke.Parent = box

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.AnchorPoint = Vector2.new(0.5, 0.5)
    fill.Position = UDim2.fromScale(0.5, 0.5)
    fill.Size = UDim2.new(1, -(CHECKBOX_FILL_INSET * 2), 1, -(CHECKBOX_FILL_INSET * 2))
    fill.BorderSizePixel = 0
    fill.Parent = box

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, math.max(0, CHECKBOX_BOX_CORNER_RADIUS - CHECKBOX_FILL_INSET + 1))
    fillCorner.Parent = fill

    local activeTweens = {}
    local localConnections = {}
    local hovered = false

    local function cancelTweens()
        for index, tween in ipairs(activeTweens) do
            tween:Cancel()
            activeTweens[index] = nil
        end
    end

    local function tweenProperty(instance, duration, properties)
        if duration <= 0 then
            for key, value in pairs(properties) do
                instance[key] = value
            end
            return
        end

        local tween = TweenService:Create(
            instance,
            TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            properties
        )
        table.insert(activeTweens, tween)
        tween:Play()
    end

    local function updateLayout()
        label.Size = UDim2.new(1, -(rightRail.AbsoluteSize.X + 8), 1, 0)
    end

    local function applyVisual(instant)
        cancelTweens()

        local isOn = control.Value
        local isDisabled = control.Disabled
        local activeColor = Library.Theme.Status.Accent
        local baseTextColor = control.Risky and Library.Theme.Status.Error or Library.Theme.Text.Primary
        local hoverTransparency = hovered and 0.82 or 1
        local duration = instant and 0 or CHECKBOX_ANIMATION_TIME

        root.Visible = control.Visible
        label.Text = control.Text

        tweenProperty(hoverFill, duration, {
            BackgroundTransparency = isDisabled and 1 or hoverTransparency,
        })
        tweenProperty(label, duration, {
            TextColor3 = isDisabled and Library.Theme.Text.Secondary or baseTextColor,
            TextTransparency = isDisabled and 0.45 or 0,
        })
        tweenProperty(boxStroke, duration, {
            Color = isOn and activeColor or Library.Theme.Surface.S5,
            Transparency = isDisabled and 0.45 or 0.1,
        })
        tweenProperty(fill, duration, {
            BackgroundColor3 = activeColor,
            BackgroundTransparency = isOn and (isDisabled and 0.45 or 0) or 1,
        })
    end

    table.insert(localConnections, rightRail:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout))

    table.insert(localConnections, root.MouseEnter:Connect(function()
        hovered = true
        applyVisual(false)
    end))

    table.insert(localConnections, root.MouseLeave:Connect(function()
        hovered = false
        applyVisual(false)
    end))

    table.insert(localConnections, root.MouseButton1Click:Connect(function()
        if control.Disabled then
            return
        end

        control:Toggle()
    end))

    updateLayout()
    applyVisual(true)

    return {
        Root = root,
        AddonContainer = addonContainer,
        HandleAction = function(action)
            if action == "ValueChanged" or action == "VisualStateChanged" then
                applyVisual(false)
            end
        end,
        Cleanup = function()
            cancelTweens()
            for _, connection in ipairs(localConnections) do
                if connection.Connected then
                    connection:Disconnect()
                end
            end
        end,
    }
end)

Library:RegisterControlRenderer("Button", function(control)
    local root = Instance.new("Frame")
    root.Name = "Button"
    root.Size = UDim2.new(1, 0, 0, BUTTON_ROW_HEIGHT)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0

    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.Size = UDim2.new(DROPDOWN_LABEL_WIDTH_SCALE, -DROPDOWN_LABEL_GAP, 1, 0)
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = root

    local pill = Instance.new("TextButton")
    pill.Name = "Pill"
    pill.AnchorPoint = Vector2.new(1, 0.5)
    pill.Position = UDim2.new(1, 0, 0.5, 0)
    pill.Size = UDim2.new(1 - DROPDOWN_LABEL_WIDTH_SCALE, -DROPDOWN_LABEL_GAP, 1, -2)
    pill.BackgroundColor3 = Library.Theme.Surface.S2
    pill.BorderSizePixel = 0
    pill.AutoButtonColor = false
    pill.Text = ""
    pill.TextSize = 11
    pill.Font = Enum.Font.GothamMedium
    pill.TextColor3 = Library.Theme.Text.Secondary
    pill.TextXAlignment = Enum.TextXAlignment.Center
    pill.TextYAlignment = Enum.TextYAlignment.Center
    pill.TextTruncate = Enum.TextTruncate.AtEnd
    pill.Parent = root

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(0, BUTTON_CORNER_RADIUS)
    pillCorner.Parent = pill

    local pillStroke = Instance.new("UIStroke")
    pillStroke.Thickness = 1
    pillStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    pillStroke.Color = Library.Theme.Surface.S5
    pillStroke.Transparency = 0.5
    pillStroke.Parent = pill

    local activeTweens = {}
    local localConnections = {}
    local hovered = false

    local function cancelTweens()
        for index, tween in ipairs(activeTweens) do
            tween:Cancel()
            activeTweens[index] = nil
        end
    end

    local function tweenProperty(instance, duration, properties)
        if duration <= 0 then
            for key, value in pairs(properties) do
                instance[key] = value
            end
            return
        end

        local tween = TweenService:Create(
            instance,
            TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            properties
        )
        table.insert(activeTweens, tween)
        tween:Play()
    end

    local function applyVisual(instant)
        cancelTweens()

        local isDisabled = control.Disabled
        local isPending = control._doubleClickPending
        local isRisky = control.Risky
        local duration = instant and 0 or BUTTON_ANIMATION_TIME

        root.Visible = control.Visible
        label.Text = control.Text
        pill.Text = control.ButtonText

        local labelColor = isDisabled and Library.Theme.Text.Secondary
            or (isRisky and Library.Theme.Status.Error or Library.Theme.Text.Primary)
        tweenProperty(label, duration, {
            TextColor3 = labelColor,
            TextTransparency = isDisabled and 0.45 or 0,
        })

        local pillTextColor = isDisabled and Library.Theme.Text.Muted or Library.Theme.Text.Secondary
        tweenProperty(pill, duration, {
            TextColor3 = pillTextColor,
            TextTransparency = isDisabled and 0.5 or 0,
        })

        if isPending then
            tweenProperty(pill, duration, {
                BackgroundColor3 = Library.Theme.Status.Accent,
                BackgroundTransparency = 0.72,
            })
            tweenProperty(pillStroke, duration, {
                Color = Library.Theme.Status.Accent,
                Transparency = 0.4,
            })
        else
            local pillBg = hovered and Library.Theme.Surface.S3 or Library.Theme.Surface.S2
            local strokeColor = isRisky and Library.Theme.Status.Error or Library.Theme.Surface.S5
            tweenProperty(pill, duration, {
                BackgroundColor3 = isDisabled and Library.Theme.Surface.S1 or pillBg,
                BackgroundTransparency = isDisabled and 0.3 or 0,
            })
            tweenProperty(pillStroke, duration, {
                Color = strokeColor,
                Transparency = isDisabled and 0.7 or 0.5,
            })
        end

        pill.Active = not isDisabled
    end

    table.insert(localConnections, pill.MouseEnter:Connect(function()
        hovered = true
        applyVisual(false)
    end))

    table.insert(localConnections, pill.MouseLeave:Connect(function()
        hovered = false
        applyVisual(false)
    end))

    table.insert(localConnections, pill.MouseButton1Click:Connect(function()
        control:Invoke()
    end))

    applyVisual(true)

    return {
        Root = root,
        HandleAction = function(action)
            if action == "VisualStateChanged" then
                applyVisual(false)
            elseif action == "Clicked" then
                cancelTweens()
                pill.BackgroundColor3 = Library.Theme.Surface.S4
                pill.BackgroundTransparency = 0
                tweenProperty(pill, BUTTON_ANIMATION_TIME * 2.5, {
                    BackgroundColor3 = hovered and Library.Theme.Surface.S3 or Library.Theme.Surface.S2,
                    BackgroundTransparency = 0,
                })
            end
        end,
        Cleanup = function()
            cancelTweens()
            for _, connection in ipairs(localConnections) do
                if connection.Connected then
                    connection:Disconnect()
                end
            end
        end,
    }
end)

Library:RegisterControlRenderer("Slider", function(control)
    local isCompact = control.Compact
    local rowHeight = isCompact and SLIDER_COMPACT_ROW_HEIGHT or SLIDER_ROW_HEIGHT

    local root = Instance.new("TextButton")
    root.Name = "Slider"
    root.Size = UDim2.new(1, 0, 0, rowHeight)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.AutoButtonColor = false
    root.Text = ""

    local hoverFill = Instance.new("Frame")
    hoverFill.Name = "HoverFill"
    hoverFill.Size = UDim2.fromScale(1, 1)
    hoverFill.BackgroundColor3 = Library.Theme.Surface.S2
    hoverFill.BackgroundTransparency = 1
    hoverFill.BorderSizePixel = 0
    hoverFill.Parent = root

    local hoverCorner = Instance.new("UICorner")
    hoverCorner.CornerRadius = UDim.new(0, 6)
    hoverCorner.Parent = hoverFill

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.BackgroundTransparency = 1
    textLabel.BorderSizePixel = 0
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.Parent = root

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.AnchorPoint = Vector2.new(1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.BorderSizePixel = 0
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.TextYAlignment = Enum.TextYAlignment.Center
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.Parent = root

    if isCompact then
        textLabel.Size = UDim2.new(SLIDER_LABEL_WIDTH_SCALE, 0, 1, 0)
        textLabel.Position = UDim2.new(0, 0, 0, 0)
        valueLabel.Size = UDim2.fromOffset(SLIDER_VALUE_WIDTH, rowHeight)
        valueLabel.Position = UDim2.new(1, 0, 0, 0)
    else
        textLabel.Size = UDim2.new(1, -SLIDER_VALUE_WIDTH, 0, SLIDER_LABEL_HEIGHT)
        textLabel.Position = UDim2.new(0, 0, 0, 0)
        valueLabel.Size = UDim2.fromOffset(SLIDER_VALUE_WIDTH, SLIDER_LABEL_HEIGHT)
        valueLabel.Position = UDim2.new(1, 0, 0, 0)
    end

    local trackContainer = Instance.new("Frame")
    trackContainer.Name = "TrackContainer"
    trackContainer.BackgroundTransparency = 1
    trackContainer.BorderSizePixel = 0
    trackContainer.Parent = root

    if isCompact then
        trackContainer.Size = UDim2.new(1 - SLIDER_LABEL_WIDTH_SCALE, -(SLIDER_VALUE_WIDTH + SLIDER_LABEL_GAP * 2), 1, 0)
        trackContainer.Position = UDim2.new(SLIDER_LABEL_WIDTH_SCALE, SLIDER_LABEL_GAP, 0, 0)
    else
        trackContainer.Size = UDim2.new(1, 0, 0, rowHeight - SLIDER_LABEL_HEIGHT)
        trackContainer.Position = UDim2.new(0, 0, 0, SLIDER_LABEL_HEIGHT)
    end

    local trackBg = Instance.new("Frame")
    trackBg.Name = "TrackBg"
    trackBg.AnchorPoint = Vector2.new(0, 0.5)
    trackBg.Position = UDim2.new(0, 0, 0.5, 0)
    trackBg.Size = UDim2.new(1, 0, 0, SLIDER_TRACK_HEIGHT)
    trackBg.BackgroundColor3 = Library.Theme.Surface.S5
    trackBg.BorderSizePixel = 0
    trackBg.Parent = trackContainer

    local trackBgCorner = Instance.new("UICorner")
    trackBgCorner.CornerRadius = UDim.new(0, SLIDER_TRACK_HEIGHT / 2)
    trackBgCorner.Parent = trackBg

    local trackFill = Instance.new("Frame")
    trackFill.Name = "TrackFill"
    trackFill.Position = UDim2.new(0, 0, 0, 0)
    trackFill.Size = UDim2.new(0, 0, 1, 0)
    trackFill.BackgroundColor3 = Library.Theme.Status.Accent
    trackFill.BorderSizePixel = 0
    trackFill.Parent = trackBg

    local trackFillCorner = Instance.new("UICorner")
    trackFillCorner.CornerRadius = UDim.new(0, SLIDER_TRACK_HEIGHT / 2)
    trackFillCorner.Parent = trackFill

    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(0, 0, 0.5, 0)
    thumb.Size = UDim2.fromOffset(SLIDER_THUMB_SIZE, SLIDER_THUMB_SIZE)
    thumb.BackgroundColor3 = Library.Theme.Text.Primary
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 2
    thumb.Parent = trackBg

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(0, SLIDER_THUMB_SIZE / 2)
    thumbCorner.Parent = thumb

    local thumbStroke = Instance.new("UIStroke")
    thumbStroke.Thickness = 1.5
    thumbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    thumbStroke.Color = Library.Theme.Surface.S5
    thumbStroke.Transparency = 0.5
    thumbStroke.Parent = thumb

    local activeTweens = {}
    local localConnections = {}
    local hovered = false
    local dragging = false

    local function cancelTweens()
        for index, tween in ipairs(activeTweens) do
            tween:Cancel()
            activeTweens[index] = nil
        end
    end

    local function tweenProperty(instance, duration, properties)
        if duration <= 0 then
            for key, value in pairs(properties) do
                instance[key] = value
            end
            return
        end

        local tween = TweenService:Create(
            instance,
            TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            properties
        )
        table.insert(activeTweens, tween)
        tween:Play()
    end

    local function applyThumb(value, instant)
        local range = control.Max - control.Min
        local percent = range > 0 and (value - control.Min) / range or 0
        local targetPos = UDim2.new(percent, 0, 0.5, 0)
        local targetFill = UDim2.new(percent, 0, 1, 0)
        if instant then
            thumb.Position = targetPos
            trackFill.Size = targetFill
        else
            tweenProperty(thumb, SLIDER_ANIMATION_TIME, {Position = targetPos})
            tweenProperty(trackFill, SLIDER_ANIMATION_TIME, {Size = targetFill})
        end
    end

    local function applyVisual(instant)
        cancelTweens()

        local isDisabled = control.Disabled
        local duration = instant and 0 or SLIDER_ANIMATION_TIME
        local hoverTransparency = hovered and 0.82 or 1

        root.Visible = control.Visible
        textLabel.Text = control.Text
        valueLabel.Text = control:_FormatValue()

        tweenProperty(hoverFill, duration, {
            BackgroundTransparency = isDisabled and 1 or hoverTransparency,
        })
        local labelColor = isDisabled and Library.Theme.Text.Secondary
            or (control.Risky and Library.Theme.Status.Error or Library.Theme.Text.Primary)
        tweenProperty(textLabel, duration, {
            TextColor3 = labelColor,
            TextTransparency = isDisabled and 0.45 or 0,
        })
        tweenProperty(valueLabel, duration, {
            TextColor3 = isDisabled and Library.Theme.Text.Tertiary or Library.Theme.Text.Secondary,
            TextTransparency = isDisabled and 0.45 or 0,
        })
        tweenProperty(trackBg, duration, {
            BackgroundColor3 = isDisabled and Library.Theme.Surface.S4 or Library.Theme.Surface.S5,
        })
        tweenProperty(trackFill, duration, {
            BackgroundColor3 = Library.Theme.Status.Accent,
            BackgroundTransparency = isDisabled and 0.5 or 0,
        })
        tweenProperty(thumb, duration, {
            BackgroundColor3 = isDisabled and Library.Theme.Text.Tertiary or Library.Theme.Text.Primary,
            BackgroundTransparency = isDisabled and 0.3 or 0,
        })

        applyThumb(control.Value, instant)
    end

    local function getValueFromMouse(mouseX)
        local absX = trackBg.AbsolutePosition.X
        local absW = trackBg.AbsoluteSize.X
        if absW <= 0 then return control.Value end
        local percent = math.clamp((mouseX - absX) / absW, 0, 1)
        return control:_Clamp(control.Min + percent * (control.Max - control.Min))
    end

    table.insert(localConnections, root.MouseEnter:Connect(function()
        hovered = true
        applyVisual(false)
    end))

    table.insert(localConnections, root.MouseLeave:Connect(function()
        hovered = false
        applyVisual(false)
    end))

    local thumbHitbox = Instance.new("TextButton")
    thumbHitbox.Name = "ThumbHitbox"
    thumbHitbox.AnchorPoint = Vector2.new(0.5, 0.5)
    thumbHitbox.Position = UDim2.fromScale(0.5, 0.5)
    thumbHitbox.Size = UDim2.fromOffset(SLIDER_THUMB_HITBOX_SIZE, SLIDER_THUMB_HITBOX_SIZE)
    thumbHitbox.BackgroundTransparency = 1
    thumbHitbox.BorderSizePixel = 0
    thumbHitbox.ZIndex = thumb.ZIndex + 1
    thumbHitbox.Text = ""
    thumbHitbox.AutoButtonColor = false
    thumbHitbox.Parent = thumb

    table.insert(localConnections, trackContainer.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if control.Disabled then return end
        dragging = true
        control:SetValue(getValueFromMouse(input.Position.X))
    end))

    table.insert(localConnections, thumbHitbox.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if control.Disabled then return end
        dragging = true
        control:SetValue(getValueFromMouse(input.Position.X))
    end))

    table.insert(localConnections, UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        control:SetValue(getValueFromMouse(input.Position.X))
    end))

    table.insert(localConnections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))

    applyVisual(true)

    return {
        Root = root,
        HandleAction = function(action)
            if action == "ValueChanged" then
                cancelTweens()
                valueLabel.Text = control:_FormatValue()
                applyThumb(control.Value, dragging)
            elseif action == "VisualStateChanged" then
                applyVisual(false)
            end
        end,
        Cleanup = function()
            cancelTweens()
            for _, connection in ipairs(localConnections) do
                if connection.Connected then
                    connection:Disconnect()
                end
            end
        end,
    }
end)

Library:RegisterControlRenderer("RangeSlider", function(control)
    local rowHeight = SLIDER_ROW_HEIGHT

    local root = Instance.new("TextButton")
    root.Name = "RangeSlider"
    root.Size = UDim2.new(1, 0, 0, rowHeight)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.AutoButtonColor = false
    root.Text = ""

    local hoverFill = Instance.new("Frame")
    hoverFill.Name = "HoverFill"
    hoverFill.Size = UDim2.fromScale(1, 1)
    hoverFill.BackgroundColor3 = Library.Theme.Surface.S2
    hoverFill.BackgroundTransparency = 1
    hoverFill.BorderSizePixel = 0
    hoverFill.Parent = root

    local hoverCorner = Instance.new("UICorner")
    hoverCorner.CornerRadius = UDim.new(0, 6)
    hoverCorner.Parent = hoverFill

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.Size = UDim2.new(1, -SLIDER_VALUE_WIDTH, 0, SLIDER_LABEL_HEIGHT)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.BorderSizePixel = 0
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.Parent = root

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.AnchorPoint = Vector2.new(1, 0)
    valueLabel.Size = UDim2.fromOffset(SLIDER_VALUE_WIDTH, SLIDER_LABEL_HEIGHT)
    valueLabel.Position = UDim2.new(1, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.BorderSizePixel = 0
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.TextYAlignment = Enum.TextYAlignment.Center
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.Parent = root

    local trackContainer = Instance.new("Frame")
    trackContainer.Name = "TrackContainer"
    trackContainer.Size = UDim2.new(1, 0, 0, rowHeight - SLIDER_LABEL_HEIGHT)
    trackContainer.Position = UDim2.new(0, 0, 0, SLIDER_LABEL_HEIGHT)
    trackContainer.BackgroundTransparency = 1
    trackContainer.BorderSizePixel = 0
    trackContainer.Parent = root

    local trackBg = Instance.new("Frame")
    trackBg.Name = "TrackBg"
    trackBg.AnchorPoint = Vector2.new(0, 0.5)
    trackBg.Position = UDim2.new(0, 0, 0.5, 0)
    trackBg.Size = UDim2.new(1, 0, 0, SLIDER_TRACK_HEIGHT)
    trackBg.BackgroundColor3 = Library.Theme.Surface.S5
    trackBg.BorderSizePixel = 0
    trackBg.Parent = trackContainer

    local trackBgCorner = Instance.new("UICorner")
    trackBgCorner.CornerRadius = UDim.new(0, SLIDER_TRACK_HEIGHT / 2)
    trackBgCorner.Parent = trackBg

    local trackFill = Instance.new("Frame")
    trackFill.Name = "TrackFill"
    trackFill.Position = UDim2.new(0, 0, 0, 0)
    trackFill.Size = UDim2.new(0, 0, 1, 0)
    trackFill.BackgroundColor3 = Library.Theme.Status.Accent
    trackFill.BorderSizePixel = 0
    trackFill.Parent = trackBg

    local trackFillCorner = Instance.new("UICorner")
    trackFillCorner.CornerRadius = UDim.new(0, SLIDER_TRACK_HEIGHT / 2)
    trackFillCorner.Parent = trackFill

    local function makeThumb(name)
        local t = Instance.new("Frame")
        t.Name = name
        t.AnchorPoint = Vector2.new(0.5, 0.5)
        t.Position = UDim2.new(0, 0, 0.5, 0)
        t.Size = UDim2.fromOffset(SLIDER_THUMB_SIZE, SLIDER_THUMB_SIZE)
        t.BackgroundColor3 = Library.Theme.Text.Primary
        t.BorderSizePixel = 0
        t.ZIndex = 2
        t.Parent = trackBg
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, SLIDER_THUMB_SIZE / 2)
        c.Parent = t
        local s = Instance.new("UIStroke")
        s.Thickness = 1.5
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Color = Library.Theme.Surface.S5
        s.Transparency = 0.5
        s.Parent = t
        local h = Instance.new("TextButton")
        h.Name = "Hitbox"
        h.AnchorPoint = Vector2.new(0.5, 0.5)
        h.Position = UDim2.fromScale(0.5, 0.5)
        h.Size = UDim2.fromOffset(SLIDER_THUMB_HITBOX_SIZE, SLIDER_THUMB_HITBOX_SIZE)
        h.BackgroundTransparency = 1
        h.BorderSizePixel = 0
        h.ZIndex = t.ZIndex + 1
        h.Text = ""
        h.AutoButtonColor = false
        h.Parent = t
        return t
    end

    local thumbLow = makeThumb("ThumbLow")
    local thumbHigh = makeThumb("ThumbHigh")

    local activeTweens = {}
    local localConnections = {}
    local hovered = false
    local draggingThumb = nil

    local function cancelTweens()
        for index, tween in ipairs(activeTweens) do
            tween:Cancel()
            activeTweens[index] = nil
        end
    end

    local function tweenProperty(instance, duration, properties)
        if duration <= 0 then
            for key, value in pairs(properties) do
                instance[key] = value
            end
            return
        end
        local tween = TweenService:Create(
            instance,
            TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            properties
        )
        table.insert(activeTweens, tween)
        tween:Play()
    end

    local function valueToPercent(v)
        local range = control.Max - control.Min
        return range > 0 and (v - control.Min) / range or 0
    end

    local function applyThumbs(instant)
        local pLow = valueToPercent(control.Value.min)
        local pHigh = valueToPercent(control.Value.max)
        if instant then
            thumbLow.Position = UDim2.new(pLow, 0, 0.5, 0)
            thumbHigh.Position = UDim2.new(pHigh, 0, 0.5, 0)
            trackFill.Position = UDim2.new(pLow, 0, 0, 0)
            trackFill.Size = UDim2.new(pHigh - pLow, 0, 1, 0)
        else
            tweenProperty(thumbLow, SLIDER_ANIMATION_TIME, {Position = UDim2.new(pLow, 0, 0.5, 0)})
            tweenProperty(thumbHigh, SLIDER_ANIMATION_TIME, {Position = UDim2.new(pHigh, 0, 0.5, 0)})
            tweenProperty(trackFill, SLIDER_ANIMATION_TIME, {
                Position = UDim2.new(pLow, 0, 0, 0),
                Size = UDim2.new(pHigh - pLow, 0, 1, 0),
            })
        end
    end

    local function applyVisual(instant)
        cancelTweens()
        local isDisabled = control.Disabled
        local duration = instant and 0 or SLIDER_ANIMATION_TIME
        local hoverTransparency = hovered and 0.82 or 1

        root.Visible = control.Visible
        textLabel.Text = control.Text
        valueLabel.Text = control:_FormatValue()

        tweenProperty(hoverFill, duration, {
            BackgroundTransparency = isDisabled and 1 or hoverTransparency,
        })
        local labelColor = isDisabled and Library.Theme.Text.Secondary
            or (control.Risky and Library.Theme.Status.Error or Library.Theme.Text.Primary)
        tweenProperty(textLabel, duration, {
            TextColor3 = labelColor,
            TextTransparency = isDisabled and 0.45 or 0,
        })
        tweenProperty(valueLabel, duration, {
            TextColor3 = isDisabled and Library.Theme.Text.Tertiary or Library.Theme.Text.Secondary,
            TextTransparency = isDisabled and 0.45 or 0,
        })
        tweenProperty(trackBg, duration, {
            BackgroundColor3 = isDisabled and Library.Theme.Surface.S4 or Library.Theme.Surface.S5,
        })
        tweenProperty(trackFill, duration, {
            BackgroundColor3 = Library.Theme.Status.Accent,
            BackgroundTransparency = isDisabled and 0.5 or 0,
        })
        for _, t in ipairs({thumbLow, thumbHigh}) do
            tweenProperty(t, duration, {
                BackgroundColor3 = isDisabled and Library.Theme.Text.Tertiary or Library.Theme.Text.Primary,
                BackgroundTransparency = isDisabled and 0.3 or 0,
            })
        end
        applyThumbs(instant)
    end

    local function getPercentFromMouse(mouseX)
        local absX = trackBg.AbsolutePosition.X
        local absW = trackBg.AbsoluteSize.X
        if absW <= 0 then return 0 end
        return math.clamp((mouseX - absX) / absW, 0, 1)
    end

    table.insert(localConnections, root.MouseEnter:Connect(function()
        hovered = true
        applyVisual(false)
    end))

    table.insert(localConnections, root.MouseLeave:Connect(function()
        hovered = false
        applyVisual(false)
    end))

    local function startThumbDrag(which, mouseX)
        if control.Disabled then return end
        draggingThumb = which
        local p = getPercentFromMouse(mouseX)
        local raw = control.Min + p * (control.Max - control.Min)
        if which == "low" then
            control:_SetLow(raw)
        else
            control:_SetHigh(raw)
        end
    end

    table.insert(localConnections, trackContainer.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if control.Disabled then return end
        local p = getPercentFromMouse(input.Position.X)
        local pLow = valueToPercent(control.Value.min)
        local pHigh = valueToPercent(control.Value.max)
        local which = math.abs(p - pLow) <= math.abs(p - pHigh) and "low" or "high"
        startThumbDrag(which, input.Position.X)
    end))

    local lowHitbox = thumbLow:FindFirstChild("Hitbox")
    local highHitbox = thumbHigh:FindFirstChild("Hitbox")

    if lowHitbox then
        table.insert(localConnections, lowHitbox.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            startThumbDrag("low", input.Position.X)
        end))
    end

    if highHitbox then
        table.insert(localConnections, highHitbox.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            startThumbDrag("high", input.Position.X)
        end))
    end

    table.insert(localConnections, UserInputService.InputChanged:Connect(function(input)
        if not draggingThumb then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local p = getPercentFromMouse(input.Position.X)
        local raw = control.Min + p * (control.Max - control.Min)
        if draggingThumb == "low" then
            control:_SetLow(raw)
        else
            control:_SetHigh(raw)
        end
    end))

    table.insert(localConnections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if draggingThumb then
                local v = control.Value
                control.Changed:Fire(v)
                SafeCallback(control.Callback, v)
                draggingThumb = nil
            end
        end
    end))

    applyVisual(true)

    return {
        Root = root,
        HandleAction = function(action)
            if action == "ValueChanged" then
                cancelTweens()
                valueLabel.Text = control:_FormatValue()
                applyThumbs(draggingThumb ~= nil)
            elseif action == "VisualStateChanged" then
                applyVisual(false)
            end
        end,
        Cleanup = function()
            cancelTweens()
            for _, connection in ipairs(localConnections) do
                if connection.Connected then
                    connection:Disconnect()
                end
            end
        end,
    }
end)

Library:RegisterControlRenderer("Input", function(control)
    local root = Instance.new("Frame")
    root.Name = "Input"
    root.Size = UDim2.new(1, 0, 0, INPUT_ROW_HEIGHT)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.Size = UDim2.new(INPUT_LABEL_WIDTH_SCALE, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.BorderSizePixel = 0
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.Parent = root

    local inputContainer = Instance.new("Frame")
    inputContainer.Name = "InputContainer"
    inputContainer.AnchorPoint = Vector2.new(1, 0.5)
    inputContainer.Position = UDim2.new(1, 0, 0.5, 0)
    inputContainer.Size = UDim2.new(1 - INPUT_LABEL_WIDTH_SCALE, -INPUT_LABEL_GAP, 1, -2)
    inputContainer.BackgroundColor3 = Library.Theme.Surface.S3
    inputContainer.BorderSizePixel = 0
    inputContainer.ClipsDescendants = true
    inputContainer.Parent = root

    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, INPUT_CORNER_RADIUS)
    containerCorner.Parent = inputContainer

    local containerStroke = Instance.new("UIStroke")
    containerStroke.Thickness = 1
    containerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    containerStroke.Color = Library.Theme.Surface.S5
    containerStroke.Transparency = 0.5
    containerStroke.Parent = inputContainer

    local innerRow = Instance.new("Frame")
    innerRow.Name = "InnerRow"
    innerRow.Size = UDim2.fromScale(1, 1)
    innerRow.BackgroundTransparency = 1
    innerRow.BorderSizePixel = 0
    innerRow.Parent = inputContainer

    local innerLayout = Instance.new("UIListLayout")
    innerLayout.FillDirection = Enum.FillDirection.Horizontal
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    innerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    innerLayout.Padding = UDim.new(0, 0)
    innerLayout.Parent = innerRow

    local prefixLabel
    if control.Prefix then
        prefixLabel = Instance.new("TextLabel")
        prefixLabel.Name = "Prefix"
        prefixLabel.AutomaticSize = Enum.AutomaticSize.X
        prefixLabel.Size = UDim2.new(0, 0, 1, 0)
        prefixLabel.BackgroundTransparency = 1
        prefixLabel.BorderSizePixel = 0
        prefixLabel.Text = control.Prefix
        prefixLabel.TextXAlignment = Enum.TextXAlignment.Left
        prefixLabel.TextYAlignment = Enum.TextYAlignment.Center
        prefixLabel.TextSize = 11
        prefixLabel.Font = Enum.Font.Gotham
        prefixLabel.TextColor3 = Library.Theme.Text.Tertiary
        prefixLabel.LayoutOrder = 1

        local prefixPad = Instance.new("UIPadding")
        prefixPad.PaddingLeft = UDim.new(0, 6)
        prefixPad.Parent = prefixLabel

        prefixLabel.Parent = innerRow
    end

    local inputBox = Instance.new("TextBox")
    inputBox.Name = "TextBox"
    inputBox.Size = UDim2.new(0, 9999, 1, 0)
    inputBox.BackgroundTransparency = 1
    inputBox.BorderSizePixel = 0
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.TextYAlignment = Enum.TextYAlignment.Center
    inputBox.TextSize = 11
    inputBox.Font = Enum.Font.Gotham
    inputBox.ClearTextOnFocus = control.ClearTextOnFocus
    inputBox.Text = control.Password and string.rep("•", #control.Value) or control.Value
    inputBox.PlaceholderText = control.Placeholder
    inputBox.LayoutOrder = 2
    inputBox.Parent = innerRow

    if not control.Prefix then
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 6)
        pad.Parent = inputBox
    end

    local passwordBuffer = control.Password and control.Value or nil
    local activeTweens = {}
    local localConnections = {}
    local focused = false

    local function cancelTweens()
        for index, tween in ipairs(activeTweens) do
            tween:Cancel()
            activeTweens[index] = nil
        end
    end

    local function tweenProperty(instance, duration, properties)
        if duration <= 0 then
            for key, value in pairs(properties) do
                instance[key] = value
            end
            return
        end
        local tween = TweenService:Create(
            instance,
            TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            properties
        )
        table.insert(activeTweens, tween)
        tween:Play()
    end

    local function applyVisual(instant)
        cancelTweens()
        local isDisabled = control.Disabled
        local isRisky = control.Risky
        local duration = instant and 0 or INPUT_ANIMATION_TIME

        root.Visible = control.Visible
        textLabel.Text = control.Text

        local labelColor = isDisabled and Library.Theme.Text.Secondary
            or (isRisky and Library.Theme.Status.Error or Library.Theme.Text.Primary)
        tweenProperty(textLabel, duration, {
            TextColor3 = labelColor,
            TextTransparency = isDisabled and 0.45 or 0,
        })

        local strokeColor = isRisky and Library.Theme.Status.Error or Library.Theme.Surface.S5
        local strokeT = focused and 0 or 0.5
        tweenProperty(containerStroke, duration, {
            Color = strokeColor,
            Transparency = isDisabled and 0.7 or strokeT,
        })

        tweenProperty(inputContainer, duration, {
            BackgroundColor3 = isDisabled and Library.Theme.Surface.S2 or Library.Theme.Surface.S3,
        })

        tweenProperty(inputBox, duration, {
            TextColor3 = isRisky and Library.Theme.Status.Error or Library.Theme.Text.Primary,
            TextTransparency = isDisabled and 0.5 or 0,
        })

        if prefixLabel then
            tweenProperty(prefixLabel, duration, {
                TextTransparency = isDisabled and 0.6 or 0,
            })
        end

        inputBox.TextEditable = not isDisabled
    end

    local function commitValue(text)
        local sanitized = control:_Sanitize(text)
        if control.Password then
            control:SetValue(sanitized)
            inputBox.Text = string.rep("•", #sanitized)
            passwordBuffer = sanitized
        else
            control:SetValue(sanitized)
            inputBox.Text = sanitized
        end
    end

    table.insert(localConnections, inputBox.Focused:Connect(function()
        if control.Disabled then
            inputBox:ReleaseFocus()
            return
        end
        focused = true
        if control.ClearTextOnFocus then
            if control.Password then
                passwordBuffer = ""
            end
            inputBox.Text = ""
        end
        applyVisual(false)
    end))

    table.insert(localConnections, inputBox.FocusLost:Connect(function(enterPressed)
        focused = false
        applyVisual(false)
        if not control.Finished or enterPressed then
            commitValue(control.Password and (passwordBuffer or "") or inputBox.Text)
        else
            if control.Password then
                inputBox.Text = string.rep("•", #(passwordBuffer or ""))
            else
                inputBox.Text = control.Value
            end
        end
    end))

    if control.Password then
        table.insert(localConnections, inputBox:GetPropertyChangedSignal("Text"):Connect(function()
            local newText = inputBox.Text
            local oldLen = #(passwordBuffer or "")
            local newLen = #newText
            if newLen > oldLen then
                local added = string.sub(newText, oldLen + 1)
                local filtered = control.Numeric and control:_FilterNumeric(added) or added
                passwordBuffer = (passwordBuffer or "") .. filtered
                if control.MaxLength and #passwordBuffer > control.MaxLength then
                    passwordBuffer = string.sub(passwordBuffer, 1, control.MaxLength)
                end
            elseif newLen < oldLen then
                passwordBuffer = string.sub(passwordBuffer or "", 1, newLen)
            end
            if focused then
                local masked = string.rep("•", #(passwordBuffer or ""))
                if inputBox.Text ~= masked then
                    inputBox.Text = masked
                end
            end
        end))
    end

    applyVisual(true)

    return {
        Root = root,
        HandleAction = function(action)
            if action == "ValueChanged" then
                if not focused then
                    if control.Password then
                        inputBox.Text = string.rep("•", #control.Value)
                        passwordBuffer = control.Value
                    else
                        inputBox.Text = control.Value
                    end
                end
            elseif action == "VisualStateChanged" then
                applyVisual(false)
            end
        end,
        Cleanup = function()
            cancelTweens()
            for _, connection in ipairs(localConnections) do
                if connection.Connected then
                    connection:Disconnect()
                end
            end
        end,
    }
end)

function RendererHelpers.FindAncestorGroupBox(component)
    local parent = component and component.Parent
    while parent do
        if parent.Kind == "GroupBox" then
            return parent
        end
        parent = parent.Parent
    end
    return nil
end

Library:RegisterControlRenderer("KeyPicker", function(control)
    local isAttached = control.Parent and control.Parent.Kind ~= "GroupBox"
    local buttonHeight = isAttached and KEYPICKER_ATTACHED_HEIGHT or KEYPICKER_BUTTON_HEIGHT

    local root = Instance.new("Frame")
    root.Name = "KeyPicker"
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0

    local textLabel
    local modeButton
    local rail
    local localConnections = {}
    local activeTweens = {}

    local keyButton = Instance.new("TextButton")
    keyButton.Name = "KeyButton"
    keyButton.AutoButtonColor = false
    keyButton.TextSize = 11
    keyButton.Font = Enum.Font.GothamMedium
    keyButton.TextXAlignment = Enum.TextXAlignment.Center
    keyButton.TextYAlignment = Enum.TextYAlignment.Center
    keyButton.BackgroundColor3 = Library.Theme.Surface.S3
    keyButton.BorderSizePixel = 0

    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, KEYPICKER_CORNER_RADIUS)
    keyCorner.Parent = keyButton

    local keyStroke = Instance.new("UIStroke")
    keyStroke.Thickness = 1
    keyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    keyStroke.Parent = keyButton

    local function cancelTweens()
        for index, tween in ipairs(activeTweens) do
            tween:Cancel()
            activeTweens[index] = nil
        end
    end

    local function tweenProperty(instance, duration, properties)
        if duration <= 0 then
            for key, value in pairs(properties) do
                instance[key] = value
            end
            return
        end

        local tween = TweenService:Create(
            instance,
            TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            properties
        )
        table.insert(activeTweens, tween)
        tween:Play()
    end

    local function updateKeyButtonWidth()
        local width = math.max(KEYPICKER_BUTTON_MIN_WIDTH, keyButton.TextBounds.X + 14)
        keyButton.Size = UDim2.fromOffset(width, buttonHeight)
        if isAttached then
            root.Size = UDim2.fromOffset(width, buttonHeight)
        end
    end

    if isAttached then
        root.Size = UDim2.fromOffset(KEYPICKER_BUTTON_MIN_WIDTH, buttonHeight)
        keyButton.Parent = root
    else
        root.Size = UDim2.new(1, 0, 0, KEYPICKER_ROW_HEIGHT)

        textLabel = Instance.new("TextLabel")
        textLabel.Name = "Text"
        textLabel.BackgroundTransparency = 1
        textLabel.BorderSizePixel = 0
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Center
        textLabel.TextSize = 12
        textLabel.Font = Enum.Font.GothamMedium
        textLabel.Parent = root

        rail = Instance.new("Frame")
        rail.Name = "RightRail"
        rail.AnchorPoint = Vector2.new(1, 0.5)
        rail.Position = UDim2.new(1, 0, 0.5, 0)
        rail.AutomaticSize = Enum.AutomaticSize.X
        rail.Size = UDim2.new(0, 0, 0, KEYPICKER_ROW_HEIGHT)
        rail.BackgroundTransparency = 1
        rail.BorderSizePixel = 0
        rail.Parent = root

        local railLayout = Instance.new("UIListLayout")
        railLayout.FillDirection = Enum.FillDirection.Horizontal
        railLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        railLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        railLayout.SortOrder = Enum.SortOrder.LayoutOrder
        railLayout.Padding = UDim.new(0, CONTROL_ADDON_GAP)
        railLayout.Parent = rail

        modeButton = Instance.new("TextButton")
        modeButton.Name = "ModeButton"
        modeButton.AutoButtonColor = false
        modeButton.Size = UDim2.fromOffset(KEYPICKER_MODE_WIDTH, buttonHeight)
        modeButton.BackgroundColor3 = Library.Theme.Surface.S2
        modeButton.BorderSizePixel = 0
        modeButton.TextSize = 10
        modeButton.Font = Enum.Font.Gotham
        modeButton.LayoutOrder = 1
        modeButton.Parent = rail

        local modeCorner = Instance.new("UICorner")
        modeCorner.CornerRadius = UDim.new(0, KEYPICKER_CORNER_RADIUS)
        modeCorner.Parent = modeButton

        local modeStroke = Instance.new("UIStroke")
        modeStroke.Name = "Stroke"
        modeStroke.Thickness = 1
        modeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        modeStroke.Parent = modeButton

        keyButton.LayoutOrder = 2
        keyButton.Parent = rail

        local function updateStandaloneLayout()
            textLabel.Size = UDim2.new(1, -(rail.AbsoluteSize.X + 8), 1, 0)
        end

        table.insert(localConnections, rail:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateStandaloneLayout))
        table.insert(localConnections, keyButton:GetPropertyChangedSignal("TextBounds"):Connect(updateStandaloneLayout))
        updateStandaloneLayout()
    end

    local function applyVisual(instant)
        cancelTweens()

        local isDisabled = control.Disabled
        local isListening = control._listening
        local isActive = control:GetState()
        local duration = instant and 0 or KEYPICKER_ANIMATION_TIME
        local keyDisplay = isListening and "..." or control:GetDisplayValue()

        root.Visible = control.Visible
        keyButton.Text = keyDisplay
        updateKeyButtonWidth()

        if textLabel then
            textLabel.Text = control.Text
            tweenProperty(textLabel, duration, {
                TextColor3 = isDisabled and Library.Theme.Text.Secondary or Library.Theme.Text.Primary,
                TextTransparency = isDisabled and 0.45 or 0,
            })
        end

        local activeColor = isListening and Library.Theme.Status.Info or (isActive and Library.Theme.Status.Accent or Library.Theme.Surface.S3)
        local strokeColor = isListening and Library.Theme.Status.Info or (isActive and Library.Theme.Status.Accent or Library.Theme.Surface.S5)
        tweenProperty(keyButton, duration, {
            BackgroundColor3 = isDisabled and Library.Theme.Surface.S2 or activeColor,
            BackgroundTransparency = isDisabled and 0.3 or 0,
            TextColor3 = isDisabled and Library.Theme.Text.Secondary or Library.Theme.Text.Primary,
            TextTransparency = isDisabled and 0.45 or 0,
        })
        tweenProperty(keyStroke, duration, {
            Color = strokeColor,
            Transparency = isDisabled and 0.7 or 0.45,
        })

        if modeButton then
            modeButton.Text = control.Mode
            local modeStroke = modeButton:FindFirstChild("Stroke")
            tweenProperty(modeButton, duration, {
                BackgroundColor3 = isDisabled and Library.Theme.Surface.S1 or Library.Theme.Surface.S2,
                BackgroundTransparency = isDisabled and 0.3 or 0,
                TextColor3 = isDisabled and Library.Theme.Text.Tertiary or Library.Theme.Text.Secondary,
                TextTransparency = isDisabled and 0.45 or 0,
            })
            if modeStroke then
                tweenProperty(modeStroke, duration, {
                    Color = Library.Theme.Surface.S5,
                    Transparency = isDisabled and 0.7 or 0.5,
                })
            end
            modeButton.Active = not isDisabled and not control.SyncToggleState
        end

        keyButton.Active = not isDisabled
    end

    table.insert(localConnections, keyButton:GetPropertyChangedSignal("TextBounds"):Connect(updateKeyButtonWidth))
    table.insert(localConnections, keyButton.MouseButton1Click:Connect(function()
        if control.Disabled then
            return
        end

        if control._listening then
            control:EndListening()
        else
            control:BeginListening()
        end
    end))
    table.insert(localConnections, keyButton.MouseButton2Click:Connect(function()
        if control.Disabled then
            return
        end
        control:CycleMode()
    end))

    if modeButton then
        table.insert(localConnections, modeButton.MouseButton1Click:Connect(function()
            if control.Disabled then
                return
            end
            control:CycleMode()
        end))
    end

    local ancestorGroupBox = RendererHelpers.FindAncestorGroupBox(control)
    if ancestorGroupBox then
        table.insert(localConnections, ancestorGroupBox.RenderHook:Connect(function(action)
            if action == "CollapsedChanged" and control._listening then
                control:EndListening()
            elseif action == "Destroy" then
                control:EndListening()
            end
        end))
    end

    applyVisual(true)

    return {
        Root = root,
        HandleAction = function(action)
            if action == "VisualStateChanged" or action == "ListeningChanged" or action == "StateChanged" then
                applyVisual(false)
            end
        end,
        Cleanup = function()
            cancelTweens()
            for _, connection in ipairs(localConnections) do
                if connection.Connected then
                    connection:Disconnect()
                end
            end
        end,
    }
end)

Library:RegisterControlRenderer("ColorPicker", function(control)
    local isAttached = control.Parent and control.Parent.Kind ~= "GroupBox"

    -- Row root
    local root = Instance.new("Frame")
    root.Name = "ColorPicker"
    root.Size = isAttached
        and UDim2.fromOffset(COLORPICKER_ATTACHED_WIDTH, COLORPICKER_ATTACHED_HEIGHT)
        or UDim2.new(1, 0, 0, COLORPICKER_ROW_HEIGHT)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0

    local textLabel
    if not isAttached then
        textLabel = Instance.new("TextLabel")
        textLabel.Name = "Text"
        textLabel.Size = UDim2.new(1 - COLORPICKER_DISPLAY_WIDTH_SCALE, -DROPDOWN_LABEL_GAP, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.BorderSizePixel = 0
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Center
        textLabel.TextSize = 12
        textLabel.Font = Enum.Font.GothamMedium
        textLabel.TextTruncate = Enum.TextTruncate.AtEnd
        textLabel.Parent = root
    end

    -- Swatch pill (right side, same style as button/input)
    local swatch = Instance.new("TextButton")
    swatch.Name = "Swatch"
    swatch.AnchorPoint = isAttached and Vector2.new(0, 0.5) or Vector2.new(1, 0.5)
    swatch.Position = isAttached and UDim2.new(0, 0, 0.5, 0) or UDim2.new(1, 0, 0.5, 0)
    swatch.Size = isAttached
        and UDim2.new(1, 0, 1, 0)
        or UDim2.new(COLORPICKER_DISPLAY_WIDTH_SCALE, -DROPDOWN_LABEL_GAP, 1, -2)
    swatch.BackgroundColor3 = control.Value
    swatch.BorderSizePixel = 0
    swatch.AutoButtonColor = false
    swatch.Text = ""
    swatch.Parent = root

    local swatchCorner = Instance.new("UICorner")
    swatchCorner.CornerRadius = UDim.new(0, DROPDOWN_CORNER_RADIUS)
    swatchCorner.Parent = swatch

    local swatchStroke = Instance.new("UIStroke")
    swatchStroke.Thickness = 1
    swatchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    swatchStroke.Color = Library.Theme.Surface.S5
    swatchStroke.Transparency = 0.5
    swatchStroke.Parent = swatch

    -- Hex label inside swatch
    local hexLabel = Instance.new("TextLabel")
    hexLabel.Name = "Hex"
    hexLabel.Size = UDim2.fromScale(1, 1)
    hexLabel.BackgroundTransparency = 1
    hexLabel.BorderSizePixel = 0
    hexLabel.TextXAlignment = Enum.TextXAlignment.Center
    hexLabel.TextYAlignment = Enum.TextYAlignment.Center
    hexLabel.TextSize = 10
    hexLabel.Font = Enum.Font.GothamMedium
    hexLabel.ZIndex = 2
    hexLabel.Visible = not isAttached
    hexLabel.Parent = swatch

    -- ── Popup ────────────────────────────────────────────────
    local hasAlpha = control.AllowTransparency
    local popupW = COLORPICKER_POPUP_PADDING * 2
        + COLORPICKER_SV_SIZE
        + COLORPICKER_HUE_GAP
        + COLORPICKER_HUE_WIDTH
        + (hasAlpha and (COLORPICKER_HUE_GAP + COLORPICKER_HUE_WIDTH) or 0)
    local popupH = COLORPICKER_POPUP_PADDING * 2
        + COLORPICKER_SV_SIZE
        + COLORPICKER_HUE_GAP
        + COLORPICKER_HEX_HEIGHT

    local popup = Instance.new("Frame")
    popup.Name = "ColorPickerPopup"
    popup.Size = UDim2.fromOffset(popupW, popupH)
    popup.BackgroundColor3 = Library.Theme.Surface.S1
    popup.BorderSizePixel = 0
    popup.ZIndex = 20
    popup.Visible = false
    popup.Active = true
    popup.Parent = ScreenGui

    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0, GROUPBOX_CORNER_RADIUS)
    popupCorner.Parent = popup

    local popupStroke = Instance.new("UIStroke")
    popupStroke.Thickness = 1
    popupStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    popupStroke.Color = Library.Theme.Surface.S4
    popupStroke.Transparency = 0
    popupStroke.Parent = popup

    local pad = COLORPICKER_POPUP_PADDING

    -- SV square
    local svFrame = Instance.new("TextButton")
    svFrame.Name = "SVMap"
    svFrame.Position = UDim2.fromOffset(pad, pad)
    svFrame.Size = UDim2.fromOffset(COLORPICKER_SV_SIZE, COLORPICKER_SV_SIZE)
    svFrame.BackgroundColor3 = Color3.fromHSV(control._hue, 1, 1)
    svFrame.BorderSizePixel = 0
    svFrame.AutoButtonColor = false
    svFrame.Text = ""
    svFrame.ZIndex = 21
    svFrame.Parent = popup

    local svCorner = Instance.new("UICorner")
    svCorner.CornerRadius = UDim.new(0, 4)
    svCorner.Parent = svFrame

    -- White gradient overlay (sat: left=white → right=transparent)
    local svWhite = Instance.new("Frame")
    svWhite.Size = UDim2.fromScale(1, 1)
    svWhite.BackgroundColor3 = Color3.new(1, 1, 1)
    svWhite.BorderSizePixel = 0
    svWhite.ZIndex = 22
    svWhite.Parent = svFrame
    local svWhiteCorner = Instance.new("UICorner")
    svWhiteCorner.CornerRadius = UDim.new(0, 4)
    svWhiteCorner.Parent = svWhite
    local svWhiteGrad = Instance.new("UIGradient")
    svWhiteGrad.Rotation = 0
    svWhiteGrad.Transparency = NumberSequence.new(0, 1)
    svWhiteGrad.Parent = svWhite

    -- Black gradient overlay (val: top=transparent → bottom=black)
    local svBlack = Instance.new("Frame")
    svBlack.Size = UDim2.fromScale(1, 1)
    svBlack.BackgroundColor3 = Color3.new(0, 0, 0)
    svBlack.BorderSizePixel = 0
    svBlack.ZIndex = 23
    svBlack.Parent = svFrame
    local svBlackCorner = Instance.new("UICorner")
    svBlackCorner.CornerRadius = UDim.new(0, 4)
    svBlackCorner.Parent = svBlack
    local svBlackGrad = Instance.new("UIGradient")
    svBlackGrad.Rotation = 90
    svBlackGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })
    svBlackGrad.Parent = svBlack

    -- SV cursor
    local svCursor = Instance.new("Frame")
    svCursor.Name = "SVCursor"
    svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    svCursor.Position = UDim2.fromScale(control._sat, 1 - control._val)
    svCursor.Size = UDim2.fromOffset(COLORPICKER_CURSOR_SIZE, COLORPICKER_CURSOR_SIZE)
    svCursor.BackgroundColor3 = Color3.new(1, 1, 1)
    svCursor.BorderSizePixel = 0
    svCursor.ZIndex = 25
    svCursor.Parent = svFrame
    local svCursorCorner = Instance.new("UICorner")
    svCursorCorner.CornerRadius = UDim.new(1, 0)
    svCursorCorner.Parent = svCursor
    local svCursorStroke = Instance.new("UIStroke")
    svCursorStroke.Thickness = 1.5
    svCursorStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    svCursorStroke.Color = Color3.new(0, 0, 0)
    svCursorStroke.Transparency = 0.3
    svCursorStroke.Parent = svCursor

    -- Hue bar
    local hueBarX = pad + COLORPICKER_SV_SIZE + COLORPICKER_HUE_GAP
    local hueBar = Instance.new("TextButton")
    hueBar.Name = "HueBar"
    hueBar.Position = UDim2.fromOffset(hueBarX, pad)
    hueBar.Size = UDim2.fromOffset(COLORPICKER_HUE_WIDTH, COLORPICKER_SV_SIZE)
    hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
    hueBar.BorderSizePixel = 0
    hueBar.AutoButtonColor = false
    hueBar.Text = ""
    hueBar.ZIndex = 21
    hueBar.Parent = popup

    local hueBarCorner = Instance.new("UICorner")
    hueBarCorner.CornerRadius = UDim.new(0, 4)
    hueBarCorner.Parent = hueBar

    local hueSeqPoints = {}
    for i = 0, 6 do
        table.insert(hueSeqPoints, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
    end
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Rotation = 90
    hueGradient.Color = ColorSequence.new(hueSeqPoints)
    hueGradient.Parent = hueBar

    local hueCursor = Instance.new("Frame")
    hueCursor.Name = "HueCursor"
    hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    hueCursor.Position = UDim2.fromScale(0.5, control._hue)
    hueCursor.Size = UDim2.new(1, 4, 0, 2)
    hueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
    hueCursor.BorderSizePixel = 0
    hueCursor.ZIndex = 22
    hueCursor.Parent = hueBar
    local hueCursorStroke = Instance.new("UIStroke")
    hueCursorStroke.Thickness = 1
    hueCursorStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    hueCursorStroke.Color = Color3.new(0, 0, 0)
    hueCursorStroke.Transparency = 0.4
    hueCursorStroke.Parent = hueCursor

    -- Alpha bar (optional)
    local alphaBar, alphaCursor, alphaColor
    if hasAlpha then
        local alphaBarX = hueBarX + COLORPICKER_HUE_WIDTH + COLORPICKER_HUE_GAP
        alphaBar = Instance.new("TextButton")
        alphaBar.Name = "AlphaBar"
        alphaBar.Position = UDim2.fromOffset(alphaBarX, pad)
        alphaBar.Size = UDim2.fromOffset(COLORPICKER_HUE_WIDTH, COLORPICKER_SV_SIZE)
        alphaBar.BackgroundColor3 = Color3.new(1, 1, 1)
        alphaBar.BorderSizePixel = 0
        alphaBar.AutoButtonColor = false
        alphaBar.Text = ""
        alphaBar.ZIndex = 21
        alphaBar.Parent = popup

        local alphaBarCorner = Instance.new("UICorner")
        alphaBarCorner.CornerRadius = UDim.new(0, 4)
        alphaBarCorner.Parent = alphaBar

        -- Checker background to show transparency
        local alphaChecker = Instance.new("Frame")
        alphaChecker.Size = UDim2.fromScale(1, 1)
        alphaChecker.BackgroundColor3 = Library.Theme.Surface.S3
        alphaChecker.BorderSizePixel = 0
        alphaChecker.ZIndex = 21
        alphaChecker.Parent = alphaBar
        local alphaCheckerCorner = Instance.new("UICorner")
        alphaCheckerCorner.CornerRadius = UDim.new(0, 4)
        alphaCheckerCorner.Parent = alphaChecker

        -- Color overlay fading from color to transparent
        alphaColor = Instance.new("Frame")
        alphaColor.Name = "AlphaColor"
        alphaColor.Size = UDim2.fromScale(1, 1)
        alphaColor.BackgroundColor3 = control.Value
        alphaColor.BorderSizePixel = 0
        alphaColor.ZIndex = 22
        alphaColor.Parent = alphaBar
        local alphaColorCorner = Instance.new("UICorner")
        alphaColorCorner.CornerRadius = UDim.new(0, 4)
        alphaColorCorner.Parent = alphaColor
        local alphaColorGrad = Instance.new("UIGradient")
        alphaColorGrad.Rotation = 90
        alphaColorGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        alphaColorGrad.Parent = alphaColor

        alphaCursor = Instance.new("Frame")
        alphaCursor.Name = "AlphaCursor"
        alphaCursor.AnchorPoint = Vector2.new(0.5, 0.5)
        alphaCursor.Position = UDim2.fromScale(0.5, control.Transparency)
        alphaCursor.Size = UDim2.new(1, 4, 0, 2)
        alphaCursor.BackgroundColor3 = Color3.new(1, 1, 1)
        alphaCursor.BorderSizePixel = 0
        alphaCursor.ZIndex = 23
        alphaCursor.Parent = alphaBar
        local alphaCursorStroke = Instance.new("UIStroke")
        alphaCursorStroke.Thickness = 1
        alphaCursorStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        alphaCursorStroke.Color = Color3.new(0, 0, 0)
        alphaCursorStroke.Transparency = 0.4
        alphaCursorStroke.Parent = alphaCursor
    end

    -- Hex input
    local hexY = pad + COLORPICKER_SV_SIZE + COLORPICKER_HUE_GAP
    local hexContainer = Instance.new("Frame")
    hexContainer.Name = "HexContainer"
    hexContainer.Position = UDim2.fromOffset(pad, hexY)
    hexContainer.Size = UDim2.new(1, -pad * 2, 0, COLORPICKER_HEX_HEIGHT)
    hexContainer.BackgroundColor3 = Library.Theme.Surface.S3
    hexContainer.BorderSizePixel = 0
    hexContainer.ZIndex = 21
    hexContainer.Parent = popup

    local hexContainerCorner = Instance.new("UICorner")
    hexContainerCorner.CornerRadius = UDim.new(0, INPUT_CORNER_RADIUS)
    hexContainerCorner.Parent = hexContainer

    local hexContainerStroke = Instance.new("UIStroke")
    hexContainerStroke.Thickness = 1
    hexContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    hexContainerStroke.Color = Library.Theme.Surface.S5
    hexContainerStroke.Transparency = 0.5
    hexContainerStroke.Parent = hexContainer

    local hexBox = Instance.new("TextBox")
    hexBox.Name = "HexBox"
    hexBox.Size = UDim2.fromScale(1, 1)
    hexBox.BackgroundTransparency = 1
    hexBox.BorderSizePixel = 0
    hexBox.TextXAlignment = Enum.TextXAlignment.Center
    hexBox.TextYAlignment = Enum.TextYAlignment.Center
    hexBox.TextSize = 11
    hexBox.Font = Enum.Font.GothamMedium
    hexBox.TextColor3 = Library.Theme.Text.Primary
    hexBox.PlaceholderText = "#FFFFFF"
    hexBox.ClearTextOnFocus = false
    hexBox.ZIndex = 22
    hexBox.Parent = hexContainer

    -- ── State ────────────────────────────────────────────────
    local opened = false
    local draggingSV = false
    local draggingHue = false
    local draggingAlpha = false
    local localConnections = {}
    local activeTweens = {}

    local function cancelTweens()
        for i, t in ipairs(activeTweens) do t:Cancel(); activeTweens[i] = nil end
    end

    local function tweenProp(inst, dur, props)
        if dur <= 0 then
            for k, v in pairs(props) do inst[k] = v end
            return
        end
        local t = TweenService:Create(inst, TweenInfo.new(dur, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
        table.insert(activeTweens, t)
        t:Play()
    end

    -- ── Helpers ──────────────────────────────────────────────
    local function clampPercent(v) return math.clamp(v, 0, 1) end

    local function srgbChannelToLinear(channel)
        if channel <= 0.04045 then
            return channel / 12.92
        end
        return ((channel + 0.055) / 1.055) ^ 2.4
    end

    local function getRelativeLuminance(color)
        local r = srgbChannelToLinear(color.R)
        local g = srgbChannelToLinear(color.G)
        local b = srgbChannelToLinear(color.B)
        return (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
    end

    local function getSwatchTextColor(bg)
        local bgLuminance = getRelativeLuminance(bg)
        local blackContrast = (bgLuminance + 0.05) / 0.05
        local whiteContrast = 1.05 / (bgLuminance + 0.05)
        local gray = blackContrast >= whiteContrast and 0 or 1
        return Color3.new(gray, gray, gray)
    end

    local function updateSwatchDisplay()
        local c = control.Value
        swatch.BackgroundColor3 = c
        if not isAttached then
            hexLabel.Text = "#" .. c:ToHex():upper()
            hexLabel.TextColor3 = getSwatchTextColor(c)
        end
        hexBox.Text = "#" .. c:ToHex():upper()
        if alphaColor then
            alphaColor.BackgroundColor3 = c
        end
    end

    local function updateSVDisplay(instant)
        local h, s, v = control._hue, control._sat, control._val
        svFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        local targetPos = UDim2.fromScale(s, 1 - v)
        if instant then
            svCursor.Position = targetPos
        else
            tweenProp(svCursor, COLORPICKER_ANIMATION_TIME, {Position = targetPos})
        end
        local hTargetPos = UDim2.fromScale(0.5, h)
        if instant then
            hueCursor.Position = hTargetPos
        else
            tweenProp(hueCursor, COLORPICKER_ANIMATION_TIME, {Position = hTargetPos})
        end
        if alphaCursor then
            local aTargetPos = UDim2.fromScale(0.5, control.Transparency)
            if instant then
                alphaCursor.Position = aTargetPos
            else
                tweenProp(alphaCursor, COLORPICKER_ANIMATION_TIME, {Position = aTargetPos})
            end
        end
        updateSwatchDisplay()
    end

    local function repositionPopup()
        local screenOrigin = ScreenGui.AbsolutePosition
        local absPos = swatch.AbsolutePosition - screenOrigin
        local absSize = swatch.AbsoluteSize
        local screenSize = ScreenGui.AbsoluteSize
        local pw = popup.AbsoluteSize.X > 0 and popup.AbsoluteSize.X or popupW
        local ph = popup.AbsoluteSize.Y > 0 and popup.AbsoluteSize.Y or popupH

        local x = absPos.X + absSize.X + COLORPICKER_POPUP_GAP
        local y = absPos.Y

        if x + pw > screenSize.X - COLORPICKER_POPUP_EDGE_PADDING then
            x = absPos.X - pw - COLORPICKER_POPUP_GAP
        end
        if y + ph > screenSize.Y - COLORPICKER_POPUP_EDGE_PADDING then
            y = screenSize.Y - COLORPICKER_POPUP_EDGE_PADDING - ph
        end
        x = math.max(COLORPICKER_POPUP_EDGE_PADDING, x)
        y = math.max(COLORPICKER_POPUP_EDGE_PADDING, y)

        popup.Position = UDim2.fromOffset(x, y)
    end

    local closePopup
    local function openPopup()
        if control.Disabled then return end
        RendererHelpers.ClaimActiveDropdown(closePopup)
        repositionPopup()
        popup.Visible = true
        opened = true
    end

    closePopup = function()
        RendererHelpers.ReleaseActiveDropdown(closePopup)
        popup.Visible = false
        opened = false
        draggingSV = false
        draggingHue = false
        draggingAlpha = false
    end

    -- ── Drag handlers ─────────────────────────────────────────
    local function applySVDrag(mouseX, mouseY)
        local absX = svFrame.AbsolutePosition.X
        local absY = svFrame.AbsolutePosition.Y
        local absW = svFrame.AbsoluteSize.X
        local absH = svFrame.AbsoluteSize.Y
        if absW <= 0 or absH <= 0 then return end
        control._sat = clampPercent((mouseX - absX) / absW)
        control._val = clampPercent(1 - (mouseY - absY) / absH)
        control.Value = Color3.fromHSV(control._hue, control._sat, control._val)
        control.Changed:Fire(control.Value)
        SafeCallback(control.Callback, control.Value)
        control.RenderHook:Fire("ValueChanged")
        updateSVDisplay(true)
    end

    local function applyHueDrag(mouseY)
        local absY = hueBar.AbsolutePosition.Y
        local absH = hueBar.AbsoluteSize.Y
        if absH <= 0 then return end
        control._hue = clampPercent((mouseY - absY) / absH)
        control.Value = Color3.fromHSV(control._hue, control._sat, control._val)
        control.Changed:Fire(control.Value)
        SafeCallback(control.Callback, control.Value)
        control.RenderHook:Fire("ValueChanged")
        updateSVDisplay(true)
    end

    local function applyAlphaDrag(mouseY)
        if not alphaBar then return end
        local absY = alphaBar.AbsolutePosition.Y
        local absH = alphaBar.AbsoluteSize.Y
        if absH <= 0 then return end
        control:SetTransparency(clampPercent((mouseY - absY) / absH))
        if alphaCursor then
            alphaCursor.Position = UDim2.fromScale(0.5, control.Transparency)
        end
    end

    -- ── Connections ───────────────────────────────────────────
    table.insert(localConnections, swatch.MouseButton1Click:Connect(function()
        if opened then
            closePopup()
        else
            openPopup()
        end
    end))

    table.insert(localConnections, swatch:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        if opened then repositionPopup() end
    end))

    local ancestorGroupBox = RendererHelpers.FindAncestorGroupBox(control)
    if ancestorGroupBox then
        table.insert(localConnections, ancestorGroupBox.RenderHook:Connect(function(action)
            if action == "CollapsedChanged" or action == "Destroy" then
                closePopup()
            end
        end))
    end

    table.insert(localConnections, svFrame.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        draggingSV = true
        applySVDrag(input.Position.X, input.Position.Y)
    end))

    table.insert(localConnections, hueBar.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        draggingHue = true
        applyHueDrag(input.Position.Y)
    end))

    if alphaBar then
        table.insert(localConnections, alphaBar.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            draggingAlpha = true
            applyAlphaDrag(input.Position.Y)
        end))
    end

    table.insert(localConnections, UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if draggingSV then applySVDrag(input.Position.X, input.Position.Y)
        elseif draggingHue then applyHueDrag(input.Position.Y)
        elseif draggingAlpha then applyAlphaDrag(input.Position.Y)
        end
    end))

    table.insert(localConnections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSV = false
            draggingHue = false
            draggingAlpha = false
        end
    end))

    -- Close when clicking outside popup
    table.insert(localConnections, UserInputService.InputBegan:Connect(function(input, processed)
        if not opened then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if processed then return end
        local mp = input.Position
        local pa = popup.AbsolutePosition
        local ps = popup.AbsoluteSize
        if mp.X < pa.X or mp.X > pa.X + ps.X or mp.Y < pa.Y or mp.Y > pa.Y + ps.Y then
            closePopup()
        end
    end))

    -- Hex input commit
    table.insert(localConnections, hexBox.FocusLost:Connect(function()
        local raw = hexBox.Text:gsub("^#", "")
        if #raw == 6 then
            local ok, r, g, b = pcall(function()
                return tonumber("0x"..raw:sub(1,2)) / 255,
                       tonumber("0x"..raw:sub(3,4)) / 255,
                       tonumber("0x"..raw:sub(5,6)) / 255
            end)
            if ok and r and g and b then
                local newColor = Color3.new(r, g, b)
                control._hue, control._sat, control._val = newColor:ToHSV()
                control.Value = newColor
                control.Changed:Fire(newColor)
                SafeCallback(control.Callback, newColor)
                control.RenderHook:Fire("ValueChanged")
                updateSVDisplay(false)
                return
            end
        end
        hexBox.Text = "#" .. control.Value:ToHex():upper()
    end))

    -- ── applyVisual ───────────────────────────────────────────
    local function applyVisual(instant)
        local isDisabled = control.Disabled
        local dur = instant and 0 or COLORPICKER_ANIMATION_TIME
        root.Visible = control.Visible
        if textLabel then
            textLabel.Text = control.Text
            tweenProp(textLabel, dur, {
                TextColor3 = isDisabled and Library.Theme.Text.Secondary or Library.Theme.Text.Primary,
                TextTransparency = isDisabled and 0.45 or 0,
            })
        end
        tweenProp(swatchStroke, dur, {
            Transparency = isDisabled and 0.7 or 0.5,
        })
        swatch.Active = not isDisabled
        if isDisabled and opened then closePopup() end
        updateSwatchDisplay()
    end

    applyVisual(true)
    updateSVDisplay(true)

    return {
        Root = root,
        HandleAction = function(action)
            if action == "ValueChanged" then
                updateSVDisplay(false)
            elseif action == "TransparencyChanged" then
                if alphaCursor then
                    alphaCursor.Position = UDim2.fromScale(0.5, control.Transparency)
                end
            elseif action == "VisualStateChanged" then
                applyVisual(false)
            end
        end,
        Cleanup = function()
            cancelTweens()
            closePopup()
            SafeDestroy(popup)
            for _, c in ipairs(localConnections) do
                if c.Connected then c:Disconnect() end
            end
        end,
    }
end)

Library:RegisterControlRenderer("Dropdown", function(control)
    local root = Instance.new("TextButton")
    root.Name = "Dropdown"
    root.Size = UDim2.new(1, 0, 0, DROPDOWN_ROW_HEIGHT)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.AutoButtonColor = false
    root.Text = ""

    local hoverFill = Instance.new("Frame")
    hoverFill.Name = "HoverFill"
    hoverFill.Size = UDim2.fromScale(1, 1)
    hoverFill.BackgroundColor3 = Library.Theme.Surface.S2
    hoverFill.BackgroundTransparency = 1
    hoverFill.BorderSizePixel = 0
    hoverFill.Parent = root

    local hoverCorner = Instance.new("UICorner")
    hoverCorner.CornerRadius = UDim.new(0, 6)
    hoverCorner.Parent = hoverFill

    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.Size = UDim2.new(DROPDOWN_LABEL_WIDTH_SCALE, -DROPDOWN_LABEL_GAP, 1, 0)
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextColor3 = control.Risky and Library.Theme.Status.Error or Library.Theme.Text.Primary
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = root

    local trigger = Instance.new("Frame")
    trigger.Name = "Trigger"
    trigger.Position = UDim2.new(DROPDOWN_LABEL_WIDTH_SCALE, DROPDOWN_LABEL_GAP, 0, 0)
    trigger.Size = UDim2.new(1 - DROPDOWN_LABEL_WIDTH_SCALE, -DROPDOWN_LABEL_GAP, 1, 0)
    trigger.BackgroundColor3 = Library.Theme.Surface.S2
    trigger.BorderSizePixel = 0
    trigger.Parent = root

    local triggerCorner = Instance.new("UICorner")
    triggerCorner.CornerRadius = UDim.new(0, DROPDOWN_CORNER_RADIUS)
    triggerCorner.Parent = trigger

    local triggerStroke = Instance.new("UIStroke")
    triggerStroke.Thickness = 1
    triggerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    triggerStroke.Parent = trigger

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Position = UDim2.new(0, 8, 0, 0)
    valueLabel.Size = UDim2.new(1, -(DROPDOWN_INDICATOR_WIDTH + 16), 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.BorderSizePixel = 0
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.TextYAlignment = Enum.TextYAlignment.Center
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
    valueLabel.Parent = trigger
    valueLabel.ZIndex = 2

    local indicator = Instance.new("TextLabel")
    indicator.Name = "Indicator"
    indicator.AnchorPoint = Vector2.new(1, 0.5)
    indicator.Position = UDim2.new(1, -8, 0.5, 0)
    indicator.Size = UDim2.fromOffset(DROPDOWN_INDICATOR_WIDTH, 12)
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.Text = "+"
    indicator.TextSize = 14
    indicator.Font = Enum.Font.GothamBold
    indicator.Parent = trigger
    indicator.ZIndex = 3

    local menuRoot = Instance.new("Frame")
    menuRoot.Name = "DropdownMenu"
    menuRoot.BackgroundTransparency = 1
    menuRoot.BorderSizePixel = 0
    menuRoot.ClipsDescendants = true
    menuRoot.Active = true
    menuRoot.Visible = false
    menuRoot.ZIndex = 20
    menuRoot.Parent = ScreenGui

    local menuSurface = Instance.new("Frame")
    menuSurface.Name = "Surface"
    menuSurface.Position = UDim2.fromOffset(DROPDOWN_MENU_INSET, DROPDOWN_MENU_INSET)
    menuSurface.Size = UDim2.new(1, -(DROPDOWN_MENU_INSET * 2), 1, -(DROPDOWN_MENU_INSET * 2))
    menuSurface.BackgroundColor3 = Library.Theme.Surface.S1
    menuSurface.BackgroundTransparency = 1
    menuSurface.BorderSizePixel = 0
    menuSurface.Active = true
    menuSurface.ZIndex = 20
    menuSurface.Parent = menuRoot

    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 8)
    menuCorner.Parent = menuSurface

    local menuStroke = Instance.new("UIStroke")
    menuStroke.Thickness = 1
    menuStroke.Color = Library.Theme.Surface.S4
    menuStroke.Transparency = 1
    menuStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    menuStroke.Parent = menuSurface

    local searchBox = Instance.new("TextBox")
    searchBox.Name = "Search"
    searchBox.Position = UDim2.new(0, 8, 0, 0)
    searchBox.Size = UDim2.new(1, -(DROPDOWN_INDICATOR_WIDTH + 16), 1, 0)
    searchBox.BackgroundColor3 = Library.Theme.Surface.S2
    searchBox.BackgroundTransparency = 1
    searchBox.BorderSizePixel = 0
    searchBox.ClearTextOnFocus = false
    searchBox.PlaceholderText = "Search..."
    searchBox.Text = ""
    searchBox.TextColor3 = Library.Theme.Text.Primary
    searchBox.PlaceholderColor3 = Library.Theme.Text.Secondary
    searchBox.TextSize = 12
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.TextYAlignment = Enum.TextYAlignment.Center
    searchBox.Visible = false
    searchBox.ZIndex = 4
    searchBox.Parent = trigger

    local searchPadding = Instance.new("UIPadding")
    searchPadding.PaddingLeft = UDim.new(0, 8)
    searchPadding.PaddingRight = UDim.new(0, 8)
    searchPadding.Parent = searchBox

    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 6)
    searchCorner.Parent = searchBox

    local searchStroke = Instance.new("UIStroke")
    searchStroke.Thickness = 1
    searchStroke.Color = Library.Theme.Surface.S4
    searchStroke.Transparency = 1
    searchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    searchStroke.Parent = searchBox

    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Name = "List"
    listFrame.BackgroundTransparency = 1
    listFrame.BorderSizePixel = 0
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.ScrollBarThickness = 0
    listFrame.ScrollBarImageColor3 = Library.Theme.Surface.S5
    listFrame.ScrollBarImageTransparency = 1
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
    listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    listFrame.VerticalScrollBarInset = Enum.ScrollBarInset.None
    listFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.None
    listFrame.Active = true
    listFrame.ZIndex = 21
    listFrame.Parent = menuSurface

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, DROPDOWN_MENU_ITEM_PADDING)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listFrame

    local activeTweens = {}
    local localConnections = {}
    local itemConnections = {}
    local menuVisualTweens = {}
    local hovered = false
    local opened = false
    local menuTween
    local menuTweenCompletedConnection
    local suppressNextRootClick = false

    local function cancelTweens()
        for index, tween in ipairs(activeTweens) do
            tween:Cancel()
            activeTweens[index] = nil
        end
    end

    local function cancelMenuTween()
        if menuTweenCompletedConnection then
            menuTweenCompletedConnection:Disconnect()
            menuTweenCompletedConnection = nil
        end

        if menuTween then
            menuTween:Cancel()
            menuTween = nil
        end
    end

    local function cancelMenuVisualTweens()
        for index, tween in ipairs(menuVisualTweens) do
            tween:Cancel()
            menuVisualTweens[index] = nil
        end
    end

    local function tweenProperty(instance, duration, properties)
        if duration <= 0 then
            for key, value in pairs(properties) do
                instance[key] = value
            end
            return
        end

        local tween = TweenService:Create(
            instance,
            TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            properties
        )
        table.insert(activeTweens, tween)
        tween:Play()
    end

    local function tweenMenuVisual(duration, backgroundTransparency, strokeTransparency)
        cancelMenuVisualTweens()

        if duration <= 0 then
            menuSurface.BackgroundTransparency = backgroundTransparency
            menuStroke.Transparency = strokeTransparency
            return
        end

        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local surfaceTween = TweenService:Create(menuSurface, tweenInfo, {
            BackgroundTransparency = backgroundTransparency,
        })
        local strokeTween = TweenService:Create(menuStroke, tweenInfo, {
            Transparency = strokeTransparency,
        })
        table.insert(menuVisualTweens, surfaceTween)
        table.insert(menuVisualTweens, strokeTween)
        surfaceTween:Play()
        strokeTween:Play()
    end

    local function disconnectItemConnections()
        for index, connection in ipairs(itemConnections) do
            if connection.Connected then
                connection:Disconnect()
            end

            itemConnections[index] = nil
        end
    end

    local function getDisplayText()
        if control.Multi then
            if #control.Value == 0 then
                return "--", true
            end

            return table.concat(control.Value, ", "), false
        end

        if control.Value == nil then
            return "--", true
        end

        return control.Value, false
    end

    local function syncTriggerContents()
        local showSearch = opened and control.Searchable and not control.Disabled
        valueLabel.Visible = not showSearch
        searchBox.Visible = showSearch
        searchBox.TextEditable = showSearch
    end

    local function isValueSelected(value)
        if control.Multi then
            for _, selectedValue in ipairs(control.Value) do
                if selectedValue == value then
                    return true
                end
            end

            return false
        end

        return control.Value == value
    end

    local function toggleMultiValue(value)
        local selectedSet = {}
        for _, selectedValue in ipairs(control.Value) do
            selectedSet[selectedValue] = true
        end

        if selectedSet[value] then
            selectedSet[value] = nil
        else
            selectedSet[value] = true
        end

        local nextValues = {}
        for _, optionValue in ipairs(control.Values) do
            if selectedSet[optionValue] then
                table.insert(nextValues, optionValue)
            end
        end

        return nextValues
    end

    local function pointInBounds(guiObject, point)
        if not guiObject.Visible then
            return false
        end

        local screenGuiPos = ScreenGui.AbsolutePosition
        local localPoint = point - screenGuiPos
        local absPos = guiObject.AbsolutePosition - screenGuiPos
        local absSize = guiObject.AbsoluteSize
        return localPoint.X >= absPos.X
            and localPoint.X <= absPos.X + absSize.X
            and localPoint.Y >= absPos.Y
            and localPoint.Y <= absPos.Y + absSize.Y
    end

    local function getMenuMetrics()
        local menuWidth = math.max(1, trigger.AbsoluteSize.X)
        local screenSize = GetScreenSize(ScreenGui)
        local screenGuiPos = ScreenGui.AbsolutePosition
        local triggerPos = trigger.AbsolutePosition - screenGuiPos
        local triggerSize = trigger.AbsoluteSize
        local x = math.clamp(triggerPos.X, 8, math.max(8, screenSize.X - menuWidth - 8))
        local y = triggerPos.Y + triggerSize.Y + DROPDOWN_MENU_GAP
        local maxHeightBelow = math.max(0, screenSize.Y - y - 8)

        return menuWidth, x, y, maxHeightBelow
    end

    local closeMenu

    local function rebuildMenu()
        disconnectItemConnections()

        for _, child in ipairs(listFrame:GetChildren()) do
            if child ~= listLayout then
                child:Destroy()
            end
        end

        local filteredValues = {}
        local query = string.lower(searchBox.Text)

        for _, value in ipairs(control.Values) do
            if query == "" or string.find(string.lower(value), query, 1, true) then
                table.insert(filteredValues, value)
            end
        end

        if #filteredValues == 0 then
            local emptyLabel = Instance.new("TextLabel")
            emptyLabel.Name = "Empty"
            emptyLabel.Position = UDim2.fromOffset(DROPDOWN_MENU_ITEM_INSET, 0)
            emptyLabel.Size = UDim2.new(1, -(DROPDOWN_MENU_ITEM_INSET * 2), 0, DROPDOWN_MENU_ITEM_HEIGHT)
            emptyLabel.BackgroundTransparency = 1
            emptyLabel.BorderSizePixel = 0
            emptyLabel.Text = "No matches"
            emptyLabel.TextColor3 = Library.Theme.Text.Tertiary
            emptyLabel.TextSize = 12
            emptyLabel.Font = Enum.Font.Gotham
            emptyLabel.TextXAlignment = Enum.TextXAlignment.Left
            emptyLabel.TextYAlignment = Enum.TextYAlignment.Center
            emptyLabel.ZIndex = 22
            emptyLabel.Parent = listFrame
        else
            for _, value in ipairs(filteredValues) do
                local item = Instance.new("TextButton")
                item.Name = value
                item.Position = UDim2.fromOffset(DROPDOWN_MENU_ITEM_INSET, 0)
                item.Size = UDim2.new(1, -(DROPDOWN_MENU_ITEM_INSET * 2), 0, DROPDOWN_MENU_ITEM_HEIGHT)
                item.BackgroundColor3 = Library.Theme.Surface.S2
                item.BackgroundTransparency = 1
                item.BorderSizePixel = 0
                item.AutoButtonColor = false
                item.Text = ""
                item.Active = not control.DisabledValueSet[value]
                item.ZIndex = 22
                item.Parent = listFrame

                local itemCorner = Instance.new("UICorner")
                itemCorner.CornerRadius = UDim.new(0, 5)
                itemCorner.Parent = item

                local itemLabel = Instance.new("TextLabel")
                itemLabel.Size = UDim2.new(1, -8, 1, 0)
                itemLabel.Position = UDim2.new(0, 8, 0, 0)
                itemLabel.BackgroundTransparency = 1
                itemLabel.BorderSizePixel = 0
                itemLabel.Text = value
                itemLabel.TextSize = 12
                itemLabel.Font = Enum.Font.Gotham
                itemLabel.TextXAlignment = Enum.TextXAlignment.Left
                itemLabel.TextYAlignment = Enum.TextYAlignment.Center
                itemLabel.ZIndex = 23
                itemLabel.Parent = item

                local function applyItemVisual(itemHovered)
                    local selected = isValueSelected(value)
                    local disabledOption = control.DisabledValueSet[value]

                    item.BackgroundColor3 = selected and Library.Theme.Status.Accent or Library.Theme.Surface.S2
                    item.BackgroundTransparency = disabledOption and 1 or (selected and 0.88 or (itemHovered and 0.92 or 1))
                    itemLabel.TextColor3 = disabledOption and Library.Theme.Text.Tertiary or Library.Theme.Text.Primary
                    itemLabel.TextTransparency = disabledOption and 0.35 or 0
                end

                applyItemVisual(false)

                table.insert(itemConnections, item.MouseEnter:Connect(function()
                    applyItemVisual(true)
                end))

                table.insert(itemConnections, item.MouseLeave:Connect(function()
                    applyItemVisual(false)
                end))

                table.insert(itemConnections, item.MouseButton1Click:Connect(function()
                    if control.DisabledValueSet[value] then
                        return
                    end

                    if control.Multi then
                        control:SetValue(toggleMultiValue(value))
                    else
                        closeMenu(false)
                        control:SetValue(value)
                    end
                end))
            end
        end

        local menuWidth, menuX, menuY, maxHeightBelow = getMenuMetrics()
        local itemCount = math.max(1, #filteredValues)
        local contentHeight = (itemCount * DROPDOWN_MENU_ITEM_HEIGHT)
            + (math.max(0, itemCount - 1) * DROPDOWN_MENU_ITEM_PADDING)
        local visibleCount = math.max(1, math.min(control.MaxVisibleDropdownItems, itemCount))
        local desiredListHeight = (visibleCount * DROPDOWN_MENU_ITEM_HEIGHT)
            + (math.max(0, visibleCount - 1) * DROPDOWN_MENU_ITEM_PADDING)
        local topOffset = DROPDOWN_MENU_PADDING

        local availableListHeight = math.max(0, maxHeightBelow - topOffset - DROPDOWN_MENU_PADDING)
        local actualListHeight = math.min(desiredListHeight, availableListHeight)

        listFrame.Visible = actualListHeight > 0
        listFrame.Position = UDim2.fromOffset(DROPDOWN_MENU_PADDING, topOffset)
        listFrame.Size = UDim2.new(1, -(DROPDOWN_MENU_PADDING * 2), 0, actualListHeight)
        listFrame.CanvasSize = UDim2.fromOffset(0, contentHeight)
        menuRoot.Position = UDim2.fromOffset(menuX - DROPDOWN_MENU_INSET, menuY - DROPDOWN_MENU_INSET)

        return UDim2.fromOffset(
            menuWidth + (DROPDOWN_MENU_INSET * 2),
            topOffset + actualListHeight + DROPDOWN_MENU_PADDING + (DROPDOWN_MENU_INSET * 2)
        )
    end

    local function refreshOpenMenu()
        if not opened then
            return
        end

        cancelMenuTween()
        menuRoot.Size = rebuildMenu()
    end

    closeMenu = function(instant)
        if not opened and not menuRoot.Visible then
            return
        end

        opened = false
        RendererHelpers.ReleaseActiveDropdown(closeMenu)
        searchBox:ReleaseFocus()
        searchBox.Text = ""

        cancelMenuTween()
        cancelMenuVisualTweens()

        local closedSize = UDim2.fromOffset(
            math.max(1, trigger.AbsoluteSize.X) + (DROPDOWN_MENU_INSET * 2),
            DROPDOWN_CLOSED_HEIGHT
        )
        if instant then
            menuRoot.Visible = false
            menuRoot.Size = closedSize
            menuSurface.BackgroundTransparency = 1
            menuStroke.Transparency = 1
            syncTriggerContents()
            return
        end

        tweenMenuVisual(DROPDOWN_ANIMATION_TIME, 1, 1)
        menuTween = TweenService:Create(
            menuRoot,
            TweenInfo.new(DROPDOWN_ANIMATION_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { Size = closedSize }
        )
        menuTweenCompletedConnection = menuTween.Completed:Connect(function(playbackState)
            menuTweenCompletedConnection = nil
            if playbackState == Enum.PlaybackState.Completed and not opened then
                menuRoot.Visible = false
            end

            menuTween = nil
        end)
        menuTween:Play()
        syncTriggerContents()
    end

    local function openMenu()
        if opened or control.Disabled or not control.Visible then
            return
        end

        RendererHelpers.ClaimActiveDropdown(closeMenu)

        opened = true
        menuRoot.Visible = true
        syncTriggerContents()

        local targetSize = rebuildMenu()
        cancelMenuTween()
        cancelMenuVisualTweens()
        menuRoot.Size = UDim2.fromOffset(targetSize.X.Offset, DROPDOWN_CLOSED_HEIGHT)
        menuSurface.BackgroundTransparency = 1
        menuStroke.Transparency = 1
        menuTween = TweenService:Create(
            menuRoot,
            TweenInfo.new(DROPDOWN_ANIMATION_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { Size = targetSize }
        )
        menuTweenCompletedConnection = menuTween.Completed:Connect(function()
            menuTweenCompletedConnection = nil
            menuTween = nil
        end)
        tweenMenuVisual(DROPDOWN_ANIMATION_TIME, 0, 0.1)
        menuTween:Play()

        if control.Searchable then
            task.defer(function()
                if opened and searchBox.Parent and searchBox.Visible then
                    searchBox:CaptureFocus()
                end
            end)
        end
    end

    local function applyVisual(instant)
        cancelTweens()

        local isDisabled = control.Disabled
        local baseTextColor = control.Risky and Library.Theme.Status.Error or Library.Theme.Text.Primary
        local displayText, isPlaceholder = getDisplayText()
        local hoverTransparency = (hovered or opened) and 0.84 or 1
        local duration = instant and 0 or DROPDOWN_ANIMATION_TIME

        root.Visible = control.Visible
        label.Text = control.Text
        valueLabel.Text = displayText
        indicator.Text = opened and "-" or "+"
        syncTriggerContents()

        tweenProperty(hoverFill, duration, {
            BackgroundTransparency = isDisabled and 1 or hoverTransparency,
        })
        tweenProperty(label, duration, {
            TextColor3 = isDisabled and Library.Theme.Text.Secondary or baseTextColor,
            TextTransparency = isDisabled and 0.45 or 0,
        })
        tweenProperty(trigger, duration, {
            BackgroundColor3 = isDisabled and Library.Theme.Surface.S1 or Library.Theme.Surface.S2,
            BackgroundTransparency = isDisabled and 0.15 or 0,
        })
        tweenProperty(triggerStroke, duration, {
            Color = opened and Library.Theme.Status.Accent or Library.Theme.Surface.S4,
            Transparency = isDisabled and 0.45 or 0.1,
        })
        tweenProperty(valueLabel, duration, {
            TextColor3 = isDisabled and Library.Theme.Text.Tertiary or (isPlaceholder and Library.Theme.Text.Secondary or Library.Theme.Text.Primary),
            TextTransparency = isDisabled and 0.25 or 0,
        })
        tweenProperty(indicator, duration, {
            TextColor3 = isDisabled and Library.Theme.Text.Tertiary or (opened and Library.Theme.Status.Accent or Library.Theme.Text.Secondary),
            TextTransparency = isDisabled and 0.25 or 0,
        })
        tweenProperty(searchBox, duration, {
            BackgroundColor3 = isDisabled and Library.Theme.Surface.S1 or Library.Theme.Surface.S2,
            TextColor3 = isDisabled and Library.Theme.Text.Tertiary or Library.Theme.Text.Primary,
            TextTransparency = isDisabled and 0.25 or 0,
            PlaceholderColor3 = isDisabled and Library.Theme.Text.Tertiary or Library.Theme.Text.Secondary,
        })
    end

    table.insert(localConnections, root.MouseEnter:Connect(function()
        hovered = true
        applyVisual(false)
    end))

    table.insert(localConnections, root.MouseLeave:Connect(function()
        hovered = false
        applyVisual(false)
    end))

    table.insert(localConnections, searchBox.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        suppressNextRootClick = true
    end))

    table.insert(localConnections, root.MouseButton1Click:Connect(function()
        if suppressNextRootClick then
            suppressNextRootClick = false
            return
        end

        if control.Disabled then
            return
        end

        if opened then
            closeMenu(false)
        else
            openMenu()
        end

        applyVisual(false)
    end))

    table.insert(localConnections, UserInputService.InputBegan:Connect(function(input)
        if not opened then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local point = ToScreenGuiSpace(input.Position)
        if pointInBounds(root, point) or pointInBounds(menuRoot, point) then
            return
        end

        closeMenu(false)
        applyVisual(false)
    end))

    table.insert(localConnections, searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if opened then
            refreshOpenMenu()
        end
    end))

    table.insert(localConnections, trigger:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        if opened then
            refreshOpenMenu()
        end
    end))

    table.insert(localConnections, trigger:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if opened then
            refreshOpenMenu()
        end
    end))

    if control.Parent then
        table.insert(localConnections, control.Parent.RenderHook:Connect(function(action)
            if action == "CollapsedChanged" or action == "Destroy" then
                closeMenu(true)
            end
        end))

        local groupBoxState = Renderer.GroupBoxes[control.Parent]
        if groupBoxState then
            table.insert(localConnections, groupBoxState.BodyContainer:GetPropertyChangedSignal("Visible"):Connect(function()
                if not groupBoxState.BodyContainer.Visible then
                    closeMenu(true)
                end
            end))
        end
    end

    applyVisual(true)

    return {
        Root = root,
        HandleAction = function(action)
            if action == "ValueChanged" or action == "ValuesChanged" or action == "VisualStateChanged" then
                if not control.Visible or control.Disabled then
                    closeMenu(true)
                elseif opened then
                    refreshOpenMenu()
                end

                applyVisual(false)
            end
        end,
        Cleanup = function()
            closeMenu(true)
            cancelTweens()
            cancelMenuTween()
            cancelMenuVisualTweens()
            disconnectItemConnections()

            for _, connection in ipairs(localConnections) do
                if connection.Connected then
                    connection:Disconnect()
                end
            end

            SafeDestroy(menuRoot)
        end,
    }
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

local RuntimeState = {
    draggingResize = false,
    draggingWindow = false,
    dragTopLeft = Vector2.new(0, 0),
    pointerPosition = Vector2.new(0, 0),
    dragWidthOffset = 0,
    windowDragStartTopLeft = Vector2.new(0, 0),
    windowDragStartPointerPosition = Vector2.new(0, 0),
    windowDragPointerPosition = Vector2.new(0, 0),
    cleanedUp = false,
    resizeHandleHovered = false,
    resizeHandleTween = nil,
    bottomDragHovered = false,
    bottomDragTween = nil,
    gbDragging = false,
    gbDragGroupBox = nil,
    gbDragPlaceholder = nil,
    gbDragOffset = Vector2.new(0, 0),
    gbDragPointer = Vector2.new(0, 0),
    gbDragTargetColumn = nil,
    gbDragSourceColumn = nil,
    gbDragSnapTween = nil,
}

function RuntimeHelpers.SetResizeHandleTransparency(target, duration)
    if RuntimeState.resizeHandleTween then
        RuntimeState.resizeHandleTween:Cancel()
    end

    RuntimeState.resizeHandleTween = TweenService:Create(
        ResizeHandleIcon,
        TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { ImageTransparency = target }
    )
    RuntimeState.resizeHandleTween:Play()
end

function RuntimeHelpers.SetBottomDragBarTransparency(target, duration)
    if RuntimeState.bottomDragTween then
        RuntimeState.bottomDragTween:Cancel()
    end

    RuntimeState.bottomDragTween = TweenService:Create(
        BottomDragBar,
        TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { ImageTransparency = target }
    )
    RuntimeState.bottomDragTween:Play()
end

function RuntimeHelpers.UpdateAffordanceHoverState()
    local isActive = RuntimeState.draggingResize or RuntimeState.draggingWindow or RuntimeState.resizeHandleHovered or RuntimeState.bottomDragHovered
    local targetTransparency = isActive and RESIZE_HANDLE_ACTIVE_TRANSPARENCY or RESIZE_HANDLE_IDLE_TRANSPARENCY
    local duration = isActive and 0.1 or 0.18

    RuntimeHelpers.SetResizeHandleTransparency(targetTransparency, duration)
    RuntimeHelpers.SetBottomDragBarTransparency(targetTransparency, duration)
end

function RuntimeHelpers.GetColumnGroupBoxes(columnName, excludeGroupBox)
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

function RuntimeHelpers.CommitColumnLayout(columnName)
    local boxes = RuntimeHelpers.GetColumnGroupBoxes(columnName, nil)
    for i, entry in ipairs(boxes) do
        entry.gb:SetPlacement(columnName, i)
    end
end

function RuntimeHelpers.UpdateDragPlaceholder()
    if not RuntimeState.gbDragging or not RuntimeState.gbDragGroupBox or not RuntimeState.gbDragPlaceholder then
        return
    end

    local targetColumn = nil
    local bestDist = math.huge

    for colName, colFrame in pairs(ColumnFrames) do
        local absPos = colFrame.AbsolutePosition
        local absSize = colFrame.AbsoluteSize
        local clampedX = math.clamp(RuntimeState.gbDragPointer.X, absPos.X, absPos.X + absSize.X)
        local dist = math.abs(RuntimeState.gbDragPointer.X - clampedX)
        if dist < bestDist then
            bestDist = dist
            targetColumn = colName
        end
    end

    if not targetColumn then
        return
    end

    RuntimeState.gbDragTargetColumn = targetColumn

    local boxes = RuntimeHelpers.GetColumnGroupBoxes(targetColumn, RuntimeState.gbDragGroupBox)
    local insertIndex = #boxes + 1

    for i, entry in ipairs(boxes) do
        local midY = entry.state.Root.AbsolutePosition.Y + entry.state.Root.AbsoluteSize.Y / 2
        if RuntimeState.gbDragPointer.Y < midY then
            insertIndex = i
            break
        end
    end

    local targetColFrame = ColumnFrames[targetColumn]
    if RuntimeState.gbDragPlaceholder.Parent ~= targetColFrame then
        RuntimeState.gbDragPlaceholder.Parent = targetColFrame
    end

    local order = 1
    for i, entry in ipairs(boxes) do
        if i == insertIndex then
            RuntimeState.gbDragPlaceholder.LayoutOrder = order
            order = order + 1
        end
        entry.state.Root.LayoutOrder = order
        order = order + 1
    end
    if insertIndex > #boxes then
        RuntimeState.gbDragPlaceholder.LayoutOrder = order
    end
end

function RuntimeHelpers.BeginGroupBoxDrag(groupBox, inputPosition)
    if RuntimeState.gbDragging or RuntimeState.gbDragSnapTween or RuntimeState.draggingWindow or RuntimeState.draggingResize then
        return
    end

    CloseActiveDropdown()

    local state = Renderer.GroupBoxes[groupBox]
    if not state then
        return
    end

    local root = state.Root
    local absPos = root.AbsolutePosition
    local absSize = root.AbsoluteSize

    RuntimeState.gbDragging = true
    RuntimeState.gbDragGroupBox = groupBox
    RuntimeState.gbDragSourceColumn = groupBox.Column
    RuntimeState.gbDragTargetColumn = groupBox.Column
    RuntimeState.gbDragPointer = ToScreenGuiSpace(inputPosition)

    local screenGuiPos = ScreenGui.AbsolutePosition
    local localRootX = absPos.X - screenGuiPos.X
    local localRootY = absPos.Y - screenGuiPos.Y

    RuntimeState.gbDragOffset = Vector2.new(
        RuntimeState.gbDragPointer.X - localRootX,
        RuntimeState.gbDragPointer.Y - localRootY
    )

    local placeholderWidth = math.max(1, absSize.X - GROUPBOX_DRAG_PLACEHOLDER_INSET * 2)
    local placeholderHeight = math.max(1, absSize.Y - GROUPBOX_DRAG_PLACEHOLDER_INSET * 2)
    local placeholder = Instance.new("Frame")
    placeholder.Name = "GBDragPlaceholder"
    placeholder.Size = UDim2.fromOffset(absSize.X, absSize.Y)
    placeholder.BackgroundTransparency = 1
    placeholder.BorderSizePixel = 0
    placeholder.LayoutOrder = groupBox.LayoutOrder

    local placeholderOutline = Instance.new("Frame")
    placeholderOutline.Name = "Outline"
    placeholderOutline.AnchorPoint = Vector2.new(0.5, 0.5)
    placeholderOutline.Position = UDim2.fromScale(0.5, 0.5)
    placeholderOutline.Size = UDim2.fromOffset(placeholderWidth, placeholderHeight)
    placeholderOutline.BackgroundColor3 = Library.Theme.Status.Accent
    placeholderOutline.BackgroundTransparency = 0.88
    placeholderOutline.BorderSizePixel = 0
    placeholderOutline.Parent = placeholder

    local placeholderStroke = Instance.new("UIStroke")
    placeholderStroke.Color = Library.Theme.Status.Accent
    placeholderStroke.Thickness = 2
    placeholderStroke.Transparency = 0
    placeholderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    placeholderStroke.Parent = placeholderOutline

    local placeholderCorner = Instance.new("UICorner")
    placeholderCorner.CornerRadius = UDim.new(0, GROUPBOX_CORNER_RADIUS)
    placeholderCorner.Parent = placeholderOutline

    RuntimeState.gbDragPlaceholder = placeholder
    placeholder.Parent = ColumnFrames[groupBox.Column]

    root.Parent = ScreenGui
    root.Size = UDim2.fromOffset(absSize.X, absSize.Y)
    root.Position = UDim2.fromOffset(localRootX, localRootY)

    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("GuiObject") then
            obj.ZIndex = obj.ZIndex + 100
        end
    end
    root.ZIndex = 100

    RuntimeHelpers.UpdateDragPlaceholder()
end

function RuntimeHelpers.EndGroupBoxDrag()
    if not RuntimeState.gbDragging then
        return
    end

    RuntimeState.gbDragging = false

    local groupBox = RuntimeState.gbDragGroupBox
    RuntimeState.gbDragGroupBox = nil

    local placeholder = RuntimeState.gbDragPlaceholder
    RuntimeState.gbDragPlaceholder = nil

    local sourceColumn = RuntimeState.gbDragSourceColumn
    RuntimeState.gbDragSourceColumn = nil

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
    local targetColumn = RuntimeState.gbDragTargetColumn or groupBox.Column
    local targetLayoutOrder = placeholder and placeholder.LayoutOrder or groupBox.LayoutOrder
    local targetColumnFrame = ColumnFrames[targetColumn]
    local placeholderY = placeholder and placeholder.AbsolutePosition.Y or root.AbsolutePosition.Y
    local columnX = targetColumnFrame and targetColumnFrame.AbsolutePosition.X or root.AbsolutePosition.X
    local targetAbsPos = Vector2.new(columnX, placeholderY)

    if RuntimeState.gbDragSnapTween then
        RuntimeState.gbDragSnapTween:Cancel()
        RuntimeState.gbDragSnapTween = nil
    end

    local screenGuiPos = ScreenGui.AbsolutePosition
    local snapTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local snapTween = TweenService:Create(
        root,
        snapTweenInfo,
        { Position = UDim2.fromOffset(
            targetAbsPos.X - screenGuiPos.X,
            targetAbsPos.Y - screenGuiPos.Y
        ) }
    )
    RuntimeState.gbDragSnapTween = snapTween
    snapTween:Play()

    if placeholder then
        local placeholderOutline = placeholder:FindFirstChild("Outline")
        if placeholderOutline then
            TweenService:Create(placeholderOutline, snapTweenInfo, { BackgroundTransparency = 1 }):Play()
        end

        local placeholderStroke = placeholderOutline and placeholderOutline:FindFirstChildOfClass("UIStroke")
        if placeholderStroke then
            TweenService:Create(placeholderStroke, snapTweenInfo, { Transparency = 1 }):Play()
        end
    end

    snapTween.Completed:Connect(function(playbackState)
        if RuntimeState.gbDragSnapTween == snapTween then
            RuntimeState.gbDragSnapTween = nil
        end

        if playbackState ~= Enum.PlaybackState.Completed then
            return
        end
        if not root or root.Parent ~= ScreenGui then
            SafeDestroy(placeholder)
            return
        end

        root.Size = UDim2.fromScale(1, 0)
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("GuiObject") then
                obj.ZIndex = obj.ZIndex - 100
            end
        end
        root.ZIndex = 1
        root.Parent = ColumnFrames[targetColumn]
        root.LayoutOrder = targetLayoutOrder

        groupBox:SetPlacement(targetColumn, targetLayoutOrder)

        SafeDestroy(placeholder)

        RuntimeHelpers.CommitColumnLayout(targetColumn)
        if sourceColumn and sourceColumn ~= targetColumn then
            RuntimeHelpers.CommitColumnLayout(sourceColumn)
        end
    end)
end

function RuntimeHelpers.Cleanup()
    if RuntimeState.cleanedUp then
        return
    end

    RuntimeState.cleanedUp = true
    RuntimeState.draggingResize = false
    RuntimeState.draggingWindow = false
    RuntimeState.dragWidthOffset = 0

    CloseActiveDropdown()

    ActiveTab:Destroy()

    if RuntimeState.resizeHandleTween then
        RuntimeState.resizeHandleTween:Cancel()
        RuntimeState.resizeHandleTween = nil
    end

    if RuntimeState.bottomDragTween then
        RuntimeState.bottomDragTween:Cancel()
        RuntimeState.bottomDragTween = nil
    end

    if RuntimeState.gbDragSnapTween then
        RuntimeState.gbDragSnapTween:Cancel()
        RuntimeState.gbDragSnapTween = nil
    end

    SafeDestroy(RuntimeState.gbDragPlaceholder)
    RuntimeState.gbDragPlaceholder = nil
    RuntimeState.gbDragging = false
    RuntimeState.gbDragGroupBox = nil

    DisconnectConnections()
end

TrackConnection(BottomDragBarInteract.MouseEnter:Connect(function()
    RuntimeState.bottomDragHovered = true
    RuntimeHelpers.UpdateAffordanceHoverState()
end))

TrackConnection(BottomDragBarInteract.MouseLeave:Connect(function()
    RuntimeState.bottomDragHovered = false
    RuntimeHelpers.UpdateAffordanceHoverState()
end))

TrackConnection(BottomDragBarInteract.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 or RuntimeState.draggingResize then
        return
    end

    CloseActiveDropdown()
    RuntimeState.draggingWindow = true
    RuntimeState.windowDragStartTopLeft = GetWindowTopLeft()
    RuntimeState.windowDragStartPointerPosition = ToScreenGuiSpace(input.Position)
    RuntimeState.windowDragPointerPosition = RuntimeState.windowDragStartPointerPosition
    RuntimeHelpers.UpdateAffordanceHoverState()
end))

TrackConnection(ResizeHandle.MouseEnter:Connect(function()
    RuntimeState.resizeHandleHovered = true
    RuntimeHelpers.UpdateAffordanceHoverState()
end))

TrackConnection(ResizeHandle.MouseLeave:Connect(function()
    RuntimeState.resizeHandleHovered = false
    RuntimeHelpers.UpdateAffordanceHoverState()
end))

TrackConnection(ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 or RuntimeState.draggingWindow then
        return
    end

    CloseActiveDropdown()
    RuntimeState.draggingResize = true
    RuntimeState.dragTopLeft = GetWindowTopLeft()
    RuntimeState.pointerPosition = ToScreenGuiSpace(input.Position)
    RuntimeState.dragWidthOffset = WindowFrame.AbsoluteSize.X - (RuntimeState.pointerPosition.X - RuntimeState.dragTopLeft.X)
    RuntimeHelpers.UpdateAffordanceHoverState()
end))

TrackConnection(UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseMovement then
        return
    end

    local guiPosition = ToScreenGuiSpace(input.Position)

    if RuntimeState.draggingResize then
        RuntimeState.pointerPosition = guiPosition
    end

    if RuntimeState.draggingWindow then
        RuntimeState.windowDragPointerPosition = guiPosition
    end

    if RuntimeState.gbDragging then
        RuntimeState.gbDragPointer = guiPosition
        RuntimeHelpers.UpdateDragPlaceholder()
    end
end))

TrackConnection(UserInputService.InputEnded:Connect(function(input)
    local stateChanged = false

    if RuntimeState.draggingWindow and input.UserInputType == Enum.UserInputType.MouseButton1 then
        RuntimeState.draggingWindow = false
        stateChanged = true
    end

    if RuntimeState.draggingResize and input.UserInputType == Enum.UserInputType.MouseButton1 then
        RuntimeState.draggingResize = false
        RuntimeState.dragWidthOffset = 0
        stateChanged = true
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        RuntimeHelpers.EndGroupBoxDrag()
    end

    if stateChanged then
        RuntimeHelpers.UpdateAffordanceHoverState()
    end
end))

TrackConnection(RunService.RenderStepped:Connect(function()
    if RuntimeState.gbDragging and RuntimeState.gbDragGroupBox then
        local gbState = Renderer.GroupBoxes[RuntimeState.gbDragGroupBox]
        if gbState and gbState.Root.Parent == ScreenGui then
            gbState.Root.Position = UDim2.fromOffset(
                RuntimeState.gbDragPointer.X - RuntimeState.gbDragOffset.X,
                RuntimeState.gbDragPointer.Y - RuntimeState.gbDragOffset.Y
            )
        end
    end

    if RuntimeState.draggingWindow then
        if not ScreenGui.Parent or not WindowFrame.Parent then
            RuntimeState.draggingWindow = false
            return
        end

        local delta = RuntimeState.windowDragPointerPosition - RuntimeState.windowDragStartPointerPosition
        local windowWidth = WindowFrame.AbsoluteSize.X
        local clampedTopLeft = ClampWindowTopLeft(
            RuntimeState.windowDragStartTopLeft + delta,
            windowWidth,
            BOTTOM_DRAG_BAR_OUTSET + BOTTOM_DRAG_BAR_HEIGHT
        )

        ApplyWindowSize(clampedTopLeft, windowWidth)
        return
    end

    if not RuntimeState.draggingResize then
        return
    end

    if not ScreenGui.Parent or not WindowFrame.Parent then
        RuntimeState.draggingResize = false
        return
    end

    local screenSize = GetScreenSize(ScreenGui)
    local maxWidth = math.min(
        math.max(0, screenSize.X - RuntimeState.dragTopLeft.X),
        math.max(0, (screenSize.Y - RuntimeState.dragTopLeft.Y) * ASPECT_RATIO)
    )

    if maxWidth <= 0 then
        return
    end

    local minWidth = math.min(MIN_WINDOW_SIZE.X, maxWidth)
    local targetWidth = math.clamp((RuntimeState.pointerPosition.X - RuntimeState.dragTopLeft.X) + RuntimeState.dragWidthOffset, minWidth, maxWidth)

    ApplyWindowSize(RuntimeState.dragTopLeft, targetWidth)
end))

TrackConnection(ScreenGui.Destroying:Connect(function()
    UnregisterCurrentExecution()
    RuntimeHelpers.Cleanup()
end))

function Library:Destroy()
    if self._destroyed then
        return
    end

    self._destroyed = true
    UnregisterCurrentExecution()
    RuntimeHelpers.Cleanup()

    if ScreenGui.Parent then
        ScreenGui:Destroy()
    end
end

if EXECUTION_STORE then
    EXECUTION_STORE[EXECUTION_REGISTRY_KEY] = {
        ScreenGui = ScreenGui,
        Destroy = function()
            Library:Destroy()
        end,
    }
end

return Library
