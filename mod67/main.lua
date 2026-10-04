local mod = RegisterMod("67 Fly", 1)
local music = MusicManager()

----------------------------------------------------------------
-- CONFIGURAZIONE (modifica questi valori)
----------------------------------------------------------------
local FLY_REPLACE_CHANCE = 1.0   -- 0..1: probabilita' che una mosca normale diventi un "67"
local FLY_ACCEL          = 0.4   -- velocita' di inseguimento (piu' alto = piu' veloce)
local FLY_WOBBLE         = 70    -- quanto e' "ubriaca" la traiettoria (gradi)
local PLAY_CUSTOM_MUSIC  = true  -- false = musica originale
local REPLACE_BOSS_MUSIC = false -- true = sostituisce anche la musica dei boss

----------------------------------------------------------------
-- ID delle entita' e della musica (definiti negli xml)
----------------------------------------------------------------
local FLY_TYPE    = Isaac.GetEntityTypeByName("67 Fly")
local FLY_VARIANT = Isaac.GetEntityVariantByName("67 Fly")
local TRACK       = Isaac.GetMusicIdByName("Mod67 Theme")

----------------------------------------------------------------
-- NEMICO: mosca "67"
----------------------------------------------------------------
if FLY_TYPE and FLY_TYPE > 0 then

	-- Sostituisce alcune mosche normali con il 67
	mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, type, variant, subtype, pos, vel, spawner, seed)
		if (type == EntityType.ENTITY_FLY or type == EntityType.ENTITY_ATTACKFLY) and variant == 0 then
			local rng = RNG()
			rng:SetSeed(seed == 0 and 1 or seed, 35)
			if rng:RandomFloat() < FLY_REPLACE_CHANCE then
				return { FLY_TYPE, FLY_VARIANT, 0, seed }
			end
		end
	end)

	-- Vola sopra rocce e buchi, collide solo con i muri
	mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
		if npc.Variant ~= FLY_VARIANT then return end
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.State = NpcState.STATE_MOVE
		npc:GetSprite():Play("Idle", true)
	end, FLY_TYPE)

	-- AI: insegue il giocatore a scatti, come una mosca
	mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
		if npc.Variant ~= FLY_VARIANT then return end

		if npc:IsDead() then return end

		-- il gioco puo' rimettere lo stato "appena comparso" (nessuna collisione): lo forziamo ogni frame
		if npc:HasEntityFlags(EntityFlag.FLAG_APPEAR) then
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		end
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		npc.State = NpcState.STATE_MOVE

		local sprite = npc:GetSprite()
		if sprite:IsPlaying("Death") then return end
		if not sprite:IsPlaying("Idle") then
			sprite:Play("Idle", true)
		end

		local target = npc:GetPlayerTarget()
		if not target then return end

		local phase = (npc.InitSeed % 360) + npc.FrameCount * 14
		local dir = (target.Position - npc.Position):Normalized()
		dir = dir:Rotated(math.sin(math.rad(phase)) * FLY_WOBBLE)

		npc.Velocity = npc.Velocity * 0.88 + dir * FLY_ACCEL
	end, FLY_TYPE)

	-- Effetto alla morte
	mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
		if npc.Variant ~= FLY_VARIANT then return end
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, npc.Position, Vector.Zero, nil)
		SFXManager():Play(SoundEffect.SOUND_MEAT_IMPACTS, 0.8)
	end, FLY_TYPE)
end

----------------------------------------------------------------
-- MUSICA
----------------------------------------------------------------
local replaceSet = {}
local function addTracks(names)
	for _, name in ipairs(names) do
		local id = Music[name]
		if id then replaceSet[id] = true end
	end
end

addTracks({
	"MUSIC_BASEMENT", "MUSIC_CELLAR", "MUSIC_BURNING_BASEMENT",
	"MUSIC_CAVES", "MUSIC_CATACOMBS", "MUSIC_FLOODED_CAVES",
	"MUSIC_DEPTHS", "MUSIC_NECROPOLIS", "MUSIC_DANK_DEPTHS",
	"MUSIC_WOMB_UTERO", "MUSIC_UTERO", "MUSIC_SCARRED_WOMB", "MUSIC_BLUE_WOMB",
	"MUSIC_SHEOL", "MUSIC_CATHEDRAL", "MUSIC_DARKROOM", "MUSIC_CHEST", "MUSIC_VOID",
	"MUSIC_DOWNPOUR", "MUSIC_DROSS", "MUSIC_MINES", "MUSIC_ASHPIT",
	"MUSIC_MAUSOLEUM", "MUSIC_GEHENNA", "MUSIC_CORPSE", "MUSIC_MORTIS",
})
if REPLACE_BOSS_MUSIC then
	addTracks({ "MUSIC_BOSS", "MUSIC_BOSS2" })
end

if PLAY_CUSTOM_MUSIC and TRACK and TRACK > 0 then
	if REPENTOGON then
		-- Con REPENTOGON: sostituzione pulita, senza riavvii al cambio stanza
		mod:AddCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, function(_, id, volumeOrFade, isFade)
			if replaceSet[id] then
				return TRACK
			end
		end)
	else
		-- Senza REPENTOGON: sostituzione "a forza".
		-- Limite: la canzone puo' ripartire da capo ad ogni cambio stanza.
		mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
			local current = music:GetCurrentMusicID()
			if current ~= TRACK and replaceSet[current] then
				music:Play(TRACK)
				music:UpdateVolume()
			end
		end)
	end
end

----------------------------------------------------------------
-- DIAGNOSTICA (scritte a schermo, la console non serve)
-- F7 = spawna un 67 accanto al giocatore
----------------------------------------------------------------
local SHOW_STATUS = true   -- metti false quando e' tutto ok

local flyOk   = FLY_TYPE and FLY_TYPE > 0
local trackOk = TRACK and TRACK > 0

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	if SHOW_STATUS then
		local playing = trackOk and music:GetCurrentMusicID() == TRACK
		Isaac.RenderText("67 Fly - mosca: " .. (flyOk and ("OK (spawn " .. FLY_TYPE .. "." .. FLY_VARIANT .. ")") or "NON TROVATA"), 110, 8, 1, 1, 1, 1)
		Isaac.RenderText("musica: " .. (trackOk and "TROVATA" or "NON TROVATA") .. " | in riproduzione: " .. (playing and "SI" or "NO"), 110, 20, 1, 1, 1, 1)
		Isaac.RenderText("REPENTOGON: " .. (REPENTOGON and "si" or "no") .. " | F7 = spawna mosca", 110, 32, 1, 1, 1, 1)
	end

	if Input.IsButtonTriggered(Keyboard.KEY_F7, 0) and flyOk then
		local p = Isaac.GetPlayer(0)
		Isaac.Spawn(FLY_TYPE, FLY_VARIANT, 0, p.Position + Vector(60, 0), Vector.Zero, nil)
	end
end)
