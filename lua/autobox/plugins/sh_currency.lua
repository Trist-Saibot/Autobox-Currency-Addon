-----
--All of the currency commands
-----
local PLUGIN = {}
PLUGIN.title = "Add Currency"
PLUGIN.author = "Trist"
PLUGIN.description = "Add currency to player's account"
PLUGIN.perm = "Currency Modification"
PLUGIN.command = "addcurrency"
PLUGIN.usage = "<player> <amount>"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({args[1]})
    if (!autobox:ValidateSingleTarget(ply,players)) then return end

    local amount = tonumber(args[#args]) or 0
    if (amount < 1) then return end

    autobox.currency:AddCurrency(players[1],amount)
    autobox:Notify(ply,autobox.colors.blue,players[1]:Nick(),autobox.colors.white," given ",autobox.colors.red,amount,autobox.colors.white," ",autobox.currency:GetCurrencyName(amount != 1),".")

end

autobox:RegisterPlugin(PLUGIN)

PLUGIN = {}
PLUGIN.title = "Remove Currency"
PLUGIN.author = "Trist"
PLUGIN.description = "Remove currency from player's account"
PLUGIN.perm = "Currency Modification"
PLUGIN.command = "removecurrency"
PLUGIN.usage = "<player> <amount>"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({args[1]})
    if (!autobox:ValidateSingleTarget(ply,players)) then return end

    local amount = tonumber(args[#args]) or 0
    if (amount < 1) then return end

    autobox.currency:RemoveCurrency(players[1],amount)
    autobox:Notify(ply,autobox.colors.blue,players[1]:Nick(),autobox.colors.white," lost ",autobox.colors.red,amount,autobox.colors.white," ",autobox.currency:GetCurrencyName(amount != 1),".")

end

autobox:RegisterPlugin(PLUGIN)

PLUGIN = {}
PLUGIN.title = "Set Currency"
PLUGIN.author = "Trist"
PLUGIN.description = "Set currency of player's account"
PLUGIN.perm = "Currency Modification"
PLUGIN.command = "setcurrency"
PLUGIN.usage = "<player> <amount>"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({args[1]})
    if (!autobox:ValidateSingleTarget(ply,players)) then return end

    local amount = tonumber(args[#args]) or 0
    if (amount < 0) then return end

    autobox.currency:SetCurrency(players[1],amount)
    autobox:Notify(ply,autobox.colors.blue,players[1]:Nick(),autobox.colors.white," set to ",autobox.colors.red,amount,autobox.colors.white," ",autobox.currency:GetCurrencyName(amount != 1),".")

end

autobox:RegisterPlugin(PLUGIN)

PLUGIN = {}
PLUGIN.title = "Get Balance"
PLUGIN.author = "Trist"
PLUGIN.description = "Get balance of player's account"
PLUGIN.command = "bal"
PLUGIN.usage = "<player>"

function PLUGIN:Call(ply,args)
    local players = autobox:FindPlayers({args[1],ply})
    if (!autobox:ValidateSingleTarget(ply,players)) then return end

    local data = autobox.currency:GetCurrencyInfo(players[1])
    local bal = 0
    if (data) then bal = data.Currency end

    autobox:Notify(ply,autobox.colors.blue,players[1]:Nick(),"'s",autobox.colors.white," balance is currently ",autobox.colors.red,bal,autobox.colors.white," ",autobox.currency:GetCurrencyName(amount != 1),".")

end

autobox:RegisterPlugin(PLUGIN)