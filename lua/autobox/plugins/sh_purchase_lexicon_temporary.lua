-----
--Purchase a lexicon to understand Goblin / Common
-----
local PLUGIN = {}
PLUGIN.title = "Purchase"
PLUGIN.author = "Trist"
PLUGIN.description = "Purchase a lexicon to understand Goblin / Common"
PLUGIN.command = "purchase"
PLUGIN.usage = ""

autobox.currency.scratch_cooldown = {}

function PLUGIN:Call(ply,args)
    local data = autobox.currency:GetCurrencyInfo(ply) --THIS WILL CHANGE LATER
    local autobux = 0
    if data and data.Currency then autobux = data.Currency end
    local badgeName = "linguist" --just in case we decide to change this before I add the others
    local badgeStatus = ply:AAT_HasMaxBadge(badgeName)
    local prog = ply:AAT_GetBadgeProgress(badgeName)
    local price = 10000 --should be a good price to start
    if prog == 0 then price = math.Round(price * 2.25) end --Italian tax

    if badgeStatus then
        autobox:Notify(ply,autobox.colors.red,"You already posess all current lexicons.")
    else
        if autobux < price then
            autobox:Notify(ply,autobox.colors.red,"You do not have enough " .. autobox.currency:GetCurrencyName(true) .. " to purchase this lexicon. You need " .. price .. " for your next issue.")
        else
            autobox.currency:RemoveCurrency(ply,price)
            ply:AAT_AddBadgeProgress(badgeName,1)
            autobox:Notify(ply,autobox.colors.red,"Thank you for your purchase!")
        end
    end
    
end

autobox:RegisterPlugin(PLUGIN)