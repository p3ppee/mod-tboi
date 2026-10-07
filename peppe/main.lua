local mod = RegisterMod("peppe", 1)
local osu = Isaac.GetItemIdByName("osu!")
print("osu id: " .. osu)
local damageOsuDamage = 1
local speedOsu = 0.3
local shotSpeedOsu = 0.2

function mod:EvaluateCache(player, cacheFlags)
    local itemCount = player:GetCollectibleNum(osu)
    if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
        local damageToAdd = damageOsuDamage * itemCount
        player.Damage = player.Damage + damageToAdd
    end
    if cacheFlags & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + (speedOsu * itemCount)
    end
    if cacheFlags & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + (shotSpeedOsu * itemCount) 
    end


end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.EvaluateCache)