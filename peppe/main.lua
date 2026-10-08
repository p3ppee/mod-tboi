local mod = RegisterMod("peppe", 1)
local osu = Isaac.GetItemIdByName("osu!")
local denju = Isaac.GetItemIdByName("denju")
local michele = Isaac.GetItemIdByName("michele")
print("osu id: " .. osu)
print("denju id: " .. denju)
print("michele id: " .. michele)
local damageOsuDamage = 1
local damageDenjuDamage = 1
local damageMicheleDamage = 2.5
local speedOsu = 0.3
local shotSpeedOsu = 0.2
local shotSpeedMichele = - 0.1
local sizeDenju = 0.5
local rangeMichele = - 0.5

function mod:EvaluateCache(player, cacheFlags)
    local itemCountOsu = player:GetCollectibleNum(osu)
    local itemCountDenju = player:GetCollectibleNum(denju)
    local itemCountMichele = player:GetCollectibleNum(michele)
    
    if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
        local damageToAddOsu = damageOsuDamage * itemCountOsu
        local damageToAddDenju = damageDenjuDamage * itemCountDenju
        local damageToAddMichele = damageMicheleDamage * itemCountMichele
        local damageToAdd = damageToAddOsu + damageToAddDenju + damageToAddMichele
        player.Damage = player.Damage + damageToAdd
    end
    if cacheFlags & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + (speedOsu * itemCountOsu)
    end
    if cacheFlags & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + (shotSpeedOsu * itemCountOsu) + (shotSpeedMichele * itemCountMichele)
    end
    if cacheFlags & CacheFlag.CACHE_SIZE == CacheFlag.CACHE_SIZE then
        player.SpriteScale = player.SpriteScale + (sizeDenju * itemCountDenju)
    end
    if cacheFlags & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange + (rangeMichele * itemCountMichele) * 40
    end


end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.EvaluateCache)
