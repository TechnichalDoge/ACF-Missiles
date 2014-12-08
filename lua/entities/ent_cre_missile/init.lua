AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


DEFINE_BASECLASS("acf_grenade")


if SERVER then
	concommand.Add("makeMissile", function(ply, args)
		local missile = ents.Create("ent_cre_missile")
		missile:SetPos(ply:GetShootPos() + ply:GetAimVector() * 16)
		missile:SetAngles(ply:GetAimVector():Angle())
		missile.Owner = ply
		
		local BulletData = {}
		BulletData["Colour"]		= Color(255, 255, 255)
		BulletData["Data10"]		= "0.00"
		BulletData["Data5"]		= "301.94"
		BulletData["Data6"]		= "30.000000"
		BulletData["Data7"]		= "0"
		BulletData["Data8"]		= "0"
		BulletData["Data9"]		= "0"
		BulletData["Id"]		= "80mmM"
		BulletData["ProjLength"]		= "12.00"
		BulletData["PropLength"]		= "0.01"
		BulletData["Type"]		= "HE"
		BulletData.IsShortForm = true
		
		missile:SetBulletData(BulletData)
		missile:SetGuidance(ACF.Guidance.Radar())
		
		missile:Spawn()
	end)
end


function ENT:Initialize()

	self.BaseClass.Initialize(self)

	if !IsValid(self.Entity.Owner) then
		self.Owner = player.GetAll()[1]
		--self:Remove()
	end

	self.Entity:SetOwner(self.Entity.Owner)
	self.Entity:SetModel( "models/missiles/aim9.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	local Mass = 74.48
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.PhysObj:SetMass( Mass )
	self.PhysObj:EnableGravity( false )
	self.PhysObj:EnableMotion( false )
	--util.SpriteTrail(self.Entity, 0, Color(255,255,255,255), false, 8, 128, 3, 1/16, "trails/smoke.vmt")

	local Time = SysTime()
	self.MotorLength = 10
	self.Gravity = GetConVar("sv_gravity"):GetFloat()
	self.DragCoef = 0.0028
	self.Motor = 7500
	self.FlightTime = 0
	self.CutoutTime = Time + self.MotorLength
	self.CurPos = self:GetPos()
	self.CurDir = self:GetForward()
	self.LastPos = self.CurPos
    self.Hit = false
	self.FirstThink = true

	local Length = 118
	local Width = 5
	self.Inertia = 0.08333 * Mass * (3.1416 * (Width / 2) ^ 2 + Length) -- cylinder, non-roll axes
	self.TorqueMul = Length * 25	--Kinda cheated here because it was unrealistic
	self.RotAxis = Vector(0,0,0)
	
	self.Launcher = self.Entity:GetOwner() or self	--Replace owner with the launcher/rail entity
	--self.CurTarget = Entity(178) --Replace with any entity you want to target - I generally use Entity( n ) to target a spawned prop with the EntIndex "n"
	--if IsValid(self.CurTarget) then self.TargetPos = self.CurTarget:GetPos()
	--else self.TargetPos = Vector(0,0,0) end
	
	self:Launch()
end



-- function ENT:Detonate()
	-- local Ent = self.Entity
	-- local Pos = Ent:GetPos()

	-- local exp = ents.Create( "env_explosion" )
	-- exp:SetPos( Pos )
	-- exp:SetOwner( Ent.Owner )
	-- exp:Spawn()
	-- exp:SetKeyValue( "iMagnitude", "140" )
	-- exp:Fire( "Explode", 0, 0 )
	-- exp:EmitSound( "^weapons/hegrenade/explode"..math.random(3,5)..".wav", 400, 100 )

	-- local shake = ents.Create( "env_shake" )
	-- shake:SetPos( Pos )
	-- shake:Spawn()
	-- shake:SetKeyValue( "Amplitude", "12" )
	-- shake:SetKeyValue( "Frequency", "50" )
	-- shake:SetKeyValue( "Radius", "1500" )
	-- shake:SetKeyValue( "Duration", "0.6" )
	-- shake:Fire( "StartShake", 0, 0 )

	-- local effect = EffectData()
	-- effect:SetStart( Pos )
	-- effect:SetOrigin( Pos )
	-- effect:SetScale( 70 )
	-- util.Effect( "cre_generic_explosion", effect )

	-- Ent:Remove()
-- end



function ENT:CalcFlight()

	local Ent = self.Entity
	local Pos = self.CurPos
	local Dir = self.CurDir

	local LastPos = self.LastPos
	local InitVel = self.InitialVel
	local Flight = self.FlightTime

    local Time = SysTime()
    local DeltaTime = Time - self.LastThink
    self.LastThink = Time
	Flight = Flight + DeltaTime


	--Motor cutout
	if Time > self.CutoutTime then
		if self.Motor ~= 0 then
			self.Entity:StopParticles()
			self.Motor = 0
		end
	end

	--Physics calculations
	local Vel = self.LastVel + (Dir * self.Motor - Vector(0,0,self.Gravity)) * ACF.VelScale * DeltaTime ^ 2
	local SpeedSq = Vel:LengthSqr()
	local Drag = Vel:GetNormalized() * (self.DragCoef * SpeedSq) / ACF.DragDiv * ACF.VelScale
	Vel = Vel - Drag
	local Speed = Vel:Length()

	local EndPos = Pos + Vel

	--Hit detetion
	local tracedata={}
	tracedata.start = Pos
	tracedata.endpos = EndPos
	tracedata.filter = {Ent, Ent:GetOwner()}
	local trace = util.TraceLine(tracedata)

	if trace.Hit then		
		self:DoFlight(trace.HitPos)
		self:Detonate()
		
		return
	end

	
	local Guidance = self.Guidance:GetGuidance(self)
	
	
	if Guidance.Detonate then
	
		local DetonatePos = Guidance.EndPos
		if DetonatePos then
			self:DoFlight(DetonatePos)
		end
		
		self:Detonate()
		return
		
	end
	
	
	local TargetPos = Guidance.TargetPos
	if TargetPos then
	
		--local Dist = Pos:Distance(TargetPos)
	
		-- TODO: move into guidance fuse
		-- if Dist < Speed / 2 then
			-- -- TODO: replace self.Hit with instant move-to + detonate.
			-- self.Hit = true
			-- self.BulletData.Flight = self.Vel
			
			-- tracedata.start = Pos
			-- tracedata.endpos = TargetPos
			-- tracedata.filter = {Ent, Ent:GetOwner()}
			-- local trace = util.TraceLine(tracedata)
			
			-- EndPos = trace.HitPos
		-- end

		local DirAng = Dir:Angle()
		local TargetDirRaw = TargetPos - Pos
		local TargetAngMul = math.max(TargetDirRaw:GetNormalized():Dot(Dir), 0)
		--local NewTargetPos = TargetPos
		--local TargetVel = (NewTargetPos - self.TargetPos) * DeltaTime

		--(TargetDirRaw + (Vector(0,0,1.1) - Vel + TargetVel * 20) * Dist / (Speed * 1.1) * TargetAngMul):GetNormalized()
		local TargetDir = TargetDirRaw:GetNormalized()
		
		if self.Motor ~= 0 then
			-- constant, prebake this
			local gravComp = math.deg(math.asin(self.Gravity / self.Motor))
			local newTargetAng = TargetDir:Angle()
			newTargetAng:RotateAroundAxis(DirAng:Right(), gravComp)
			TargetDir = newTargetAng:Forward()
		end
		
		local TargetAng = math.deg(math.acos(TargetDir:Dot(Dir)))

		local TargetRot = TargetDir:Cross(Dir)
		--print(TargetAng)
		local speedBounds = math.min(Speed / 30,2)
		DirAng:RotateAroundAxis(TargetRot, -math.Clamp(TargetAng*32, -speedBounds, speedBounds))
		Dir = DirAng:Forward()
		--DirAng:RotateAroundAxis(TargetRot,-math.min(TargetAng * 50,100))
		--self.TargetPos = NewTargetPos

		--print((math.Round(TargetAng * 100) / 100), -math.min(TargetAng * 50,math.min(Speed / 30,2)))

	else
		local DirAng = Dir:Angle()
		local VelNorm = Vel:GetNormalized()
		local AimDiff = Dir - VelNorm
		local DiffLength = AimDiff:Length()
		if DiffLength >= 0.01 then
			local Torque = DiffLength * self.TorqueMul
			local AngVelDiff = Torque / self.Inertia * DeltaTime
			local DiffAxis = AimDiff:Cross(Dir):GetNormalized()
			self.RotAxis = self.RotAxis + DiffAxis * AngVelDiff
		end

		self.RotAxis = self.RotAxis * 0.93
        DirAng:RotateAroundAxis(self.RotAxis, self.RotAxis:Length())
		Dir = DirAng:Forward()
	end

	--print("Vel = "..math.Round(Vel:Length()))

	self.LastVel = Vel
	self.LastPos = Pos
	self.CurPos = EndPos
	self.CurDir = Dir
	self.FlightTime = Flight
	
	debugoverlay.Line(self.LastPos, self.LastPos + self.LastVel:GetNormalized() * 50, 10, Color(0, 255, 0))
	debugoverlay.Line(self.LastPos, self.LastPos + self.CurDir:GetNormalized()  * 50, 10, Color(0, 0, 255))
	
	self:DoFlight()
end



function ENT:SetGuidance(guidance)

	self.Guidance = guidance
	guidance:Configure(self)

end



function ENT:Launch()

	if not self.Guidance then
		self:SetGuidance(ACF.Guidance.Dumb())
	end

	self.Launched = true
	self.ThinkDelay = 1 / 66
	
	local phys = self:GetPhysicsObject()
	phys:EnableMotion(false)
	
	if self.Motor > 0 or self.MotorLength > 0.1 then
		ParticleEffectAttach( "Rocket Motor", PATTACH_POINT_FOLLOW, self, self:LookupAttachment("exhaust") or 0 )
	end
	
	self:Think()
end



function ENT:DoFlight(ToPos, ToDir)
	local setPos = ToPos or self.CurPos
	local setDir = ToDir or self.CurDir
	self:SetPos(setPos)
	self:SetAngles(setDir:Angle())
end



function ENT:Detonate()

	self.BulletData.Flight = self.Vel

	self.BaseClass.Detonate(self)

end



function ENT:Think()
	local Time = SysTime()

	if self.Launched then
	
		if self.Hit then
			self:Detonate()
			return false
		end

		if self.FirstThink == true then
			self.FirstThink = false
			self.LastThink = SysTime()
			self.LastVel = self.Launcher:GetVelocity() / 66

		end
		self:CalcFlight()
		
	end
	
	return self.BaseClass.Think(self)
end



function ENT:PhysicsCollide()
	if self.Launched then self:Detonate() end
end



local function onRocketDamage( ent, dmginfo )
	local inflictor = dmginfo:GetInflictor():GetClass()
	if inflictor != "ent_cre_at4_rpg" then return end

	if !ent:IsPlayer() and !ent:IsNPC() then return end

	dmginfo:ScaleDamage(0)	--Disabling damage dealt by the rocket entity (to fix the killicons)
	return dmginfo
end





hook.Add("EntityTakeDamage", "Cre_RocketDamage", onRocketDamage)