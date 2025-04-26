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
--#region === Common ===


SMODS.Joker:take_ownership('blue_joker',
	{
		atlas = atlas.jokers.key,
		pos = { x = 7, y = 10 },
		loc_txt = {
			name = "Blue",
			text = {
				"{C:chips}+#1#{} Chips for each",
				"remaining card in {C:attention}deck",
				"{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)",
				"{C:chips,s:0.9}A noble Sea Slug"
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('cavendish',
	{
		atlas = atlas.jokers.key,
		pos = { x = 5, y = 11 },
		loc_txt = {
			name = "Banangry",
			text = {
				"{X:mult,C:white} X#1# {} Mult",
                "{C:green}#2# in #3#{} chance this",
                "card is destroyed",
                "at end of round",
				"{C:mult,s:0.9}Now you've upset him >:c",
				"{C:attention,s:0.8}Art by FuzzyRemi!",
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('green_joker',
	{
		atlas = atlas.jokers.key,
		pos = { x = 2, y = 11 },
		loc_txt = {
			name = "Green Joker",
			text = {
				"{C:mult}+#1#{} Mult per hand played",
                "{C:mult}-#2#{} Mult per discard",
                "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult)",
				--"{C:blue,s:1.1}discord.gg/RXqc9wxWHs",
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('gros_michel',
	{
		atlas = atlas.jokers.key,
		pos = { x = 7, y = 6 },
		loc_txt = {
			name = "Banana",
			text = {
				"{C:mult}+#1#{} Mult",
                "{C:green}#2# in #3#{} chance this",
                "card is destroyed",
                "at end of round",
				"{C:blue,s:0.9}:P",
				"{C:attention,s:0.8}Art by FuzzyRemi!",
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('ice_cream',
	{
		atlas = atlas.jokers.key,
		pos = { x = 4, y = 10 },
		loc_txt = {
			name = "Bedi",
			text = {
				"{C:chips}+#1#{} Chips",
				"{C:chips}-#2#{} Chips for",
				"every hand played",
				"{C:green,s:0.9}Yap!"
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('joker',
	{
		atlas = atlas.jokers.key,
		pos = { x = 0, y = 0 },
		loc_txt = {
			name = "Jimbo",
			text = {
				"{C:red,s:1.1}+#1#{} Mult",
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('splash',
	{
		atlas = atlas.jokers.key,
		pos = { x = 6, y = 10 },
		loc_txt = {
			name = "Kink",
			text = {
				"Every {C:attention}played card",
                "counts in scoring",
				"{C:blue,s:0.9}Big fish!",
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

--#endregion
--#region ==-Uncommon ===

SMODS.Joker:take_ownership('bootstraps',
	{
		atlas = atlas.jokers.key,
		pos = { x = 9, y = 8 },
		loc_txt = {
			name = "Socks",
			text = {
				"{C:mult}+#1#{} Mult for every",
                "{C:money}$#2#{} you have",
                "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult)",
				"{C:attention,s:0.8}Pick yourself up by your... socks",
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('ceremonial',
	{
		atlas = atlas.jokers.key,
		pos = { x = 5, y = 5 },
		loc_txt = {
			name = "Lagos",
			text = {
				"When {C:attention}Blind{} is selected,",
				"destroy Joker to the right",
				"and permanently add {C:attention}double",
				"its sell value to this {C:red}Mult",
				"{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult)",
				"{C:purple,s:0.8}Always hungry...",
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('cloud_9',
	{
		atlas = atlas.jokers.key,
		pos = { x = 7, y = 12 },
		loc_txt = {
			name = "Stratus",
			text = {
				"Earn {C:money}$#1#{} for each",
                "{C:attention}9{} in your {C:attention}full deck",
                "at end of round",
                "{C:inactive}(Currently {C:money}$#2#{}{C:inactive})",
				"{C:blue,s:0.8}Cozy Cloudbeast",
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('constellation',
	{
		atlas = atlas.jokers.key,
		pos = { x = 9, y = 10 },
		loc_txt = {
			name = "Akashi",
			text = {
				"This fay gains",
                "{X:mult,C:white} X#1# {} Mult every time",
                "a {C:planet}Planet{} card is used",
                "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
				"{C:purple,s:0.9}Glittering stars",
				"{C:red,s:0.8}Art by FuzzyRemi!",
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('erosion',
	{
		atlas = atlas.jokers.key,
		pos = { x = 5, y = 13 },
		loc_txt = {
			name = "Valyx",
			text = {
				"{C:red}+#1#{} Mult for each",
                "card below {C:attention}#3#{}",
                "in your full deck",
                "{C:inactive}(Currently {C:red}+#2#{C:inactive} Mult)",
				"{C:chips,s:0.9}The Crocodragon's healing power"
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('fibonacci',
	{
		atlas = atlas.jokers.key,
		pos = { x = 1, y = 5 },
		loc_txt = {
			name = "Lorcan",
			text = {
				"Each played {C:attention}Ace{},",
				"{C:attention}2{}, {C:attention}3{}, {C:attention}5{}, or {C:attention}8{} gives",
				"{C:mult}+#1#{} Mult when scored",
				"{C:green,s:0.9}Gorp!"
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('hack',
	{
		atlas = atlas.jokers.key,
		pos = { x = 5, y = 2 },
		loc_txt = {
			name = "Serkular",
			text = {
				"Retrigger",
                "each played",
                "{C:attention}2{}, {C:attention}3{}, {C:attention}4{}, or {C:attention}5{}",
				"{C:red,s:0.8}The best jokes around"
                },
			},
		},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('hologram',
	{
		atlas = atlas.jokers.key,
		pos = { x = 4, y = 12 },
		soul_pos = { x = 10, y = 10 },
		loc_txt = {
			name = "Lischer Voge",
			text = {
				"This bird gains {X:mult,C:white} X#1# {} Mult",
				"every time a {C:attention}playing card{}",
				"is added to your deck",
				"{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('onyx_agate',
	{
		atlas = atlas.jokers.key,
		pos = { x = 2, y = 8 },
		loc_txt = {
			name = "Rhasakani",
			text = {
				"Played cards with",
                "{C:clubs}Club{} suit give",
                "{C:mult}+#1#{} Mult when scored",
				"{C:blue,s:0.9}Shiny~"
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('oops',
	{
		atlas = atlas.jokers.key,
		pos = { x = 5, y = 6 },
		soul_pos = { x = 10, y = 3 },
		loc_txt = {
			name = "Xenon",
			text = {
				"Doubles all {C:attention}listed",
                "{C:green,E:1,S:1.1}probabilities",
                "{C:inactive}(ex: {C:green}1 in 3{C:inactive} -> {C:green}2 in 3{C:inactive})",
				"{C:red,s:0.9}He gave me loaded dice!"
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('rocket',
	{
		atlas = atlas.jokers.key,
		pos = { x = 8, y = 12 },
		loc_txt = {
			name = "Einarr",
			text = {
				"Earn {C:money}$#1#{} at end of round",
				"Payout increases by {C:money}$#2#{}",
				"when {C:attention}Boss Blind{} is defeated",
				"{C:red,s:0.9}Reach for the stars"
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('seeing_double',
	{
		atlas = atlas.jokers.key,
		pos = { x = 4, y = 4 },
		loc_txt = {
			name = "Malthy",
			text = {
				"{X:mult,C:white} X#1# {} Mult if played",
                "hand has a scoring",
                "{C:clubs}Club{} card and a scoring",
                "card of any other {C:attention}suit",
				"{C:blue,s:0.8}Different, yet the same"
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('smeared',
	{
		atlas = atlas.jokers.key,
		pos = { x = 4, y = 6 },
		loc_txt = {
			name = "Smeared Kobold",
			text = {
				"{C:hearts}Hearts{} and {C:diamonds}Diamonds",
				"count as the same suit,",
				"{C:spades}Spades{} and {C:clubs}Clubs",
				"count as the same suit",
				"{C:attention,s:0.8}Art by Boldarts!"
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('sock_and_buskin',
	{
		atlas = atlas.jokers.key,
		pos = { x = 3, y = 1 },
		loc_txt = {
			name = "Jaitsu",
			text = {
				"Retrigger all",
				"played {C:attention}face{} cards",
				"{C:inactive,s:0.9}Jock and Juskin"
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('steel_joker',
	{
		atlas = atlas.jokers.key,
		pos = { x = 7, y = 2 },
		loc_txt = {
			name = "Metaflame",
			text = {
				"Gives {X:mult,C:white} X#1# {} Mult",
				"for each {C:attention}Steel Card",
				"in your {C:attention}full deck",
				"{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
				"{C:planet,s:0.9}Beep",
				"{C:red,s:0.8}Art by LaserFire!",
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('trading',
	{
		atlas = atlas.jokers.key,
		pos = { x = 9, y = 14 },
		loc_txt = {
			name = "Kusarii",
			text = {
				"If {C:attention}first discard{} of round",
				"has only {C:attention}1{} card,",
				"destroy it and earn {C:money}$#1#",
				"{C:purple,s:0.8}Art by KusariiBites!",
			},
		},
	},
	false -- true = silent | suppresses mod badge
)


--endregion
--region ===Rares===


SMODS.Joker:take_ownership('baron',
	{
		atlas = atlas.jokers.key,
		pos = { x = 6, y = 12 },
		loc_txt = {
			name = "Giga",
			text = {
				"Each {C:attention}King{}",
                "held in hand",
                "gives {X:mult,C:white} X#1# {} Mult",
				"{C:blue,s:0.9}Submit to the King's icy glare"
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('baseball',
	{
		atlas = atlas.jokers.key,
		pos = { x = 6, y = 14 },
		loc_txt = {
			name = "Fletcher",
			text = {
				"{C:green}Uncommon{} Jokers",
                "each give {X:mult,C:white} X#1# {} Mult",
				"{C:attention,s:0.9}Stylish noodle"
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('campfire',
	{
		atlas = atlas.jokers.key,
		pos = { x = 5, y = 15 },
		loc_txt = {
			name = "Apolar",
			text = {
				"This Joker gains {X:mult,C:white}X#1#{} Mult",
				"for each card {C:attention}sold{}, resets",
				"when {C:attention}Boss Blind{} is defeated",
				"{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
				"{C:red,s:0.9}A cozy spot to rest"
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('obelisk',
	{
		atlas = atlas.jokers.key,
		pos = { x = 9, y = 12 },
		loc_txt = {
			name = "Borruhn",
			text = {
				"This Coga gains {X:mult,C:white} X#1# {} Mult",
				"per {C:attention}consecutive{} hand played",
				"without playing your",
				"most played {C:attention}poker hand",
				"{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
				"{C:mult,s:0.7}Tummy :3",
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('stuntman',
	{
		atlas = atlas.jokers.key,
		pos = { x = 8, y = 6 },
		soul_pos = { x = 10, y = 2 },
		loc_txt = {
			name = "Rider and Ryune",
			text = {
				"{C:chips}+#1#{} Chips,",
                "{C:attention}-#2#{} hand size",
				"{C:mult,s:0.9}I've got you, little one",
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('trio',
	{
		atlas = atlas.jokers.key,
		pos = { x = 6, y = 4 },
		loc_txt = {
			name = "Esker",
			text = {
				"{X:mult,C:white} X#1# {} Mult if played",
				"hand contains",
				"a {C:attention}#2#",
				"{C:red,s:0.9}Three eyes grant their power"
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Joker:take_ownership('wee',
	{
		atlas = atlas.jokers.key,
		pos = { x = 10, y = 1 },
		loc_txt = {
			name = "Lil Guy",
			text = {
				"This lil guy gains",
				"{C:chips}+#2#{} Chips when each",
				"played {C:attention}2{} is scored",
				"{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips)",
				"{C:red,s:0.9}Just a lil guy!",
				"{C:attention,s:0.8}Art by DaxlMonitor!",
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

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
--#region =====What?=====
--SMODS.Joker {
--	key = 'The_Start',
--	loc_txt = {
--		name = 'Hastagazpacho',
--		text = {
--			"{s:1.1}My role is to carry part of the message.",
--			"{s:1.1}Follow the sound of my music",
--			"{s:1.1}Find {C:red}Chris Rawlings{}, he can",
--			"{s:1.1}tell you the {C:red}12-digit code{}",
--			"DM the code to Ithanias!"
--
--		}
--	},
--	config = { extra = { chips = 1 } },
--	loc_vars = function(self, info_queue, card)
--		return { vars = { card.ability.extra.chips } }
--	end,
--	rarity = 4,
--	atlas = atlas.jokers.key,
--	pos = { x = 11, y = 4 },
--	cost = 0,
--	calculate = function(self, card, context)
--		if context.joker_main then
--			return {
--				mult_mod = card.ability.extra.chips,
--
--				message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips } }
--			}
--		end
--	end
--}

--#endregion

SMODS.Joker:take_ownership('caino',
	{
		atlas = atlas.jokers.key,
		pos = { x = 3, y = 8 },
		soul_pos = { x = 3, y = 9 },
		loc_txt = {
			name = "Kornio",
			text = {
				"This dragon gains {X:mult,C:white} X#1# {} Mult",
				"when a {C:attention}face{} card is destroyed",
				"{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
				"{C:red,s:0.9}Art by RenTradewind!",
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

--#endregion

--#region ===== Consumables =====

--#region ===== Tarots =====
--For all consumables, redefine loc_vars and provide base game variables again

SMODS.Consumable:take_ownership('chariot',
	{
		atlas = atlas.consumables.key,
		pos = { x = 7, y = 0 },
		loc_txt = {
			name = "Frank",
			text = {
				"Enhances {C:attention}#2#{} selected",
				"card into a",
				"{C:attention}#1#",
			},
		},
		loc_vars = function(self, info_queue, card)
			info_queue[#info_queue+1] = G.P_CENTERS.m_steel
			return {
				vars = {
					-- Fun fact! the game *specifically* localizes the card name for tarot cards (etc.) so we gotta do it here too!
					-- localize() is a base-game function from misc_functions
					localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv },
					card.ability.max_highlighted
				}
			}
		end,
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Consumable:take_ownership('fool',
    {
        atlas = atlas.consumables.key,
        pos = { x = 0, y = 0 },
        loc_txt = {
            name = "Foolsnapz",
            text = {
                "Creates the last",
                "{C:tarot}Tarot{} or {C:planet}Planet{} card",
                "used during this run",
                "{s:0.9,C:tarot}Just one!",
            },
        },
        loc_vars = function(self, info_queue, card)
            -- Copied from the base game
            local fool_c = G.GAME.last_tarot_planet and G.P_CENTERS[G.GAME.last_tarot_planet] or nil
            local last_tarot_planet = fool_c and localize { type = 'name_text', key = fool_c.key, set = fool_c.set } or
                localize('k_none')
            local colour = (not fool_c or fool_c.name == 'The Fool') and G.C.RED or G.C.GREEN
            local main_end = {
                {
                    n = G.UIT.C,
                    config = { align = "bm", padding = 0.02 },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = { align = "m", colour = colour, r = 0.05, padding = 0.05 },
                            nodes = {
                                { n = G.UIT.T, config = { text = ' ' .. last_tarot_planet .. ' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true } },
                            }
                        }
                    }
                }
            }
            local loc_vars = { last_tarot_planet }
            if not (not fool_c or fool_c.name == 'The Fool') then
                info_queue[#info_queue + 1] = fool_c
            end

            return {
                vars = loc_vars,
                main_end = main_end,
            }
        end,
    },
    false -- true = silent | suppresses mod badge
)

SMODS.Consumable:take_ownership('hanged_man',
	{
		atlas = atlas.consumables.key,
		pos = { x = 2, y = 1 },
		loc_txt = {
			name = "Varghus",
			text = {
				"Destroys up to",
                "{C:attention}#1#{} selected cards",
				"{C:black,s:0.9}Lost in black wings"
			},
		},
		loc_vars = function(self, info_queue, card)
			return { vars = { card.ability.max_highlighted } }
		end,
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Consumable:take_ownership('high_priestess',
	{
		atlas = atlas.consumables.key,
		pos = { x = 2, y = 0 },
		loc_txt = {
			name = "Echo",
			text = {
				"Creates up to {C:attention}#1#",
				"random {C:planet}Planet{} cards",
				"{C:inactive}(Must have room)",
				"{C:blue,s:0.9}Celestial flames"
			},
		},
		loc_vars = function(self, info_queue, card)
			return { vars = { card.ability.planets } }
		end,
	},
	false -- true = silent | suppresses mod badge
)


SMODS.Consumable:take_ownership('tower',
	{
		atlas = atlas.consumables.key,
		pos = { x = 6, y = 1 },
		loc_txt = {
			name = "Degyn",
			text = {
				"Enhances {C:attention}#2#{} selected",
				"card into an",
				"{C:attention}#1#",
			},
		},
		loc_vars = function(self, info_queue, card)
			info_queue[#info_queue+1] = G.P_CENTERS.m_stone
			return {
				vars = {
					localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv },
					card.ability.max_highlighted
				}
			}
		end,
	},
	false -- true = silent | suppresses mod badge
)
--#endregion
--#region ===== Spectrals =====
SMODS.Consumable:take_ownership('immolate',
	{
		atlas = atlas.consumables.key,
		pos = { x = 9, y = 4 },
		loc_txt = {
			name = "Immolate",
			text = {
				"Destroys {C:attention}#1#{} random",
				"cards in hand,",
				"gain {C:money}$#2#",
				"{C:inactive,s:0.9}Dragon insurance pays off"
			},
		},
		loc_vars = function(self, info_queue, card)
			return { vars = { card.ability.extra.destroy, card.ability.extra.dollars } }
		end,
	},
	false -- true = silent | suppresses mod badge
)


SMODS.Consumable:take_ownership('medium',
	{
		atlas = atlas.consumables.key,
		pos = { x = 4, y = 5 },
		loc_txt = {
			name = "Void Gift",
			text = {
				"One card receives the",
				"{C:purple}Reaper's Mark{}",
			},
		},
		loc_vars = function (self, info_queue, card)
			info_queue[#info_queue+1] = {key = 'purple_seal', set = 'Other'}
		end
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Consumable:take_ownership('soul',
	{
		atlas = atlas.consumables.key,
		pos = { x = 2, y = 2 },
		-- soul_pos = { x = 6, y = 5 }, -- this would have worked if the game didn't use G.shared_soul for just this one card for some reason
		loc_txt = {
			name = "Oh Snap(z)!",
			text = {
				"{C:legendary,E:1,s:0.8}A rat!{}",
				"Creates a {C:legendary}Legendary{} Joker"
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

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
--#endregion

--#region ===== Editions/Seals/Extra =====

SMODS.Seal:take_ownership('Purple',
	{
		atlas = atlas.enhancers.key,
		pos = { x = 4, y = 4 },
		loc_txt = {
			name = "Reaper's Mark",
			text = {
				"Creates a {C:tarot}Tarot{} card",
				"when {C:attention}discarded",
				"{C:inactive}(Must have room)",
				"{C:tarot,s:0.9}A gift from the Void",
			},
		},
	},
	false -- true = silent | suppresses mod badge
)

SMODS.Enhancement:take_ownership('stone',
	{
		atlas = atlas.enhancers.key,
		pos = { x = 5, y = 0 },
		loc_txt = {
			name = "Obscured Card",
			text = {
				"{C:chips}+#1#{} Chips",
                "no rank or suit",
			},
		},
		loc_vars = function(self, info_queue, card)
			return { vars = { card.ability.bonus } }
		end,
	},
	false -- true = silent | suppresses mod badge
)

--endregion
