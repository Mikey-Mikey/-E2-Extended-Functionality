--self.entity = chip
--self.player = chip owner

E2Lib.RegisterExtension("extendedfunc", false, "Extended e2 functions and events")

local extendedfunc = {}
extendedfunc.gravholding = {}
extendedfunc.physholding = {}
extendedfunc.handholding = {}

E2Lib.registerEvent("entityCollide", {
	{"ColData","t"}
})
E2Lib.registerEvent("entityCreated", {
	{"Ent","e"}
})
E2Lib.registerEvent("entityDamaged", {
	{"Ent","e"},
	{"DmgData","t"}
})
E2Lib.registerEvent("entityBreak", {
	{"Ply","e"},
	{"Ent","e"}
})
E2Lib.registerEvent("gravGunPickup", {
	{"Ply","e"},
	{"Ent","e"}
})
E2Lib.registerEvent("gravGunDropped", {
	{"Ply","e"},
	{"Ent","e"}
})
E2Lib.registerEvent("gravGunPunt", {
	{"Ply","e"},
	{"Ent","e"}
})
E2Lib.registerEvent("physGunPickup", {
	{"Ply","e"},
	{"Ent","e"}
})
E2Lib.registerEvent("physGunDropped", {
	{"Ply","e"},
	{"Ent","e"}
})
E2Lib.registerEvent("physGunFreeze", {
	{"Ply","e"},
	{"Ent","e"}
})
E2Lib.registerEvent("physGunUnfreeze", {
	{"Ply","e"},
	{"Ent","e"}
})
E2Lib.registerEvent("propPickup", {
	{"Ply","e"},
	{"Ent","e"}
})
E2Lib.registerEvent("propDropped", {
	{"Ply","e"},
	{"Ent","e"}
})
E2Lib.registerEvent("propThrown", {
	{"Ply","e"},
	{"Ent","e"}
})
E2Lib.registerEvent("bulletFired", {
	{"Ent","e"},
	{"BulletData","t"}
})

E2Lib.registerEvent("mouseInput", {
	{"Ply","e"},
	{"DeltaX","n"},
	{"DeltaY","n"},
	{"Scroll", "n"}
})

if SERVER then
	util.AddNetworkString("e2_propresize")
end

