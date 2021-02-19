AddCSLuaFile()
DEFINE_BASECLASS("base_gmodentity")
ENT.Category = "Autobox"
ENT.PrintName = "ABX Bobber"
ENT.Author = "Trist"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Spawnable = false
ENT.Editable = false
ENT.DisableDuplicator = true
ENT.DoNotDuplicate = true

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Hooked")
    self:NetworkVar("Bool", 0, "Waited")
end

function ENT:Initialize()
    if (SERVER) then
        self:SetModel("models/abx/Bobber.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_NONE)
        local phys = self:GetPhysicsObject()

        if (phys:IsValid()) then
            phys:SetBuoyancyRatio(1)
            phys:Wake()
        end
    else
        self.PosePosition = 0
    end
end

function ENT:Think()
end