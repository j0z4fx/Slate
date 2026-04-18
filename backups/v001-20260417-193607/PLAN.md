# Slate: Framework Architecture Specification

## 1. Executor Environment Constraints
1. **CoreGui Injection**: Instances run natively inside `CoreGui`. Protected using `cloneref` and `syn.protect_gui` (or equivalent executor fallbacks).
2. **No Datamodel Modules (`require()`)**: Delivered as a single concatenated `.lua` file. Sub-modules are embedded directly as upvalue function closures.
3. **No Script Identity Dependence**: Defensively verifies `LocalPlayer` without crashing immediately on early injection.
4. **Protected Service Access**: Wraps all `game:GetService` references with `pcall` and `cloneref` to bypass hostile anticheat scans.
5. **Drawing API Fallback**: Core architecture relies heavily on Roblox GUI instances, but abstracts overlays to support `Drawing` tables natively if needed.
6. **Pure Client**: No `DataStoreService`, `HttpService`, or server remote calls.
7. **Persistence**: Registers the root GUI instance inside `getgenv().SlateRegistry` to destroy old lingering instances unconditionally on library re-injection.
8. **Metatables**: Public-facing API objects are strictly locked via `__newindex` / `__metatable`.
9. **Yield Safety**: Fully event-driven logic layer. Zero `RenderStepped` polling loops allowed for state resolution.
10. **Error Boundaries**: External user callbacks are wrapped strictly inside `task.spawn(pcall)` to prevent runtime crashes from taking down the UI state.

## 2. Core Internal Systems
- **Task 1: FastSignal**: A zero-allocation signal implementation using a doubly-linked list. Encompasses `:Connect()`, `:Fire()`, `:Once()`, `:Wait()` (via `coroutine`), and `:DisconnectAll()`.
- **Task 2: Component Base Class**: The core headless model. Contains `.Value`, a public `.Changed` signal, a private `.RenderHook` signal, and `._destroyed`. Implements `:SetValue()`, `:RawSet()`, and teardown via `:Destroy()`.
- **Task 3: Unified Registry**: The master `Library.Registry` tracks state components by string keys. `Library.Toggles` and `Library.Options` utilize `__index` handlers to securely and silently bridge backwards compatibility pointing at the registry.

## 3. Deep Component Specs (Logic & Visual Separation)

### Toggle (and Checkbox)
- **Logic Config**: `Default` *(boolean)*
- **Visual Config**: `Text`, `Tooltip`, `DisabledTooltip`, `Disabled`, `Visible`, `Risky`
- **Internal Data Type**: `Boolean`
- **Logic Validation**: Validates that the incoming value evaluates strictly to a boolean type.
- **Methods**: `:SetValue(boolean)`, `:Toggle()`, `:RawSet(boolean)`
- **Integration Example**:
  ```lua
  Slate.Toggles.MyToggle.Changed:Connect(function(NewValue)
      print("Toggle state:", NewValue)
  end)
  ```

### Button
- **Logic Config**: `Func` *(function)*, `DoubleClick` *(boolean)*, `DoubleClickWindow` *(number, default 0.35)*
- **Visual Config**: `Text`, `Tooltip`, `DisabledTooltip`, `Disabled`, `Visible`, `Risky`
- **Internal Data Type**: Firing Trigger Element (No persistent `.Value`)
- **Logic Validation**: Verifies active `Disabled` states, checks `os.clock()` elapsed time against `DoubleClickWindow`.
- **Methods**: `:Invoke()` — Spawns `pcall(Func)`. Fires `.OnInvoke` signal.

### Slider
- **Logic Config**: `Default` *(number)*, `Min`, `Max`, `Rounding` *(number)*
- **Visual Config**: `Text`, `Suffix`, `Compact`, `HideMax`, `FormatDisplayValue`, `DisabledTooltip`, `Disabled`, `Visible`
- **Internal Data Type**: `Number`
- **Logic Validation**: Values clamped to `Min`/`Max` and stepped using `Rounding`.
- **Integration Example**:
  ```lua
  Slate.Options.MySlider.Changed:Connect(function(NewValue)
      print("Slider scalar:", NewValue)
  end)
  ```

