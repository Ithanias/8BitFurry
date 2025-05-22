--#region ===== Helpers =====

--#region ===== Logging =====
local logger_name = "8BitFurryDeckLogger"
-- Helper object for logging
local log = {
	---@diagnostic disable-next-line: undefined-global
	trace = function(msg) sendTraceMessage(msg, logger_name) end, -- Might be missing a definition, but the docs say it exists
	debug = function(msg) sendDebugMessage(msg, logger_name) end,
	info = function(msg) sendInfoMessage(msg, logger_name) end,
	warn = function(msg) sendWarnMessage(msg, logger_name) end,
	error = function(msg) sendErrorMessage(msg, logger_name) end,
	fatal = function(msg) sendFatalMessage(msg, logger_name) end,
}

--#endregion

--#region ===== Helper constructors =====

---Helper function for making a standard atlas
---@param key string Unique atlas key
---@param path string Atlas image path (relative to 1x/ and 2x/)
---@return SMODS.Atlas
local function make_atlas(key, path)
	log.debug(("Registering atlas %s at path %s"):format(key, path))
	return SMODS.Atlas {
		key = key,
		path = path,
		px = 71,
		py = 95,
	}
end

---Replaces the atlas for all `obj_keys` in `smods_obj` with `atlas_key` by calling `take_ownership()`
---This is roughly equivalent to repeatedly calling:
---```lua
---smods_obj:take_ownership(obj_keys[i],
---  {
---    atlas = atlas_key
---  },
---  silent
---)
---```
---Each obj_key item may be a string, or a key-table entry with additional properties.
---Example:
---```lua
----- atlas.jokers.key refers to an atlas key
---replace_atlas_for(SMODS.Joker, atlas.jokers.key, {
---  -- Simple atlas replacement
---  "blue_joker",
---  -- Also replaces pos
---  wee = { pos = { x = 10, y = 1 } },
---  -- You can also specify an arbitrary string key with ["..."]
---  ["hologram"] = { soul_pos = { x = 10, y = 10 } },
---})
---```
---@param smods_obj any Needs a valid take_ownership() function
---@param atlas_key string
---@param obj_keys table<string, (string|table)> A list of object keys to replace. Each item may be a simple string like in an array, or a key with a table of additional properties to replace.
---@param silent boolean?
local function replace_atlas_for(smods_obj, atlas_key, obj_keys, silent)
	silent = silent or false
	log.debug(("Replacing atlas for %d objects with \"%s\""):format(#obj_keys, atlas_key))
	for k, v in pairs(obj_keys) do
		local obj_key
		local replace_table

		if type(k) == "number" then
			-- Assumed to be an array item - the value is the object key
			obj_key = v
			replace_table = {}
		else
			-- Table item - the key is the object key, the value is a list of additional properties
			obj_key = k
			replace_table = v
		end

		replace_table.atlas = atlas_key

		log.debug("\t" .. obj_key)
		local orig_o = smods_obj:take_ownership(obj_key, replace_table, silent)
		log.debug("\tNew object: \n" .. inspectDepth(orig_o, 2, 2))
	end
end

---@enum rankName
local RANK = {
	["2"] = "2",
	["3"] = "3",
	["4"] = "4",
	["5"] = "5",
	["6"] = "6",
	["7"] = "7",
	["8"] = "8",
	["9"] = "9",
	["10"] = "10",
	Two = "2",
	Three = "3",
	Four = "4",
	Five = "5",
	Six = "6",
	Seven = "7",
	Eight = "8",
	Nine = "9",
	Ten = "10",

	Jack = "Jack",
	Queen = "Queen",
	King = "King",
	Ace = "Ace",
	J = "Jack",
	Q = "Queen",
	K = "King",
	A = "Ace",
}

---@alias suit "Spades" | "Diamonds" | "Clubs" | "Hearts"
---@class RankDef
---@field x integer
---@field y integer

---Helper function for making a skin with multiple palettes
---@param suit suit Target suit
---@param key_suffix string Unique deck skin key suffix
---@param loc_txt? string|table Skin localized name
---@param ranks table<rankName, RankDef> Replaced ranks and their locations in the atlas
---@param display_ranks rankName[] Which card ranks should be show in the deck skin preview
---@param palettes table<string, { colour?: table, palette: Palette }> Skin palettes
---@return SMODS.DeckSkin
local function make_skin(suit, key_suffix, loc_txt, ranks, display_ranks, palettes)
	local skin_key = suit .. "_" .. key_suffix
	log.debug(("Registering skin %s (%s) for %s"):format(skin_key, loc_txt or "[Default name]", suit))
	local palette_array = {}
	-- Generate a table for all palettes
	for key, value in pairs(palettes) do
		local atlas_key = value.palette.atlas.key
		local palette_loc_txt = value.palette.loc_txt
		log.debug(("  Palette %s (%s) with atlas %s"):format(key, palette_loc_txt or "[Default name]", atlas_key))
		local pos_style = {}
		-- "ranks" needs to contain only the rank keys
		local rank_keys = {}

		-- Generate a pos_style entry for every item in ranks
		for rank, rank_pos in pairs(ranks) do
			log.debug(("    %s added at position [%d, %d]"):format(rank, rank_pos.x, rank_pos.y))
			pos_style[rank] = {
				atlas = atlas_key,
				pos = rank_pos,
			}
			table.insert(rank_keys, rank)
		end


		-- Add that to the palette array
		table.insert(palette_array, {
			key = key,
			ranks = rank_keys,
			display_ranks = display_ranks,
			atlas = atlas_key,
			pos_style = pos_style,
			loc_txt = palette_loc_txt,
			colour = value.colour,
		})
	end

	-- Note: add_palette() exists, but it's an internal function and shouldn't be used
	return SMODS.DeckSkin {
		key = skin_key,
		suit = suit,
		loc_txt = loc_txt,
		palettes = palette_array,
	}
end

--#endregion

--#endregion

--#region ===== Atlases =====

-- Key can be whatever, but may match the atlas_defs key
-- Image path is relative to 1x/ or 2x/
-- Uses the default 71x95 card resolution
local atlas = {
	cards_lc = make_atlas("cards_lc", "8BitDeck.png"),
	cards_hc = make_atlas("cards_hc", "8BitDeck_opt2.png"),
	jokers = make_atlas("jokers", "Jokers.png"),
	consumables = make_atlas("consumables", "Consumables.png"),
	enhancers = make_atlas("enhancers", "Enhancers.png"),
}

--#endregion

--#region ===== Skins =====

-- Skin palettes
---@class Palette
---@field atlas SMODS.Atlas
---@field loc_txt? string | table

---@type table<string, Palette>
local skin_palettes = {
	lc = {
		atlas = atlas.cards_lc,
		loc_txt = "Original Colors",
	},
	hc = {
		atlas = atlas.cards_hc,
		-- default loc_txt
	}
}

--Add entries for suit colors not changing correctly!

-- Key is generated automatically as [suit]_[key_suffix]
make_skin(
	"Spades",
	"1",
	"8-Bit Furries",
	{
		[RANK.Two] = { x = 0, y = 3 },
		[RANK.Three] = { x = 1, y = 3 },
		[RANK.Four] = { x = 2, y = 3 },
		[RANK.Five] = { x = 3, y = 3 },
		[RANK.Six] = { x = 4, y = 3 },
		[RANK.Seven] = { x = 5, y = 3 },
		[RANK.Eight] = { x = 6, y = 3 },
		[RANK.Nine] = { x = 7, y = 3 },
		[RANK.Ten] = { x = 8, y = 3 },
		[RANK.J] = { x = 9, y = 3 },
		[RANK.Q] = { x = 10, y = 3 },
		[RANK.K] = { x = 11, y = 3 },
		[RANK.A] = { x = 12, y = 3 },
	},
	{ RANK.A, RANK.K, RANK.Q, RANK.J },
	{
		lc = {
			colour = HEX("1b1b1b"),
			palette = skin_palettes.lc,
		},
		hc = {
			colour = HEX("851fc5"),
			palette = skin_palettes.hc,
		}
	}
)

make_skin(
	"Diamonds",
	"1",
	"8-Bit Furries",
	{
		[RANK.Two] = { x = 0, y = 2 },
		[RANK.Three] = { x = 1, y = 2 },
		[RANK.Four] = { x = 2, y = 2 },
		[RANK.Five] = { x = 3, y = 2 },
		[RANK.Six] = { x = 4, y = 2 },
		[RANK.Seven] = { x = 5, y = 2 },
		[RANK.Eight] = { x = 6, y = 2 },
		[RANK.Nine] = { x = 7, y = 2 },
		[RANK.Ten] = { x = 8, y = 2 },
		[RANK.J] = { x = 9, y = 2 },
		[RANK.Q] = { x = 10, y = 2 },
		[RANK.K] = { x = 11, y = 2 },
		[RANK.A] = { x = 12, y = 2 },
	},
	{ RANK.A, RANK.K, RANK.Q, RANK.J },
	{
		lc = {
			colour = HEX("d9400d"),
			palette = skin_palettes.lc,
		},
		hc = {
			colour = HEX("e39100"),
			palette = skin_palettes.hc,
		}
	}
)

make_skin(
	"Clubs",
	"1",
	"8-Bit Furries",
	{
		[RANK.Two] = { x = 0, y = 1 },
		[RANK.Three] = { x = 1, y = 1 },
		[RANK.Four] = { x = 2, y = 1 },
		[RANK.Five] = { x = 3, y = 1 },
		[RANK.Six] = { x = 4, y = 1 },
		[RANK.Seven] = { x = 5, y = 1 },
		[RANK.Eight] = { x = 6, y = 1 },
		[RANK.Nine] = { x = 7, y = 1 },
		[RANK.Ten] = { x = 8, y = 1 },
		[RANK.J] = { x = 9, y = 1 },
		[RANK.Q] = { x = 10, y = 1 },
		[RANK.K] = { x = 11, y = 1 },
		[RANK.A] = { x = 12, y = 1 },
	},
	{ RANK.A, RANK.K, RANK.Q, RANK.J },
	{
		lc = {
			colour = HEX("235955"),
			palette = skin_palettes.lc,
		},
		hc = {
			colour = HEX("008ee6"),
			palette = skin_palettes.hc,
		}
	}
)

make_skin(
	"Hearts",
	"1",
	"8-Bit Furries",
	{
		[RANK.Two] = { x = 0, y = 0 },
		[RANK.Three] = { x = 1, y = 0 },
		[RANK.Four] = { x = 2, y = 0 },
		[RANK.Five] = { x = 3, y = 0 },
		[RANK.Six] = { x = 4, y = 0 },
		[RANK.Seven] = { x = 5, y = 0 },
		[RANK.Eight] = { x = 6, y = 0 },
		[RANK.Nine] = { x = 7, y = 0 },
		[RANK.Ten] = { x = 8, y = 0 },
		[RANK.J] = { x = 9, y = 0 },
		[RANK.Q] = { x = 10, y = 0 },
		[RANK.K] = { x = 11, y = 0 },
		[RANK.A] = { x = 12, y = 0 },
	},
	{ RANK.A, RANK.K, RANK.Q, RANK.J },
	{
		lc = {
			colour = HEX("f03464"),
			palette = skin_palettes.lc,
		},
		hc = {
			colour = HEX("e32b1f"),
			palette = skin_palettes.hc,
		}
	}
)

--#endregion

--#region ===== Jokers =====

replace_atlas_for(SMODS.Joker, atlas.jokers.key, {
	--#region === Common ===
	"blue_joker",
	"cavendish",
	"green_joker",
	"gros_michel",
	"ice_cream",
	"joker",
	"splash",
	"riff_raff",
	--#endregion
	--#region ==-Uncommon ===
	"bootstraps",
	"ceremonial",
	"cloud_9",
	"constellation",
	"erosion",
	"fibonacci",
	"hack",
	hologram = { soul_pos = { x = 10, y = 10 } },
	"onyx_agate",
	oops = { soul_pos = { x = 10, y = 3 } },
	"rocket",
	"seeing_double",
	"smeared",
	"sock_and_buskin",
	"steel_joker",
	"trading",
	"vampire",
	--endregion
	--region ===Rare===
	"baron",
	"baseball",
	"campfire",
	"obelisk",
	stuntman = { soul_pos = { x = 10, y = 2 } },
	"trio",
	wee = { pos = { x = 10, y = 1 } },
	--#endregion
	--#region =====Legendary=====
	"caino",
	--#endregion
})

-- This removes the glitch effects from Hologram
---@type function
local floating_sprite_original_func = SMODS.DrawSteps['floating_sprite'].func

SMODS.DrawStep:take_ownership('floating_sprite',
	{
		-- We capture the original function outside, and wrap it with our own
		-- If the card is Hologram, we temporarily remove the ability name, which renders it with the regular shader
		func = function(self)
			if self.ability.name == 'Hologram' then
				self.ability.name = '' -- Yoink the ability name to skip rendering the shader
				floating_sprite_original_func(self)
				self.ability.name = 'Hologram' -- put it back
			else
				floating_sprite_original_func(self)
			end
		end,
	}, true
)

--#endregion

--#region ===== Consumables =====

replace_atlas_for(SMODS.Consumable, atlas.consumables.key, {
	--#region ===== Tarots =====
	"chariot",
	"fool",
	"hanged_man",
	"high_priestess",
	"tower",
	--#endregion
	--#region ===== Spectrals =====
	"immolate",
	"medium",
	"soul",
	"trance"
	--#endregion
})

-- Override The Soul floating sprite, since it's not actually a floating_sprite for some reason (and so it doesn't use soul_pos)
-- This needs to be called after our atlases are loaded, hence the event manager
G.E_MANAGER:add_event(Event({
	trigger = "immediate",
	blocking = false,
	blockable = false,
	func = function()
		log.debug("Modifying shared_soul")
		G.shared_soul = Sprite(
			0, 0, atlas.consumables.px, atlas.consumables.py, -- card dimensions
			G.ASSET_ATLAS[atlas.consumables.key],    -- A direct reference to the already-loaded mod atlas
			{ x = 6, y = 5 }                         -- card sprite pos (like soul_pos)
		)
		return true                                  -- if true isn't returned, this would be called every frame
	end
}))

--#endregion

--#region ===== Editions/Seals/Extra =====

replace_atlas_for(SMODS.Seal, atlas.enhancers.key, {
	"Purple",
})

replace_atlas_for(SMODS.Seal, atlas.enhancers.key, {
	"Blue",
})

replace_atlas_for(SMODS.Enhancement, atlas.enhancers.key, {
	"stone",
})

--endregion
