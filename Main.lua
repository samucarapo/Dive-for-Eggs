local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Request = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Request")

for _, Name in ipairs({"LennonTP", "LennonTPOpen"}) do
    local Old = CoreGui:FindFirstChild(Name)
    if Old then
        Old:Destroy()
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LennonTP"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local OpenGui = Instance.new("ScreenGui")
OpenGui.Name = "LennonTPOpen"
OpenGui.ResetOnSpawn = false
OpenGui.DisplayOrder = 10000
OpenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
OpenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(174, 156)
Main.Position = UDim2.new(0.5, -87, 0.5, -78)
Main.BackgroundColor3 = Color3.fromRGB(18, 20, 23)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1
MainStroke.Parent = Main

local Strokes = {MainStroke}
local Hue = 0

local ColorConnection = RunService.RenderStepped:Connect(function(Delta)
    Hue = (Hue + Delta * 0.2) % 1

    for Index, Stroke in ipairs(Strokes) do
        if Stroke.Parent then
            Stroke.Color = Color3.fromHSV(
                (Hue + (Index - 1) * 0.035) % 1,
                0.85,
                1
            )
        end
    end
end)

local function CreateButton(Text, Position, Size, Parent)
    local Button = Instance.new("TextButton")
    Button.Size = Size or UDim2.new(1, -16, 0, 24)
    Button.Position = Position
    Button.BackgroundColor3 = Color3.fromRGB(29, 32, 36)
    Button.BorderSizePixel = 0
    Button.Text = Text
    Button.TextColor3 = Color3.fromRGB(250, 250, 250)
    Button.TextSize = 10
    Button.Font = Enum.Font.Arcade
    Button.AutoButtonColor = true
    Button.Active = true
    Button.Selectable = true
    Button.ZIndex = 10
    Button.Parent = Parent or Main

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 0.6
    Stroke.Parent = Button

    table.insert(Strokes, Stroke)

    return Button
end

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -58, 0, 24)
Title.Position = UDim2.fromOffset(8, 2)
Title.BackgroundTransparency = 1
Title.Text = "Lennon hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 11
Title.Font = Enum.Font.Arcade
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 2
Title.Parent = Main

local Minimize = CreateButton(
    "-",
    UDim2.new(1, -43, 0, 3),
    UDim2.fromOffset(17, 19)
)

local Close = CreateButton(
    "X",
    UDim2.new(1, -23, 0, 3),
    UDim2.fromOffset(17, 19)
)

local FloatingOpen = CreateButton(
    "OPEN",
    UDim2.new(0, 12, 0.5, 0),
    UDim2.fromOffset(60, 30),
    OpenGui
)

FloatingOpen.Visible = false
FloatingOpen.ZIndex = 100
FloatingOpen.Draggable = true

local function SetPanelVisible(Visible)
    ScreenGui.Enabled = true
    OpenGui.Enabled = true
    Main.Visible = Visible
    FloatingOpen.Visible = not Visible
end

local function ConnectFloatingButton(Button, Callback)
    local LastActivation = 0

    local function Activate()
        local Now = os.clock()

        if Now - LastActivation < 0.25 then
            return
        end

        LastActivation = Now
        Callback()
    end

    Button.Activated:Connect(Activate)

    Button.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.Touch
            or Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Activate()
        end
    end)

    UserInputService.InputBegan:Connect(function(Input)
        if not Button.Visible or not Button.Parent then
            return
        end

        if Input.UserInputType ~= Enum.UserInputType.Touch
            and Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        local Position = Vector2.new(Input.Position.X, Input.Position.Y)
        local ButtonPosition = Button.AbsolutePosition
        local ButtonSize = Button.AbsoluteSize

        if Position.X >= ButtonPosition.X
            and Position.X <= ButtonPosition.X + ButtonSize.X
            and Position.Y >= ButtonPosition.Y
            and Position.Y <= ButtonPosition.Y + ButtonSize.Y then
            Activate()
        end
    end)
end

ConnectFloatingButton(FloatingOpen, function()
    SetPanelVisible(true)
end)

local function GetRoot()
    local Character = Player.Character
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

local function Teleport(Position)
    local Root = GetRoot()

    if Root then
        Root.CFrame = CFrame.new(Position)
    end
end

local SurfacePosition = Vector3.new(-1, 3, 96)
local DeepPosition = Vector3.new(-70, -4723, -60)

local Surface = CreateButton("TP SURFACE", UDim2.fromOffset(8, 29))

Surface.Activated:Connect(function()
    Teleport(SurfacePosition)
end)

local Deep = CreateButton("TP DEEP", UDim2.fromOffset(8, 56))

Deep.Activated:Connect(function()
    Teleport(DeepPosition)
end)

local PromptEnabled = false
local PromptBusy = false

local PromptToggle = CreateButton(
    "INSTANT PROMPT: OFF",
    UDim2.fromOffset(8, 83)
)

