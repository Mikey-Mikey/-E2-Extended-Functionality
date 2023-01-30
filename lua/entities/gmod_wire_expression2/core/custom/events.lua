--self.entity = chip
--self.player = chip owner

E2Lib.RegisterExtension("extendedfunc", false, "Extended e2 functions and events")
local extendedfunc = {}
extendedfunc.alwaysallowpickups = {}
E2Lib.registerEvent("entityCollide", {"t"})
E2Lib.registerEvent("gravGunPunt", {"e","e"})
E2Lib.registerEvent("gravGunPickup", {"e","e"})
E2Lib.registerEvent("physicsPickup", {"e","e"})
E2Lib.registerEvent("physicsDropped", {"e","e"})
E2Lib.registerEvent("physicsThrown", {"e","e"})

if SERVER then
    util.AddNetworkString("alreadycallback")
    util.AddNetworkString("set_visual_size")
end

__e2setcost(2)
e2function void entity:addCollisionCallback()
    if !IsValid(this) then return end
    if #(this:GetCallbacks("PhysicsCollide")) > 0 then
        return 0
    end
    return this:AddCallback("PhysicsCollide", function(ent,data)
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
    end)
end

e2function void entity:removeCollisionCallback()
    if !IsValid(this) then return end
    for k, v in ipairs(this:GetCallbacks("PhysicsCollide")) do
        this:RemoveCallback("PhysicsCollide", k)
    end
end

function GAMEMODE:GravGunOnPickedUp(ply, ent)
    E2Lib.triggerEvent("gravGunPickup", {ply, ent})
end

function GAMEMODE:GravGunPunt(ply, ent)
    timer.Simple(0, function() E2Lib.triggerEvent("gravGunPunt", {ply, ent}) end)
    return true
end

function GAMEMODE:OnPlayerPhysicsPickup(ply, ent)
    E2Lib.triggerEvent("physicsPickup", {ply, ent})
end

function GAMEMODE:OnPlayerPhysicsDrop(ply, ent, thrown)
    if thrown then
        timer.Simple(0, function() E2Lib.triggerEvent("physicsThrown", {ply, ent}) end)
    else
        timer.Simple(0, function() E2Lib.triggerEvent("physicsDropped", {ply, ent}) end)
    end
end

e2function entity table:getOurEntity()
    return this.s.OurEntity
end
e2function vector table:getHitPos()
    return this.s.HitPos
end
e2function entity table:getHitEntity()
    return this.s.HitEntity
end
e2function vector table:getOurOldVel()
    return this.s.OurOldVelocity
end
e2function number table:getDeltaTime()
    return this.s.DeltaTime
end
e2function vector table:getTheirOldVel()
    return this.s.TheirOldVelocity
end
e2function number table:getSpeed()
    return this.s.Speed
end
e2function vector table:getHitNormal()
    return this.s.HitNormal
end
e2function vector table:getHitSpeed()
    return this.s.HitSpeed
end
e2function vector table:getOurNewVel()
    return this.s.OurNewVelocity
end
e2function angle table:getTheirNewVel()
    return this.s.TheirNewVelocity
end
e2function angle table:getOurOldAngvel()
    local old = this.s.OurOldAngularVelocity
    return Angle(old[2],old[3],old[1])
end
e2function vector table:getTheirOldAngvel()
    local old = this.s.TheirOldAngularVelocity
    return Angle(old[2],old[3],old[1])
end
e2function vector table:getOurOldAngvelVec()
    return this.s.OurOldAngularVelocity
end
e2function vector table:getTheirOldAngvelVec()
    return this.s.TheirOldAngularVelocity
end

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
		end

	end
    if pointcount > 4800 then return false end
    ent:PhysicsDestroy()
    ent:PhysicsInit( SOLID_VPHYSICS )
	ent:PhysicsInitMultiConvex( physmesh )
	ent:EnableCustomCollisions( true )
	return ent:GetPhysicsObject():IsValid()

end

e2function void entity:scaleEnt(vector scale)
    if !self.player:IsUserGroup("superadmin") then --change this to whatever group you want if you're on a server
        self.player:PrintMessage("You're not a superadmin, you can't use this function!") -- same here
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
    end
end

e2function void entity:resetScale()
    if !self.player:IsUserGroup("superadmin") then --change this to whatever group you want if you're on a server
        self.player:PrintMessage("You're not a superadmin, you can't use this function!") -- same here
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
        net.Start("set_visual_size")
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
    end
end