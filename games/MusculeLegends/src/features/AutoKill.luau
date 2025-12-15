--!strict

local Logger = require("../shared/Logger")

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

local AutoKillRunning = false
local KillSelectedOnly = false
local IgnoreFriends = false

local ServerHopEnabled = false
local ServerHopDelay = 60
local UsePlayerLimits = false
local MinPlayers = 1
local MaxPlayers = 20

local Whitelist = {}
local Targets = {}
local PlayerNames = {}

local Cursor = ""

local function RefreshPlayerNames()
    table.clear(PlayerNames)
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            PlayerNames[#PlayerNames + 1] = Player.Name
        end
    end
end

local function IsFriend(Player)
    if not IgnoreFriends then
        return false
    end
    local Success, Result = pcall(function()
        return LocalPlayer:IsFriendsWith(Player.UserId)
    end)
    return Success and Result
end

local function IsWhitelisted(Name)
    return Whitelist[Name] == true
end

local function IsTargetAllowed(Name)
    if not KillSelectedOnly then
        return true
    end
    return Targets[Name] == true
end

local function AutoKill(TargetPlayer)
    local Character = LocalPlayer.Character
    if not Character then return end

    local RightHand = Character:FindFirstChild("RightHand")
    local LeftHand = Character:FindFirstChild("LeftHand")

    if not RightHand or not LeftHand then return end

    local Tool = LocalPlayer.Backpack:FindFirstChild("Punch")
    if Tool then
        Tool.Parent = Character
    end

    local TargetCharacter = TargetPlayer.Character
    if not TargetCharacter then return end

    local TargetRoot = TargetCharacter:FindFirstChild("HumanoidRootPart")
    if not TargetRoot then return end

    local Original = TargetRoot.CFrame

    for _, Part in ipairs(TargetCharacter:GetChildren()) do
        if Part:IsA("BasePart") then
            Part.Transparency = 1
        end
    end

    TargetRoot.CFrame = RightHand.CFrame
    task.wait()
    TargetRoot.CFrame = LeftHand.CFrame

    LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
    LocalPlayer.muscleEvent:FireServer("punch", "leftHand")

    TargetRoot.CFrame = Original

    for _, Part in ipairs(TargetCharacter:GetChildren()) do
        if Part:IsA("BasePart") then
            Part.Transparency = 0
        end
    end
end

local function AutoKillLoop()
    while AutoKillRunning do
        for _, Player in ipairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer
                and not IsWhitelisted(Player.Name)
                and not IsFriend(Player)
                and IsTargetAllowed(Player.Name)
            then
                AutoKill(Player)
            end
        end
        task.wait()
    end
end

local function FetchServers(CursorValue)
    local Url =
        "https://games.roblox.com/v1/games/"
        .. PlaceId
        .. "/servers/Public?sortOrder=Asc&limit=100"

    if CursorValue ~= "" then
        Url ..= "&cursor=" .. CursorValue
    end

    local Response = request({ Url = Url, Method = "GET" })
    if Response and Response.Success then
        return HttpService:JSONDecode(Response.Body)
    end
end

local function ServerHop()
    while ServerHopEnabled do
        local Data = FetchServers(Cursor)
        if Data and Data.data then
            for _, Server in ipairs(Data.data) do
                local Count = Server.playing
                local Max = Server.maxPlayers

                local Valid = true
                if UsePlayerLimits then
                    Valid = Count >= MinPlayers and Count <= MaxPlayers
                end

                if Valid and Count < Max then
                    TeleportService:TeleportToPlaceInstance(
                        PlaceId,
                        Server.id,
                        LocalPlayer
                    )
                    return
                end
            end
            Cursor = Data.nextPageCursor or ""
        end
        task.wait(0.5)
    end
end

local function StartServerHopTimer()
    task.spawn(function()
        while ServerHopEnabled do
            task.wait(ServerHopDelay)
            if ServerHopEnabled then
                ServerHop()
            end
        end
    end)
end

return function(Window, Options)
    local StartTime = os.clock()

    local Tab = Window:AddTab({ Title = "Killer", Icon = "skull" })

    RefreshPlayerNames()

    local WhitelistDropdown = Tab:CreateDropdown("KillWhitelist", {
        Title = "Whitelist",
        Values = PlayerNames,
        Multi = true
    })

    WhitelistDropdown:OnChanged(function(Value)
        table.clear(Whitelist)
        for Name, State in next, Value do
            if State then
                Whitelist[Name] = true
            end
        end
    end)

    local TargetDropdown = Tab:CreateDropdown("KillTargets", {
        Title = "Targets",
        Values = PlayerNames,
        Multi = true
    })

    TargetDropdown:OnChanged(function(Value)
        table.clear(Targets)
        for Name, State in next, Value do
            if State then
                Targets[Name] = true
            end
        end
    end)

    Tab:AddToggle("KillSelectedOnly", {
        Title = "Kill Selected Only",
        Default = false
    }):OnChanged(function(State)
        Options.KillSelectedOnly = State
        KillSelectedOnly = State
    end)

    Tab:AddToggle("IgnoreFriends", {
        Title = "Ignore Friends",
        Default = true
    }):OnChanged(function(State)
        Options.IgnoreFriends = State
        IgnoreFriends = State
    end)

    Tab:AddToggle("AutoKill", {
        Title = "Auto Kill",
        Default = false
    }):OnChanged(function(State)
        Options.AutoKill = State
        AutoKillRunning = State
        if State then
            task.spawn(AutoKillLoop)
        end
    end)

    Tab:AddInput("ServerHopDelay", {
        Title = "Server Hop Delay (sec)",
        Default = 60,
        Numeric = true,
        Finished = true
    }):OnChanged(function(Value)
        Options.ServerHopDelay = tonumber(Value) or ServerHopDelay
        ServerHopDelay = Options.ServerHopDelay
    end)

    Tab:AddToggle("EnableServerHop", {
        Title = "Enable Server Hop",
        Default = false
    }):OnChanged(function(State)
        Options.EnableServerHop = State
        ServerHopEnabled = State
        if State then
            StartServerHopTimer()
        end
    end)

    Tab:AddToggle("UsePlayerLimits", {
        Title = "Use Player Limits",
        Default = false
    }):OnChanged(function(State)
        Options.UsePlayerLimits = State
        UsePlayerLimits = State
    end)

    Tab:AddSlider("MinPlayers", {
        Title = "Min Players",
        Min = 1,
        Max = 20,
        Default = 1
    }):OnChanged(function(Value)
        Options.MinPlayers = Value
        MinPlayers = Value
    end)

    Tab:AddSlider("MaxPlayers", {
        Title = "Max Players",
        Min = 1,
        Max = 20,
        Default = 20
    }):OnChanged(function(Value)
        Options.MaxPlayers = Value
        MaxPlayers = Value
    end)

    Players.PlayerAdded:Connect(function()
        RefreshPlayerNames()
        WhitelistDropdown:SetValues(PlayerNames)
        TargetDropdown:SetValues(PlayerNames)
    end)

    Players.PlayerRemoving:Connect(function(Player)
        Whitelist[Player.Name] = nil
        Targets[Player.Name] = nil
        RefreshPlayerNames()
        WhitelistDropdown:SetValues(PlayerNames)
        TargetDropdown:SetValues(PlayerNames)
    end)

    Logger.Log(("Killer initialized in %.3fs"):format(os.clock() - StartTime))
end
