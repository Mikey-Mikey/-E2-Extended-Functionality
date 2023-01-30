E2Helper.Descriptions["addCollisionCallback"] = [[
Use the entityCollision event with this to get the collision data and the entity.
Data: OurEntity, HitPos, HitEntity,
OurOldVelocity, DeltaTime, TheirOldVelocity,
Speed, HitNormal, HitSpeed,
OurNewVelocity, TheirNewVelocity, OurOldAngularVelocity,
TheirOldAngularVelocity
]]
E2Helper.Descriptions["removeCollisionCallback"] = [[
Removes the collision callback on the entity.
]]
E2Helper.Descriptions["scaleEnt"] = [[
Sets the visual and physical scale of an entity.
]]
E2Helper.Descriptions["resetScale"] = [[
Resets the visual and physical scale of an entity.
]]

E2Helper.Descriptions["getOurEntity"] = [[
Gets our entity of the collision event
]]
E2Helper.Descriptions["getHitPos"] = [[
Gets the pos of the collision event
]]
E2Helper.Descriptions["getHitEntity"] = [[
Gets the hit entity of the collision event
]]
E2Helper.Descriptions["ourOldVel"] = [[
Gets our old velocity of the collision event
]]
E2Helper.Descriptions["getDeltaTime"] = [[
Gets the time since last collision of the collision event
]]
E2Helper.Descriptions["getTheirOldVel"] = [[
Gets their old velocity of the collision event
]]
E2Helper.Descriptions["getSpeed"] = [[
Gets the speed the collision event
]]
E2Helper.Descriptions["getHitNormal"] = [[
Gets the hit normal of the collision event
]]
E2Helper.Descriptions["getHitSpeed"] = [[
Gets the velocity at the point of collision of the collision event
]]
E2Helper.Descriptions["getOurNewVel"] = [[
Gets our new velocity of the collision event
]]
E2Helper.Descriptions["getTheirNewVel"] = [[
Gets their new velocity of the collision event
]]
E2Helper.Descriptions["getOurOldAngvel"] = [[
Gets our old angle velocity of the collision event
]]
E2Helper.Descriptions["getTheirOldAngvel"] = [[
Gets their old angle velocity of the collision event
]]
E2Helper.Descriptions["getOurOldAngvelVec"] = [[
Gets our old angle velocity as a vector of the collision event
]]
E2Helper.Descriptions["getTheirOldAngvelVec"] = [[
Gets their old angle velocity as a vector of the collision event
]]
E2Helper.Descriptions["vecToAng"] = [[
Converts vec(R,P,Y) to ang(P,Y,R) 
]]
E2Helper.Descriptions["angToVec"] = [[
Converts ang(P,Y,R) to vec(R,P,Y)
]]

net.Receive("set_visual_size", function()
    local ent = net.ReadEntity()
    local scale = Vector(net.ReadFloat(),net.ReadFloat(),net.ReadFloat())
    local m = Matrix()
    m:Scale(scale)
    if ent:IsValid() then
        ent:EnableMatrix("RenderMultiply", m)
        ent:SetRenderBounds(ent:OBBMins() * scale,ent:OBBMaxs() * scale)
        ent:DestroyShadow()
    end
end)