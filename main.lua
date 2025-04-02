--═══════ Main Codes For Avatar ═══════--
local USERNAME = "Ghost Tracker"
local AVATAR_ICON = "https://cdn.discordapp.com/attachments/905256599906558012/1356371225714102324/IMG_1773.jpg"
local FOOTER_ICON = "https://cdn.discordapp.com/attachments/905256599906558012/1356371225714102324/IMG_1773.jpg"

--═══════ Main Codes ═══════--
local Client = game:GetService('ReplicatedStorage').Library.Client
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local SaveModule = require(Client.Save)

local GEMS_ORDER = {
    "Onyx Gem",
    "Topaz Gem", 
    "Quartz Gem",
    "Rainbow Gem",
    "Amethyst Gem",
    "Emerald Gem"
}


local function getPlayerData()
    local data = SaveModule.Get()
    local playerData = {
        Gems = {},
        Diamonds = 0,
        Username = Players.LocalPlayer.Name
    }
    
    local inventory = data.Inventory or {}
    for _, category in pairs(inventory) do
        for _, item in pairs(category) do
            if table.find(GEMS_ORDER, item.id) then
                playerData.Gems[item.id] = item._am or 1
            end
        end
    end
    
    playerData.Diamonds = data.Diamonds or data.diamonds or 
                         (data.Currency and data.Currency.Diamonds) or 0
    
    return playerData
end


local function createWebhookMessage()
    local playerData = getPlayerData()
    local currentTime = os.date("%Y/%m/%d %H:%M:%S")
    
    local gemsText = ""
    for _, gemName in ipairs(GEMS_ORDER) do
        local amount = playerData.Gems[gemName] or 0
        if amount > 0 then
            gemsText = gemsText .. "> " .. gemName .. " : `" .. amount .. "` \n"
        end
    end
    
    return {
        username = USERNAME,
        avatar_url = AVATAR_ICON, 
        embeds = {{
            title = "💎 Inventory Tracker",
            description = "**Inventory Info**\n" .. gemsText,
            color = 0x3498db,
            fields = {
                {
                    name = "👤 User Info",
                    value = "> 💎 Diamond Left : `" .. playerData.Diamonds .. "` \n" ..
                            "> 🆔 Account : ||" .. playerData.Username .. "||",
                    inline = false
                }
            },
            footer = {
                text = "Ｇんｏｓｔ • Tracker | " .. currentTime,
                icon_url = FOOTER_ICON 
            },
            thumbnail = {
                url = AVATAR_ICON 
            }
        }}
    }
end


local function sendWebhook()
    local message = createWebhookMessage()
    local success, response = pcall(function()
        local requestFunc = syn and syn.request or http_request or game.HttpPostAsync
        return requestFunc({
            Url = getgenv().Config.WebhookUrl, 
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(message)
        })
    end)
    
    if success then
        print("[" .. os.date("%H:%M:%S") .. "] Successful ✅ ")
    else
        warn("[" .. os.date("%H:%M:%S") .. "] Failed ❌ :", response)
    end
end

--═══════ Auto Start ═══════--
sendWebhook()
while wait(getgenv().Config.UpdateInterval) do 
    sendWebhook()
end
