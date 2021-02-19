autobox.currency = autobox.currency or {}

if SERVER then --this is all serverside, no client currency storage
    ---SQL Section
    hook.Add("AAT_SetupSQLTables","AAT_Currency_Table",function()
        if (!sql.TableExists("AAT_Currency")) then
            sql.Query("CREATE TABLE AAT_Currency(`SteamID` TEXT,`Currency` INTEGER DEFAULT 0,CONSTRAINT `PK_Currency` PRIMARY KEY (`SteamID`))")
        end
    end)
    function autobox.currency:SQL_GetCurrencyInfo(steamID)
        if (type(steamID) == "string" and string.match(steamID,"STEAM_[0-5]:[0-9]:[0-9]+")) then
            local data = sql.QueryRow("SELECT * FROM AAT_Currency WHERE SteamID = " .. sql.SQLStr(steamID),1)
            if (data) then
                data.Currency = tonumber(data.Currency)
            end
            return data
        end
        return nil
    end
    function autobox.currency:SQL_SetCurrency(steamID,number)
        if (type(steamID) == "string" and string.match(steamID,"STEAM_[0-5]:[0-9]:[0-9]+") and tonumber(number)) then
            if (tonumber(number) < 0) then
                error("Invalid Number : " .. number)
            elseif (tonumber(number) == 0) then
                self:SQL_RemoveCurrencyEntry(steamID)
            else
                if (!self:SQL_GetCurrencyInfo(steamID)) then
                    self:SQL_CreateEntry(steamID)
                end
                sql.Query("UPDATE AAT_Currency SET " ..
                    "Currency = " .. tonumber(number) .. " " ..
                    "WHERE SteamID = " .. sql.SQLStr(steamID)
                )
            end
        end
        --set the value in the currency info to whatever we pass in
        --check for negative numbers, throw error
        --if number is 0, remove from table
        --only whole integers
    end
    function autobox.currency:SQL_RemoveCurrencyEntry(steamID)
        if (type(steamID) == "string" and string.match(steamID,"STEAM_[0-5]:[0-9]:[0-9]+")) then
            return sql.Query("DELETE FROM AAT_Currency WHERE SteamID = " .. sql.SQLStr(steamID))
        end
    end
    function autobox.currency:SQL_CreateEntry(steamID)
        if (type(steamID) == "string" and string.match(steamID,"STEAM_[0-5]:[0-9]:[0-9]+")) then
            sql.Query("INSERT INTO AAT_Currency(SteamID,Currency)" ..
            " VALUES(" ..
            sql.SQLStr(steamID) .. ",0)"
            )
        end
    end
    function autobox.currency:SQL_AddCurrency(steamID,number)
        if (type(steamID) == "string" and string.match(steamID,"STEAM_[0-5]:[0-9]:[0-9]+") and tonumber(number)) then
            number = math.floor(tonumber(number))
            if (number < 1) then error("Invalid Number : " .. number) end

            local data = self:SQL_GetCurrencyInfo(steamID)
            if (!data) then
                self:SQL_CreateEntry(steamID)
                data = self:SQL_GetCurrencyInfo(steamID)
            end

            self:SQL_SetCurrency(steamID,data.Currency + number)
        end
        --add the value to the currency info
        --if < 1, do nothing, throw error
        --only whole integers
    end
    function autobox.currency:SQL_RemoveCurrency(steamID,number)
        if (type(steamID) == "string" and string.match(steamID,"STEAM_[0-5]:[0-9]:[0-9]+") and tonumber(number)) then
            number = math.floor(tonumber(number))
            if (number < 1) then error("Invalid Number : " .. number) end

            local data = self:SQL_GetCurrencyInfo(steamID)
            if (!data) then return end
            if (number >= data.Currency) then self:SQL_RemoveCurrencyEntry(steamID) return end

            self:SQL_SetCurrency(steamID,data.Currency - number)
        end

        --subtract value from currency info
        --if value > value available, remove their entry in our table
        --if < 1, do nothing, throw error
    end

    -- Error Catching
    local function VerifyPlayer(ply)
        if (!ply:IsValid() or !ply:IsPlayer() or ply:IsBot()) then error("Invalid Player") end
        return true
    end

    --- Logic Section
    function autobox.currency:AddCurrency(ply,number)
        if (!VerifyPlayer(ply) or !tonumber(number)) then error("Invalid Inputs") end
        number = math.floor(tonumber(number)) --make sure it's an integer
        if (number < 1) then error("Invalid Number : " .. number) end
        self:SQL_AddCurrency(ply:SteamID(),number) --call the SQL function with (hopefully) valid information
    end
    function autobox.currency:RemoveCurrency(ply,number)
        if (!VerifyPlayer(ply) or !tonumber(number)) then error("Invalid Inputs") end
        number = math.floor(tonumber(number)) --make sure it's an integer
        if (number < 1) then error("Invalid Number : " .. number) end
        self:SQL_RemoveCurrency(ply:SteamID(),number) --call the SQL function with (hopefully) valid information
    end
    function autobox.currency:SetCurrency(ply,number)
        if (!VerifyPlayer(ply) or !tonumber(number)) then error("Invalid Inputs") end
        number = math.floor(tonumber(number)) --make sure it's an integer
        if (number < 0) then error("Invalid Number : " .. number) end
        self:SQL_SetCurrency(ply:SteamID(),number) --call the SQL function with (hopefully) valid information
    end
    function autobox.currency:GetCurrencyInfo(ply)
        if (!VerifyPlayer(ply)) then error("Invalid Player") end
        return self:SQL_GetCurrencyInfo(ply:SteamID())
    end

    --General Plugin Functions
    function autobox.currency:TransferCurrency(sender,target,number)
        --Error Checking
        if (!VerifyPlayer(sender) or !VerifyPlayer(target) or !tonumber(number)) then error("Invalid Inputs") end
        number = math.floor(tonumber(number))
        if (number < 1) then error("Invalid Number : " .. number) end
        --Logic
        local data = self:GetCurrencyInfo(sender)
        if (!data or data.Currency < number) then error("Invalid Funds") end

        self:RemoveCurrency(sender,number)
        self:AddCurrency(target,number)
    end
    function autobox.currency:GetCurrencyName(plural)
        --TODO: Read from file
        CurrencyNames  = {"Autobux","Gold","Walnut","Rupee","Shekel","Penny","Gil","Credit","Glimmer","Septim","Mon","Crown","Bell","Lion","Yen","Argentine Peso","Woolong","Col","Dollar"}
        CurrencyNamesP = {"Autobux","Gold","Walnuts","Rupees","Shekels","Pennies","Gil","Credits","Glimmer","Septims","Mons","Crowns","Bells","Lions","Yen","Argentine Pesos","Woolongs","Col","Dollars"}

        if (plural) then
            val,key = table.Random(CurrencyNamesP)
            return val
        else
            val,key = table.Random(CurrencyNames)
            return val
        end
    end
    --Transaction Verification

    autobox.currency.transactions = autobox.currency.transactions or {} --Table of currently unverified transactions
    util.AddNetworkString("AAT_Process_Transaction")

    function autobox.currency:RequestTransaction(target,sender,number) --target is the player getting the money, sender is the one the request is sent to
        if ( target == sender ) then error("Cannot process transaction from self to self") end
        if (!VerifyPlayer(sender) or !VerifyPlayer(target) or !tonumber(number)) then error("Invalid inputs") end
        number = math.floor(tonumber(number))
        if (number < 1) then error("Invalid Number : " .. number) end
        local data = self:GetCurrencyInfo(sender)

        if (!data or data.Currency < number) then error("Invalid Funds") end

        local t = {}
        t.sender = sender
        t.target = target
        t.number = number
        t.answer = nil
        local index = table.insert(self.transactions,t)

        net.Start("AAT_Process_Transaction")
            net.WriteInt(index,32)
            net.WriteEntity(target)
            net.WriteInt(number,32)
            net.WriteString(self:GetCurrencyName(number > 1))
        net.Send(sender)

        return index
    end

    function autobox.currency:GetTransactionStatus(index)
        if (!self.transactions[index]) then return -1 end --invalid
        if (self.transactions[index].answer == nil) then return 0 end --nil
        if (self.transactions[index].answer == true) then return 1 end --true
        if (self.transactions[index].answer == false) then return 2 end --false
    end

    net.Receive("AAT_Process_Transaction",function(len,sender)
        local index = net.ReadInt(32)
        local answer = net.ReadBool()
        if (autobox.currency.transactions[index] ) then
            local t = autobox.currency.transactions[index]
            if (t.sender != sender) then error("Confirmation Mismatch") end
            t.answer = answer
            if (answer) then
                autobox.currency:TransferCurrency(t.sender,t.target,t.number)
            end
            hook.Run("AAT_ConfirmTransaction",index,answer)
        end
    end)
end

if CLIENT then
    net.Receive("AAT_Process_Transaction",function()
        local index = net.ReadInt(32)
        local target = net.ReadEntity()
        local number = net.ReadInt(32)
        local name = net.ReadString()
        Derma_Query(
            "Do you want to send " .. target:Nick() .. " " .. number .. " " .. name .. "?",
            "Confirm Transaction",
            "Yes",
            function()
                net.Start("AAT_Process_Transaction")
                    net.WriteInt(index,32)
                    net.WriteBool(true)
                net.SendToServer()
            end,
            "No",
            function()
                net.Start("AAT_Process_Transaction")
                    net.WriteInt(index,32)
                    net.WriteBool(true)
                net.SendToServer()
            end
        )
    end)
end