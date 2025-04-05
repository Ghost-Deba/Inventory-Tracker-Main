local Client = game:GetService('ReplicatedStorage').Library.Client
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local SaveModule = require(Client.Save)

--═══════ Webhook Settings ═══════--
local CUSTOM_USERNAME = "Tracker"
local CUSTOM_AVATAR = "https://cdn.discordapp.com/attachments/905256599906558012/1356371225714102324/IMG_1773.jpg?ex=67ee4ce4&is=67ecfb64&hm=762cc5bd771fc9dffc9f286792a40d86f28c00c358f398f9bc81f06d337c9dc5&"
local FOOTER_ICON = "https://cdn.discordapp.com/attachments/905256599906558012/1356371225714102324/IMG_1773.jpg?ex=67ee4ce4&is=67ecfb64&hm=762cc5bd771fc9dffc9f286792a40d86f28c00c358f398f9bc81f06d337c9dc5&"

--═══════ Gem Order ═══════--
local GEMS_ORDER = {
    "Onyx Gem",
    "Topaz Gem",
    "Quartz Gem",
    "Rainbow Gem",
    "Amethyst Gem",
    "Emerald Gem"
}

--═══════ Data Display ═══════--
local function getPlayerData()
    local data = SaveModule.Get()
    return {
        Gems = {
            ["Onyx Gem"] = 0,
            ["Topaz Gem"] = 0,
            ["Quartz Gem"] = 0,
            ["Rainbow Gem"] = 0,
            ["Amethyst Gem"] = 0,
            ["Emerald Gem"] = 0
        },
        Diamonds = data.Diamonds or data.diamonds or data.Currency.Diamonds or 0,
        Username = Players.LocalPlayer.Name
    }
end

local function updateInventory(playerData)
    local inventory = SaveModule.Get().Inventory or {}
    for _, category in pairs(inventory) do
        for _, item in pairs(category) do
            if playerData.Gems[item.id] ~= nil then
                playerData.Gems[item.id] = item._am or 1
            end
        end
    end
end

--═══════ Webhook Create ═══════--
local function createWebhookMessage()
    local playerData = getPlayerData()
    updateInventory(playerData)
    local currentTime = os.date("%Y/%m/%d %H:%M:%S")
    
    local gemsText = ""
    for _, gemName in ipairs(GEMS_ORDER) do
        gemsText = gemsText .. "> " .. gemName .. " : `" .. playerData.Gems[gemName] .. "` \n"
    end
    
    return {
        username = CUSTOM_USERNAME,
        avatar_url = CUSTOM_AVATAR,
        embeds = {{
            title = "🎒 Inventory Tracker",
            description = "** 🛠️ Inventory Info :**\n" .. gemsText,
            color = 0x3498db,
            fields = {
                {
                    name = "👤 User Info :",
                    value = "> 💎 Diamond Left : `" .. playerData.Diamonds .. "` \n" ..
                            "> 🆔 Account : ||" .. playerData.Username .. "||",
                    inline = false
                }
            },
            footer = {
                text = "Ｇんｏｓｔ • Tracker",
                icon_url = FOOTER_ICON
            },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
end

--═══════ Webhook Send ═══════--
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
        print("[" .. os.date("%H:%M:%S") .. "] Send Done :white_check_mark:")
    else
        warn("[" .. os.date("%H:%M:%S") .. "] Send False :x::", response)
    end
end

--═══════ Auto Send ═══════--
while wait(getgenv().Config.UpdateInterval) do
    sendWebhook()
end