local function collisionCallback(ent, data)
	local coldata = {
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
	for e2, _ in pairs(ent.e2CollisionCallbacks) do
		if IsValid(e2) then
			e2:ExecuteEvent("entityCollide", {coldata})
		end
	end
end

hook.Add("GravGunOnPickedUp", "extendedcore_gravpickup", function(ply,ent)
	E2Lib.triggerEvent("gravGunPickup", {ply, ent})
	extendedfunc.gravholding[ent] = true
end)

hook.Add("GravGunOnDropped", "extendedcore_gravdrop", function(ply,ent)
	E2Lib.triggerEvent("gravGunDropped", {ply, ent})
	extendedfunc.gravholding[ent] = false
end)

hook.Add("GravGunPunt", "extendedcore_gravpunt", function(ply, ent)
	timer.Simple(0, function() E2Lib.triggerEvent("gravGunPunt", {ply, ent}) end)
	extendedfunc.gravholding[ent] = false
end)

hook.Add("OnPhysgunPickup", "extendedcore_physpickup", function(ply,ent)
	E2Lib.triggerEvent("physGunPickup", {ply, ent})
	extendedfunc.physholding[ent] = true
end)

hook.Add("PhysgunDrop", "extendedcore_physdrop", function(ply, ent)
	timer.Simple(0, function() E2Lib.triggerEvent("physGunDropped", {ply, ent}) end)
	extendedfunc.physholding[ent] = false
end)

hook.Add("OnPhysgunFreeze", "extendedcore_physfreeze", function(weapon, phys, ent, ply)
	timer.Simple(0, function() E2Lib.triggerEvent("physGunFreeze", {ply, ent}) end)
	extendedfunc.physholding[ent] = false
end)

hook.Add("CanPlayerUnfreeze", "extendedcore_physunfreeze", function(ply, ent, phys)
	timer.Simple(0, function() E2Lib.triggerEvent("physGunUnfreeze", {ply, ent}) end)
end)

hook.Add("OnPlayerPhysicsPickup", "extendedcore_physpickup", function(ply, ent)
	E2Lib.triggerEvent("propPickup", {ply, ent})
	extendedfunc.handholding[ent] = true
end)

hook.Add("OnPlayerPhysicsDrop", "extendedcore_physdrop", function(ply, ent, thrown)
	-- this hook is run before the player actually dropped the item, for entity manipulation
	timer.Simple(0, function() E2Lib.triggerEvent("prop"..(thrown and "Thrown" or "Dropped"), {ply, ent}) end)
	extendedfunc.handholding[ent] = false
end)

hook.Add("EntityTakeDamage", "extendedcore_entdamage", function(ent, dmginfo)
	local dmgdata = {
		s = { 
			Inflictor = dmginfo:GetInflictor(),
			Attacker = dmginfo:GetAttacker(),
			DamagePos = dmginfo:GetDamagePosition(),
			IsBulletDamage = dmginfo:IsBulletDamage() and 1 or 0,
			IsExplosionDamage = dmginfo:IsExplosionDamage() and 1 or 0,
			IsFallDamage = dmginfo:IsFallDamage() and 1 or 0,
			Damage = dmginfo:GetDamage(),
		},
		stypes = {
			Inflictor = "e",
			Attacker = "e",
			DamagePos = "v",
			IsBulletDamage = "n",
			IsExplosionDamage = "n",
			IsFallDamage = "n",
			Damage = "n",
		},
		n = {}, ntypes = {},
		size = 7
	}
	-- timer is here to fix infinite loop crash if the entity damages itself.
	timer.Simple(0, function() E2Lib.triggerEvent("entityDamaged", {ent, dmgdata}) end)
end)

hook.Add("PropBreak", "extendedfunc_entbreak", function(ply, ent)
	E2Lib.triggerEvent("entityBreak", {ply, ent})
	extendedfunc.handholding[ent] = false
	extendedfunc.physholding[ent] = false
	extendedfunc.gravholding[ent] = false
end)

hook.Add("EntityFireBullets", "extendedfunc_firebullets", function(ent, bulletinfo)
	local ply_dmg = game.GetAmmoPlayerDamage(game.GetAmmoID(bulletinfo.AmmoType))
	local npc_dmg = game.GetAmmoNPCDamage(game.GetAmmoID(bulletinfo.AmmoType))
	if ply_dmg == 0 and npc_dmg == 0 then
		ply_dmg = bulletinfo.Damage
		npc_dmg = bulletinfo.Damage
	end
	local bulletdata = {
		s = {
			Direction = bulletinfo.Dir,
			Origin = bulletinfo.Src,
			BulletCount = bulletinfo.Num,
			AmmoType = bulletinfo.AmmoType,
			PlyDamage = ply_dmg,
			NpcDamage = npc_dmg
		},
		stypes = {
			Direction = "v",
			Origin = "v",
			BulletCount = "n",
			AmmoType = "s",
			PlyDamage = "n",
			NpcDamage = "n"
		},
		n = {}, ntypes = {},
		size = 6
	}
	-- timer is here to fix infinite loop crash if you fire a bullet inside of the event.
	timer.Simple(0, function() E2Lib.triggerEvent("bulletFired", {ent, bulletdata}) end)
end)

hook.Add("OnEntityCreated", "extendedfunc_entitycreated", function(ent)
	timer.Simple(0, function() E2Lib.triggerEvent("entityCreated", {ent}) end)
end)

hook.Add("SetupMove", "extendedfunc_mouseInput", function( ply, mv, cmd )
	local deltaX = cmd:GetMouseX()
	local deltaY = cmd:GetMouseY()
	local scroll = cmd:GetMouseWheel()
	E2Lib.triggerEvent("mouseInput", {ply, deltaX, deltaY, scroll})
end)

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
	ent:PhysicsInit( SOLID_VPHYSICS )
	ent:PhysicsInitMultiConvex( physmesh )
	ent:EnableCustomCollisions( true )
	return true

end
__e2setcost(50)

e2function void entity:scaleEnt(vector scale)
	if !self.player:IsUserGroup("superadmin") then --change this to whatever group you want if you're on a server
		return self:throw("Function is superadmin only!", nil)
	end
	
	if this:IsPlayer() then
		return self:throw("Function can't be ran on players!", nil)
	end

	if IsValid(this) then
		local phys = this:GetPhysicsObject()

		if not IsValid(phys) then
			self:throw("Can't resize a physicsless entity!", "") 
			return
		end

		local vel = phys:GetVelocity()
		local angvel = phys:GetAngleVelocity()
		local pos = this:GetPos()
		local mass = phys:GetMass()
		local frozen = phys:IsMotionEnabled()
		local phys_mat = phys:GetMaterial()
		scale[1] = math.Clamp(scale[1],-20,20)
		scale[2] = math.Clamp(scale[2],-20,20)
		scale[3] = math.Clamp(scale[3],-20,20)
		if ResizePhysics(this, scale) then
			net.Start("e2_propresize")
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
			this.e2_scale = scale
		end
	else
		self:throw("Invalid entity!", "") 
	end
	
end

e2function void entity:resetScale()
	if !self.player:IsUserGroup("superadmin") then --change this to whatever group you want if you're on a server
		return self:throw("Function is superadmin only!", nil)
	end

	if this:IsPlayer() then
		return self:throw("Function can't be ran on players!", nil)
	end

	if IsValid(this) then
		local phys = this:GetPhysicsObject()
		local vel = this:GetVelocity()
		local angvel = phys:GetAngleVelocity()
		local pos = this:GetPos()
		local mass = phys:GetMass()
		local frozen = phys:IsMotionEnabled()
		local phys_mat = phys:GetMaterial()
		if ResizePhysics(this, scale) then
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
			this.e2_scale = scale
		end
	else
		self:throw("Invalid entity!", "") 
	end
end

__e2setcost(5)

e2function void entity:addCollisionCallback()
	if !IsValid(this) then self:throw("Invalid entity!", "") return end
	this.e2CollisionCallbacks = this.e2CollisionCallbacks or {}
	if this.e2CollisionCallbacks[self.entity] then self:throw("Entity already has a collision callback set!", "") return end
	this.e2CollisionCallbacks[self.entity] = this:AddCallback("PhysicsCollide", collisionCallback)
end

e2function void entity:removeCollisionCallback()
	if !IsValid(this) then self:throw("Invalid entity!", "") return end
	if not (this.e2CollisionCallbacks or this.e2CollisionCallbacks[self]) then self:throw("Entity already had its collision callback removed!", "") return end
	this:RemoveCallback("PhysicsCollide", this.e2CollisionCallbacks[self.entity])
	this.e2CollisionCallbacks[self.entity] = nil
end

__e2setcost(2)

e2function angle vector:axisToAng()
	return Angle(this[2],this[3],this[1])
end

e2function vector angle:angToAxis()
	return Vector(this[2],this[1],this[3])
end

e2function number entity:isPlayerHoldingGrav()
	if !IsValid(this) then return self:throw("Invalid entity!", 0) end
	return extendedfunc.gravholding[this] and 1 or 0
end

e2function number entity:isPlayerHoldingPhys()
	if !IsValid(this) then return self:throw("Invalid entity!", 0) end
	return extendedfunc.physholding[this] and 1 or 0
end

e2function number entity:isPlayerHoldingHands()
	if !IsValid(this) then return self:throw("Invalid entity!", 0) end
	return extendedfunc.handholding[this] and 1 or 0
end

e2function vector entity:getScale()
	if !IsValid(this) then return self:throw("Invalid entity!", 0) end
	return this.e2_scale or Vector(1,1,1)
end