### RangeSlider (Dual-Thumb)
- **Logic Config**: `Default` *({min, max})*, `Min`, `Max`, `MinDistance`, `Rounding`
- **Visual Config**: `Text`, `Suffix`, `DisabledTooltip`, `Disabled`, `Visible`
- **Internal Data Type**: `Table {min = number, max = number}`
- **Logic Validation**: Clamps both bounds rigidly. Enforces that `value.max - value.min >= MinDistance`, adjusting the non-primary thumb automatically.

### Dropdown
- **Logic Config**: `Values` *(table)*, `DisabledValues` *(table)*, `Default`, `Multi` *(boolean)*
- **Visual Config**: `Text`, `Tooltip`, `Searchable`, `MaxVisibleDropdownItems`, `Disabled`, `Visible`
- **Internal Data Type**: `String` (Single) or `Table` (Multi mode)
- **Logic Validation**: Discards strings not found in `Values` list. Logs a warning when attempting to `.SetValue` on a record inside `DisabledValues`.
- **Methods**: `:AddValue(v)`, `:RemoveValue(v)`, `:RefreshValues(newValues)`

### Input (TextBox)
- **Logic Config**: `Default` *(string)*, `Numeric` *(boolean)*, `Finished` *(boolean)*, `MaxLength` *(number)*
- **Visual Config**: `Text`, `Placeholder`, `ClearTextOnFocus`, `Tooltip`, `Disabled`, `Visible`
- **Internal Data Type**: `String`
- **Logic Validation**: Truncates precisely at `MaxLength`. If `Numeric` is true, explicitly strips non-numerical characters (allowing "-" and "."). 

### ColorPicker
- **Logic Config**: `Default` *(Color3)*
- **Visual Config**: `Title`, `Transparency` *(number 0-1)*
- **Internal Data Type**: `Color3`
- **Logic Validation**: HSV calculations guarantee color bounds remain 0-1.
- **Methods**: `:SetTransparency(t)` (Triggers independent `.RenderHook` carrying `{color=Value, transparency=t}`).

### KeyPicker
- **Logic Config**: `Default` *(KeyCode|string)*, `Mode` *(Always|Toggle|Hold)*, `SyncToggleState` *(string)*, `WaitForCallback`
- **Visual Config**: `Text`, `NoUI`
- **Internal Data Type**: `Enum.KeyCode | String`
- **Logic Validation**: Gates binding logic natively against illegal keystrokes cleanly. Uses temporary internal `_listening` states correctly tracking assignments cleanly.

## 4. The Renderer Layer (View Hooks)
- **Initialization**: GUI explicitly bootstraps safely out of sight leveraging `syn.protect_gui` locally. View initializes via `View:Initialize(Component)`.
- **Theming**: Central nested table mappings dictate visuals downward structurally merging over a core `DefaultTheme`.
- **Hierarchy Engine**: Handles functional bounds linking `Window`, `Tab`, and structural list-based `GroupBox`.
- **Component Renderers**: Headless model components fire `.RenderHook`. The disconnected renderer catches this signal explicitly processing dynamic UI elements mathematically without polluting logic blocks. 

## 5. Security & Input Management
- **Task 6: Input Handling**: `UserInputService` binds input checks globally enforcing standard interaction blocks accurately trapping dragging logic natively.
- **Task 7: Teardown**: Library `.Destroy()` loops `.Registry` structurally removing every active visual instance cleanly executing `Disconnect()` fully securing execution memory pools safely.
- **Task 8: Theming**: Core configuration structural swapping updates aesthetics runtime immediately smoothly altering frames appropriately via `Library.ThemeChanged`.
- **Task 9: Alerts**: Toast notification queue bounds overlays floating explicitly independent of parent windows.
- **Task 10: API Format**: Global entry logic dynamically initializes window wrappers mapping component chains safely bridging `.Changed` triggers seamlessly via API standards natively mimicking Linoria functionality safely effectively structuring explicit API tables predictably naturally gracefully cleanly resolving parameters optimally cleanly.
