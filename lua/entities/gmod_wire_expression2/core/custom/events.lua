--self.entity = chip
--self.player = chip owner

E2Lib.RegisterExtension("extendedfunc", false, "Extended e2 functions and events")

E2Lib.registerEvent("entityCollide", {"t"})
E2Lib.registerEvent("gravGunPunt", {"e","e"})
E2Lib.registerEvent("gravGunPickup", {"e","e"})
E2Lib.registerEvent("physicsPickup", {"e","e"})
E2Lib.registerEvent("physicsDropped", {"e","e"})
E2Lib.registerEvent("physicsThrown", {"e","e"})

if SERVER then
	util.AddNetworkString("e2_propresize")
end

local function collisionCallback(ent, data)
	local e2data = {
		s = { 
			OurEntity = ent,
			HitPos = data.HitPos,
			HitEntity = data.HitEntity,
			OurOldVelocity = data.OurOldVelocity,
			DeltaTime = data.DeltaTime,
			TheirOldVelocity = data.TheirOldVelocity,
			Speed = data.Speed,
			HitNormal = data.HitNormal,
			HitSpeed = data.HitSpeed,
			OurNewVelocity = data.OurNewVelocity,
			TheirNewVelocity = data.TheirNewVelocity,
			OurOldAngularVelocity = data.OurOldAngularVelocity,
			TheirOldAngularVelocity = data.TheirOldAngularVelocity
		},
		stypes = {
			OurEntity = "e",
			HitPos = "v",
			HitEntity = "e",
			OurOldVelocity = "v",
			DeltaTime = "n",
			TheirOldVelocity = "v",
			Speed = "n",
			HitNormal = "v",
			HitSpeed = "v",
			OurNewVelocity = "v",
			TheirNewVelocity = "v",
			OurOldAngularVelocity = "v",
			TheirOldAngularVelocity = "v"
		},
		n = {}, ntypes = {},
		size = 11
	}
	E2Lib.triggerEvent("entityCollide", {e2data})
end

__e2setcost(2)
e2function void entity:addCollisionCallback()

	if !IsValid(this) then self:throw("Invalid entity!", "") return end
	if this.e2CollisionCallback then self:throw("Entity already has a collision callback set!", "")  return end
	this.e2CollisionCallback = this:AddCallback("PhysicsCollide", collisionCallback)

end

e2function void entity:removeCollisionCallback()

	if !IsValid(this) then self:throw("Invalid entity!", "") return end
	if not this.e2CollisionCallback then self:throw("Entity already had its collision callback removed!", "") return end
	this:RemoveCallback("PhysicsCollide", this.e2CollisionCallback)

end

hook.Add("GravGunOnPickedUp", function(ply,ent)
	E2Lib.triggerEvent("gravGunPickup", {ply, ent})
end)

hook.Add("GravGunPunt", function(ply, ent)
	timer.Simple(0, function() E2Lib.triggerEvent("gravGunPunt", {ply, ent}) end)
end)

hook.Add("OnPlayerPhysicsPickup", function(ply, ent)
	E2Lib.triggerEvent("physicsPickup", {ply, ent})
end)

hook.Add("OnPlayerPhysicsDrop", function(ply, ent, thrown)
	if thrown then
		timer.Simple(0, function() E2Lib.triggerEvent("physicsThrown", {ply, ent}) end)
	else
		timer.Simple(0, function() E2Lib.triggerEvent("physicsDropped", {ply, ent}) end)
	end
end)

e2function angle vector:vecToAng()
	return Angle(this[2],this[3],this[1])
end

e2function vector angle:angToVec()
	return Vector(this[2],this[1],this[3])
end

local function ResizePhysics( ent, scale )

	local physobj = ent:GetPhysicsObject()

	if ( not physobj:IsValid() ) then return false end

	local physmesh = physobj:GetMeshConvexes()
	local pointcount = 0

	if ( not istable( physmesh ) ) or ( #physmesh < 1 ) then return false end

	for convexkey, convex in pairs( physmesh ) do

		for poskey, postab in pairs( convex ) do
			convex[ poskey ] = postab.pos * scale
			pointcount = pointcount + 1
			if pointcount > 4800 then return false end
		end

	end
	ent:PhysicsDestroy()
	ent:PhysicsInit( SOLID_VPHYSICS )
	ent:PhysicsInitMultiConvex( physmesh )
	ent:EnableCustomCollisions( true )
	return

end

e2function void entity:scaleEnt(vector scale)

	if !self.player:IsUserGroup("superadmin") then --change this to whatever group you want if you're on a server
		self:throw("Function is superadmin only!", "")
		return
	end

	if IsValid(this) then
		local phys = this:GetPhysicsObject()

		if not IsValid(phys) then
			self:throw("Can't resize a physicsless entity!", "") 
			return
		end

		local vel = this:GetVelocity()
		local angvel = phys:GetAngleVelocity()
		local pos = this:GetPos()
		local mass = phys:GetMass()
		local frozen = phys:IsMotionEnabled()
		local phys_mat = phys:GetMaterial()
		scale[1] = math.Clamp(scale[1],-20,20)
		scale[2] = math.Clamp(scale[2],-20,20)
		scale[3] = math.Clamp(scale[3],-20,20)
		if ResizePhysics(this, scale) then
			net.Start("set_visual_size")
				net.WriteEntity(this)
				net.WriteFloat(scale[1])
				net.WriteFloat(scale[2])
				net.WriteFloat(scale[3])
			net.Broadcast()
			this:SetPos(pos)
			phys = this:GetPhysicsObject()
			phys:SetMass(mass * scale:Length())
			phys:SetVelocity(vel)
			phys:SetAngleVelocity(angvel)
			phys:EnableMotion(frozen)
			phys:SetMaterial(phys_mat)
		end
	else
		self:throw("Invalid entity!", "") 
	end
	
end

e2function void entity:resetScale()
	if !self.player:IsUserGroup("superadmin") then --change this to whatever group you want if you're on a server
		self:throw("Function is superadmin only!", "")
		return
	end

	if IsValid(this) then
		local phys = this:GetPhysicsObject()
		local vel = this:GetVelocity()
		local angvel = phys:GetAngleVelocity()
		local pos = this:GetPos()
		local mass = phys:GetMass()
		local frozen = phys:IsMotionEnabled()
		local phys_mat = phys:GetMaterial()
		ResizePhysics(this, scale)
		net.Start("e2_propresize")
			net.WriteEntity(this)
			net.WriteFloat(1)
			net.WriteFloat(1)
			net.WriteFloat(1)
		net.Broadcast()
		this:SetPos(pos)
		phys = this:GetPhysicsObject()
		phys:SetMass(mass * scale:Length())
		phys:SetVelocity(vel)
		phys:SetAngleVelocity(angvel)
		phys:EnableMotion(frozen)
		phys:SetMaterial(phys_mat)
	else
		self:throw("Invalid entity!", "") 
	end
end