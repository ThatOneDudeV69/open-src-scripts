--!strict

local Logger = {}
Logger.__index = Logger

local MarketplaceService = game:GetService("MarketplaceService")

local FolderName = "VectorLogs"
local FilePath: string? = nil

local function InitialiseFolder()
    if not isfolder(FolderName) then
        makefolder(FolderName)
    end
end

local function GetFilePath(): string
    if FilePath then
        return FilePath
    end

    local UnixTime = os.time()
    local GameName = "UnknownGame"

    pcall(function()
        GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)

    GameName = GameName:gsub("[^%w_%-]", "_")
    FilePath = string.format("%s/Log_%d_%s.txt", FolderName, UnixTime, GameName)
    return FilePath
end

InitialiseFolder()

function Logger.Log(...: any)
    local Count = select("#", ...)
    local Parts = table.create(Count)

    for Index = 1, Count do
        Parts[Index] = tostring(select(Index, ...))
    end

    local Line = table.concat(Parts, "\t") .. "\n"
    local Path = GetFilePath()

    if isfile(Path) then
        appendfile(Path, Line)
    else
        writefile(Path, Line)
    end
end

return Logger
