-----
--All of the currency commands
-----
local PLUGIN = {}
PLUGIN.title = "Scratch"
PLUGIN.author = "Trist"
PLUGIN.description = "Scratch tickets for autobux"
PLUGIN.command = "scratch"
PLUGIN.usage = ""

autobox.currency.scratch_cooldown = {}

function PLUGIN:Call(ply,args)
    local cooldown = 900 --15 minutes
    if (autobox.currency.scratch_cooldown[ply] and autobox.currency.scratch_cooldown[ply] > CurTime()) then
        autobox:Notify(ply,autobox.colors.white,"Please wait ",autobox.colors.red,autobox:FormatTime(autobox.currency.scratch_cooldown[ply] - CurTime()),autobox.colors.white," and try again later.")
    else
        local amount = 0
        if (math.random(1,5) == 1) then
            amount = math.random(1,10) * 20
        else
            amount = math.random(1,5) * 10
        end
        autobox:Notify(ply,autobox.colors.white,"You won ",autobox.colors.red,amount,autobox.colors.white," ",autobox.currency:GetCurrencyName(amount > 1),".")
        autobox.currency:AddCurrency(ply,amount)
        autobox.currency.scratch_cooldown[ply] = CurTime() + cooldown
    end
end

autobox:RegisterPlugin(PLUGIN)