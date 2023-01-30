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