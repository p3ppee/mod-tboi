local mod = RegisterMod("peppe", 1)
local osu = Isaac.GetItemIdByName("osu!")
local denju = Isaac.GetItemIdByName("denju")
local michele = Isaac.GetItemIdByName("michele")
local lattosio = Isaac.GetItemIdByName("lattosio")
local tettamanti = Isaac.GetItemIdByName("tettamanti")
local mohassino = Isaac.GetItemIdByName("mohassino")
print("osu id: " .. osu)
print("denju id: " .. denju)
print("michele id: " .. michele)
print("lattosio id: " .. lattosio)
print("andrea id: " .. tettamanti)
print("mohassino id: " .. mohassino)
local damageOsuDamage = 1
local damageDenjuDamage = 1
local damageMicheleDamage = 2.5
local damageTettamanti = 2
local shotSpeedOsu = 0.2
local speedOsu = 2
local shotSpeedMichele = - 0.1
local sizeDenju = 1.5
local sizeTettamanti = 2.3
local rangeMichele = - 0.5



function mod:EvaluateCache(player, cacheFlags)
    local itemCountOsu = player:GetCollectibleNum(osu)
    local itemCountDenju = player:GetCollectibleNum(denju)
    local itemCountMichele = player:GetCollectibleNum(michele)
    local itemCountTettamanti = player:GetCollectibleNum(tettamanti)
    
    if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
        local damageToAddOsu = damageOsuDamage * itemCountOsu
        local damageToAddDenju = damageDenjuDamage * itemCountDenju
        local damageToAddMichele = damageMicheleDamage * itemCountMichele
        local damageToAddTettamanti = damageTettamanti * itemCountTettamanti
        local damageToAdd = damageToAddOsu + damageToAddDenju + damageToAddMichele + damageToAddTettamanti
        
        player.Damage = player.Damage + damageToAdd
    end
    if cacheFlags & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + (speedOsu * itemCountOsu)
    end
    if cacheFlags & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + (shotSpeedOsu * itemCountOsu) + (shotSpeedMichele * itemCountMichele)
    end
    if cacheFlags & CacheFlag.CACHE_SIZE == CacheFlag.CACHE_SIZE then
        if itemCountDenju > 0 then
            player.SpriteScale = player.SpriteScale * (sizeDenju ^ itemCountDenju)
        end
        if itemCountTettamanti > 0 then
            player.SpriteScale = player.SpriteScale * (sizeTettamanti * itemCountTettamanti)
        end
    end
    if cacheFlags & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange + (rangeMichele * itemCountMichele) * 40
    end
end

function mod:LattosioUse(item, rng, player, useFlags, activeSlot)
    local RoomEntities = Isaac.GetRoomEntities()
    local room = Game():GetRoom()
    for _, entity in ipairs(RoomEntities) do
        if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() and not entity:IsBoss() then
            local position = entity.Position
            local gridPos = room:GetGridPosition(room:GetGridIndex(position))
            entity:Kill()
            Isaac.GridSpawn(GridEntityType.GRID_POOP, 0, gridPos, true)
        end
    end

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true
    }
    
end

function mod:MohassinoUse(item, rng, player,useFlags, activeShot)
    local room = Game():GetRoom()
    local numMonete = math.random(20) + 1
    local effects = player:GetEffects()
    effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_ANEMIC, true)
    for i = 1, numMonete do
        local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pos, Vector.Zero, nil)
    end
    if numMonete == 20 then
        local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_STICKYNICKEL, pos, Vector.Zero, nil)
    end

    
    if player:GetHearts() == 0 then
        player:TakeDamage(2, DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 30)
    else
        player:TakeDamage(2, 0, EntityRef(player), 30)
    end
    
        
            
    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true
        }
end
    
    
        
    


mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.MohassinoUse, mohassino)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.LattosioUse, lattosio)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.EvaluateCache)
