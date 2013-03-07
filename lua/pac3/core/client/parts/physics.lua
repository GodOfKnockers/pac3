local PART = {}

PART.ThinkTime = 0
PART.ClassName = "physics"
PART.NonPhysical = true

pac.StartStorableVars()	
	pac.GetSet(PART, "Box", true)
	pac.GetSet(PART, "Radius", 1)

	pac.GetSet(PART, "FollowPos", false)
	
	pac.GetSet(PART, "SecondsToArrive", 0.1)
	
	pac.GetSet(PART, "MaxSpeed", 10000)
	pac.GetSet(PART, "MaxAngular", 3600)
	
	pac.GetSet(PART, "MaxSpeedDamp", 1000)
	pac.GetSet(PART, "MaxAngularDamp", 1000)
	pac.GetSet(PART, "DampFactor", 1)
	
	pac.GetSet(PART, "TeleportDistance", 0)
pac.EndStorableVars()

PART.phys = NULL

function PART:SetBox(b)
	self.Box = b
	self:SetRadius(self.Radius)
end

function PART:SetRadius(n)
	self.Radius = n	
	
	if self.Parent.ClassName ~= "model" then return end
	
	local ent = self.Parent:GetEntity()
	
	if n <= 0 then n = ent:BoundingRadius()/2 end
	
	ent:SetNoDraw(false)
	
	if self.Box then 
		ent:PhysicsInitBox(Vector(1,1,1) * -n, Vector(1,1,1) * n) 
	else
		ent:PhysicsInitSphere(n)
	end
	
	self.phys = ent:GetPhysicsObject()
end

local params = {}

function PART:OnThink()

	local phys = self.phys
	
	if phys:IsValid() then
		phys:Wake()

		if not self.FollowPos then return end

		params.pos = self.Parent.cached_pos
		params.angle  = self.Parent.cached_ang
		
		params.secondstoarrive = self.SecondsToArrive
		params.maxangular = self.MaxAngular
		params.maxangulardamp = self.MaxAngularDamp
		params.maxspeed = self.MaxSpeed
		params.maxspeeddamp = self.MaxSpeedDamp
		params.dampfactor = self.DampFactor
		
		params.teleportdistance = 0
				
		-- this is nicer i think
		if self.TeleportDistance ~= 0 and phys:GetPos():Distance(self.Parent.cached_pos) > self.TeleportDistance then
			phys:SetPos(self.Parent.cached_pos + (self.Parent.cached_pos - phys:GetPos()):GetNormalized() * -self.TeleportDistance)
		end
		
		phys:ComputeShadowControl(params)
	end
end

function PART:OnParent(part)
	timer.Simple(0, function() self:OnShow() end)
end

function PART:OnUnParent(part)
	timer.Simple(0, function() self:OnHide() end)
end

function PART:OnShow()
	local part = self:GetParent()
	if part.ClassName ~= "model" then return end
	
	part.skip_orient = true

	local ent = part:GetEntity()
	ent:SetNoDraw(false)
	
	self:SetRadius(self.Radius)

	for key, val in pairs(self.StorableVars) do
		if self.BaseClass.StorableVars[key] then continue end
		self["Set" .. key](self, self[key])
	end
end

function PART:OnHide()
	local part = self:GetParent()
	if part.ClassName ~= "model" then return end
		
	local ent = part:GetEntity()
	ent:SetNoDraw(true)
	ent:PhysicsInit(SOLID_NONE)
	part.skip_orient = false
end

function PART:SetPositionDamping(num)
	self.PositionDamping = num
	
	if self.phys:IsValid() then
		self.phys:SetDamping(self.PositionDamping, self.AngleDamping)
	end
end

function PART:SetAngleDamping(num)
	self.AngleDamping = num
	
	if self.phys:IsValid() then
		self.phys:SetDamping(self.PositionDamping, self.AngleDamping)
	end
end

pac.RegisterPart(PART)