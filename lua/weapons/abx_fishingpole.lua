-----------------------------------------
--  Author Info
-----------------------------------------
SWEP.Author = "Trist Saibot"
SWEP.Category = "Autobox"
SWEP.Instructions = ""
SWEP.Spawnable = true
SWEP.ViewModel = Model("models/abx/weathered_fishing_rod.mdl")
SWEP.WorldModel = "models/abx/weathered_fishing_rod.mdl"
-----------------------------------------
--  Properties
-----------------------------------------
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Casting = false

if SERVER then
    util.AddNetworkString("t_notify_message")

    function SWEP:HandleFishing(hooked, waited, ply)
        self:GetOwner():EmitSound("abx/wow_reel.mp3", 75, math.random(90, 110))

        if (hooked) then
            if (not waited) then
                local amount = math.random(1, 9)

                if (math.random(1, 50) == 1) then
                    amount = amount + math.random(10, 25) * 10
                else
                    amount = amount + math.random(0, 5) * 10
                end
                net.Start("t_notify_message")
                net.WriteString("Caught a fish worth " .. amount .. " " .. autobox.currency:GetCurrencyName(amount > 1))
                net.Send(ply)
                --autobox:Notify(ply, autobox.colors.white, "Caught a fish worth ", autobox.colors.red, amount, autobox.colors.white, " ", autobox.currency:GetCurrencyName(amount > 1), ".")
                autobox.currency:AddCurrency(ply, amount)
            else
                net.Start("t_notify_message")
                net.WriteString("It got away...")
                net.Send(ply)
                --autobox:Notify(ply, autobox.colors.red, "It got away...")
            end
        else
            net.Start("t_notify_message")
            net.WriteString("No Bites...")
            net.Send(ply)
            --autobox:Notify(ply, autobox.colors.red, "No Bites...")
        end

        timer.Remove("trist_fishing_hook" .. self:GetOwner():SteamID())
        timer.Remove("trist_fishing_wait" .. self:GetOwner():SteamID())
    end
end

if CLIENT then
    net.Receive("t_notify_message", function()
        local msg = net.ReadString()
        notification.AddLegacy(msg, NOTIFY_GENERIC, 5)
    end)
end

if SERVER then
    function SWEP:PrimaryAttack()
        if (not self.Casting) then
            local tr = util.TraceLine({
                start = self:GetOwner():EyePos(),
                endpos = self:GetOwner():EyePos() + self:GetOwner():EyeAngles():Forward() * 10000,
                collisiongroup = COLLISION_GROUP_WORLD,
                mask = MASK_WATER
            })

            local pos

            if (tr.Hit) then
                pos = tr.HitPos
            else
                return
            end

            self:SetHoldType("melee")

            timer.Simple(.1, function()
                self:SetHoldType("pistol")
            end)

            timer.Simple(.2, function()
                if (IsValid(self.Bobber)) then
                    self.Bobber:Remove()
                end

                self.Bobber = ents.Create("abx_bobber")
                self.Bobber:SetOwner(self:GetOwner())
                self.Bobber:SetPos(pos)
                self.Bobber:Spawn()

                if SERVER then
                    timer.Create("trist_fishing_hook" .. self:GetOwner():SteamID(), math.random(3, 10), 1, function()
                        if (self.Bobber:IsValid()) then
                            local ed = EffectData()
                            ed:SetOrigin(pos)
                            util.Effect("watersplash", ed)
                            self.Bobber:SetNWBool("Hooked", true)

                            timer.Create("trist_fishing_wait" .. self:GetOwner():SteamID(), math.random(3, 5), 1, function()
                                self.Bobber:SetNWBool("Waited", true)
                            end)
                        end
                    end)
                end

                local ed = EffectData()
                ed:SetOrigin(pos)
                util.Effect("watersplash", ed)
                self:EmitSound("abx/oot_sword_overhead.mp3", 75, math.random(90, 110))
                self:SetNWEntity("bobber",self.Bobber)
                --self.Owner:SetNWEntity("trist_bobber", self.Bobber)
                local phys = self.Bobber:GetPhysicsObject()

                if (not IsValid(phys)) then
                    self.Bobber:Remove()

                    return
                end

                local vel = self.Owner:GetAimVector()
                vel = vel * 10000
                phys:ApplyForceCenter(vel)
                self.Casting = true
            end)
        else
            if (IsValid(self.Bobber)) then
                self:HandleFishing(self.Bobber:GetNWBool("Hooked", false), self.Bobber:GetNWBool("Waited", false), self:GetOwner())
                self.Bobber:Remove()
            end

            self:SetHoldType("melee")

            timer.Simple(.2, function()
                self:SetHoldType("pistol")
            end)

            self.Casting = false
        end
    end
