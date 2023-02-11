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
E2Helper.Descriptions["axisToAng"] = [[
Converts vec(R,P,Y) to ang(P,Y,R) 
]]
E2Helper.Descriptions["angToAxis"] = [[
Converts ang(P,Y,R) to vec(R,P,Y)
]]
E2Helper.Descriptions["isPlayerHoldingGrav"] = [[
Is the entity being held with a gravity gun?
]]
E2Helper.Descriptions["isPlayerHoldingPhys"] = [[
Is the entity being held with a physics gun?
]]
E2Helper.Descriptions["isPlayerHoldingHands"] = [[
Is the entity being held with a players hands?
]]
E2Helper.Descriptions["ragSpawn"] = [[
Spawns a ragdoll with the specified model.
]]
E2Helper.Descriptions["ragCanSpawn"] = [[
Is an E2 created ragdoll able to be spawned by this player?
]]
E2Helper.Descriptions["ragSpawnUndo"] = [[
Is an E2 created ragdoll able to be spawned by this player?
]]

net.Receive("e2_propresize", function()
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