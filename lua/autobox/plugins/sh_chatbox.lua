-----
--Changes the default chat box
-----
local PLUGIN = {}
PLUGIN.title = "Chatbox"
PLUGIN.author = "Trist"
PLUGIN.souschef = "Green"
PLUGIN.souschefspeller = "Bob"
PLUGIN.meatballorganizer = "Bob"
PLUGIN.noodleboi = "Sakiren"
PLUGIN.description = "Changes the default chat box"

PLUGIN.suggestions = {}

if (CLIENT) then
    if (!autobox.OnChatText) then
        autobox.OnChatText = chat.AddText
    end
    function chat.AddText(...)
        local args = {...}
        if (type(args[1]) ==  "table" and !IsColor(args[1])) then
            table.remove(args[1])
            autobox.OnChatText(unpack(args))
        else
            autobox.OnChatText(...)
        end
    end
end

--temp evolve code
function PLUGIN:HUDPaint()
	if ( self.Chat ) then
		local x, y = chat.GetChatBoxPos()
		x = x + ScrW() * 0.03875
		y = y + ScrH() / 4 + 5

		surface.SetFont( "ChatFont" )

		for _, v in ipairs( self.suggestions ) do
			local sx, sy = surface.GetTextSize( v.command )

			draw.SimpleText( v.command, "ChatFont", x, y, Color( 0, 0, 0, 255 ) )
			draw.SimpleText( " " .. v.usage or "", "ChatFont", x + sx, y, Color( 0, 0, 0, 255 ) )
			draw.SimpleText( v.command, "ChatFont", x, y, Color( 255, 255, 100, 255 ) )
			draw.SimpleText( " " .. v.usage or "", "ChatFont", x + sx, y, Color( 255, 255, 255, 255 ) )

			y = y + sy
		end
	end