end

if CLIENT then
    function SWEP:PrimaryAttack()
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
end

function SWEP:Holster()
    if SERVER then
        if (IsValid(self.FishingPole)) then
            self.FishingPole:Remove()
        end

        if (IsValid(self.Bobber)) then
            self.Bobber:Remove()
        end

        return true
    else
        timer.Remove("trist_fishing_hook" .. self:GetOwner():SteamID())
        timer.Remove("trist_fishing_wait" .. self:GetOwner():SteamID())
        --hook.Remove("CalcView", "Trist_FishingRod_ViewSwap")
    end
end

function SWEP:SetupDataTables()
    --self:NetworkVar("Bool", 0, "Equipped")
    self:NetworkVar("Entity", nil, "bobber")
end

if CLIENT then
    SWEP.PrintName = "Fishing Pole"
    SWEP.Slot = 1
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
else
    AddCSLuaFile()
    SWEP.Weight = 5
    SWEP.AutoSwitchTo = false
    SWEP.AutoSwitchFrom = false

    function SWEP:Initialize()
        self:SetHoldType("pistol")
    end

    function SWEP:Think()
    end

    function SWEP:OnRemove()
    end

    function SWEP:OwnerChanged()
    end

    function SWEP:OnDrop()
    end
end

if CLIENT then
    local rope = Material("cable/rope")

    local function drawLine(pos1, pos2)
        local segs = 10
        render.StartBeam(segs + 2)
        render.AddBeam(pos1, 0.5, 0, color_white) --start

        for i = 1, segs do
            local dir = pos2 - pos1 --direction vector between the two points
            --local d3 = dir[3] --distance top to bottom
            dir = dir * i / segs --choose distance from start
            dir[3] = dir[3] + i ^ 2 - (segs * i) --adjust it down a little in a curved way
            render.AddBeam(pos1 + dir, 0.5, 0, color_white) --segment
        end

        render.AddBeam(pos2, 0.5, 0, color_white) --end
        render.EndBeam()
    end

    hook.Add("PostDrawTranslucentRenderables", "Draw_Fishing_Lines", function(_isDepth, _isSkybox)
        if _isSkybox then return end

        for _, ply in pairs(player.GetAll()) do
            local wep = ply:GetActiveWeapon()
            if (not wep:IsValid()) then continue end
            if (wep:GetClass() != "abx_fishingpole") then continue end
            if (wep:GetNWEntity("bobber"):IsValid()) then
                render.SetMaterial(rope)
                pos1 = wep:GetAttachment(1).Pos
                pos2 = wep:GetNWEntity("bobber"):GetPos()
                drawLine(pos1, pos2)
            end

            --[[
            if (wep:GetClass() == "abx_fishingpole" and IsValid(ply:GetNWEntity("trist_bobber"))) then
                render.SetMaterial(rope)
                pos1 = wep:GetAttachment(1).Pos
                pos2 = ply:GetNWEntity("trist_bobber"):GetPos()
                drawLine(pos1, pos2)
            end
            ]]--
        end
    end)

    hook.Add("CalcView", "Trist_FishingRod_ViewSwap", function(ply, pos, angles, fov)
        local wep = ply:GetActiveWeapon()

        if (wep:IsValid() and wep:GetClass() == "abx_fishingpole") then
            local view = {}
            view.origin = pos - (angles:Forward() * 120)
            view.angles = angles
            view.fov = fov
            view.drawviewer = true

            return view
        end
    end)
end