local FloatingPrompt = CreateButton(
    "INSTANT",
    UDim2.new(0, 12, 0.5, 32),
    UDim2.fromOffset(86, 27),
    OpenGui
)

FloatingPrompt.Visible = false
FloatingPrompt.ZIndex = 101
FloatingPrompt.Draggable = true

local function FindClosestPrompt()
    local Root = GetRoot()

    if not Root then
        return nil
    end

    local ClosestPrompt
    local ClosestDistance = math.huge

    for _, Object in ipairs(Workspace:GetDescendants()) do
        if Object:IsA("ProximityPrompt") and Object.Enabled then
            local Parent = Object.Parent
            local Part

            if Parent:IsA("BasePart") then
                Part = Parent
            elseif Parent:IsA("Attachment") then
                Part = Parent.Parent
            end

            if Part and Part:IsA("BasePart") then
                local Distance = (Root.Position - Part.Position).Magnitude

                if Distance < ClosestDistance then
                    ClosestDistance = Distance
                    ClosestPrompt = Object
                end
            end
        end
    end

    return ClosestPrompt
end

local function ActivateInstantPrompt()
    if not PromptEnabled or PromptBusy then
        return
    end

    PromptBusy = true

    task.spawn(function()
        pcall(function()
            local Prompt = FindClosestPrompt()

            if not Prompt then
                return
            end

            if type(fireproximityprompt) ~= "function" then
                return
            end

            fireproximityprompt(Prompt, 0)
            task.wait(0.3)
            Teleport(SurfacePosition)
        end)

        PromptBusy = false
    end)
end

ConnectFloatingButton(FloatingPrompt, ActivateInstantPrompt)

PromptToggle.Activated:Connect(function()
    PromptEnabled = not PromptEnabled

    PromptToggle.Text = PromptEnabled
        and "INSTANT PROMPT: ON"
        or "INSTANT PROMPT: OFF"

    FloatingPrompt.Visible = PromptEnabled
end)

local TrainBoostEnabled = false
local TrainBoostButton = CreateButton(
    "TRAIN BOOST: OFF",
    UDim2.fromOffset(8, 110)
)

TrainBoostButton.Activated:Connect(function()
    TrainBoostEnabled = not TrainBoostEnabled

    TrainBoostButton.Text = TrainBoostEnabled
        and "TRAIN BOOST: ON"
        or "TRAIN BOOST: OFF"

    if not TrainBoostEnabled then
        return
    end

    task.spawn(function()
        while TrainBoostEnabled and ScreenGui.Parent do
            pcall(function()
                Request:InvokeServer("ClaimTrainBoost")
            end)

            task.wait(0.5)
        end

        if TrainBoostButton.Parent then
            TrainBoostButton.Text = "TRAIN BOOST: OFF"
        end
    end)
end)

local Confirm = Instance.new("Frame")
Confirm.Size = UDim2.fromScale(1, 1)
Confirm.BackgroundColor3 = Color3.fromRGB(18, 20, 23)
Confirm.BorderSizePixel = 0
Confirm.Visible = false
Confirm.ZIndex = 20
Confirm.Parent = Main

local ConfirmCorner = Instance.new("UICorner")
ConfirmCorner.CornerRadius = UDim.new(0, 6)
ConfirmCorner.Parent = Confirm

local ConfirmStroke = Instance.new("UIStroke")
ConfirmStroke.Thickness = 0.8
ConfirmStroke.Parent = Confirm
table.insert(Strokes, ConfirmStroke)

local ConfirmText = Instance.new("TextLabel")
ConfirmText.Size = UDim2.new(1, -8, 0, 30)
ConfirmText.Position = UDim2.fromOffset(4, 40)
ConfirmText.BackgroundTransparency = 1
ConfirmText.Text = "CLOSE PANEL?"
ConfirmText.TextColor3 = Color3.new(1, 1, 1)
ConfirmText.TextSize = 11
ConfirmText.Font = Enum.Font.Arcade
ConfirmText.ZIndex = 21
ConfirmText.Parent = Confirm

local Yes = CreateButton(
    "YES",
    UDim2.new(0.5, -64, 0, 88),
    UDim2.fromOffset(58, 24),
    Confirm
)
Yes.ZIndex = 22

local No = CreateButton(
    "NO",
    UDim2.new(0.5, 6, 0, 88),
    UDim2.fromOffset(58, 24),
    Confirm
)
No.ZIndex = 22

Minimize.Activated:Connect(function()
    SetPanelVisible(false)
end)

Close.Activated:Connect(function()
    Confirm.Visible = true
end)

No.Activated:Connect(function()
    Confirm.Visible = false
end)

Yes.Activated:Connect(function()
    TrainBoostEnabled = false
    PromptEnabled = false

    if ColorConnection then
        ColorConnection:Disconnect()
    end

    ScreenGui:Destroy()
    OpenGui:Destroy()
end)