end
function PLUGIN:ChatTextChanged( str )
	if ( string.Left( str, 1 ) == "/" or string.Left( str, 1 ) == "!" or string.Left( str, 1 ) == "@" ) then
		local com = string.sub( str, 2, ( string.find( str, " " ) or ( #str + 1 ) ) - 1 )
		self.suggestions = {}

		for _, v in pairs( autobox.plugins ) do
			if ( v.command and string.sub( v.command, 0, #com ) == string.lower( com ) and #self.suggestions < 4 ) then table.insert( self.suggestions, { command = string.sub( str, 1, 1 ) .. v.command, usage = v.usage or "" } ) end
		end
		table.SortByMember( self.suggestions, "command", function( a, b ) return a < b end )
	else
		self.suggestions = {}
	end
end

function PLUGIN:OnChatTab( str )
	if ( string.match( str, "^[/!][^ ]*$" ) and #self.suggestions > 0 ) then
		return self.suggestions[1].command .. " "
	end
end
function PLUGIN:StartChat() self.Chat = true end
function PLUGIN:FinishChat() self.Chat = false end

function PLUGIN:OnPlayerChat( ply, txt, teamchat, dead )

    local tab = {}
    --rank names
    table.insert( tab, color_white )
    table.insert( tab, "(" .. autobox:GetRankInfo(ply:AAT_GetRank()).RankName .. ") " )

    if ( IsValid( ply ) ) then
        table.insert( tab, autobox:HexToColor(autobox:GetRankInfo(ply:AAT_GetRank()).Color) or team.GetColor( ply:Team() ) )
        table.insert( tab, ply:Nick())
    else
        table.insert( tab, "Console" )
    end
    
    --language code
    
    local PLA = LocalPlayer() --just to make this easier on myself
    local TAR = ply
    local TLang = autobox:DetermineLanguage(TAR) --language of the message coming in
    
    if PLA != TAR then
        if !autobox:CanUnderstand(PLA,TAR) then
            if autobox:DetermineLanguage(PLA) == "Italian" then
                txt = self:CipherText(txt,"Italian") --pasta vision
            else
                txt = self:CipherText(txt,TLang)
            end
        end
    end
    
    if TLang == "Abyssal" then table.insert(tab,autobox.colors.ascian) else table.insert(tab,color_white) end
    table.insert(tab, " [" .. TLang .. "]")

    --the final bit and message
    table.insert( tab, color_white )
    table.insert(tab, ": " .. txt)
    
    chat.AddText( unpack( tab ) )

    return true
end
function autobox:DetermineLanguage(ply)
    if (!IsValid(ply) or !ply:IsPlayer() or ply:IsBot()) then return "Common" end
    
    PL1,PL2 = self:GetLanguageCodes(ply)
    if bit.band(PL1,128) > 0 then return "Abyssal" end --10000000
    if bit.band(PL1,2) > 0 then return "Common" end --00000010
    if bit.band(PL1,1) > 0 then return "Goblin" end --00000001
    
    return "Italian" --mama mia
end
function autobox:GetLanguageCodes(ply)
    if (!IsValid(ply) or !ply:IsPlayer() or ply:IsBot()) then return 255,255 end
    
    --setting up some secret mousecatools to help us later
    local lang1 = 0 --00000000 : 1-6, special range. 7-8 normal languages
    local lang2 = 0 --00000000 : 1-8, extended languages (to come later)
    local d1 = tonumber(string.sub(ply:SteamID(),9,9)) or 0
    local d2 = tonumber(string.sub(ply:SteamID(),11,11)) or 0
    local badgeName = "linguist" --for if we change it later
    local prog = ply:AAT_GetBadgeProgress(badgeName)

    --Abyssal
    if ply:IsAdmin() then lang1 = bit.bor(lang1,128) end --10000000
    if prog > 0 then if d1 == 0 then lang1 = bit.bor(lang1,2) else lang1 = bit.bor(lang1,1) end end --00000010 common, 00000001 goblin
    if prog > 1 then if d1 == 1 then lang1 = bit.bor(lang1,2) else lang1 = bit.bor(lang1,1) end end --fancy man talking his fancy words
    
    return lang1, lang2
end
function autobox:CanUnderstand(ply,tar)
    PL1,PL2 = self:GetLanguageCodes(ply)
    TL1,TL2 = self:GetLanguageCodes(tar)
    if (PL1 == 0) or (TL1 == 0) then return false end --"the Italian clause", even admins don't wanna talk to you.
    return (bit.band(PL1,TL1) > 0) or (bit.band(PL2,TL2) > 0) or (bit.band(PL1,128) > 0) or (bit.band(TL1,128) > 0) --returns true if they understand a language "auto mode"
end
ghetti = 1
function PLUGIN:CipherText(text,lang)
    text = text:gsub("[^%a%d%p%s]","")
    local tab = string.Split(text,"")
    --a = 97
    --A = 65
    --------------------{"a","-","-","-","e","-","-","-","i","-","-","-","-","-","o","-","-","-","-","-","u","-","-","-","y","-","A","-","-","-","E","-","-","-","I","-","-","-","-","-","O","-","-","-","-","-","-","-","-","-","Y","-"}
    local normal_lang = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
    local goblin_lang = {"o","p","z","r","i","f","d","w","y","j","g","b","t","h","e","c","x","q","m","k","a","l","v","s","u","n","O","P","Z","R","I","F","D","W","Y","J","G","B","T","H","E","C","X","Q","M","K","A","L","V","S","U","N"}
    local common_lang = {"y","m","k","b","o","f","g","l","e","t","d","n","q","r","u","c","s","v","p","h","i","j","z","x","a","w","Y","M","K","B","O","F","G","L","E","T","D","N","Q","R","U","C","S","V","P","H","I","J","Z","X","A","W"}
    

    if (lang == "Italian") then
        local spag = {"p","i","z","z","a","p","a","s","t","a","s","p","a","g","h","e","t","t","i","s","t","r","o","m","b","o","l","i","m","a","m","a","m","i","a"}
        local past = tab
        for sauce,noodle in ipairs(past) do
            if noodle:match("%a") then
                local MAH = (noodle == noodle:upper())
                past[sauce] = spag[ghetti]
                if MAH then past[sauce] = past[sauce]:upper() end
                ghetti = ghetti + 1
                if ghetti > #spag then ghetti = 1 end
            end
        end
        return table.concat(past)
    end
    
    --select language
    local selected_lang = normal_lang
    if lang == "Common" then selected_lang = common_lang 
    elseif lang == "Goblin" then selected_lang = goblin_lang
    end

    --translate via mapping
    for k,t in ipairs(tab) do
        if t:match("%a") then
            if t == t:upper() then
                local n = string.byte(t) - 64 + 26
                --tab[k] = selected_lang[n]
                --lol this will really piss them off
                if (math.random(2) % 2 == 0) then tab[k] = goblin_lang[n] else tab[k] = common_lang[n] end
            else
                local n = string.byte(t) - 96
                --tab[k] = selected_lang[n]
                if (math.random(2) % 2 == 0) then tab[k] = goblin_lang[n] else tab[k] = common_lang[n] end
            end
        end
    end    
    return table.concat(tab)    
end
function PLUGIN:AAT_InitializePlayer(ply)
    local badgeName = "linguist" --just in case we decide to change this before I add the others
    local badgeStatus = ply:AAT_HasBadge(badgeName)
    if !badgeStatus then
        if tonumber(string.sub(ply:SteamID(),11,11)) != 6 then --can't let those Italians slip through and learn to talk
            ply:AAT_SetBadgeProgress(badgeName,1)
        end
    end
end

autobox:RegisterPlugin(PLUGIN)