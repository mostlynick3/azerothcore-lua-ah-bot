-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
--
-- Welcome to mostlynick's Eluna AH Bot :)
--
-- Features: * Plug and Play *, * Extensive filters *, * Buyer *, * Seller *, * Both bids and buyouts *, * and more *
-- This module is compatible with all Eluna versions that support async DB queries.
-- Made for Yggdrasil WotLK / AzerothCore. 
-- You may freely use this file for emulation purposes. It is released under this repository's GPL v3 license: https://github.com/mostlynick3/azerothcore-lua-ah-bot
--
-------------------------------------------------------------------------------------------------------------------------
-- AH Bot Configs
-------------------------------------------------------------------------------------------------------------------------

local EnableAHBot			= true			-- Default: True. If false, AH bot is disabled. 
local AHBots				= {1, 2, 3}		-- Default: 1, 2, 3. Chooses which player GUID lows will be used as AH bots. Must match extant characters. Not faction specific.
local EnabledAuctionHouses	= {2, 6, 7}			-- Default: 2, 6, 7. Possible values: 2 is ally, 6 is horde, 7 is cross faction (neutral). Multiple values accepted, like {2, 6, 7}. Only 7 is required on cross-faction servers.
local AHBotActionDebug		= true			-- Default: False. Enables various action debug prints. Critical prints will still be active even if false.
local AHBotItemDebug		= false			-- Default: False. Enables debug prints on item handling, cost per item entry, Quality, etc.
local ActionsPerCycle		= 500			-- Default: 500 (items). The higher the value, the faster the bots fill the AH up to the min auctions limit and the more items they buy, at the expense of performance.
local StartupDelay 			= 1000			-- Default: 1000 (ms). Delay after startup/Eluna reload before the auction house initializes. Having this set to 0 will cause lag on initial world load. 
local EnableGMMessages		= true			-- Default: True. Messages all online GMs on command and initiation events.
local AnnounceOnLogin		= true			-- Default: True. Announces to all players on login that this server runs the Eluna AH Bot module.

-------------------------------------------------------------------------------------------------------------------------
-- Buyer Configs
-------------------------------------------------------------------------------------------------------------------------

local EnableBuyer			= true			-- Default: True.
local AHBuyTimer 			= 0.5 			-- Default: 0.5 (hours). How often the AH bot will try to purchase a few items.
local ItemLevelLimit 		= 187			-- Default: 187. Prevents bots from buying items above this item level, to ensure players get access to those items instead.
local BotsBuyFromBots		= false			-- Default: False. Prevent bots from buying other bots' items.
local CostFormula 			= 1     		-- Default: 1. 1 = Quality based scaling, 2 = Entry ID influenced, 3 = Quality/Level focused, 4 = Balanced multi-factor, 5 = Progressive thresholds, 6 = Random (1000-1000000)
local BotsPriceTolerance	= 1.5			-- Default: 1.5. Factor with which unadjusted CostFormula is multiplied to return how much a bot is willing to pay for an item. 
local PlaceBidChance		= 20			-- Default: 10 (%). Setting to 0 disables bids. 
local PlaceBuyoutChance		= 10			-- Default: 5 (%). Settings to 0 disables buyouts.
local BuyOnStartup			= true			-- Default: True. Buyer bot will start buying auctions immediately on server start, instead of on AHBuyTimer. If false, will still activate on AHBuyTimer. 
local DisableBidFight		= true			-- Default: True. Don't place bids/buyouts on items that players have already placed bids on

-------------------------------------------------------------------------------------------------------------------------
-- Seller Configs
-------------------------------------------------------------------------------------------------------------------------

local EnableSeller			= true			-- Default: True.
local MaxAuctions 			= 10000			-- Default: 5000. Max number of auctions posted by the AH bot.
local MinAuctions			= 2000	 		-- Default: 2000. Min number of auctions. If under this value, AH will repopulate sales. If over, but less than max, has 30% chance per check to populate AH.
local RepopulationChance	= 30			-- Default: 30. Percentage chance to partially restock AH if stock is between max and min during a periodical check. Can be overriden to force populate whenever with ".ahbot auctions add". 
local CostFormula 			= 1 	    	-- Default: 1. 1 = Quality based scaling, 2 = Entry ID influenced, 3 = Quality/Level focused, 4 = Balanced multi-factor, 5 = Progressive thresholds, 6 = Random (1000-1000000)
local SellPriceVariance		= 20			-- Default: 20. How many % to randomize prices with. 
local AHSellTimer 			= 5 			-- Default: 5 (hours). How often the AH bot will check whether it needs to put up new auctions, in hours.
local SellOnStartup			= true			-- Default: True. Used for debugging and instantly populating an empty auction house. If true, fires AH bot on Eluna load (startup / Eluna reloads). If false, activates on AHSellTimer. 
local ApplyRandomProperties = true			-- Default: True. Adds enchant/random stats and corresponding name to items (e.g., "of the Eagle"). This is DBC-based with Lua tables copied into this script. Disable if non-WotLK core.
local SetAsCraftedBy		= true			-- Default: True. Marks items created by player spells as created by the AH bot posting the item.

-------------------------------------------------------------------------------------------------------------------------
-- Item Seller Filter Configs
-------------------------------------------------------------------------------------------------------------------------

-- General Item Filters
local Expansion				= 0									-- Default: 0 (no expansion lock). Possible values: 0 (no expansion lock), 1 (Vanilla, patch 1.12), 2 (TBC, patch 2.4.3), 3 (WotLK, patch 3.3.5a). Any expansion filter makes bots includes all items in the item_template database table per expansion.
local EnableItemFilters		= true								-- Default: True. Disable only for debugging.
local AllowDeprecated 		= false								-- Default: False. Items with flag 16 (Deprecated) or name like NPC, zzOLD, etc. will not be sold.
local AllowedBinds 			= {0, 2, 3} 						-- Default: 0, 2, 3. 0 = no bounds, 1 = Bind on Pickup, 2 = Bind on Equip, 3 = Bind on Use, 4-5 Quest Items (see also AllowQuestItems to control quest item sales).
local AllowBindOnAccount	= false								-- Default: False. Decides whether BoA items (e.g., hierlooms) can be sold by the AH bot.
local AllowedQualities		= {1, 2, 3, 4}						-- Default: 1, 2, 3, 4. 0 = Gray/Poor, 1 = White/Common, 2 = Green/Uncommon, 3 = Blue/Rare, 4 = Purple/Epic, 5 = Orange/Legendary, 6 = Red/Artifact, 7 = Gold/Heirloom.
local AllowQuestItems		= false								-- Default: False.
local AllowConsumables		= true								-- Default: True. Toggles selling consumables (potions, elixirs, etc.).
local MinContainerSize		= 16								-- Default: 16. Don't allow selling containers (including quivers, bags, etc.) under specified size.
local MinLevelConsumables	= 50								-- Default: 50. Prevents the AH bot from flooding the market with low level junk.
local MinLevelGear			= 10								-- Default: 10. Prevents the AH bot from flooding the market with low level junk and unobtainable starter items.
local MaxLevel				= 80								-- Default: 80. The AH bot will not sell any item with a level limit exceeding this value.
local StackedItemClasses	= {0, 5, 6, 7}						-- Default: 0, 5, 6, 7. Sells stacks between 50-100% of max stack size. Possible values: 0 (Consumable), 1 (Container), 2 (Weapon), 3 (Gem), 4 (Armor), 5 (Reagent), 6 (Projectile), 7 (Trade Goods), 9 (Recipe), 11 (Quiver), 12 (Quest), 13 (Key) 15 (Miscellaneous), 16 (Glyph).
local AlwaysMaxStackAmmo	= true								-- Default: True. If true, always sells ammo in stacks of 1000.
local AdjustedAmmoPrices 	= true								-- Default: True. Ammo price variables are inconsistent. This adjusts ammunition prices to realistic in-game prices. For example, Iceblade Arrows are set to between 20g-35g per stack.
local AllowCommonAmmo		= false								-- Defualt: False. Common ammo is just dead weight.
local AllowReputationItems 	= false								-- Default: False.
local AllowMounts			= false								-- Default: False. If true, the X-51 rocket has a tendency to show up.
local AllowCompanions		= true								-- Default: True. 

-- Character and Race Filters
local AllowedClassItems		= {-1} 									-- Default: -1. Possible values: -1 (Items with no class restrictions), 1 (Warrior), 2 (Paladin), 3 (Hunter), 4 (Rogue), 5 (Priest), 6 (DK), 7 (Shaman), 9 (Warlock), 11 (Druid). Table accepts multiple values, such as {-1, 1, 2, 3}.
local AllowedAllyRaces		= {-1, 1, 4, 8, 64, 1024, 2147483647}	-- Default: -1, 1, 4, 8, 64, 1024, 2147483647 (All races and all raceless items). Possible values: 1 (Human), 2 (Orc), 4 (Dwarf), 8 (Night Elf), 16 (Undead), 32 (Tauren), 64 (Gnome), 128 (Troll), 512 (Blood Elf), 1024 (Draenei), -1 and 2147483647 (all races).
local AllowedHordeRaces		= {-1, 2, 16, 32, 128, 512, 2147483647}	-- Default: -1, 2, 16, 32, 128, 512, 2147483647 (All races and all raceless items). Possible values: 1 (Human), 2 (Orc), 4 (Dwarf), 8 (Night Elf), 16 (Undead), 32 (Tauren), 64 (Gnome), 128 (Troll), 512 (Blood Elf), 1024 (Draenei), -1 and 2147483647 (all races).

-- Profession Filters
local AllowedProfessions 	= {8, 16, 32, 64, 128, 512, 1024} 	-- Default: 8, 16, 32, 64, 128, 512, 1024. Possible values: 8 (Leatherworking Supplies), 16 (Inscription Supplies), 32 (Herbs), 64 (Enchanting Supplies), 128 (Engineering Supplies), 512 (Gems), 1024 (Mining Supplies).
local AllowLockpicking		= true								-- Default: True. Toggles lockboxes, etc.
local AllowGlyphs			= true								-- Default: True. Toggles selling glyphs.
local AllowRecipes			= true								-- Default: True. Toggles profession recipes.
local RecipePriceAdjustment = 10								-- Default: 10. Factor to increase recipe prices by. These are usually low in price because their associated variables are low. Set to false to disable.
local GemPriceAdjustment	= 0.142								-- Default: 1/7. Factor to decrease gem prices by. These are usually high in price because their associated variables are high. Set to false to disable.
local UndervaluedItemAdjust	= 5									-- Default: 5. Vellums, Titanium materials, VIII scrolls etc. are usually somewhat undervalued. Set to false to disable.
local LowPriceFloor			= 200000							-- Default: 200000 (20g). Price floor for certain items where multipliers don't work well. Companions, glyphs, etc. Randomized +- 30% around this base cost. If nil, defaults to UndervaluedItemAdjust.

-- Misc Config
local AllowKeys				= false								-- Default: False.
local AllowMisc				= false								-- Default: False. If enabled, allows Soul Shards, Currency Tokens and "Misc Other" items (item_template class 15, subclass 4).
local AllowJunk				= true								-- Default: True. Toggles junk, such as fishing boxes.
local AllowHolidayItems		= false								-- Default: False. Toggles holiday/seasonal items.
local AllowConjured			= false								-- Default: False. Toggles conjured items like mage strudels.

-- Seller Item Weights
-- The weight is always relative to the total set and number of items in the category.
-- The way it works is that it feeds all the items of the class/ID X times into the weight tables,
-- increasing the bool we can pick items from with duplicates of higher weighted categories.
-- Increasing one value will supplant the value of the other values.
local ItemWeights = {
    Gear = {
        ["Gray/Poor"] 			= 0,
        ["White/Common"] 		= 0.1,
        ["Green/Uncommon"] 		= 25,
        ["Blue/Rare"]			= 15,
        ["Purple/Epic"] 		= 5,
        ["Orange/Legendary"] 	= 0,
        ["Red/Artifact"] 		= 0,
        ["Gold/Heirloom"]		= 0
    },
    Mats = {
        ["Gray/Poor"] 			= 0,
        ["White/Common"] 		= 2,
        ["Green/Uncommon"] 		= 30,
        ["Blue/Rare"] 			= 10,
        ["Purple/Epic"] 		= 1,
        ["Orange/Legendary"] 	= 0,
        ["Red/Artifact"] 		= 0,
        ["Gold/Heirloom"]		= 0
    },
    Glyph = 10,
    Projectile = 5,
    Other = 20,
    SpecificItems = {
		-- Example items to include that the auction house bots will weigh as separate categories.
		-- Adding weights per item ID here can, for example, ensure that they are always sold by the AH in a desired (relative) quantity.
		-- Example below: Frostweave Bag
		-- [41599] = 2, -- Frostweave Bag
		-- Add more items with the following structure:
		-- [Item ID] = Weight,
	},
}

-- Customizable item ID exclusion filters
local NeverSellIDs			= {									-- Default: Various items not intended for AH sale. Append list by adding new "<item_entry>," rows. 
							   52252, -- Lightbringer Tabard	-- Additions here append to the SQL "NAME NOT" list. 
							   44663, -- Adventurer's Satchel
							   54822, -- Sen'Jin's Overcloak
							   37201, -- Corpse Dust
							   17195, -- Fake Mistletoe
							   44432, -- China Glyph of Raise Dead??
							    4439, -- Wooden Stock, vendor trash
							   40533, -- Electrified blade, unobtainable item
							   30418, -- Unused polearm
							   -- Deprecated Classic mounts
							   1041, 1133, 1134, 2413, 2415, 5663, 5874, 5875, 
							   8583, 8589, 8590, 8627, 8628, 8630, 8633, 14062,
							   -- Add more item IDs if needed
							   }

-------------------------------------------------------------------------------------------------------------------------
-- Do not edit below this line unless you know what you're doing
-------------------------------------------------------------------------------------------------------------------------

if not EnableAHBot then return end

-------------------------------------------------------------------------------------------------------------------------
-- Helper functions, tables, etc.
-------------------------------------------------------------------------------------------------------------------------

-- As the core iterates upwards through auction IDs from the highest extrant value on startup,
-- we must insert either far above or far below this value. The caveat of this is that, on 
-- reload eluna, we can't tell whether an insert was made on the same session as Eluna
-- can't access the core's AH counter. So, we're tracking server startup instead and assigning
-- a tag to all inserts to identify which we can safely go below and which we must be above.

local AddedByEluna = 1 -- 0 means created by the core, 1 means created by Eluna

local function TagElunaAuctions(event)
    CharDBQueryAsync("SHOW COLUMNS FROM auctionhouse LIKE 'AddedByEluna'", function(result) -- Checks if tracker exists directly from table structure
        if not result and not (event == 14) then -- Check if any row is returned, indicating the column exists. FetchRow attempts to get the first row, if it fails (returns nil), then no column exists.
            CharDBExecute("ALTER TABLE auctionhouse ADD COLUMN AddedByEluna INT NOT NULL DEFAULT 0") -- Adds the column if it doesn't exist
        elseif event == 14 then
            CharDBExecute("UPDATE auctionhouse SET AddedByEluna = 0 WHERE AddedByEluna > 0") -- Ensures all entries tracked by the core are reset on event 14
        end
    end)
    CharDBQueryAsync("SHOW COLUMNS FROM item_instance LIKE 'AddedByEluna'", function(result) -- Checks if tracker exists directly from table structure
        if not result and not (event == 14) then -- Check if any row is returned, indicating the column exists. FetchRow attempts to get the first row, if it fails (returns nil), then no column exists.
            CharDBExecute("ALTER TABLE item_instance ADD COLUMN AddedByEluna INT NOT NULL DEFAULT 0") -- Adds the column if it doesn't exist
        elseif event == 14 then
            CharDBExecute("UPDATE item_instance SET AddedByEluna = 0 WHERE AddedByEluna > 0") -- Ensures all entries tracked by the core are reset on event 14
        end
    end)
end

TagElunaAuctions()
RegisterServerEvent(14, TagElunaAuctions)

local itemCache = {}										-- Stores all entries from the item_template for further processing
local NextAHBotSellCycle = os.time() + AHSellTimer * 60 * 60-- Used in print and cmd feedback
local NextAHBotBuyCycle	= os.time() + AHBuyTimer * 60 * 60 	-- Used in print and cmd feedback 
local AHBotSellEventId										-- Used to track if running, for cmd etc
local AHBotBuyEventId										-- Used to track if the indefinite Lua event for the AH bot is running, to not schedule another on top through the cmd system
local botList = table.concat(AHBots, ",") 					-- Converts table to a string for SQL and concat interaction
local houseList = table.concat(EnabledAuctionHouses, ",")	-- Converts table to a string for SQL and concat interaction
local postedAuctions = {} 									-- Counts how many auctions have been posted by the auction bots last. Used in info cmd

-- Early returns and MySQL error failsafes
if not EnabledAuctionHouses then error("[Eluna AH Bot]: Core - No valid auction houses found!") end
if not botList or botList == "" or botList:match("[^%d,]") then error("[Eluna AH Bot]: Core - Invalid auction house bots selection! Correct config value 'AHBots' to contain only digits and commas.") end 
if not houseList or houseList == "" or houseList:match("[^%d,]") then  print("[Eluna AH Bot]: Core - No valid house list given! Defaulting to 2, 6, 7 (ally, horde, and neutral).") houseList = "2,6,7" end
if not ActionsPerCycle or type(ActionsPerCycle) ~= "number" then print("[Eluna AH Bot]: Core - ActionsPerCycle must be a number! Defaulting to 500.") ActionsPerCycle = 500 end

function SendMessageToGMs(message)
    for _, player in pairs(GetPlayersInWorld()) do
        if player:GetGMRank() > 0 then
			if not EnableGMMessages then
				if tonumber(message) ~= nil then RemoveEventById(message) end -- If GM messages are off, remove any events in the GM message handler (identified by msg var being number)
				return
			end
			if tonumber(message) ~= nil then player:SendBroadcastMessage("|cFFFF0000 [Eluna AH Bot GM]: Fatal error - No valid bots configured! |r")
			else player:SendBroadcastMessage("|cFFD8D8E6[Eluna AH Bot GM]|r: "..message)
			end
        end
    end
end

local function queryBotCharacters() -- Verifies bots' existence
    local result = CharDBQuery("SELECT guid FROM characters WHERE guid IN (" .. botList .. ")")
    if not result then CreateLuaEvent(SendMessageToGMs, 15 * 60 * 1000, 0) error("[Eluna AH Bot]: Core - No valid bots found!") end -- Notify GMs every 15 minutes if enabled with erroneous AH bot setup

    local validGUIDs = {}

    repeat
        table.insert(validGUIDs, result:GetUInt32(0))
    until not result:NextRow()
	
    if #validGUIDs < #AHBots then
        print("[Eluna AH Bot]: Error in selected bot list "..botList..", bot(s) not found! Defaulting to "..table.concat(validGUIDs, ",")..".")
		SendMessageToGMs("Error in bot list "..botList.."! Defaulting to "..table.concat(validGUIDs, ",")..".")
        AHBots = validGUIDs
		botList = table.concat(AHBots, ",")
    end
	print("[Eluna AH Bot]: AH bot module loaded. Type '.ahbot' in game to manage, set cache settings, and display statistics.")
end

queryBotCharacters()

-- Static table of crafted items that can be assigned bot's name as crafter.
-- There's no convenient way of getting this from the database as it's set by the spell.dbc. For servers that don't have the spell_dbc database-loaded, we need to have a cached table for reference. 
local craftedItems = { 
5349,1113,5232,5514,1450,1114,6265,2302,2304,2303,2305,2306,2307,2308,2300,2309,2310,2311,2312,2313,2314,2315,2316,2317,2454,118,2455,2456,3390,2458,2459,2460,858,41191,2568,2569,2570,2572,2575,2576,2577,2578,2579,2580,2582,2583,2584,2585,2587,2679,
2680,2681,2684,724,733,2683,2682,2687,1082,2685,1017,2840,2842,2841,2862,2851,2852,2853,2854,2863,2857,2864,2865,2866,2867,2868,2869,2871,2870,2844,2845,2847,2848,2849,2850,2888,2318,2996,2997,1625,3239,3240,3241,3382,3383,3384,3385,3386,3387,3388,
3389,3391,2457,1251,2581,3530,3531,3487,3488,3489,3490,3491,3492,3576,3575,3577,3469,3470,3471,3472,3473,3474,3478,3480,3481,3482,3483,3484,3485,3486,3662,3220,3663,3664,3665,3666,3726,3727,3728,3729,929,3823,3824,3825,3826,3827,3828,3829,3848,3849,
3850,3851,3852,3853,3854,3855,3856,3835,3836,3837,3840,3841,3842,3843,3844,3845,3846,3847,5513,3859,4237,4238,4239,4240,4241,4242,3719,4243,4244,4246,4247,4248,4249,4250,4251,4252,4253,4254,4255,4256,4257,4258,4259,4260,4262,4264,4265,4245,4231,4233,
4236,4305,4307,4308,4309,4310,4311,4312,4313,4314,4315,4316,4317,4318,4319,4320,4321,4322,4323,4324,4325,4326,4327,4328,4329,4339,4330,4331,4332,4333,4334,4335,4336,4343,4344,4357,4358,8067,4359,4360,4361,4362,4363,4401,4364,8068,4365,4366,4367,4368,
4369,4370,4371,4372,4373,4374,4375,4376,4377,4378,8069,4379,4380,4381,4382,4383,4384,4385,4386,4387,4388,4403,4389,4390,4391,4392,4393,4394,4395,4396,4397,4398,4404,4405,4406,4407,4457,4455,4456,4596,4623,4703,1450,5184,5081,5350,2288,2136,3772,1487,
5455,41170,5472,5473,5474,5476,5477,5478,5479,5480,5507,5525,5527,5526,5540,5541,5542,5639,5645,5646,5631,5633,5634,5739,5762,5763,5766,5770,5764,5765,5780,5781,5782,5783,5868,5957,5958,5961,5962,5963,5964,5965,5966,5996,1710,5997,6038,6042,6043,6040,
6041,6051,6048,6049,6050,6052,6182,6214,38679,38766,6218,38767,38768,6219,38769,38770,38771,6238,6241,6239,6240,6242,6243,6263,6264,38772,38773,6290,787,4592,6316,4593,38774,38775,38776,38777,38778,38779,38780,38781,6339,6350,6338,5095,4594,6370,6371,6372,6373,38782,
38783,38784,38785,38786,6384,6385,6435,6450,6451,6452,6453,6466,6467,6468,5349,6657,6662,4852,6265,6265,6709,6712,6714,6730,6731,6733,6786,6787,6795,6796,6888,6890,5349,7046,7048,7050,7051,7052,7071,7054,7055,7057,7026,7027,7047,7049,7065,7053,7056,7058,
7059,7060,7061,7062,7063,7064,7134,7135,7166,7189,7206,7268,7276,7277,7278,7279,7280,7281,7282,7283,7284,7285,7348,7349,7352,7358,7359,7371,7372,7373,7374,7375,7377,7378,7386,7387,7390,7391,7506,6533,7148,7676,5639,7771,7770,7769,7733,7733,7913,7914,
7915,7916,7917,7963,7964,7966,7965,7918,7919,7920,7921,7922,7924,7967,7925,7926,5060,7927,7928,7938,7929,7930,7931,7969,7932,7933,7934,7935,7939,7970,7936,7937,7955,7956,7957,7958,7941,7942,7943,7945,7954,7944,7961,7946,7959,7947,7960,8007,8008,3860,
6037,8077,8078,8079,8075,8076,8172,8173,8174,8175,8176,8187,8189,8192,8198,8200,8203,8210,8201,8205,8204,8211,8214,8193,8195,8191,8209,8185,8197,8202,8216,8207,8213,8206,8208,8212,8215,8347,8345,8346,8348,8349,8367,8544,8545,128,8708,9240,9254,6149,
8949,8951,8956,9030,9036,9060,9061,3928,9144,9149,9154,9155,9172,9179,9088,9187,9197,9206,9210,9264,9224,9233,3577,6037,9280,9284,9282,9281,9306,9316,9365,9366,9372,6265,8585,9440,9441,9438,9593,9718,10045,10046,10047,10048,9998,9999,10001,10002,10003,10004,
10007,10008,10009,10056,10010,10011,10052,10050,10018,10019,10020,10042,10021,10023,10024,10026,10027,10054,10028,10053,10029,10051,10055,10030,10031,10032,10033,10034,10025,10038,10044,10035,10039,10040,10041,10036,10423,10421,128,128,10589,10558,10505,10507,10499,10559,10498,10560,10500,10508,
10512,10546,10561,10514,10501,10592,10510,10502,10518,10506,10503,10562,10548,10513,10504,10576,10644,10577,10542,10543,10579,10580,10585,10662,10586,10587,10588,10645,10646,10691,10692,10693,10694,10713,10545,10716,10719,10720,10721,10723,10724,10725,10726,10727,10818,10841,10577,9173,10939,10938,
38787,38788,11024,38789,38790,38791,38792,11082,10998,38793,38794,38795,38796,38797,38798,38799,38800,38801,38802,38803,38804,11130,11131,38805,11135,11134,38806,38807,38808,38809,38810,38811,38812,38813,38814,38815,38816,38817,38818,38819,38820,38821,38822,38823,38824,11145,11149,11175,11174,38825,
38826,38827,38828,38829,38830,38831,38832,38833,38834,38835,38836,38837,38838,38839,11522,38840,38841,38842,38843,38844,38845,38846,38847,38848,38849,38850,38851,11230,11149,11270,11282,11283,11287,11128,11144,11288,11289,11290,11371,5120,11413,8217,8218,5120,5120,5120,5120,11470,11511,9307,
11482,11582,11590,11608,11606,11607,11605,11604,11149,11149,11950,11951,11952,5646,10464,11811,11825,11826,12567,11947,11949,11954,12190,12209,12210,13851,12212,12213,12214,12217,12215,12216,12218,12224,12259,12260,12144,12347,12349,12359,12443,12442,2048,12384,12563,12648,12649,12644,12643,12404,
12405,12406,12408,12416,12428,12424,12415,12425,12624,12645,12409,12410,12418,12631,12419,12426,12427,12417,12625,12632,12414,12422,12610,12611,12628,12633,12420,12612,12636,12640,12429,12613,12614,12639,12620,12619,12618,12641,12723,12764,12769,12772,12773,12774,12775,12776,12777,12779,12781,12792,
12782,12795,12802,12796,12790,12798,12797,12794,12784,12783,12847,12885,12907,12655,12810,12360,13155,13159,5633,13370,13423,13442,13443,13445,13447,13446,13453,7078,7076,7080,7082,7080,12808,7076,12803,13455,13452,13462,13454,13457,13456,13458,13461,13459,13460,13444,13503,13506,13510,13511,
13512,13513,13544,41192,41193,12846,41169,41171,41172,6887,13927,13928,13930,13929,13931,13932,13933,13934,13935,12368,16384,14339,14048,13856,13869,13868,14046,13858,13857,14042,13860,14143,13870,14043,14142,14100,14101,14141,13863,14044,14107,14103,14132,14134,13864,13871,14045,14136,14108,13865,
14104,14137,14144,14111,13866,14155,14128,14138,14139,13867,14130,14106,14140,14112,14146,14156,14154,14152,14153,14342,14529,14530,14645,14894,9319,15209,15448,15407,15077,15083,15045,15076,15084,15074,15047,15091,15564,15054,15046,15061,15067,15073,15078,15092,15071,15057,15064,15082,15086,15093,
15072,15069,15079,15053,15048,15060,15056,15065,15075,15094,15087,15063,15050,15066,15070,15080,15049,15058,15095,15088,15138,15051,15059,15062,15085,15081,15055,15090,15096,15068,15141,15052,15802,32768,32768,32768,15845,15843,15409,15846,15869,15870,15871,15872,15885,15992,15993,15994,15995,15996,
15999,16000,16004,10515,16005,15997,16023,16006,16009,16008,16022,16040,16007,38852,38853,38854,38855,38856,38857,38858,38859,38860,38861,9421,38862,5232,38863,38864,38865,38866,38867,38868,38869,38870,38871,38872,38873,38874,38875,16203,16202,16207,16206,16642,16643,16644,16766,2319,4234,4304,
16787,16892,16893,16895,16896,16973,16980,16979,16982,16983,16984,16989,16988,17014,17013,17015,17016,8364,4096,7867,1024,4096,128,17126,17197,17198,17182,17193,17222,17223,17074,2048,17324,17333,17325,17323,17353,17362,17363,17224,17364,17442,17505,17507,17506,17506,2048,48,17696,17704,
17708,38876,17202,17191,17716,17721,17723,17735,17758,2048,17781,4096,17690,17905,17906,17907,17908,17909,17691,17900,17901,17902,17903,17904,8051,16309,2756,2757,2758,2759,5462,8170,18045,18151,11320,18232,18238,18251,18253,38877,38878,18262,18263,18254,18283,18282,18168,18294,18258,18258,
7586,4096,18405,18407,18408,18409,18413,18486,18492,18504,18506,18508,18513,18509,18510,18511,11286,15875,8432,8095,18540,19016,17771,18583,18582,18584,32768,18609,18608,8192,18628,18640,9318,9312,9313,18588,18641,18631,18634,18587,18637,18594,18638,18639,18645,18642,18643,18598,18597,18660,
18662,18608,2048,18662,18713,20487,20488,18769,18770,18771,18799,2048,18775,18948,6265,18984,18986,19026,19004,19005,4228,19043,19048,19051,19057,19148,19164,19166,19167,19170,19168,19169,19213,19047,19050,19056,19059,19156,19165,19228,19257,19267,19277,19044,19049,19052,19058,19149,19157,19162,
19163,19422,19440,38879,38880,38881,38882,38883,38884,19450,19642,19574,19575,19576,19577,19696,19579,19585,19586,19588,19591,19592,19593,19594,19725,19598,19599,19600,19601,19602,19603,19604,19605,19610,19611,19612,19613,19606,19607,19608,19609,19614,19615,19616,19617,19618,19619,19620,19621,19682,
19683,19684,19685,19686,19687,19688,19689,19690,19691,19692,19693,19694,19695,13209,2048,19812,768,19880,19932,19931,19955,19953,19954,19959,19958,19952,19956,19951,19957,19974,19999,19998,20007,20002,20008,20004,19858,20039,20074,16416,16384,1024,1024,20256,20295,20296,20380,20393,20402,20402,
20452,20454,20455,20456,6265,20481,20480,20479,20476,20477,20478,20371,18715,18713,20416,20418,20419,20420,20432,20433,20435,20436,16384,20447,20448,20449,20450,20538,20539,20537,20549,20551,20550,20575,38885,38886,38887,38888,38889,38890,38891,38892,38893,38894,38895,16384,20744,20745,20746,20747,
20750,20749,20748,7068,20816,20817,20818,20821,20820,20823,20826,20827,20828,20831,20832,20833,20830,20907,20906,20909,20949,20950,20954,20955,20956,20963,20958,20966,20959,20960,20961,20967,21023,21072,21111,21109,21107,21106,21042,21136,21158,21161,21160,21174,21171,21171,21175,21206,21207,21208,
21209,21210,21201,21202,21203,21204,21205,21196,21197,21198,21199,21200,21217,21277,21340,21341,21342,128,128,32768,128,32768,2048,21519,21212,21536,21546,21278,21711,21154,21542,21558,21559,21557,21589,21590,21592,21571,21574,21576,21714,21716,21718,21569,21570,21975,21816,21818,21819,21821,
21823,21822,21820,21817,21840,21841,21842,21843,21844,21845,21846,21847,21848,21858,21869,21870,21871,21872,21873,21874,21875,21876,21849,21850,21851,21852,21853,21854,21855,21859,21860,21861,21862,21863,21864,21865,21866,21867,21868,21748,21756,20964,21758,21755,20969,21752,21760,21763,21764,21765,
21754,21753,21766,21769,21979,21767,21768,21785,21786,21774,21775,21790,21777,21778,21791,21784,21789,21792,21779,21793,21780,22260,21931,21932,21933,21934,22114,13583,21990,21991,2581,2581,2581,22018,768,768,768,768,22044,22048,6265,22116,22178,22160,22159,22163,22161,22162,40773,21980,
22155,22164,22154,22156,21981,21975,22165,22166,22158,22157,22167,22168,22169,22171,22170,22172,22048,22047,21984,22050,22049,22052,22051,22056,22197,22198,22196,22195,22194,22191,22246,22248,22249,22131,22132,22133,22262,22263,22136,22135,22134,22283,22284,22285,22287,22286,22288,22291,22289,22290,
22293,22292,22294,22296,22295,22297,22298,22299,22300,22251,22252,22048,22048,21946,22115,21986,21983,22385,22384,22383,38896,4096,38897,38898,38899,22475,22474,38900,38901,38902,38903,22484,38904,38905,38906,38907,38908,38909,37603,38910,38911,38912,38913,38914,38915,38916,38917,38918,38919,38920,
38921,38922,38923,38924,38925,38926,38927,22521,22522,22445,22449,22460,22459,22451,22452,21884,21885,22456,22457,21886,22628,41194,22654,22652,22658,22655,22660,22661,22662,22663,22664,22666,22665,22669,22670,22671,22645,22719,23194,23195,23196,22727,22728,22754,22762,22763,22764,22759,22760,22761,
22756,22757,22758,22822,22823,22824,22825,22826,22827,22828,22829,22830,22831,22871,22832,22833,22834,22835,22836,22837,22838,22839,21884,21885,22452,22451,22840,22841,22842,22844,22845,22846,22847,22848,22849,21885,22456,21884,22457,22452,21886,22850,22851,22853,22854,22861,22866,22895,23024,13909,
19822,19823,23094,23095,23096,23097,19824,19825,23098,23099,23100,23101,23103,23104,23105,19826,19827,19831,19829,23106,23108,19830,23109,19832,19833,23110,19834,23111,19835,23113,19836,19838,19839,19840,19841,23114,19842,19843,23115,23116,20034,23118,19845,19846,23119,20033,23120,19849,23121,19848,
19828,21407,21409,21408,21401,21403,21402,21413,21415,21414,21395,21397,21396,21410,21412,21411,21404,21406,21405,21398,21400,21399,21416,21418,21417,21392,21394,21393,23184,23182,23183,23211,23179,23180,23181,23227,23248,23355,6265,13582,23445,23446,23447,23448,23449,23442,23552,23482,23484,23487,
23488,23489,23493,23491,23494,23490,23497,23498,23499,23502,23503,23504,23505,23506,23508,23507,23510,23509,23511,23512,23515,23516,23514,23513,23517,23518,23519,23532,23524,23523,23525,23520,23521,23522,23526,23527,23528,23529,23530,23531,23533,23534,23535,23536,23537,23538,23539,23573,23571,23540,
23541,23542,23543,23544,23546,23554,23555,23556,23575,23576,23584,23585,23586,23614,23616,23670,23705,23709,23710,23712,23713,23714,23716,23720,23750,23726,23781,23782,23783,23784,23785,23786,23787,23736,23737,23742,23746,23747,23748,23758,23761,23762,23763,23764,23765,23766,23767,23768,23769,23770,
23771,23772,34504,23774,23775,23792,22575,22576,22577,23819,23821,23820,33092,33093,23840,23824,23826,23827,23831,23836,23838,23839,23841,23835,23825,23832,23828,23829,23859,23878,23879,23880,23895,24074,24075,24076,24077,24078,24079,24080,24082,24085,24086,24087,24088,24089,24092,24093,24095,24097,
24098,24106,24110,24114,24116,24117,24121,24122,24123,24124,24125,24126,24127,24128,24027,24028,24029,24030,24031,24032,24036,24033,24037,24039,24047,24048,24051,24050,24052,24053,24054,24055,24056,24057,24058,24059,24060,24061,24062,24066,24065,24067,24148,24149,23990,24035,24156,24184,24226,24271,
24273,24275,24274,24276,24249,24250,24251,24252,24253,24254,24255,24256,24257,23837,24258,24259,24260,24261,24262,24263,24264,24266,24267,24270,24268,24269,24287,24317,24520,24522,24573,24579,24581,24579,24579,24581,24581,24538,18662,25438,25439,25498,23559,25521,21887,23793,25650,25651,25652,25653,
25654,25655,25656,25657,25662,25661,25660,25659,25669,25670,25668,25671,25673,25674,25675,25676,25679,25680,25681,25683,25682,25685,25686,25687,25689,25690,25691,25695,25697,25696,25694,25692,25693,25752,25752,25752,25752,25843,25844,25845,22461,22462,22463,25840,25853,25867,25868,25880,25881,25882,
25883,25884,25886,25896,25897,25898,25899,25901,25890,25893,25894,25895,22446,22447,26045,26045,27445,27446,27317,27635,24105,27636,27651,27655,27656,27657,27658,27659,27660,27661,27662,27663,27664,27665,27666,27667,27808,22019,28100,28101,28102,28103,28104,24581,24579,28112,28132,28132,38928,38929,
38930,38931,38932,38933,38934,38935,38936,38937,38938,38939,38940,38941,38942,38943,38944,38945,38946,28290,22103,22104,22105,28048,28471,23563,23564,28483,28484,28425,28426,28428,28429,28431,28432,28434,28435,28437,28438,28440,28441,28595,28420,28421,28784,29051,29052,29157,29158,29159,29160,24289,
29201,29202,29203,29204,29207,28455,29483,29485,29486,29487,29488,29489,29490,29491,29493,29492,29540,29494,29495,29496,29497,29498,29499,29500,29532,29531,29528,29529,29530,29533,29535,29534,29536,29502,29503,29504,29505,29506,29507,29508,29512,29509,29510,29511,29514,29515,29516,29517,29519,29520,
29521,29522,29524,29523,29525,29526,29527,28455,22573,22574,29769,29778,29964,29970,29971,29973,29974,29975,30069,30070,30071,30072,30073,30074,30076,30077,30086,30087,30088,30089,30093,30155,23565,28485,28427,28430,28433,28436,28439,28442,30038,30036,30037,30035,30042,30040,30046,30044,30041,30039,
30045,30043,30309,30034,30032,30033,30031,30320,30419,30420,30421,30422,30438,30459,30460,30461,30465,30463,30464,24272,30499,30539,30542,30544,30616,30632,30639,30567,30658,30659,30703,30719,30721,30804,30816,30825,30831,30837,30838,30839,30847,31079,31080,31088,31122,31123,31108,31154,31130,31310,
30540,31346,31372,31364,31367,31368,31369,31370,31371,31398,31399,31518,31518,31530,22781,31607,31663,31672,31673,31679,31677,31676,31366,31704,24494,31763,31813,31084,31860,31861,31862,31864,31865,31863,31866,31869,31867,31868,31890,31891,31907,31914,31880,31881,32062,32063,32067,32068,29287,29290,
29279,29283,32193,32194,32195,32196,32197,32198,32199,32200,32201,32202,32203,32204,32205,32206,32207,32208,32209,32210,32211,32212,32213,32214,32215,32216,32217,32218,32219,32220,32221,32222,32223,32224,32225,32226,32320,32092,32364,7191,32408,32409,32410,32423,32413,32398,32400,32397,32394,32395,
32396,32393,32391,32392,32389,32390,32402,32403,32404,32401,32420,32449,32461,32498,32508,32578,32588,32566,32542,32594,32658,32665,32655,32659,32661,32656,32664,32662,32660,32663,31942,31942,31942,31942,32688,32689,32690,32691,32692,32693,32680,32657,32700,32701,32702,32703,32704,32705,32706,32707,
32708,32709,32710,32711,32712,32713,32598,32598,32601,32601,32734,32568,32570,32571,32573,32582,32583,32580,32581,32574,32575,32577,32579,32586,32587,32584,32585,32756,32472,32473,32474,32476,32475,32478,32479,32480,32494,32495,32572,32772,32774,32776,32833,32836,32840,32839,32846,32847,32844,32845,
32849,32850,32851,32852,29301,29297,29309,29305,32859,32860,32857,32858,32862,32861,32906,31279,32601,32601,32971,33041,33048,33051,33052,33053,32971,32971,33081,33081,33797,25535,33096,33105,33122,33133,33134,33131,33135,33143,33140,33144,22448,22448,38947,33173,33040,33185,33204,33208,33226,33218,
33226,32897,43518,43523,38948,33312,36799,33336,33341,33311,33340,33455,33477,33615,33616,33614,33617,33614,33618,33620,33781,33782,32643,33791,33797,33803,20475,33825,33839,33850,33848,33848,33866,33867,33872,33874,33924,33929,6265,32854,33993,33614,33614,34024,34062,34044,34056,34055,34060,34061,
34077,33306,34112,34099,34100,34105,33306,38949,34113,34123,34125,38950,38951,38953,38954,38955,38956,38959,37829,38960,38961,38962,38963,34135,38964,38965,38966,38967,38968,38969,44815,38972,38973,38974,22044,38975,38976,38977,38978,38979,38980,38981,38982,38984,38985,38987,38988,38989,38990,38991,
38992,38993,38995,38997,34092,34106,34207,34220,34087,34086,34085,34330,34411,34191,34440,34482,34490,34494,34494,34497,34497,34501,23773,34599,34599,34663,1180,34721,34722,39691,34748,34749,34750,34751,34752,34753,34754,34755,34756,34757,34758,34759,34760,34761,34762,34763,34764,34765,34766,34767,
42942,34769,34768,34832,34833,22449,35183,35185,35181,35182,35184,34847,34355,34356,34354,34357,34353,34362,34363,34361,34359,34360,34358,34366,34367,34364,34365,34372,34374,34370,34376,34371,34373,34369,34375,34380,34378,34379,34377,35126,35128,35276,35289,35315,35316,35318,38998,38999,35501,35503,
35563,35565,35568,35569,35581,35671,35692,35693,35694,35700,35702,35703,35707,35701,35734,35738,11445,35748,35749,35750,35751,39000,35759,35758,35760,35761,35784,35792,35908,35945,35806,35946,36748,36768,36772,36786,39001,36848,39002,6265,36895,41195,41196,39003,39004,39005,39006,37063,955,1181,
40924,37163,37163,37163,37163,37163,37164,37164,37164,37164,37168,37118,33929,37250,37303,37312,37459,37503,37501,41166,37570,37597,35623,36860,35622,35627,35625,35624,36916,36913,6836,37925,35797,38186,38225,36846,36828,36836,38266,36848,38324,38308,2290,4419,10308,27499,33458,37091,37092,1712,
4424,10306,27501,33460,37097,37098,1711,4422,10307,27502,33461,37093,37094,38277,38278,38333,38382,38380,38425,38408,38410,38411,38409,38407,38406,38400,38401,38402,38403,38404,38405,38414,38416,38424,38415,38413,38412,38420,38422,38417,38421,38419,38418,38375,38376,38371,38373,38372,38374,38374,
38378,38399,38347,38387,38388,38389,38390,38483,22044,4388,38590,38591,38592,38433,38437,38600,38626,38630,38631,38656,38653,38655,39213,39086,39087,39088,39085,39084,39083,39314,39314,39314,32399,37101,38682,39349,39469,36734,39576,39575,39520,39614,39656,39690,39737,39738,39748,39774,39710,39707,
39709,39711,39708,35627,36860,35622,35625,35622,35624,35624,35625,35623,35627,35623,36860,38699,40195,39996,39900,39905,39911,39906,33447,33448,39671,40067,39666,40068,40070,39907,39908,39909,40072,40076,23113,39912,39914,39915,39916,39918,39917,39934,39935,39942,39936,39941,39943,39945,39937,39944,
39938,39939,39933,39940,39947,39948,39949,39950,39951,39952,39953,39954,39955,39946,39956,39957,39958,39959,39960,39961,39962,39963,39964,39965,39966,39967,39968,40077,40078,40079,40081,46376,46379,46377,40087,40093,39974,39975,39976,39977,39978,39979,39980,39981,39982,39983,39984,39985,39986,39988,
39989,39990,39991,39992,39919,40213,40215,40217,40214,39920,39927,40216,39932,39997,39998,39999,40000,40001,40002,40003,40008,40009,40010,40011,40012,40013,40014,40015,40016,40017,40022,40023,40024,40025,40026,40027,40028,40029,40030,40031,40032,40033,40034,40037,40038,40039,40040,40043,40044,40045,
40046,40047,40048,40049,40050,40051,40052,40053,40054,40055,40056,40057,40058,40085,40086,40088,40089,40090,40091,40092,40095,40099,40102,40104,40094,40096,40100,40103,40105,40098,40101,40106,39910,40041,40248,40059,40110,46378,40073,40097,40211,40212,39688,36799,33312,22044,8008,8007,5513,5514,
40668,40669,40671,40672,40674,40673,40675,40670,40686,5396,31084,11000,13704,28395,24490,27808,32092,40942,40949,40950,40951,40952,40953,40943,40954,40955,20132,20131,25549,22999,24344,31404,40956,40957,40958,40959,31405,40643,28788,41117,41113,41114,41116,41126,41127,41128,41129,41132,41181,41182,
41183,41184,41185,41186,41187,41188,41189,41190,41238,41239,41240,41241,41242,41243,41245,37663,41163,41264,40769,41355,41356,41357,41344,41345,41346,41354,41351,41352,41348,41349,41347,41353,41350,38687,41257,41383,41384,41386,41387,41388,41391,41392,41394,41377,41375,41378,41379,41285,41307,41333,
41335,41339,41400,41401,41395,41396,41397,41398,41380,41381,41382,41385,41389,41376,41611,41741,41745,41974,41975,41976,41509,41510,41511,41548,41513,41515,44211,41520,41521,41522,41523,41525,41528,41543,41546,41551,41549,41545,41550,41544,41553,41554,41555,41248,41249,41251,41250,41252,41253,41254,
41255,41594,41593,41595,41597,41600,41598,41599,41601,41602,41603,41604,41607,41608,41609,41610,41984,41985,41986,42093,42095,42096,42100,42103,42101,42111,42102,42113,41519,41512,37705,37701,37702,37704,37703,37700,41544,42142,42143,42144,36766,42151,42152,42148,42153,42146,42158,42154,42150,42156,
42149,36767,42145,42155,42157,42342,42350,42381,42336,42337,42338,42339,42340,42341,42395,42413,42418,41367,42420,42421,17191,42423,42435,42433,42434,42432,42443,23529,39681,42500,42508,42545,40892,40771,40893,40772,40536,39682,41112,40767,40865,44951,41121,41146,39683,40768,40895,41164,41165,37567,
42546,41167,41168,42549,42550,42552,42553,42554,42555,42642,42643,42644,42645,42646,42647,42641,40109,42701,42702,42723,42727,42729,42730,42724,42726,42725,42728,42733,42551,37372,40896,40899,40914,40920,40908,40919,40915,40900,40923,40903,40909,40912,40913,40902,40901,40921,40916,40906,40897,40922,
40948,44922,40484,42734,42735,42736,42737,42738,42739,42741,42742,42743,42744,42745,42746,42747,42748,42749,42750,42751,42752,42753,42754,44920,44955,42897,42897,42897,42898,42899,42900,42901,42902,42903,42904,42905,42906,42907,42908,42909,42910,42911,42912,42913,42914,42915,42916,42917,42897,42897,
42897,42897,41101,41104,41107,41096,41099,41098,41103,41105,41095,41097,41106,41092,41108,41100,41094,41110,41109,41102,42897,42897,42897,42897,42897,42897,42897,42897,42954,42955,42956,42957,42958,42959,42960,42961,42962,42963,42964,42965,42966,42967,42968,42969,42970,42971,42972,42973,42974,42897,
42897,42897,42897,43420,43425,43412,43414,43415,43416,43417,43418,43419,43421,43422,43413,43423,43430,43424,43426,43427,43428,43429,43431,43432,42897,42897,42897,42897,42897,42897,42897,42897,42396,42397,42398,42399,42400,42401,42402,42403,42404,42405,42406,42407,42408,42409,42410,42411,42412,42414,
42415,42416,42417,42897,42897,42897,42897,43533,43534,43535,43536,43537,43538,43541,43542,43539,43543,43544,43545,43546,43547,43548,43549,43550,43551,43552,43553,43554,43673,43671,43672,42897,41517,41518,41524,41526,41527,41529,41530,41531,41532,41547,41533,41534,41535,41536,41537,41538,41539,41540,
41552,41541,41542,44923,42897,42897,42897,42453,42454,42455,42456,42457,42458,42459,42460,42461,42462,42463,42464,42465,42466,42467,42468,42469,42470,42471,42472,42473,42897,42897,42897,42897,42976,42976,42976,42976,42976,42976,42976,42976,34747,43015,41266,41334,42993,42994,43004,42995,42996,42997,
42998,43005,42999,43000,43001,43087,43099,43115,43116,43117,43118,43119,43120,43121,43122,43123,43124,43125,43126,43127,42740,43136,43144,43149,43215,43268,6265,43269,43270,43272,43274,43275,43276,43288,43298,43244,43245,43246,43247,43248,43249,43250,43251,43252,43253,43300,43348,43349,43316,43334,
43331,43332,43336,43337,40948,40484,43335,43355,43356,43338,43354,43350,43351,43339,43357,43359,43360,43364,43362,43361,43365,43366,43367,43340,43368,43369,43342,43371,43370,43373,43372,43374,43379,43376,43377,43343,43378,43380,43381,43385,43344,43386,43388,43383,43384,43389,43390,43392,43393,43391,
43394,43395,43396,43397,43398,43399,43400,3012,1477,4425,10309,27498,33457,43463,43464,954,2289,4426,10310,27503,33462,43465,43466,43482,43498,43490,43488,43491,43492,43478,43480,43515,43523,43570,43569,36892,36893,36894,43582,40068,40070,8529,43674,43725,43825,43826,43827,43850,43854,43853,
43860,43864,43865,43870,43871,43654,43655,44142,43656,43657,44161,39350,43660,43661,44163,43663,43664,43666,43667,38322,44210,37602,43145,43146,44316,44317,44318,43867,43868,43869,43969,43974,43973,43970,41516,43972,43975,43971,44497,44493,43987,44010,44063,33568,44148,44148,44148,44148,44148,44158,
44158,44158,44158,44158,43824,44221,44229,41173,41174,44259,44259,44259,44259,44259,44259,44259,44259,44326,44326,44326,44326,44326,44326,44326,44326,44276,44276,44276,44276,44276,44276,44276,44276,44294,44294,44294,44294,44294,44294,44294,44294,44304,44314,44315,41163,44325,44327,44328,44329,19228,
19228,19228,19228,19228,19228,19228,44330,44331,44332,19267,19267,19267,19267,19267,19267,19267,19277,19277,19277,19277,19277,19277,19277,19257,19257,19257,19257,19257,19257,19257,31890,31890,31890,31890,31890,31890,31890,44322,31907,31907,31907,31907,31907,31907,44323,31907,44324,31914,31914,31914,
31914,31914,31914,31914,31891,31891,31891,31891,31891,31891,31891,44434,38436,38440,44436,44437,44438,44449,38434,38438,44456,44440,44441,38971,44451,44452,44442,44453,38435,38986,38439,44443,44444,44445,38441,43566,43565,44446,44447,44448,43129,44430,43130,43131,44455,43132,43133,42731,44457,43255,
43256,44458,43257,43258,44462,44462,44462,44463,44465,43260,43433,43434,43435,43436,43437,44466,43438,43439,44467,43261,43262,43263,43264,43265,43266,43271,43273,43447,43449,43445,43444,43446,43442,43448,43443,43455,43457,43453,43452,43454,43450,43456,43451,43458,43459,43461,43469,43481,43484,43495,
43502,44469,44470,44480,44480,44480,44480,41508,44413,44504,41165,41164,44554,44558,44555,44557,44556,43584,43583,43585,43590,43591,43592,43593,43594,43595,43586,43587,43588,44607,44608,44609,44617,44616,44618,44619,44724,44738,44739,44740,44741,44742,44684,34052,44836,44838,44834,44840,44837,44839,
44928,44930,44931,44936,44939,44943,44947,44946,44949,44953,44958,8827,44963,39286,44981,45127,35279,35280,45127,45127,45039,45045,45054,45056,45060,45127,45127,45082,45085,45550,45559,45552,45561,45551,45560,45553,45562,45554,45563,45555,45564,45556,45565,45557,45566,45558,45567,45176,45500,45621,
45626,45627,45628,45631,46069,46069,46069,46069,46069,46070,46070,46070,46070,46070,45773,46069,45854,45849,33004,45735,45778,45785,45734,45789,45747,45797,45733,45746,45793,45623,45740,45622,45760,45768,45775,45776,45804,45805,45601,45602,45625,45731,45736,45737,45738,45741,45742,45743,45753,45755,
45756,45758,45761,45762,45764,45770,45771,45772,45779,45781,45790,45792,45799,45800,45803,45806,45908,45795,45769,45732,45745,45604,45744,45757,45767,45783,45794,45603,45739,45766,45777,45782,45780,45942,45932,46026,46098,33568,46106,45812,45813,45808,45809,45811,45810,46319,46372,46377,46376,46378,
46379,46397,46396,46691,46783,44839,44840,44836,44838,44837,46847,41165,40167,40168,40166,40175,40165,40164,40170,40169,40171,40176,40172,40181,40177,40174,40180,40179,40182,40178,40173,40113,40111,40112,40114,40118,40117,40115,40116,46887,40119,40120,40122,40121,40125,40124,40123,40126,40127,40128,
33447,40136,40129,40132,40133,40130,40134,40138,40139,40141,40135,40140,40137,40131,40151,40142,40147,40152,40153,40154,40143,40157,40155,40148,40162,40156,40161,40144,40158,40160,40145,40146,40150,40149,40163,40159,46735,36931,36919,36922,36928,36925,36934,47030,47036,46978,46955,47499,47605,47587,
47603,47585,47597,47579,47595,47576,47602,47583,47599,47581,47591,47570,47589,47572,47593,47574,47592,47571,47590,47573,47594,47575,47598,47580,47596,47582,47601,47584,47600,47577,47606,47586,47604,47588,42482,47828,46725,48720,48933,48945,48933,49040,49084,49110,49301,43489,49632,49633,49634,49497,
49655,49916,49698,49703,49704,49739,49750,49768,12655,49891,49890,49892,49893,49898,49894,49899,49895,49900,49896,49901,49897,49902,49905,49903,49906,49904,49907,49915,49661,49668,49669,49670,50125,37706,50045,50077,50816,52020,52021,49888,52566,52729,53510,54467,54797,
}

-- Expansion-specific item ID tables. These are inversions of the item_template tables per expansion (ie., all entries below the max entry which are *not* populated) to conserve space. Used as an initial filter for the "Expansion" config setting.
local ItemsVanilla = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,
26,27,28,29,30,31,32,33,34,41,42,46,50,54,58,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,81,82,83,84,86,87,88,89,90,91,92,93,94,95,96,97,98,99,
100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,119,122,123,124,125,126,130,131,132,133,134,135,136,137,138,141,142,143,144,145,146,149,150,151,152,155,156,157,158,160,161,162,163,
164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,183,184,185,186,187,188,189,190,191,192,196,197,198,199,204,205,206,207,208,211,212,213,214,215,216,217,218,219,220,221,222,223,
224,225,226,227,228,229,230,231,232,233,234,235,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,
278,279,280,281,282,283,284,288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,316,317,318,319,320,321,322,323,324,325,326,327,328,329,330,
331,332,333,334,335,336,337,338,339,340,341,342,343,344,345,346,347,348,349,350,351,352,353,354,355,356,357,358,359,360,361,362,363,364,365,366,367,368,369,370,371,372,373,374,375,376,377,378,379,380,
381,382,383,384,385,386,387,388,389,390,391,392,393,394,395,396,397,398,399,400,401,402,403,404,405,406,407,408,409,410,411,412,413,415,416,417,418,419,420,421,423,424,425,426,427,428,429,430,431,432,
433,434,435,436,437,438,439,440,441,442,443,444,445,446,447,448,449,450,451,452,453,454,455,456,457,458,459,460,461,462,463,464,465,466,467,468,469,470,471,472,473,474,475,476,477,478,479,480,481,482,
483,484,485,486,487,488,489,490,491,492,493,494,495,496,497,498,499,500,501,502,503,504,505,506,507,508,509,510,511,512,513,514,515,516,517,518,519,520,521,522,523,524,525,526,527,528,529,530,531,532,
533,534,535,536,538,539,540,541,542,543,544,545,546,547,548,549,550,551,552,553,554,557,558,559,560,561,562,563,564,565,566,567,568,569,570,571,572,573,574,575,576,577,578,579,580,581,582,583,584,585,
586,587,588,589,590,591,592,593,594,595,596,597,598,599,600,601,602,603,604,605,606,607,608,609,610,611,612,613,614,615,616,617,618,619,620,621,622,623,624,625,626,627,628,629,630,631,632,633,634,635,
636,637,638,639,640,641,642,643,644,645,646,648,649,650,651,652,653,654,655,656,657,658,659,660,661,662,663,664,665,666,667,668,669,670,671,672,673,674,675,676,677,678,679,680,681,682,683,684,685,686,
687,688,689,690,691,692,693,694,695,696,697,698,699,700,701,702,703,704,705,706,707,708,709,712,713,715,716,717,721,722,726,734,736,741,746,747,749,751,757,758,759,760,761,762,764,775,784,786,788,800,
801,802,803,806,807,808,813,815,817,819,822,823,824,825,830,831,834,836,842,855,861,874,875,876,877,879,881,882,883,891,894,898,900,901,902,903,904,905,906,907,908,909,912,913,917,919,930,931,941,945,
946,947,948,949,950,951,952,953,956,958,959,960,963,964,965,966,967,968,969,970,971,972,973,974,975,976,977,978,979,980,982,984,985,986,987,988,989,990,991,992,993,994,995,996,998,999,1000,1001,1002,1003,
1004,1005,1007,1012,1014,1016,1018,1020,1021,1022,1023,1025,1026,1028,1029,1030,1031,1032,1033,1034,1035,1036,1037,1038,1039,1040,1042,1043,1044,1045,1046,1047,1048,1049,1050,1051,1052,1053,1054,1055,1056,1057,1058,1059,1060,1061,1062,1063,1064,1065,
1066,1067,1068,1069,1070,1071,1072,1073,1078,1079,1084,1085,1086,1087,1088,1089,1090,1091,1092,1093,1094,1095,1096,1097,1098,1099,1100,1101,1102,1103,1104,1105,1106,1107,1108,1109,1110,1111,1112,1115,1117,1118,1119,1120,1122,1123,1124,1125,1126,1128,
1135,1136,1137,1138,1139,1140,1141,1142,1143,1144,1145,1146,1147,1148,1149,1150,1151,1152,1153,1157,1160,1162,1163,1164,1165,1170,1174,1176,1184,1185,1186,1188,1192,1199,1209,1216,1222,1223,1224,1225,1226,1227,1228,1229,1230,1231,1232,1233,1234,1235,
1236,1237,1238,1239,1240,1241,1242,1243,1244,1245,1246,1247,1248,1249,1250,1253,1258,1259,1266,1267,1268,1269,1271,1272,1277,1278,1279,1281,1285,1286,1289,1290,1291,1295,1298,1301,1305,1308,1311,1312,1313,1316,1320,1321,1323,1324,1328,1329,1330,1331,
1332,1333,1334,1335,1336,1337,1338,1339,1340,1341,1342,1343,1344,1345,1346,1347,1348,1350,1352,1354,1356,1363,1365,1371,1373,1375,1379,1385,1390,1392,1393,1397,1398,1400,1402,1403,1424,1426,1428,1432,1435,1437,1439,1441,1442,1444,1450,1452,1456,1463,
1466,1471,1472,1474,1492,1494,1496,1500,1508,1517,1525,1526,1527,1530,1531,1533,1534,1535,1536,1538,1540,1541,1542,1543,1544,1545,1546,1548,1549,1550,1551,1552,1553,1554,1555,1556,1558,1559,1562,1563,1564,1565,1567,1568,1569,1570,1571,1572,1573,1574,
1575,1576,1577,1578,1579,1580,1581,1582,1583,1584,1585,1586,1587,1588,1589,1590,1591,1592,1593,1594,1595,1597,1599,1600,1601,1603,1605,1606,1609,1610,1611,1612,1614,1615,1616,1617,1618,1619,1620,1621,1622,1623,1626,1627,1628,1629,1631,1632,1633,1634,
1635,1636,1638,1641,1642,1643,1644,1646,1647,1648,1649,1650,1651,1653,1654,1655,1657,1658,1660,1661,1662,1663,1665,1666,1667,1668,1669,1670,1671,1672,1673,1674,1675,1676,1681,1682,1683,1684,1689,1690,1691,1692,1693,1694,1695,1698,1699,1700,1704,1709,
1719,1723,1724,1736,1762,1763,1765,1771,1773,1779,1781,1833,1834,1837,1838,1841,1842,1847,1848,1851,1854,1855,1856,1857,1858,1859,1860,1861,1862,1863,1864,1865,1866,1867,1868,1869,1870,1871,1872,1873,1874,1876,1877,1878,1879,1880,1881,1882,1883,1884,
1885,1886,1887,1888,1889,1890,1891,1892,1895,1896,1897,1898,1899,1900,1901,1902,1903,1904,1905,1906,1907,1908,1909,1910,1911,1912,1914,1915,1916,1918,1919,1920,1921,1924,1932,1940,1947,1948,1949,1950,1952,1953,1954,1957,1960,1961,1963,1964,1966,1967,
1969,1977,1983,1984,1985,1989,1995,1999,2001,2002,2003,2009,2010,2012,2016,2019,2022,2023,2031,2038,2045,2049,2050,2051,2052,2053,2056,2060,2061,2062,2063,2068,2071,2076,2081,2083,2086,2090,2093,2094,2095,2096,2097,2103,2104,2106,2107,2111,2115,2116,
2118,2128,2135,2147,2155,2157,2170,2171,2174,2176,2177,2178,2179,2180,2181,2182,2183,2184,2185,2189,2190,2191,2192,2193,2196,2197,2198,2199,2200,2201,2202,2206,2228,2229,2242,2247,2248,2253,2255,2261,2269,2270,2272,2273,2275,2279,2285,2286,2293,2294,
2297,2298,2301,2305,2306,2322,2323,2328,2329,2330,2331,2332,2333,2334,2335,2336,2337,2338,2339,2340,2341,2342,2343,2344,2345,2346,2347,2348,2349,2350,2351,2352,2353,2354,2355,2356,2357,2358,2359,2360,2363,2365,2368,2404,2405,2410,2412,2416,2430,2433,
2436,2439,2460,2461,2462,2478,2481,2482,2483,2484,2485,2486,2487,2496,2497,2498,2500,2501,2502,2503,2513,2514,2517,2518,2537,2538,2539,2540,2541,2542,2543,2544,2550,2551,2552,2554,2556,2557,2558,2559,2573,2574,2588,2597,2599,2600,2602,2603,2626,2627,
2630,2631,2638,2641,2647,2655,2664,2668,2669,2670,2688,2689,2693,2695,2703,2704,2705,2706,2707,2708,2709,2710,2711,2714,2715,2716,2717,2718,2726,2727,2729,2731,2733,2736,2737,2739,2741,2743,2746,2747,2752,2753,2755,2761,2762,2767,2768,2769,2789,2790,
2791,2792,2793,2796,2803,2804,2808,2809,2810,2811,2812,2813,2814,2826,2827,2860,2861,2867,2873,2884,2887,2890,2891,2895,2896,2897,2914,2918,2919,2920,2921,2922,2923,2927,2929,2932,2935,2936,2937,2938,2945,2948,2952,2993,2994,2995,3001,3002,3003,3004,
3005,3006,3007,3009,3015,3028,3029,3031,3032,3038,3043,3044,3046,3050,3051,3052,3054,3059,3060,3061,3062,3063,3064,3068,3077,3088,3089,3090,3091,3092,3093,3094,3095,3096,3097,3098,3099,3100,3101,3102,3104,3105,3106,3109,3112,3113,3114,3115,3116,3118,
3119,3120,3121,3122,3123,3124,3125,3126,3127,3128,3129,3130,3132,3133,3134,3136,3138,3139,3140,3141,3142,3143,3144,3145,3146,3147,3149,3150,3159,3168,3178,3215,3219,3221,3222,3226,3232,3242,3243,3244,3245,3246,3247,3249,3259,3271,3278,3298,3316,3320,
3326,3333,3338,3346,3350,3351,3359,3361,3362,3364,3366,3367,3368,3398,3410,3432,3433,3436,3438,3441,3459,3479,3494,3500,3501,3503,3504,3507,3512,3513,3519,3522,3523,3524,3525,3526,3527,3528,3529,3532,3533,3534,3535,3536,3537,3538,3539,3540,3541,3542,
3543,3544,3545,3546,3547,3548,3549,3557,3568,3579,3580,3584,3620,3624,3646,3648,3675,3677,3686,3687,3694,3695,3696,3697,3698,3699,3700,3705,3707,3709,3738,3744,3746,3756,3757,3762,3768,3773,3774,3788,3789,3790,3791,3861,3865,3878,3881,3883,3884,3885,
3886,3887,3888,3895,3896,3903,3929,3933,3934,3952,3953,3954,3955,3956,3957,3958,3959,3977,3978,3979,3980,3981,3982,3983,3984,3988,3991,4008,4009,4010,4011,4012,4013,4014,4015,4030,4031,4032,4033,4081,4095,4141,4142,4143,4144,4145,4146,4147,4148,4149,
4150,4151,4152,4153,4154,4155,4156,4157,4158,4159,4160,4161,4162,4163,4164,4165,4166,4167,4168,4169,4170,4171,4172,4173,4174,4175,4176,4177,4178,4179,4180,4181,4182,4183,4184,4185,4186,4187,4188,4189,4190,4191,4192,4193,4194,4195,4196,4198,4199,4200,
4201,4202,4203,4204,4205,4206,4207,4208,4209,4210,4211,4212,4214,4215,4216,4217,4218,4219,4220,4221,4222,4223,4224,4225,4226,4227,4228,4229,4230,4266,4267,4268,4269,4270,4271,4272,4273,4274,4275,4276,4277,4279,4280,4281,4282,4283,4284,4285,4286,4287,
4288,4295,4418,4420,4423,4427,4431,4442,4451,4452,4475,4486,4501,4523,4524,4559,4572,4573,4574,4578,4579,4617,4618,4619,4620,4642,4651,4657,4664,4667,4670,4673,4679,4682,4685,4688,4691,4704,4728,4730,4747,4748,4749,4750,4754,4756,4760,4761,4762,4763,
4764,4773,4774,4811,4812,4815,4839,4842,4853,4855,4856,4857,4858,4868,4884,4885,4889,4899,4900,4901,4902,4912,4927,4930,4934,4943,4950,4955,4956,4959,4965,4966,4981,4985,4988,4989,4990,4991,4993,4994,4996,4997,5000,5004,5008,5010,5013,5014,5015,5024,
5031,5032,5033,5034,5035,5036,5037,5039,5041,5045,5046,5047,5049,5053,5070,5090,5091,5106,5108,5126,5127,5129,5130,5131,5132,5139,5141,5142,5144,5145,5146,5147,5148,5149,5150,5151,5152,5153,5154,5155,5156,5157,5158,5159,5160,5161,5162,5163,5171,5172,
5174,5222,5223,5224,5225,5226,5227,5228,5230,5231,5235,5255,5258,5259,5260,5261,5262,5264,5265,5276,5277,5278,5280,5281,5282,5283,5284,5285,5286,5287,5288,5289,5290,5291,5292,5293,5294,5295,5296,5297,5298,5300,5301,5303,5304,5305,5307,5308,5330,5331,
5333,5353,5358,5365,5372,5378,5380,5381,5384,5400,5401,5402,5403,5406,5407,5408,5409,5410,5434,5436,5438,5449,5450,5452,5453,5454,5491,5492,5495,5496,5497,5499,5501,5502,5515,5531,5532,5545,5546,5548,5549,5550,5551,5552,5553,5554,5555,5556,5557,5558,
5559,5560,5561,5562,5563,5564,5577,5597,5598,5599,5600,5603,5607,5625,5632,5641,5644,5647,5648,5649,5650,5651,5652,5653,5654,5657,5658,5660,5661,5662,5666,5667,5670,5671,5672,5673,5674,5676,5677,5678,5679,5680,5682,5683,5684,5685,5688,5696,5697,5698,
5699,5700,5701,5702,5703,5704,5705,5706,5707,5708,5709,5710,5711,5712,5713,5714,5715,5716,5719,5720,5721,5722,5723,5724,5725,5726,5727,5728,5729,5730,5742,5743,5745,5746,5747,5748,5768,5769,5821,5822,5823,5828,5845,5856,5857,5858,5859,5870,5878,5885,
5886,5887,5888,5889,5890,5891,5892,5893,5894,5895,5896,5898,5899,5900,5901,5902,5903,5904,5905,5906,5907,5908,5909,5910,5911,5912,5913,5914,5915,5916,5920,5921,5922,5923,5924,5925,5926,5927,5928,5929,5930,5931,5932,5933,5934,5935,5937,5949,5953,5954,
5955,5968,5977,5978,5979,5980,5981,5982,5983,5984,5985,5986,5987,5988,5989,5990,5991,5992,5993,5994,5995,5999,6000,6001,6002,6003,6004,6005,6006,6007,6008,6009,6010,6011,6012,6013,6014,6015,6017,6018,6019,6020,6021,6022,6023,6024,6025,6026,6027,6028,
6029,6030,6031,6032,6033,6034,6035,6036,6088,6090,6099,6100,6101,6102,6103,6104,6105,6106,6107,6108,6109,6110,6111,6112,6113,6114,6115,6128,6130,6131,6132,6133,6141,6142,6143,6151,6152,6153,6154,6155,6156,6157,6158,6159,6160,6161,6162,6163,6164,6165,
6174,6192,6207,6208,6209,6210,6213,6216,6221,6222,6224,6225,6227,6228,6229,6230,6231,6232,6233,6234,6235,6236,6237,6243,6244,6254,6255,6262,6273,6276,6277,6278,6279,6280,6322,6334,6343,6345,6374,6376,6434,6437,6478,6483,6484,6485,6489,6490,6491,6492,
6493,6494,6495,6496,6497,6498,6499,6500,6501,6516,6544,6589,6606,6618,6619,6620,6621,6623,6638,6639,6644,6646,6648,6649,6650,6673,6674,6680,6683,6698,6699,6700,6701,6702,6703,6704,6705,6706,6707,6708,6711,6724,6728,6730,6733,6734,6736,6754,6758,6759,
6760,6761,6762,6763,6764,6765,6768,6769,6770,6771,6772,6777,6778,6779,6813,6814,6815,6816,6817,6818,6819,6820,6821,6822,6823,6824,6825,6837,6850,6852,6853,6854,6855,6856,6857,6858,6859,6860,6861,6862,6863,6864,6865,6867,6868,6869,6870,6871,6872,6873,
6874,6875,6876,6877,6878,6879,6880,6881,6882,6883,6884,6885,6886,6891,6896,6897,6899,6917,6918,6919,6920,6921,6922,6923,6924,6925,6932,6933,6934,6935,6936,6937,6938,6939,6940,6941,6942,6943,6944,6945,6946,6954,6955,6956,6957,6958,6959,6960,6961,6962,
6963,6964,6965,6988,7007,7008,7009,7010,7011,7012,7013,7014,7015,7016,7017,7018,7019,7020,7021,7022,7023,7024,7025,7028,7029,7030,7031,7032,7033,7034,7035,7036,7037,7038,7039,7040,7041,7042,7043,7044,7045,7066,7093,7102,7103,7104,7105,7121,7122,7123,
7124,7125,7136,7137,7138,7139,7140,7141,7142,7143,7144,7145,7147,7149,7150,7151,7152,7153,7154,7155,7156,7157,7158,7159,7160,7161,7162,7163,7164,7165,7167,7168,7169,7170,7171,7172,7173,7174,7175,7176,7177,7178,7179,7180,7181,7182,7183,7184,7185,7186,
7187,7188,7192,7193,7194,7195,7196,7197,7198,7199,7200,7201,7202,7203,7204,7205,7210,7211,7212,7213,7214,7215,7216,7217,7218,7219,7220,7221,7222,7223,7224,7225,7232,7233,7234,7235,7236,7237,7238,7239,7240,7241,7242,7243,7244,7245,7246,7248,7250,7251,
7252,7253,7254,7255,7256,7257,7258,7259,7260,7261,7262,7263,7264,7265,7275,7299,7300,7301,7302,7303,7304,7305,7310,7311,7312,7313,7314,7315,7316,7317,7318,7319,7320,7321,7322,7323,7324,7325,7347,7379,7380,7381,7382,7383,7384,7385,7388,7393,7394,7395,
7396,7397,7398,7399,7400,7401,7402,7403,7404,7405,7425,7426,7427,7466,7467,7497,7501,7502,7503,7504,7505,7547,7548,7550,7562,7563,7564,7565,7570,7571,7572,7573,7574,7575,7576,7577,7578,7579,7580,7581,7582,7583,7584,7585,7588,7589,7590,7591,7592,7593,
7594,7595,7596,7597,7598,7599,7600,7601,7602,7603,7604,7605,7612,7614,7615,7616,7617,7618,7619,7620,7621,7622,7623,7624,7625,7630,7631,7632,7633,7634,7635,7636,7637,7638,7639,7640,7641,7642,7643,7644,7645,7647,7648,7649,7650,7651,7652,7653,7654,7655,
7656,7657,7658,7659,7660,7661,7662,7663,7664,7665,7677,7681,7692,7693,7694,7695,7696,7697,7698,7699,7700,7701,7702,7703,7704,7705,7706,7707,7716,7732,7743,7744,7745,7762,7763,7764,7765,7772,7773,7774,7775,7776,7777,7778,7779,7780,7781,7782,7783,7784,
7785,7788,7789,7790,7791,7792,7793,7794,7795,7796,7797,7798,7799,7800,7801,7802,7803,7804,7805,7814,7815,7816,7817,7818,7819,7820,7821,7822,7823,7824,7825,7826,7827,7828,7829,7830,7831,7832,7833,7834,7835,7836,7837,7838,7839,7840,7841,7842,7843,7844,
7845,7849,7850,7851,7852,7853,7854,7855,7856,7857,7858,7859,7860,7861,7862,7863,7864,7865,7868,7869,7872,7873,7874,7875,7876,7877,7878,7879,7880,7881,7882,7883,7884,7885,7889,7890,7891,7892,7893,7894,7895,7896,7897,7898,7899,7900,7901,7902,7903,7904,
7905,7925,7940,7948,7949,7950,7951,7952,7953,7962,7977,7986,7987,7988,7994,7998,7999,8000,8001,8002,8003,8004,8005,8010,8011,8012,8013,8014,8015,8016,8017,8018,8019,8020,8021,8022,8023,8024,8025,8031,8032,8033,8034,8035,8036,8037,8038,8039,8040,8041,
8042,8043,8044,8045,8054,8055,8056,8057,8058,8059,8060,8061,8062,8063,8064,8065,8096,8097,8098,8099,8100,8101,8102,8103,8104,8105,8145,8147,8148,8166,8195,8219,8220,8221,8222,8227,8228,8229,8230,8231,8232,8233,8234,8235,8236,8237,8238,8239,8240,8241,
8242,8243,8321,8322,8323,8324,8325,8326,8327,8328,8329,8330,8331,8332,8333,8334,8335,8336,8337,8338,8339,8340,8341,8342,8351,8352,8353,8354,8355,8356,8357,8358,8359,8360,8361,8362,8369,8370,8371,8372,8373,8374,8375,8376,8377,8378,8379,8380,8381,8382,
8388,8413,8414,8415,8416,8417,8418,8419,8420,8421,8422,8433,8434,8435,8436,8437,8438,8439,8440,8441,8442,8445,8446,8447,8448,8449,8450,8451,8452,8453,8454,8455,8456,8457,8458,8459,8460,8461,8462,8464,8465,8466,8467,8468,8469,8470,8471,8472,8473,8474,
8475,8476,8477,8478,8479,8480,8481,8482,8493,8502,8503,8504,8505,8506,8507,8509,8510,8511,8512,8513,8514,8515,8516,8517,8518,8519,8520,8521,8522,8530,8531,8532,8533,8534,8535,8536,8537,8538,8539,8540,8541,8542,8543,8546,8547,8549,8550,8551,8552,8553,
8554,8555,8556,8557,8558,8559,8560,8561,8562,8565,8566,8567,8568,8569,8570,8571,8572,8573,8574,8575,8576,8577,8578,8579,8580,8581,8582,8596,8597,8598,8599,8600,8601,8602,8604,8605,8606,8607,8608,8609,8610,8611,8612,8613,8614,8615,8616,8617,8618,8619,
8620,8621,8622,8634,8635,8636,8637,8638,8639,8640,8641,8642,8648,8649,8650,8651,8652,8653,8654,8655,8656,8657,8658,8659,8660,8661,8662,8664,8665,8666,8667,8668,8669,8670,8671,8672,8673,8674,8675,8676,8677,8678,8679,8680,8681,8682,8688,8689,8690,8691,
8692,8693,8694,8695,8696,8697,8698,8699,8700,8701,8702,8706,8709,8710,8711,8712,8713,8714,8715,8716,8717,8718,8719,8720,8721,8722,8725,8726,8727,8728,8729,8730,8731,8732,8733,8734,8735,8736,8737,8738,8739,8740,8741,8742,8743,8744,8745,8756,8757,8758,
8759,8760,8761,8762,8763,8764,8765,8767,8768,8769,8770,8771,8772,8773,8774,8775,8776,8777,8778,8779,8780,8781,8782,8783,8784,8785,8786,8787,8788,8789,8790,8791,8792,8793,8794,8795,8796,8797,8798,8799,8800,8801,8802,8803,8804,8805,8806,8807,8808,8809,
8810,8811,8812,8813,8814,8815,8816,8817,8818,8819,8820,8821,8822,8823,8824,8825,8826,8828,8829,8830,8832,8833,8834,8835,8837,8840,8841,8842,8843,8844,8847,8848,8849,8850,8851,8852,8853,8854,8855,8856,8857,8858,8859,8860,8861,8862,8863,8864,8865,8866,
8867,8868,8869,8870,8871,8872,8873,8874,8875,8876,8877,8878,8879,8880,8881,8882,8883,8884,8885,8886,8887,8888,8889,8890,8891,8892,8893,8894,8895,8896,8897,8898,8899,8900,8901,8902,8903,8904,8905,8906,8907,8908,8909,8910,8911,8912,8913,8914,8915,8916,
8917,8918,8919,8920,8921,8922,8929,8930,8931,8933,8934,8935,8936,8937,8938,8939,8940,8941,8942,8943,8944,8945,8946,8947,8954,8955,8958,8960,8961,8962,8963,8965,8966,8967,8968,8969,8970,8971,8972,8974,8975,8976,8977,8978,8979,8980,8981,8982,8983,8986,
8987,8988,8989,8990,8991,8992,8993,8994,8995,8996,8997,8998,8999,9000,9001,9002,9003,9004,9005,9006,9007,9008,9009,9010,9011,9012,9013,9014,9015,9016,9017,9018,9019,9020,9021,9022,9023,9024,9025,9026,9027,9028,9029,9031,9032,9033,9034,9035,9037,9038,
9039,9040,9041,9042,9043,9044,9045,9046,9047,9048,9049,9050,9051,9052,9053,9054,9055,9056,9057,9058,9059,9062,9063,9064,9065,9066,9067,9068,9069,9070,9071,9072,9073,9074,9075,9076,9077,9078,9079,9080,9081,9082,9083,9084,9085,9086,9087,9089,9090,9091,
9092,9093,9094,9095,9096,9097,9098,9099,9100,9101,9102,9103,9104,9105,9106,9107,9108,9109,9110,9111,9112,9113,9114,9115,9116,9117,9118,9119,9120,9121,9122,9123,9124,9125,9126,9127,9128,9129,9130,9131,9132,9133,9134,9135,9136,9137,9138,9139,9140,9141,
9142,9143,9145,9146,9147,9148,9150,9151,9152,9156,9157,9158,9159,9160,9161,9162,9163,9164,9165,9166,9167,9168,9169,9170,9171,9174,9175,9176,9177,9178,9180,9181,9182,9183,9184,9185,9188,9190,9191,9192,9193,9194,9195,9196,9198,9199,9200,9201,9202,9203,
9204,9205,9207,9208,9209,9211,9212,9213,9215,9216,9217,9218,9219,9220,9221,9222,9223,9225,9226,9227,9228,9229,9230,9231,9232,9239,9267,9268,9269,9270,9271,9272,9273,9274,9310,9325,9337,9338,9339,9340,9341,9342,9343,9344,9345,9346,9347,9348,9349,9350,
9351,9352,9353,9354,9373,9374,9376,9377,9380,9417,9443,9464,9493,9494,9495,9496,9497,9498,9499,9500,9501,9502,9503,9504,9505,9506,9524,9525,9526,9529,9532,9537,9549,9582,9583,9584,9585,9586,9610,9611,9612,9613,9614,9615,9616,9617,9659,9667,9668,9669,
9670,9671,9672,9673,9674,9675,9676,9677,9685,9688,9689,9690,9691,9692,9693,9694,9695,9696,9697,9700,9701,9702,9707,9708,9709,9710,9711,9712,9713,9714,9715,9716,9717,9720,9721,9722,9723,9724,9725,9726,9727,9728,9729,9730,9731,9732,9733,9734,9735,9736,
9737,9888,9975,9976,9977,9979,9980,9981,9982,9983,9984,9985,9986,9987,9988,9989,9990,9991,9992,9993,9994,9995,9996,9997,10006,10010,10011,10012,10013,10014,10015,10016,10017,10020,10032,10037,10038,10039,10049,10114,10115,10116,10117,10284,10291,10292,10293,10294,10295,10296,
10297,10303,10304,10313,10319,10322,10324,10334,10335,10336,10337,10339,10340,10341,10342,10343,10344,10345,10346,10347,10348,10349,10350,10351,10352,10353,10354,10355,10356,10357,10395,10396,10397,10415,10416,10417,10419,10422,10425,10426,10427,10428,10429,10430,10431,10432,10433,10434,10435,10436,
10437,10448,10449,10451,10452,10453,10468,10469,10470,10471,10472,10473,10474,10475,10476,10477,10478,10480,10481,10482,10483,10484,10485,10486,10487,10488,10489,10490,10491,10492,10493,10494,10495,10496,10497,10516,10517,10519,10520,10521,10522,10523,10524,10525,10526,10527,10528,10529,10530,10531,
10532,10533,10534,10535,10536,10537,10555,10557,10568,10579,10580,10585,10591,10594,10595,10596,10611,10612,10613,10614,10615,10616,10617,10618,10619,10650,10651,10665,10666,10667,10668,10669,10670,10671,10672,10673,10674,10675,10676,10677,10683,10685,10719,10723,10729,10730,10731,10732,10733,10734,
10735,10736,10737,10756,10809,10810,10811,10812,10813,10814,10815,10816,10817,10825,10848,10849,10850,10851,10852,10853,10854,10855,10856,10857,10859,10860,10861,10862,10863,10864,10865,10866,10867,10868,10869,10870,10871,10872,10873,10874,10875,10876,10877,10878,10879,10880,10881,10882,10883,10884,
10885,10886,10887,10888,10889,10890,10891,10892,10893,10894,10895,10896,10897,10898,10899,10900,10901,10902,10903,10904,10905,10906,10907,10908,10909,10910,10911,10912,10913,10914,10915,10916,10917,10923,10924,10925,10926,10927,10928,10929,10930,10931,10932,10933,10934,10935,10936,10937,10941,10942,
10943,10944,10945,10946,10947,10948,10949,10950,10951,10952,10953,10954,10955,10956,10957,10960,10961,10962,10963,10964,10965,10966,10967,10968,10969,10970,10971,10972,10973,10974,10975,10976,10977,10979,10980,10981,10982,10983,10984,10985,10986,10987,10988,10989,10990,10991,10992,10993,10994,10995,
10996,10997,11001,11002,11003,11004,11005,11006,11007,11008,11009,11010,11011,11012,11013,11014,11015,11016,11017,11019,11021,11025,11028,11029,11030,11031,11032,11033,11034,11035,11036,11037,11041,11042,11043,11044,11045,11046,11047,11048,11049,11050,11051,11052,11053,11054,11055,11056,11057,11059,
11060,11061,11062,11063,11064,11065,11066,11067,11068,11069,11070,11071,11072,11073,11074,11075,11076,11077,11085,11087,11088,11089,11090,11091,11092,11093,11094,11095,11096,11097,11099,11100,11111,11115,11117,11153,11154,11155,11156,11157,11158,11159,11160,11161,11170,11171,11180,11181,11182,11183,
11198,11199,11200,11201,11209,11210,11211,11212,11213,11214,11215,11216,11217,11218,11219,11220,11221,11228,11232,11233,11234,11235,11236,11237,11238,11239,11240,11241,11244,11245,11246,11247,11248,11249,11250,11251,11252,11253,11254,11255,11256,11257,11258,11259,11260,11261,11264,11271,11272,11273,
11274,11275,11276,11277,11278,11279,11280,11281,11292,11293,11294,11295,11296,11297,11298,11299,11300,11301,11314,11317,11321,11322,11323,11326,11327,11328,11329,11330,11331,11332,11333,11334,11335,11336,11337,11338,11339,11340,11341,11342,11343,11344,11345,11346,11347,11348,11349,11350,11351,11352,
11353,11354,11355,11356,11357,11358,11359,11360,11361,11365,11369,11372,11373,11374,11375,11376,11377,11378,11379,11380,11381,11383,11396,11397,11398,11399,11400,11401,11421,11424,11425,11426,11427,11428,11429,11430,11431,11432,11433,11434,11435,11436,11437,11438,11439,11440,11441,11442,11443,11447,
11448,11449,11450,11451,11452,11453,11454,11455,11456,11457,11458,11459,11460,11461,11473,11481,11483,11484,11485,11486,11487,11488,11489,11490,11491,11492,11493,11494,11495,11496,11497,11498,11499,11500,11501,11505,11506,11517,11518,11519,11520,11521,11523,11524,11525,11526,11527,11528,11529,11530,
11531,11532,11533,11534,11535,11536,11537,11538,11539,11540,11541,11542,11543,11544,11545,11546,11547,11548,11549,11550,11551,11552,11553,11554,11555,11556,11557,11558,11559,11560,11561,11571,11572,11573,11574,11575,11576,11577,11578,11579,11580,11581,11585,11586,11587,11588,11589,11591,11592,11593,
11594,11595,11596,11597,11598,11599,11600,11601,11609,11613,11616,11618,11619,11620,11621,11636,11637,11638,11639,11640,11641,11650,11651,11652,11653,11654,11655,11656,11657,11658,11659,11660,11661,11663,11664,11666,11667,11670,11671,11672,11673,11676,11680,11681,11683,11687,11688,11689,11690,11691,
11692,11693,11694,11695,11696,11697,11698,11699,11700,11701,11704,11705,11706,11707,11708,11709,11710,11711,11712,11713,11714,11715,11716,11717,11718,11719,11720,11721,11738,11739,11740,11741,11756,11757,11758,11759,11760,11761,11762,11763,11769,11770,11771,11772,11773,11774,11775,11776,11777,11778,
11779,11780,11781,11788,11789,11790,11791,11792,11793,11794,11795,11796,11797,11798,11799,11800,11801,11806,11836,11838,11877,11878,11879,11880,11881,11890,11891,11892,11893,11894,11895,11896,11897,11898,11899,11900,11901,11903,11956,11957,11958,11959,11960,11961,12063,12067,12068,12069,12070,12071,
12072,12073,12074,12075,12076,12077,12078,12079,12080,12081,12084,12085,12086,12087,12088,12089,12090,12091,12092,12093,12094,12095,12096,12097,12098,12099,12100,12101,12104,12105,12106,12107,12116,12117,12118,12119,12120,12121,12123,12124,12125,12126,12127,12128,12129,12130,12131,12132,12133,12134,
12135,12136,12137,12138,12139,12140,12141,12142,12143,12145,12146,12147,12148,12149,12150,12151,12152,12153,12154,12155,12156,12157,12158,12159,12160,12161,12165,12166,12167,12168,12169,12170,12171,12172,12173,12174,12175,12176,12177,12178,12179,12180,12181,12182,12183,12186,12187,12188,12189,12193,
12194,12195,12196,12197,12198,12199,12200,12201,12211,12221,12222,12244,12245,12246,12258,12265,12266,12267,12268,12269,12270,12271,12272,12273,12274,12275,12276,12277,12278,12279,12280,12281,12285,12290,12294,12297,12298,12304,12305,12306,12307,12308,12309,12310,12311,12312,12313,12314,12315,12316,
12317,12318,12319,12320,12321,12322,12328,12329,12331,12332,12333,12338,12340,12348,12357,12362,12369,12370,12371,12372,12373,12374,12375,12376,12377,12378,12379,12380,12381,12385,12386,12387,12388,12389,12390,12391,12392,12393,12394,12395,12396,12397,12398,12399,12401,12403,12407,12413,12421,12423,
12439,12440,12441,12442,12443,12452,12453,12454,12456,12461,12468,12469,12473,12474,12475,12476,12477,12478,12479,12480,12481,12482,12483,12484,12485,12486,12487,12488,12489,12490,12491,12492,12493,12494,12495,12496,12497,12498,12499,12500,12501,12502,12503,12504,12505,12506,12507,12508,12509,12510,
12511,12512,12513,12514,12515,12516,12517,12518,12519,12520,12521,12523,12526,12536,12537,12538,12539,12540,12541,12559,12560,12561,12568,12569,12570,12571,12572,12573,12574,12575,12576,12577,12578,12579,12580,12581,12585,12591,12593,12594,12595,12596,12597,12598,12599,12600,12601,12615,12616,12617,
12629,12656,12657,12658,12659,12660,12661,12664,12665,12666,12667,12668,12669,12670,12671,12672,12673,12674,12675,12676,12677,12678,12679,12680,12681,12686,12729,12742,12743,12744,12745,12746,12747,12748,12749,12750,12751,12754,12755,12758,12759,12760,12761,12762,12763,12764,12767,12769,12778,12779,
12786,12787,12788,12789,12795,12801,12802,12805,12816,12817,12818,12826,12831,12832,12850,12851,12852,12853,12854,12855,12856,12857,12858,12859,12860,12861,12862,12863,12864,12865,12866,12867,12868,12869,12870,12872,12873,12874,12875,12876,12877,12878,12879,12880,12881,12882,12883,12889,12890,12892,
12893,12901,12902,12904,12908,12909,12910,12911,12912,12913,12914,12915,12916,12917,12918,12919,12920,12921,12931,12932,12933,12934,12937,12941,12943,12944,12948,12949,12950,12951,12959,12961,12962,12970,12971,12972,12980,12981,12986,12991,12993,12995,13050,13061,13069,13078,13080,13090,13092,13104,
13147,13149,13150,13151,13152,13153,13154,13160,13165,13200,13201,13214,13215,13219,13220,13221,13222,13223,13224,13225,13226,13227,13228,13229,13230,13231,13232,13233,13234,13235,13236,13237,13238,13239,13240,13241,13242,13247,13256,13263,13264,13265,13266,13267,13268,13269,13270,13271,13272,13273,
13274,13275,13276,13277,13278,13279,13280,13281,13290,13291,13292,13293,13294,13295,13296,13297,13298,13299,13300,13301,13312,13316,13318,13319,13330,13336,13337,13338,13339,13341,13342,13343,13355,13406,13407,13410,13411,13412,13413,13414,13415,13416,13417,13418,13419,13420,13421,13424,13425,13426,
13427,13428,13429,13430,13431,13432,13433,13434,13435,13436,13437,13438,13439,13440,13441,13449,13472,13500,13503,13504,13516,13517,13540,13541,13543,13547,13548,13549,13550,13551,13552,13553,13554,13555,13556,13557,13558,13559,13560,13561,13563,13564,13565,13566,13567,13568,13569,13570,13571,13572,
13573,13574,13575,13576,13577,13578,13579,13580,13581,13586,13587,13588,13589,13590,13591,13592,13593,13594,13595,13596,13597,13598,13599,13600,13601,13604,13605,13606,13607,13608,13609,13610,13611,13612,13613,13614,13615,13616,13617,13618,13619,13620,13621,13622,13623,13625,13627,13628,13629,13630,
13631,13632,13633,13634,13635,13636,13637,13638,13639,13640,13641,13642,13643,13644,13645,13646,13647,13648,13649,13650,13651,13652,13653,13654,13655,13656,13657,13658,13659,13660,13661,13662,13663,13664,13665,13666,13667,13668,13669,13670,13671,13672,13673,13674,13675,13676,13677,13678,13679,13680,
13681,13682,13683,13684,13685,13686,13687,13688,13689,13690,13691,13692,13693,13694,13695,13696,13697,13698,13705,13706,13707,13708,13709,13710,13711,13712,13713,13714,13715,13716,13717,13718,13719,13720,13721,13722,13723,13726,13727,13728,13729,13730,13731,13732,13733,13734,13735,13736,13737,13738,
13739,13740,13741,13742,13743,13744,13745,13746,13747,13748,13749,13750,13751,13753,13762,13763,13764,13765,13766,13767,13768,13769,13770,13771,13772,13773,13774,13775,13776,13777,13778,13779,13780,13781,13782,13783,13784,13785,13786,13787,13788,13789,13790,13791,13792,13793,13794,13795,13796,13797,
13798,13799,13800,13801,13802,13803,13804,13805,13806,13807,13808,13809,13811,13812,13814,13826,13827,13828,13829,13830,13831,13832,13833,13834,13835,13836,13837,13838,13839,13840,13841,13842,13843,13844,13845,13846,13847,13848,13849,13854,13855,13859,13861,13862,13894,13919,13921,13922,13923,13924,
13925,13936,13970,13971,13972,13973,13974,13975,13976,13977,13978,13979,13980,13981,13985,13987,13988,13989,13990,13991,13992,13993,13994,13995,13996,13997,13998,13999,14000,14001,14003,14004,14005,14006,14007,14008,14009,14010,14011,14012,14013,14014,14015,14016,14017,14018,14019,14020,14021,14026,
14027,14028,14029,14030,14031,14032,14033,14034,14035,14036,14037,14038,14039,14040,14041,14049,14050,14051,14052,14053,14054,14055,14056,14057,14058,14059,14060,14061,14063,14064,14065,14066,14067,14068,14069,14070,14071,14072,14073,14074,14075,14076,14077,14078,14079,14080,14081,14082,14083,14084,
14085,14092,14105,14118,14135,14345,14346,14347,14348,14349,14350,14351,14352,14353,14354,14355,14356,14357,14358,14359,14360,14361,14362,14363,14382,14383,14384,14385,14386,14387,14388,14389,14390,14391,14392,14393,14394,14475,14515,14516,14517,14518,14519,14520,14521,14524,14527,14532,14533,14534,
14535,14550,14556,14575,14586,14597,14609,14618,14642,14643,14689,14690,14691,14692,14693,14694,14695,14696,14697,14698,14699,14700,14701,14702,14703,14704,14705,14706,14707,14708,14709,14710,14711,14712,14713,14714,14715,14716,14717,14718,14719,14720,14721,14731,14732,14733,14734,14735,14736,14737,
14738,14739,14740,14741,14818,14819,14820,14822,14823,14824,14836,14837,14845,14870,14871,14873,14874,14875,14876,14877,14878,14879,14880,14881,14882,14883,14884,14885,14886,14887,14888,14889,14890,14891,14892,14893,14984,14985,14986,14987,14988,14989,14990,14991,14992,14993,14994,14995,14996,14997,
14998,14999,15000,15001,15020,15021,15022,15023,15024,15025,15026,15027,15028,15029,15030,15031,15032,15033,15034,15035,15036,15037,15038,15039,15040,15041,15089,15097,15098,15099,15100,15101,15201,15315,15316,15317,15318,15319,15320,15321,15446,15460,15586,15688,15700,15701,15711,15712,15713,15714,
15715,15716,15717,15718,15719,15720,15721,15769,15780,15816,15817,15818,15819,15820,15821,15828,15829,15830,15831,15832,15833,15834,15835,15836,15837,15838,15839,15840,15841,15888,15889,15896,15897,15898,15899,15900,15901,15910,15948,15949,15950,15951,15952,15953,15954,15955,15956,15957,15958,15959,
15960,15961,16010,16011,16012,16013,16014,16015,16016,16017,16018,16019,16020,16021,16024,16025,16026,16027,16028,16029,16030,16031,16032,16033,16034,16035,16036,16037,16038,16061,16062,16063,16064,16065,16066,16067,16068,16069,16070,16071,16073,16074,16075,16076,16077,16078,16079,16080,16081,16082,
16085,16086,16087,16088,16089,16090,16091,16092,16093,16094,16095,16096,16097,16098,16099,16100,16101,16102,16103,16104,16105,16106,16107,16108,16109,16116,16117,16118,16119,16120,16121,16122,16123,16124,16125,16126,16127,16128,16129,16130,16131,16132,16133,16134,16135,16136,16137,16138,16139,16140,
16141,16142,16143,16144,16145,16146,16147,16148,16149,16150,16151,16152,16153,16154,16155,16156,16157,16158,16159,16160,16161,16162,16163,16164,16172,16173,16174,16175,16176,16177,16178,16179,16180,16181,16182,16183,16184,16185,16186,16187,16188,16191,16193,16194,16195,16196,16197,16198,16199,16200,
16201,16211,16212,16213,16225,16226,16227,16228,16229,16230,16231,16232,16233,16234,16235,16236,16237,16238,16239,16240,16241,16256,16257,16258,16259,16260,16261,16264,16265,16266,16267,16268,16269,16270,16271,16272,16273,16274,16275,16276,16277,16278,16279,16280,16281,16284,16285,16286,16287,16288,
16289,16290,16291,16292,16293,16294,16295,16296,16297,16298,16299,16300,16301,16308,16315,16334,16336,16337,16338,16340,16343,16344,16367,16370,16394,16395,16398,16399,16400,16402,16404,16407,16411,16412,16438,16439,16445,16447,16458,16460,16461,16464,16469,16470,16481,16482,16488,16493,16495,16500,
16511,16512,16517,16520,16529,16537,16538,16546,16547,16553,16556,16557,16559,16570,16572,16575,16576,16582,16584,16585,16586,16587,16588,16589,16590,16591,16592,16593,16594,16595,16596,16597,16598,16599,16600,16601,16609,16610,16611,16612,16613,16614,16615,16616,16617,16618,16619,16620,16621,16624,
16625,16626,16627,16628,16629,16630,16631,16632,16633,16634,16635,16636,16637,16638,16639,16640,16641,16657,16664,16749,16750,16751,16752,16753,16754,16755,16756,16757,16758,16759,16760,16761,16770,16771,16772,16773,16774,16775,16776,16777,16778,16779,16780,16781,16792,16874,16875,16876,16877,16878,
16879,16880,16881,17000,17024,17027,17040,17041,17079,17080,17081,17083,17084,17085,17086,17087,17088,17089,17090,17091,17092,17093,17094,17095,17096,17097,17098,17099,17100,17101,17108,17115,17116,17120,17121,17122,17123,17127,17128,17129,17130,17131,17132,17133,17134,17135,17136,17137,17138,17139,
17140,17141,17142,17143,17144,17145,17146,17147,17148,17149,17150,17151,17152,17153,17154,17155,17156,17157,17158,17159,17160,17161,17162,17163,17164,17165,17166,17167,17168,17169,17170,17171,17172,17173,17174,17175,17176,17177,17178,17179,17180,17181,17199,17205,17206,17207,17208,17209,17210,17211,
17212,17213,17214,17215,17216,17217,17218,17219,17220,17221,17225,17226,17227,17228,17229,17230,17231,17232,17233,17234,17235,17236,17237,17238,17239,17240,17241,17243,17244,17245,17246,17247,17248,17249,17250,17251,17252,17253,17254,17255,17256,17257,17258,17259,17260,17261,17263,17264,17265,17266,
17267,17268,17269,17270,17271,17272,17273,17274,17275,17276,17277,17278,17279,17280,17281,17282,17283,17284,17285,17286,17287,17288,17289,17290,17291,17292,17293,17294,17295,17296,17297,17298,17299,17300,17301,17311,17312,17313,17314,17315,17316,17317,17318,17319,17320,17321,17334,17335,17336,17337,
17338,17339,17340,17341,17342,17343,17347,17350,17354,17356,17357,17358,17359,17360,17361,17365,17366,17367,17368,17369,17370,17371,17372,17373,17374,17375,17376,17377,17378,17379,17380,17381,17382,17383,17385,17386,17387,17388,17389,17390,17391,17392,17393,17394,17395,17396,17397,17398,17399,17400,
17401,17409,17412,17415,17416,17417,17418,17419,17420,17421,17424,17425,17426,17427,17428,17429,17430,17431,17432,17433,17434,17435,17436,17437,17438,17439,17440,17441,17443,17444,17445,17446,17447,17448,17449,17450,17451,17452,17453,17454,17455,17456,17457,17458,17459,17460,17461,17462,17463,17464,
17465,17466,17467,17468,17469,17470,17471,17472,17473,17474,17475,17476,17477,17478,17479,17480,17481,17482,17483,17484,17485,17486,17487,17488,17489,17490,17491,17492,17493,17494,17495,17496,17497,17498,17499,17500,17501,17509,17510,17511,17512,17513,17514,17515,17516,17517,17518,17519,17520,17521,
17524,17525,17526,17527,17528,17529,17530,17531,17532,17533,17534,17535,17536,17537,17538,17539,17540,17541,17543,17544,17545,17546,17547,17548,17549,17550,17551,17552,17553,17554,17555,17556,17557,17558,17559,17560,17561,17563,17565,17574,17575,17582,17585,17587,17589,17595,17597,17606,17609,17614,
17615,17619,17621,17627,17628,17629,17630,17631,17632,17633,17634,17635,17636,17637,17638,17639,17640,17641,17644,17645,17646,17647,17648,17649,17650,17651,17652,17653,17654,17655,17656,17657,17658,17659,17660,17661,17663,17664,17665,17666,17667,17668,17669,17670,17671,17672,17673,17674,17675,17676,
17677,17678,17679,17680,17681,17697,17698,17699,17700,17701,17729,17731,17769,17783,17784,17785,17786,17787,17788,17789,17790,17791,17792,17793,17794,17795,17796,17797,17798,17799,17800,17801,17802,17803,17804,17805,17806,17807,17808,17809,17810,17811,17812,17813,17814,17815,17816,17817,17818,17819,
17820,17821,17824,17825,17826,17827,17828,17829,17830,17831,17832,17833,17834,17835,17836,17837,17838,17839,17840,17841,17842,17843,17844,17845,17846,17847,17848,17851,17852,17853,17854,17855,17856,17857,17858,17859,17860,17861,17862,17863,17864,17865,17866,17867,17868,17869,17870,17871,17872,17873,
17874,17875,17876,17877,17878,17879,17880,17881,17882,17883,17884,17885,17886,17887,17888,17889,17890,17891,17892,17893,17894,17895,17896,17897,17898,17899,17910,17911,17912,17913,17914,17915,17916,17917,17918,17919,17920,17921,17923,17924,17925,17926,17927,17928,17929,17930,17931,17932,17933,17934,
17935,17936,17937,17938,17939,17940,17941,17942,17944,17945,17946,17947,17948,17949,17950,17951,17952,17953,17954,17955,17956,17957,17958,17959,17960,17961,17970,17971,17972,17973,17974,17975,17976,17977,17978,17979,17980,17981,17983,17984,17985,17986,17987,17988,17989,17990,17991,17992,17993,17994,
17995,17996,17997,17998,17999,18002,18003,18004,18006,18007,18008,18009,18010,18011,18012,18013,18014,18015,18016,18017,18018,18019,18020,18021,18023,18024,18025,18026,18027,18028,18029,18030,18031,18032,18033,18034,18035,18036,18037,18038,18039,18040,18041,18049,18050,18051,18052,18053,18054,18055,
18056,18057,18058,18059,18060,18061,18062,18063,18064,18065,18066,18067,18068,18069,18070,18071,18072,18073,18074,18075,18076,18077,18078,18079,18080,18081,18084,18085,18086,18087,18088,18089,18090,18091,18092,18093,18094,18095,18096,18097,18098,18099,18100,18101,18105,18106,18107,18108,18109,18110,
18111,18112,18113,18114,18115,18116,18117,18118,18119,18120,18121,18122,18123,18124,18125,18126,18127,18128,18129,18130,18131,18132,18133,18134,18135,18136,18137,18138,18139,18140,18141,18153,18155,18156,18157,18158,18159,18161,18162,18163,18164,18165,18166,18167,18174,18175,18176,18177,18178,18179,
18180,18181,18183,18184,18185,18186,18187,18188,18189,18190,18191,18192,18193,18194,18195,18196,18197,18198,18199,18200,18201,18209,18210,18211,18212,18213,18214,18215,18216,18217,18218,18219,18220,18221,18235,18270,18271,18272,18273,18274,18275,18276,18277,18278,18279,18280,18281,18293,18303,18304,
18316,18320,18341,18342,18355,18419,18431,18433,18438,18439,18446,18474,18548,18549,18550,18551,18552,18553,18554,18555,18556,18557,18558,18559,18560,18561,18568,18569,18570,18571,18572,18573,18574,18575,18576,18577,18578,18579,18580,18581,18589,18593,18595,18596,18599,18613,18614,18615,18616,18617,
18618,18619,18620,18621,18627,18630,18644,18666,18667,18668,18669,18685,18732,18733,18747,18748,18750,18751,18763,18764,18765,18800,18801,18881,18882,18883,18884,18885,18886,18887,18888,18889,18890,18891,18892,18893,18894,18895,18896,18897,18898,18899,18900,18901,18903,18905,18906,18907,18908,18909,
18910,18911,18912,18913,18914,18915,18916,18917,18918,18919,18920,18921,18923,18924,18925,18926,18927,18928,18929,18930,18931,18932,18933,18934,18935,18936,18937,18938,18939,18940,18941,18942,18950,18951,18963,18964,18965,18966,18967,18968,18971,18973,18974,18975,18976,18977,18978,18979,18980,18981,
18982,18983,18985,18988,18989,18990,18991,18992,18993,18994,18995,18996,18997,18998,18999,19000,19001,19014,19021,19053,19054,19055,19063,19065,19072,19073,19074,19075,19076,19077,19078,19079,19080,19081,19082,19122,19129,19158,19161,19171,19172,19173,19174,19175,19176,19177,19178,19179,19180,19181,
19184,19185,19186,19187,19188,19189,19190,19191,19192,19193,19194,19195,19196,19197,19198,19199,19200,19201,19214,19226,19285,19286,19294,19313,19314,19359,19404,19408,19409,19410,19411,19412,19413,19414,19415,19416,19417,19418,19419,19420,19421,19427,19428,19429,19455,19456,19457,19458,19459,19460,
19461,19463,19464,19465,19466,19467,19468,19469,19470,19471,19472,19473,19474,19475,19476,19477,19478,19479,19480,19481,19482,19485,19486,19487,19488,19489,19490,19492,19493,19494,19495,19496,19497,19498,19499,19500,19501,19502,19503,19504,19622,19623,19624,19625,19626,19627,19628,19629,19630,19631,
19632,19633,19634,19635,19636,19637,19638,19639,19640,19641,19642,19643,19644,19645,19646,19647,19648,19649,19650,19651,19652,19653,19654,19655,19656,19657,19658,19659,19660,19661,19662,19663,19664,19665,19666,19667,19668,19669,19670,19671,19672,19673,19674,19675,19676,19677,19678,19679,19680,19681,
19728,19729,19730,19731,19732,19733,19734,19735,19736,19737,19738,19739,19740,19741,19742,19743,19744,19745,19746,19747,19748,19749,19750,19751,19752,19753,19754,19755,19756,19757,19758,19759,19761,19762,19763,19791,19792,19793,19794,19795,19796,19797,19798,19799,19800,19801,19804,19809,19810,19811,
19837,19844,19847,19860,19868,19916,19917,19924,19926,19932,19966,19976,19977,19980,19981,19983,19985,19986,19987,19988,19989,20003,20005,20020,20024,20026,20084,20118,20119,20120,20121,20122,20123,20133,20135,20136,20137,20138,20139,20140,20141,20142,20143,20144,20145,20146,20147,20148,20149,20178,
20179,20180,20182,20183,20185,20238,20239,20240,20241,20242,20245,20246,20247,20248,20249,20250,20251,20252,20267,20268,20269,20270,20271,20272,20273,20274,20275,20276,20277,20278,20279,20280,20281,20282,20283,20284,20285,20286,20287,20288,20289,20290,20291,20292,20293,20294,20297,20298,20299,20300,
20301,20302,20303,20304,20305,20306,20307,20308,20309,20311,20312,20313,20314,20315,20316,20317,20318,20319,20320,20321,20322,20323,20324,20325,20326,20327,20328,20329,20330,20331,20332,20333,20334,20335,20336,20337,20338,20339,20340,20341,20342,20343,20344,20345,20346,20347,20348,20349,20350,20351,
20352,20353,20354,20355,20356,20357,20358,20359,20360,20361,20362,20363,20364,20365,20366,20367,20368,20370,20372,20386,20412,20417,20421,20423,20445,20446,20460,20462,20468,20471,20473,20475,20484,20485,20486,20489,20502,20522,20523,20524,20525,20529,20583,20584,20585,20586,20587,20588,20589,20590,
20591,20592,20593,20594,20595,20596,20597,20598,20609,20651,20718,20719,20737,20738,20739,20740,20743,20751,20759,20760,20762,20764,20765,20771,20772,20773,20774,20775,20776,20777,20778,20779,20780,20781,20782,20783,20784,20785,20786,20787,20788,20789,20790,20791,20792,20793,20794,20795,20796,20797,
20798,20799,20804,20811,20812,20813,20814,20815,20816,20817,20818,20819,20820,20821,20822,20823,20824,20825,20826,20827,20828,20829,20830,20831,20832,20833,20834,20835,20836,20837,20838,20839,20840,20841,20842,20843,20845,20846,20847,20848,20849,20850,20851,20852,20853,20854,20855,20856,20857,20880,
20883,20887,20891,20892,20893,20894,20895,20896,20897,20898,20899,20900,20901,20902,20903,20904,20905,20906,20907,20908,20909,20910,20911,20912,20913,20914,20915,20916,20917,20918,20919,20920,20921,20922,20923,20924,20925,20934,20935,20936,20937,20938,20946,20950,20952,20953,20954,20955,20956,20957,
20958,20959,20960,20961,20962,20963,20964,20965,20966,20967,20968,20969,20970,20971,20972,20973,20974,20975,20976,20977,20978,20979,20980,20981,20982,20983,20984,20985,20986,20987,20988,20989,20990,20991,20992,20993,20994,20995,20996,20997,20998,20999,21000,21001,21002,21003,21004,21005,21006,21007,
21008,21009,21010,21011,21012,21013,21014,21015,21016,21017,21018,21019,21020,21021,21022,21026,21034,21035,21036,21043,21045,21046,21047,21048,21049,21050,21051,21052,21053,21054,21055,21056,21057,21058,21059,21060,21061,21062,21063,21064,21065,21066,21067,21068,21069,21070,21073,21074,21075,21076,
21077,21078,21079,21080,21081,21082,21083,21084,21085,21086,21087,21088,21089,21090,21091,21092,21093,21094,21095,21096,21097,21098,21101,21102,21121,21122,21123,21124,21125,21127,21129,21135,21141,21152,21159,21163,21168,21169,21170,21172,21173,21192,21193,21194,21195,21231,21233,21234,21236,21238,
21239,21240,21246,21247,21274,21276,21286,21313,21339,21369,21419,21420,21421,21422,21423,21424,21425,21426,21427,21428,21429,21430,21431,21432,21433,21434,21435,21437,21439,21440,21441,21442,21443,21444,21445,21446,21447,21448,21449,21450,21451,21465,21516,21518,21549,21550,21551,21553,21554,21555,
21556,21560,21564,21572,21573,21575,21577,21578,21580,21584,21588,21591,21594,21612,21613,21614,21628,21629,21630,21631,21632,21633,21634,21636,21637,21638,21641,21642,21643,21644,21646,21649,21653,21654,21655,21656,21657,21658,21659,21660,21661,21662,21717,21719,21720,21736,21739,21748,21752,21753,
21754,21755,21756,21757,21758,21759,21760,21763,21764,21765,21766,21767,21768,21769,21770,21771,21772,21773,21774,21775,21776,21777,21778,21779,21780,21781,21782,21783,21784,21785,21786,21787,21788,21789,21790,21791,21792,21793,21794,21795,21796,21797,21798,21799,21807,21808,21811,21824,21825,21826,
21827,21828,21832,21834,21835,21840,21841,21842,21843,21844,21845,21846,21847,21848,21849,21850,21851,21852,21853,21854,21855,21857,21858,21859,21860,21861,21862,21863,21864,21865,21866,21867,21868,21869,21870,21871,21872,21873,21874,21875,21876,21877,21878,21879,21880,21881,21882,21883,21884,21885,
21886,21887,21890,21892,21893,21894,21895,21896,21897,21898,21899,21900,21901,21902,21903,21904,21905,21906,21907,21908,21909,21910,21911,21912,21913,21914,21915,21916,21917,21918,21919,21922,21923,21924,21927,21929,21930,21931,21932,21933,21934,21940,21941,21942,21943,21944,21945,21947,21948,21949,
21950,21951,21952,21953,21954,21955,21956,21957,21958,21959,21961,21962,21963,21964,21965,21966,21967,21968,21969,21970,21971,21972,21973,21974,21976,21977,21978,21990,21991,21992,21993,22012,22018,22019,22020,22021,22022,22023,22024,22025,22026,22027,22028,22029,22030,22031,22032,22033,22034,22035,
22036,22037,22038,22039,22040,22041,22042,22043,22044,22045,22053,22054,22055,22103,22104,22105,22114,22116,22118,22124,22125,22126,22127,22128,22129,22130,22146,22147,22148,22151,22152,22153,22179,22180,22181,22182,22183,22184,22185,22186,22187,22188,22189,22190,22199,22210,22211,22213,22215,22230,
22233,22258,22273,22316,22323,22341,22346,22386,22387,22391,22413,22414,22415,22445,22446,22447,22448,22449,22450,22451,22452,22453,22454,22455,22456,22457,22459,22460,22461,22462,22463,22473,22474,22475,22485,22486,22487,22521,22522,22530,22531,22532,22533,22534,22535,22536,22537,22538,22539,22540,
22541,22542,22543,22544,22545,22546,22547,22548,22549,22550,22551,22552,22553,22554,22555,22556,22557,22558,22559,22560,22561,22562,22563,22564,22565,22566,22567,22569,22570,22571,22572,22573,22574,22575,22576,22577,22578,22579,22580,22581,22582,22583,22584,22585,22586,22587,22588,22590,22591,22592,
22594,22596,22597,22598,22599,22619,22625,22626,22627,22628,22629,22633,22634,22639,22640,22641,22642,22643,22644,22645,22646,22647,22653,22674,22675,22677,22684,22685,22686,22687,22692,22693,22694,22695,22696,22697,22698,22703,22704,22705,22706,22709,22710,22717,22724,22735,22738,22751,22755,22765,
22775,22776,22777,22778,22779,22780,22781,22782,22783,22784,22785,22786,22787,22788,22789,22790,22791,22792,22793,22794,22795,22796,22797,22805,22814,22817,22823,22824,22825,22826,22827,22828,22829,22830,22831,22832,22833,22834,22835,22836,22837,22838,22839,22840,22841,22842,22844,22845,22846,22847,
22848,22849,22850,22851,22853,22854,22861,22866,22871,22888,22889,22893,22894,22896,22898,22899,22900,22901,22902,22903,22904,22905,22906,22907,22908,22909,22910,22911,22912,22913,22914,22915,22916,22917,22918,22919,22920,22921,22922,22923,22924,22925,22926,22927,22928,22929,22931,22933,22934,22951,
22952,22953,22955,22956,22957,22958,22959,22962,22963,22964,22965,22966,22969,22971,22976,22978,22979,22980,22982,22984,22985,22986,22987,22989,22990,22991,22992,22993,22995,22996,22997,22998,23003,23026,23034,23052,23058,23072,23074,23076,23077,23079,23080,23086,23094,23095,23096,23097,23098,23099,
23100,23101,23102,23103,23104,23105,23106,23107,23108,23109,23110,23111,23112,23113,23114,23115,23116,23117,23118,23119,23120,23121,23130,23131,23133,23134,23135,23136,23137,23138,23140,23141,23142,23143,23144,23145,23146,23147,23148,23149,23150,23151,23152,23153,23154,23155,23157,23158,23159,23162,
23163,23164,23165,23166,23167,23172,23174,23175,23176,23185,23186,23187,23188,23189,23190,23191,23202,23204,23205,23208,23209,23210,23212,23213,23214,23215,23216,23217,23218,23222,23223,23224,23225,23227,23228,23229,23230,23231,23232,23233,23234,23235,23236,23239,23240,23241,23245,23248,23249,23265,
23266,23267,23268,23269,23270,23271,23321,23322,23325,23328,23329,23330,23331,23332,23333,23334,23335,23336,23337,23338,23339,23340,23341,23342,23343,23344,23345,23346,23347,23348,23349,23350,23351,23352,23353,23354,23355,23356,23357,23358,23359,23360,23361,23362,23363,23364,23365,23366,23367,23368,
23369,23370,23371,23372,23373,23374,23375,23376,23377,23378,23380,23381,23382,23383,23384,23385,23386,23387,23388,23389,23390,23391,23392,23393,23394,23395,23396,23397,23398,23399,23400,23401,23402,23403,23404,23405,23406,23407,23408,23409,23410,23411,23412,23413,23414,23415,23416,23417,23418,23419,
23420,23421,23422,23423,23424,23425,23426,23427,23428,23429,23430,23431,23432,23433,23434,23436,23437,23438,23439,23440,23441,23442,23443,23444,23445,23446,23447,23448,23449,23450,23457,23458,23459,23460,23461,23462,23463,23470,23471,23472,23473,23474,23475,23476,23477,23478,23479,23480,23481,23482,
23483,23484,23485,23486,23487,23488,23489,23490,23491,23492,23493,23494,23495,23496,23497,23498,23499,23500,23501,23502,23503,23504,23505,23506,23507,23508,23509,23510,23511,23512,23513,23514,23515,23516,23517,23518,23519,23520,23521,23522,23523,23524,23525,23526,23527,23528,23529,23530,23531,23532,
23533,23534,23535,23536,23537,23538,23539,23540,23541,23542,23543,23544,23546,23550,23551,23552,23553,23554,23555,23556,23559,23560,23561,23562,23563,23564,23565,23566,23567,23568,23569,23571,23572,23573,23574,23575,23576,23580,23581,23582,23583,23584,23585,23586,23587,23588,23589,23590,23591,23592,
23593,23594,23595,23596,23597,23598,23599,23600,23601,23602,23603,23604,23605,23606,23607,23608,23609,23610,23611,23612,23613,23614,23615,23616,23617,23618,23619,23620,23621,23622,23623,23624,23625,23626,23627,23628,23629,23630,23631,23632,23633,23634,23635,23636,23637,23638,23639,23640,23641,23642,
23643,23644,23645,23646,23647,23648,23649,23650,23651,23652,23653,23654,23655,23656,23657,23658,23659,23660,23661,23662,23669,23670,23671,23672,23673,23674,23675,23676,23677,23678,23679,23680,23681,23682,23683,23684,23685,23686,23687,23688,23689,23690,23691,23692,23693,23694,23695,23696,23697,23698,
23699,23700,23701,23702,23703,23704,23705,23706,23707,23708,23709,23710,23711,23712,23713,23714,23715,23716,23717,23718,23719,23721,23722,23723,23724,23725,23726,23727,23728,23729,23730,23731,23732,23733,23734,23735,23736,23737,23738,23739,23740,23741,23742,23743,23744,23745,23746,23747,23748,23749,
23750,23751,23752,23753,23754,23755,23756,23757,23758,23759,23760,23761,23762,23763,23764,23765,23766,23767,23768,23769,23770,23771,23772,23773,23774,23775,23776,23777,23778,23779,23780,23781,23782,23783,23784,23785,23786,23787,23788,23789,23790,23791,23792,23793,23794,23795,23796,23797,23798,23799,
23800,23801,23802,23803,23804,23805,23806,23807,23808,23809,23810,23811,23812,23813,23814,23815,23816,23817,23818,23819,23820,23821,23822,23823,23824,23825,23826,23827,23828,23829,23830,23831,23832,23833,23834,23835,23836,23837,23838,23839,23840,23841,23842,23843,23844,23845,23846,23847,23848,23849,
23850,23851,23852,23853,23854,23855,23856,23857,23858,23859,23860,23861,23862,23863,23864,23865,23866,23867,23868,23869,23870,23871,23872,23873,23874,23875,23876,23877,23878,23879,23880,23881,23882,23883,23884,23885,23886,23887,23888,23889,23890,23891,23892,23893,23894,23895,23896,23897,23898,23899,
23900,23901,23902,23903,23904,23905,23906,23907,23908,23909,23910,23911,23912,23913,23914,23915,23916,23917,23918,23919,23920,23921,23922,23923,23924,23925,23926,23927,23928,23929,23930,23931,23932,23933,23934,23935,23936,23937,23938,23939,23940,23941,23942,23943,23944,23945,23946,23947,23948,23949,
23950,23951,23952,23953,23954,23955,23956,23957,23958,23959,23960,23961,23962,23963,23964,23965,23966,23967,23968,23969,23970,23971,23972,23973,23974,23975,23976,23977,23978,23979,23980,23981,23982,23983,23984,23985,23986,23987,23988,23989,23990,23991,23992,23993,23994,23995,23996,23997,23998,23999,
24000,24001,24002,24003,24004,24005,24006,24007,24008,24009,24010,24011,24012,24013,24014,24015,24016,24017,24018,24019,24020,24021,24022,24023,24024,24025,24026,24027,24028,24029,24030,24031,24032,24033,24034,24035,24036,24037,24038,24039,24040,24041,24042,24043,24044,24045,24046,24047,24048,24049,
24050,24051,24052,24053,24054,24055,24056,24057,24058,24059,24060,24061,24062,24063,24064,24065,24066,24067,24068,24069,24070,24071,24072,24073,24074,24075,24076,24077,24078,24079,24080,24081,24082,24083,24084,24085,24086,24087,24088,24089,24090,24091,24092,24093,24094,24095,24096,24097,24098,24099,
24100,24103,24104,24105,24106,24107,24108,24109,24110,24111,24112,24113,24114,24115,24116,24117,24118,24119,24120,24121,24122,24123,24124,24125,24126,24127,24128,24129,24130,24131,24132,24133,24134,24135,24136,24137,24138,24139,24140,24141,24142,24143,24144,24145,24146,24147,24148,24149,24150,24151,
24152,24153,24154,24155,24156,24157,24158,24159,24160,24161,24162,24163,24164,24165,24166,24167,24168,24169,24170,24171,24172,24173,24174,24175,24176,24177,24178,24179,24180,24181,24182,24183,24184,24185,24186,24187,24188,24189,24190,24191,24192,24193,24194,24195,24196,24197,24198,24199,24200,24201,
24202,24203,24204,24205,24206,24207,24208,24209,24210,24211,24212,24213,24214,24215,24216,24217,24218,24219,24220,24221,24223,24224,24225,24226,24227,24228,24229,24230,24233,24234,24235,24236,24237,24238,24239,24240,24241,24242,24243,24244,24245,24246,24247,24248,24249,24250,24251,24252,24253,24254,
24255,24256,24257,24258,24259,24260,24261,24262,24263,24264,24265,24266,24267,24268,24269,24270,24271,24272,24273,24274,24275,24276,24277,24278,24279,24280
}
local ItemsTBC = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,23,24,26,27,28,29,30,31,32,33,34,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,78,81,82,83,84,96,106,107,108,109,110,111,112,116,142,144,145,158,160,
161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,183,185,186,187,188,189,190,191,196,197,198,199,204,205,206,207,208,211,212,213,214,215,216,217,218,219,220,221,222,
223,224,225,226,227,228,229,230,231,232,233,234,235,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,
277,278,279,280,281,282,283,284,288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,316,317,318,319,320,321,322,323,324,325,326,327,328,329,
330,331,332,333,334,335,336,337,338,339,340,341,342,343,344,345,346,347,348,349,350,351,352,353,354,355,356,357,358,359,360,361,362,363,364,365,366,367,368,369,370,371,372,373,374,375,376,377,378,379,
380,381,382,383,384,385,386,387,388,389,390,391,392,393,394,395,396,397,398,399,400,401,402,403,404,405,406,407,408,409,410,411,412,413,415,416,417,418,419,420,421,423,424,425,426,427,428,429,430,431,
432,433,434,435,436,437,438,439,440,441,442,443,444,445,446,447,448,449,450,451,452,453,454,455,456,457,458,459,460,461,462,463,464,465,466,467,468,469,470,471,472,473,474,475,476,477,478,479,480,481,
482,483,484,485,486,487,488,489,490,491,492,493,494,495,496,497,498,499,500,501,502,503,504,505,506,507,508,509,510,511,512,513,514,515,516,517,518,519,520,521,522,523,524,525,526,528,529,530,531,532,
533,534,535,536,538,539,540,541,542,543,544,545,546,547,548,549,550,551,552,553,554,557,558,559,560,561,562,563,564,565,566,567,568,569,570,571,572,573,574,575,576,577,578,579,580,581,582,583,584,585,
586,587,588,589,590,591,592,593,594,595,596,597,598,599,600,601,602,603,604,605,606,607,608,609,610,611,612,613,614,615,616,617,618,619,620,621,622,623,624,625,626,627,628,629,630,631,632,633,634,635,
636,637,638,639,640,641,642,643,644,645,646,648,649,650,651,652,653,654,655,656,657,658,659,660,661,662,663,664,665,666,667,668,669,670,671,672,673,674,675,676,677,678,679,680,681,682,683,684,685,686,
687,688,689,690,691,692,693,694,695,696,697,698,699,700,701,702,703,704,705,706,707,708,709,712,713,715,716,717,721,722,726,736,747,749,757,758,759,760,762,764,775,800,801,802,803,815,817,819,822,824,
825,830,831,834,861,874,879,881,882,891,904,912,919,946,947,949,950,952,953,959,963,969,970,971,972,977,978,979,982,984,987,988,990,991,993,995,998,999,1000,1001,1002,1003,1005,1007,1012,1039,1040,1045,1050,1051,
1054,1055,1056,1059,1060,1062,1064,1065,1066,1067,1068,1069,1070,1071,1073,1079,1094,1097,1098,1103,1104,1106,1107,1110,1118,1120,1126,1135,1137,1140,1142,1143,1145,1147,1148,1152,1153,1160,1185,1188,1209,1223,1225,1226,1227,1230,1233,1234,1235,1236,
1237,1240,1241,1242,1247,1248,1249,1271,1277,1278,1285,1286,1289,1290,1291,1295,1301,1305,1308,1316,1320,1329,1330,1331,1333,1335,1336,1337,1338,1340,1342,1343,1344,1345,1346,1347,1348,1365,1373,1375,1390,1393,1426,1428,1437,1439,1441,1442,1452,1456,
1463,1466,1471,1474,1494,1496,1517,1525,1526,1530,1531,1538,1540,1541,1542,1543,1546,1548,1549,1550,1551,1552,1553,1555,1556,1558,1562,1563,1564,1565,1569,1570,1572,1573,1575,1576,1577,1578,1579,1580,1581,1582,1583,1584,1585,1586,1587,1590,1592,1593,
1594,1595,1600,1601,1605,1606,1609,1610,1611,1614,1615,1616,1617,1618,1620,1621,1626,1627,1628,1629,1631,1632,1633,1634,1635,1636,1642,1643,1644,1646,1647,1650,1653,1660,1661,1662,1665,1666,1667,1668,1669,1670,1671,1673,1674,1675,1682,1683,1709,1723,
1762,1763,1765,1771,1773,1779,1781,1833,1834,1837,1838,1841,1842,1847,1848,1855,1856,1857,1858,1859,1860,1861,1862,1863,1864,1865,1866,1867,1868,1869,1870,1871,1872,1873,1874,1876,1878,1879,1880,1881,1883,1884,1885,1887,1888,1889,1890,1891,1892,1898,
1916,1919,1920,1921,1932,1947,1949,1952,1953,1954,1964,1966,1967,1989,2001,2009,2010,2019,2022,2031,2049,2061,2062,2063,2068,2076,2083,2086,2090,2093,2094,2095,2096,2097,2111,2116,2118,2135,2155,2157,2171,2174,2185,2190,2192,2193,2228,2229,2242,2247,
2248,2253,2261,2269,2270,2272,2279,2285,2286,2293,2294,2297,2298,2301,2328,2329,2330,2331,2332,2333,2334,2335,2336,2337,2338,2339,2340,2341,2342,2343,2344,2345,2346,2347,2348,2349,2350,2351,2352,2353,2354,2355,2356,2357,2358,2359,2360,2363,2365,2368,
2416,2430,2433,2436,2439,2537,2538,2539,2540,2541,2542,2543,2544,2597,2603,2626,2627,2630,2631,2641,2670,2689,2726,2727,2729,2731,2733,2736,2737,2739,2741,2743,2746,2747,2752,2753,2761,2762,2767,2768,2769,2796,2860,2861,2873,2897,2914,2935,2936,2937,
2938,2952,3009,3038,3043,3104,3105,3106,3112,3178,3359,3398,3479,3512,3579,3580,3700,3709,3896,3903,4081,4142,4144,4160,4222,4224,4227,4229,4420,4423,4559,4572,4574,4617,4618,4619,4642,4651,4842,5031,5032,5033,5034,5035,5036,5037,5039,5046,5047,5070,
5144,5146,5157,5159,5161,5162,5224,5225,5290,5378,5384,5452,5492,5496,5497,5499,5501,5678,5885,5886,5887,5888,5889,5890,5891,5892,5893,5894,5895,5898,5899,5900,5901,5902,5903,5904,5905,5906,5907,5908,5909,5910,5911,5912,5913,5914,5915,5920,5921,5922,
5923,5924,5925,5926,5927,5928,5929,5930,5931,5932,5933,5934,5935,5937,5955,5977,5978,5979,5980,5981,5982,5983,5984,5985,5986,5987,5988,5989,5990,5991,5992,5993,5994,5995,5999,6000,6001,6002,6003,6004,6005,6006,6007,6008,6009,6010,6011,6012,6013,6014,
6015,6017,6018,6019,6020,6021,6022,6023,6024,6025,6026,6027,6028,6029,6030,6031,6032,6033,6034,6035,6099,6100,6101,6102,6103,6104,6105,6106,6107,6108,6109,6110,6111,6112,6113,6114,6115,6128,6141,6142,6143,6151,6152,6153,6154,6155,6156,6157,6158,6159,
6160,6161,6162,6163,6164,6165,6207,6208,6209,6210,6221,6244,6255,6483,6484,6485,6606,6699,6700,6701,6702,6703,6704,6705,6706,6758,6759,6760,6761,6762,6763,6764,6765,6768,6769,6770,6771,6772,6813,6814,6815,6816,6817,6818,6819,6820,6821,6822,6823,6824,
6825,6853,6854,6855,6856,6857,6858,6859,6860,6861,6862,6863,6864,6865,6867,6868,6869,6870,6871,6872,6873,6874,6875,6876,6877,6878,6879,6880,6881,6882,6883,6884,6885,6917,6918,6919,6920,6921,6922,6923,6924,6925,6932,6933,6934,6935,6936,6937,6938,6939,
6940,6941,6942,6943,6944,6945,6954,6955,6956,6957,6958,6959,6960,6961,6962,6963,6964,6965,7008,7009,7010,7011,7012,7013,7014,7015,7016,7017,7018,7019,7020,7021,7022,7023,7024,7025,7028,7029,7030,7031,7032,7033,7034,7035,7036,7037,7038,7039,7040,7041,
7042,7043,7044,7045,7066,7102,7103,7104,7105,7121,7122,7123,7124,7125,7136,7137,7138,7139,7140,7141,7142,7143,7144,7145,7147,7149,7150,7151,7152,7153,7154,7155,7156,7157,7158,7159,7160,7161,7162,7163,7164,7165,7167,7168,7169,7172,7173,7174,7175,7176,
7177,7178,7179,7180,7181,7182,7183,7184,7185,7186,7193,7194,7195,7196,7197,7198,7199,7200,7201,7202,7203,7204,7205,7210,7211,7212,7213,7214,7215,7216,7217,7218,7219,7220,7221,7222,7223,7224,7225,7232,7233,7234,7235,7236,7237,7238,7239,7240,7241,7242,
7243,7244,7245,7246,7250,7251,7252,7253,7254,7255,7256,7257,7258,7259,7260,7261,7262,7263,7264,7265,7300,7301,7302,7303,7304,7305,7310,7311,7312,7313,7314,7315,7316,7317,7318,7319,7320,7321,7322,7323,7324,7325,7379,7380,7381,7382,7383,7384,7385,7393,
7394,7395,7396,7397,7398,7399,7400,7401,7402,7403,7404,7405,7501,7502,7503,7504,7505,7562,7563,7564,7565,7570,7571,7572,7573,7574,7575,7576,7577,7578,7579,7580,7581,7582,7583,7584,7585,7588,7589,7590,7591,7592,7593,7594,7595,7596,7597,7598,7599,7600,
7601,7602,7603,7604,7605,7614,7615,7616,7617,7618,7619,7620,7621,7622,7623,7624,7625,7630,7631,7632,7633,7634,7635,7636,7637,7638,7639,7640,7641,7642,7643,7644,7645,7647,7648,7649,7650,7651,7652,7653,7654,7655,7656,7657,7658,7659,7660,7661,7662,7663,
7664,7665,7677,7692,7693,7694,7695,7696,7697,7698,7699,7700,7701,7702,7703,7704,7705,7732,7743,7744,7745,7762,7763,7764,7765,7772,7773,7774,7775,7776,7777,7778,7779,7780,7781,7782,7783,7784,7785,7788,7789,7790,7791,7792,7793,7794,7795,7796,7797,7798,
7799,7800,7801,7802,7803,7804,7805,7814,7815,7816,7817,7818,7819,7820,7821,7822,7823,7824,7825,7827,7828,7829,7830,7831,7832,7833,7834,7835,7836,7837,7838,7839,7840,7841,7842,7843,7844,7845,7849,7850,7851,7852,7853,7854,7855,7856,7857,7858,7859,7860,
7861,7862,7863,7864,7865,7873,7874,7875,7876,7877,7878,7879,7880,7881,7882,7883,7884,7885,7889,7890,7891,7892,7893,7894,7895,7896,7897,7898,7899,7900,7901,7902,7903,7904,7905,7940,7962,7998,7999,8000,8001,8002,8003,8004,8005,8010,8011,8012,8013,8014,
8015,8016,8017,8018,8019,8020,8021,8022,8023,8024,8025,8031,8032,8033,8034,8035,8036,8037,8038,8039,8040,8041,8042,8043,8044,8045,8054,8055,8056,8057,8058,8059,8060,8061,8062,8063,8064,8065,8096,8097,8098,8099,8100,8101,8102,8103,8104,8105,8145,8166,
8219,8220,8221,8222,8227,8228,8229,8230,8231,8232,8233,8234,8235,8236,8237,8238,8239,8240,8241,8242,8321,8322,8323,8324,8325,8326,8327,8328,8329,8330,8331,8332,8333,8334,8335,8336,8337,8338,8339,8340,8341,8342,8351,8352,8353,8354,8355,8356,8357,8358,
8359,8360,8361,8362,8369,8370,8371,8372,8373,8374,8375,8376,8377,8378,8379,8380,8381,8382,8413,8414,8415,8416,8417,8418,8419,8420,8421,8422,8433,8434,8435,8436,8437,8438,8439,8440,8441,8442,8445,8446,8447,8448,8449,8450,8451,8452,8453,8454,8455,8456,
8457,8458,8459,8460,8461,8462,8464,8465,8466,8467,8468,8469,8470,8471,8472,8473,8474,8475,8476,8477,8478,8479,8480,8481,8482,8509,8510,8511,8512,8513,8514,8515,8516,8517,8518,8519,8520,8521,8522,8530,8531,8532,8533,8534,8535,8536,8537,8538,8539,8540,
8541,8542,8549,8550,8551,8552,8553,8554,8555,8556,8557,8558,8559,8560,8561,8562,8565,8566,8567,8568,8569,8570,8571,8572,8573,8574,8575,8576,8577,8578,8579,8580,8581,8582,8596,8597,8598,8599,8600,8601,8602,8604,8605,8606,8607,8608,8609,8610,8611,8612,
8613,8614,8615,8616,8617,8618,8619,8620,8621,8622,8634,8635,8636,8637,8638,8639,8640,8641,8642,8648,8649,8650,8651,8652,8653,8654,8655,8656,8657,8658,8659,8660,8661,8662,8664,8665,8666,8667,8668,8669,8670,8671,8672,8673,8674,8675,8676,8677,8678,8679,
8680,8681,8682,8689,8690,8691,8692,8693,8694,8695,8696,8697,8698,8699,8700,8701,8702,8706,8709,8710,8711,8712,8713,8714,8715,8716,8717,8718,8719,8720,8721,8722,8725,8726,8727,8728,8729,8730,8731,8732,8733,8734,8735,8736,8737,8738,8739,8740,8741,8742,
8745,8767,8803,8817,8870,8908,8946,8970,8979,8982,9038,9042,9045,9092,9106,9107,9108,9109,9110,9111,9112,9113,9114,9115,9116,9117,9118,9119,9120,9121,9122,9163,9196,9213,9220,9232,9239,9267,9268,9269,9270,9271,9272,9273,9274,9310,9337,9338,9339,9340,
9341,9342,9343,9344,9345,9346,9347,9348,9349,9350,9351,9352,9353,9354,9373,9374,9376,9377,9493,9494,9495,9496,9497,9498,9499,9500,9501,9502,9503,9504,9505,9506,9524,9525,9526,9549,9582,9583,9584,9585,9586,9610,9611,9612,9613,9614,9615,9616,9617,9667,
9668,9669,9670,9671,9672,9673,9674,9675,9676,9677,9688,9689,9690,9691,9692,9693,9694,9695,9696,9697,9707,9708,9709,9710,9711,9712,9713,9714,9715,9716,9717,9720,9721,9722,9723,9724,9725,9726,9727,9728,9729,9730,9731,9732,9733,9734,9735,9736,9737,9975,
9976,9977,9979,9980,9981,9982,9983,9984,9985,9986,9987,9988,9989,9990,9991,9992,9993,9994,9995,9996,9997,10006,10012,10013,10014,10015,10016,10017,10037,10114,10115,10116,10117,10284,10291,10292,10293,10294,10295,10296,10297,10334,10335,10336,10337,10339,10340,10341,10342,10343,
10344,10345,10346,10347,10348,10349,10350,10351,10352,10353,10354,10355,10356,10357,10395,10396,10397,10415,10416,10417,10419,10422,10425,10426,10427,10428,10429,10430,10431,10432,10433,10434,10435,10436,10437,10448,10449,10451,10452,10453,10468,10469,10470,10471,10472,10473,10474,10475,10476,10477,
10480,10481,10482,10483,10484,10485,10486,10487,10488,10489,10490,10491,10492,10493,10494,10495,10496,10497,10516,10517,10519,10520,10521,10522,10523,10524,10525,10526,10527,10528,10529,10530,10531,10532,10533,10534,10535,10536,10537,10557,10665,10666,10667,10668,10669,10670,10671,10672,10673,10674,
10675,10676,10677,10729,10730,10731,10732,10733,10734,10735,10736,10737,10809,10810,10811,10812,10813,10814,10815,10816,10817,10848,10849,10850,10851,10852,10853,10854,10855,10856,10857,10859,10860,10861,10862,10863,10864,10865,10866,10867,10868,10869,10870,10871,10872,10873,10874,10875,10876,10877,
10879,10880,10881,10882,10883,10884,10885,10886,10887,10888,10889,10890,10891,10892,10893,10894,10895,10896,10897,10899,10900,10901,10902,10903,10904,10905,10906,10907,10908,10909,10910,10911,10912,10913,10914,10915,10916,10917,10923,10924,10925,10926,10927,10928,10929,10930,10931,10932,10933,10934,
10935,10936,10937,10941,10942,10943,10944,10945,10946,10947,10948,10949,10950,10951,10952,10953,10954,10955,10956,10957,10960,10961,10962,10963,10964,10965,10966,10967,10968,10969,10970,10971,10972,10973,10974,10975,10976,10977,10979,10980,10981,10982,10983,10984,10985,10986,10987,10988,10989,10990,
10991,10992,10993,10994,10995,10996,10997,11001,11002,11003,11004,11005,11006,11007,11008,11009,11010,11011,11012,11013,11014,11015,11016,11017,11028,11029,11030,11031,11032,11033,11034,11035,11036,11037,11043,11044,11045,11046,11047,11048,11049,11050,11051,11052,11053,11054,11055,11056,11057,11059,
11060,11061,11062,11063,11064,11065,11066,11067,11068,11069,11070,11071,11072,11073,11074,11075,11076,11077,11085,11088,11089,11090,11091,11092,11093,11094,11095,11096,11097,11100,11117,11153,11154,11155,11156,11157,11158,11159,11160,11161,11180,11181,11182,11183,11209,11210,11211,11212,11213,11214,
11215,11216,11217,11218,11219,11220,11221,11232,11233,11234,11235,11236,11237,11238,11239,11240,11241,11244,11245,11246,11247,11248,11249,11250,11251,11252,11253,11254,11255,11256,11257,11258,11259,11260,11261,11271,11272,11273,11274,11275,11276,11277,11278,11279,11280,11281,11292,11293,11294,11295,
11296,11297,11298,11299,11300,11301,11326,11327,11328,11329,11330,11331,11332,11333,11334,11335,11336,11337,11338,11339,11340,11341,11344,11345,11346,11347,11348,11349,11350,11351,11352,11353,11354,11355,11356,11357,11358,11359,11360,11361,11372,11373,11374,11375,11376,11377,11378,11379,11380,11381,
11396,11397,11398,11399,11400,11401,11421,11425,11426,11427,11428,11429,11430,11431,11432,11433,11434,11435,11436,11437,11438,11439,11440,11441,11442,11447,11448,11449,11450,11451,11452,11453,11454,11455,11456,11457,11458,11459,11460,11461,11481,11483,11484,11485,11486,11487,11488,11489,11490,11491,
11492,11493,11494,11495,11496,11497,11498,11499,11500,11501,11517,11518,11519,11520,11521,11523,11524,11525,11526,11527,11528,11529,11530,11531,11532,11533,11534,11535,11536,11537,11538,11539,11540,11541,11543,11544,11545,11546,11547,11548,11549,11550,11551,11552,11553,11554,11555,11556,11557,11558,
11559,11560,11561,11571,11572,11573,11574,11575,11576,11577,11578,11579,11580,11581,11592,11593,11594,11595,11596,11597,11598,11599,11600,11601,11618,11619,11620,11621,11636,11637,11638,11639,11640,11641,11650,11651,11652,11653,11654,11655,11656,11657,11658,11659,11660,11661,11680,11681,11687,11688,
11689,11690,11691,11692,11693,11694,11695,11696,11697,11698,11699,11700,11701,11704,11705,11706,11707,11708,11709,11710,11711,11712,11713,11714,11715,11716,11717,11718,11719,11720,11721,11738,11739,11740,11741,11756,11757,11758,11759,11760,11761,11769,11770,11771,11772,11773,11774,11775,11776,11777,
11778,11779,11780,11781,11788,11789,11790,11791,11792,11793,11794,11795,11796,11797,11798,11799,11800,11801,11806,11836,11877,11878,11879,11880,11881,11890,11891,11892,11893,11894,11895,11896,11897,11898,11899,11900,11901,11956,11957,11958,11959,11960,11961,12067,12068,12069,12070,12071,12072,12073,
12074,12075,12076,12077,12078,12079,12080,12081,12084,12085,12086,12087,12088,12089,12090,12091,12092,12093,12094,12095,12096,12097,12098,12099,12100,12101,12116,12117,12118,12119,12120,12121,12123,12124,12125,12126,12127,12128,12129,12130,12131,12132,12133,12134,12135,12136,12137,12138,12139,12140,
12141,12143,12145,12146,12147,12148,12149,12150,12151,12152,12153,12154,12155,12156,12157,12158,12159,12160,12161,12165,12166,12167,12168,12169,12170,12171,12172,12173,12174,12175,12176,12177,12178,12179,12180,12181,12193,12194,12195,12196,12197,12198,12199,12200,12201,12221,12222,12246,12265,12266,
12267,12268,12269,12270,12271,12272,12273,12274,12275,12276,12277,12278,12279,12280,12281,12305,12306,12307,12308,12309,12310,12311,12312,12313,12314,12315,12316,12317,12318,12319,12320,12321,12333,12340,12357,12362,12370,12371,12372,12373,12374,12375,12376,12377,12378,12379,12380,12381,12386,12387,
12388,12389,12390,12391,12392,12393,12394,12395,12396,12397,12398,12399,12400,12401,12407,12413,12423,12439,12441,12473,12474,12475,12476,12477,12478,12479,12480,12481,12483,12484,12485,12486,12487,12488,12489,12490,12491,12492,12493,12494,12495,12496,12497,12498,12499,12500,12501,12503,12504,12505,
12506,12507,12508,12509,12510,12511,12512,12513,12514,12515,12516,12517,12518,12519,12520,12521,12536,12537,12538,12539,12540,12541,12559,12560,12561,12568,12569,12570,12571,12572,12573,12574,12575,12576,12577,12578,12579,12580,12581,12594,12595,12596,12597,12598,12599,12600,12601,12656,12657,12658,
12659,12660,12661,12664,12665,12666,12667,12668,12669,12670,12671,12672,12673,12674,12675,12676,12677,12678,12679,12680,12681,12686,12758,12759,12760,12761,12767,12872,12873,12874,12875,12876,12877,12878,12879,12880,12881,12908,12909,12910,12911,12912,12913,12914,12915,12916,12917,12918,12919,12920,
12921,12948,12986,13200,13201,13215,13224,13225,13226,13227,13228,13229,13230,13231,13232,13233,13234,13235,13236,13237,13238,13239,13240,13241,13256,13263,13264,13265,13266,13267,13268,13269,13270,13271,13272,13273,13274,13275,13276,13277,13278,13279,13280,13281,13294,13295,13296,13297,13298,13299,
13300,13301,13355,13410,13411,13412,13413,13414,13415,13416,13417,13418,13419,13420,13421,13424,13425,13426,13427,13428,13429,13430,13431,13432,13433,13434,13435,13436,13437,13438,13439,13440,13441,13449,13472,13516,13540,13541,13547,13548,13549,13550,13551,13552,13553,13554,13555,13556,13557,13558,
13559,13560,13561,13563,13564,13565,13566,13567,13568,13569,13570,13571,13572,13573,13574,13575,13576,13577,13578,13579,13580,13581,13587,13588,13589,13590,13591,13592,13593,13594,13595,13596,13597,13598,13599,13600,13601,13613,13614,13615,13616,13617,13618,13619,13620,13621,13633,13634,13635,13636,
13637,13638,13639,13640,13641,13729,13735,13774,13786,13789,13792,13795,13799,13800,13826,13827,13828,13829,13830,13831,13832,13833,13834,13835,13836,13837,13838,13839,13840,13841,13919,13921,13970,13971,13972,13973,13974,13975,13976,13977,13978,13979,13980,13981,13985,13987,13988,13989,13990,13991,
13992,13993,13994,13995,13996,13997,13998,13999,14000,14001,14003,14004,14005,14006,14007,14008,14009,14010,14011,14012,14013,14014,14015,14016,14017,14018,14019,14020,14021,14026,14027,14028,14029,14030,14031,14032,14033,14034,14035,14036,14037,14038,14039,14040,14041,14049,14050,14051,14052,14053,
14054,14055,14056,14057,14058,14059,14060,14061,14063,14064,14065,14066,14067,14068,14069,14070,14071,14072,14073,14074,14075,14076,14077,14078,14079,14080,14081,14135,14345,14346,14347,14348,14349,14350,14351,14352,14353,14354,14355,14356,14357,14358,14359,14360,14361,14362,14515,14516,14517,14518,
14519,14520,14521,14556,14689,14690,14692,14693,14694,14695,14697,14698,14699,14700,14701,14702,14703,14704,14705,14708,14709,14710,14711,14712,14713,14714,14715,14716,14717,14718,14719,14720,14721,14731,14732,14733,14734,14735,14736,14737,14738,14739,14740,14741,14819,14984,14985,14986,14987,14988,
14989,14990,14991,14992,14993,14994,14995,14996,14997,14998,14999,15000,15001,15020,15021,15022,15023,15024,15025,15026,15027,15028,15029,15030,15031,15032,15033,15034,15035,15036,15037,15038,15039,15040,15041,15089,15097,15098,15099,15100,15101,15201,15315,15316,15317,15318,15319,15320,15321,15700,
15701,15711,15712,15713,15714,15715,15716,15717,15718,15719,15720,15721,15816,15817,15818,15819,15820,15821,15828,15829,15830,15831,15832,15833,15834,15835,15836,15837,15838,15839,15840,15841,15896,15897,15898,15899,15900,15901,15948,15949,15950,15951,15952,15953,15954,15955,15956,15957,15958,15959,
15960,15961,16010,16011,16012,16013,16014,16015,16016,16017,16018,16019,16020,16021,16032,16087,16088,16089,16090,16091,16092,16093,16094,16095,16096,16097,16098,16099,16100,16101,16128,16130,16133,16193,16194,16195,16196,16197,16198,16199,16200,16201,16225,16226,16227,16228,16229,16230,16231,16232,
16233,16234,16235,16236,16237,16238,16239,16240,16241,16256,16257,16258,16259,16260,16261,16264,16265,16266,16267,16268,16269,16270,16271,16272,16273,16274,16275,16276,16277,16278,16279,16280,16281,16284,16285,16286,16287,16288,16289,16290,16291,16292,16293,16294,16295,16296,16297,16298,16299,16300,
16301,16308,16367,16370,16394,16395,16398,16399,16400,16402,16404,16407,16411,16412,16438,16439,16445,16447,16458,16460,16461,16464,16469,16470,16481,16482,16488,16493,16495,16500,16511,16512,16517,16520,16529,16537,16538,16546,16547,16553,16556,16557,16559,16570,16572,16575,16576,16584,16585,16586,
16587,16588,16589,16590,16591,16592,16593,16594,16595,16596,16597,16598,16599,16600,16601,16609,16610,16611,16612,16613,16614,16615,16616,16617,16618,16619,16620,16621,16624,16625,16626,16627,16628,16629,16630,16631,16632,16633,16634,16635,16636,16637,16638,16639,16640,16641,16657,16749,16750,16751,
16752,16753,16754,16755,16756,16757,16758,16759,16760,16761,16770,16771,16772,16773,16774,16775,16776,16777,16778,16779,16780,16781,16874,16875,16876,16877,16878,16879,16880,16881,17079,17080,17081,17083,17084,17085,17086,17087,17088,17089,17090,17091,17092,17093,17094,17095,17096,17097,17098,17099,
17100,17101,17120,17121,17127,17128,17129,17130,17131,17132,17133,17134,17135,17136,17137,17138,17139,17140,17141,17143,17144,17145,17146,17147,17148,17149,17150,17151,17152,17153,17154,17155,17156,17157,17158,17159,17160,17161,17164,17165,17166,17167,17168,17169,17170,17171,17172,17173,17174,17175,
17176,17177,17178,17179,17180,17181,17205,17206,17207,17208,17209,17210,17211,17212,17213,17214,17215,17216,17217,17218,17219,17220,17221,17225,17226,17227,17228,17229,17230,17231,17232,17233,17234,17235,17236,17237,17238,17239,17240,17241,17243,17244,17245,17246,17247,17248,17249,17250,17251,17252,
17253,17254,17255,17256,17257,17258,17259,17260,17261,17263,17264,17265,17266,17267,17268,17269,17270,17271,17272,17273,17274,17275,17276,17277,17278,17279,17280,17281,17284,17285,17286,17287,17288,17289,17290,17291,17292,17293,17294,17295,17296,17297,17298,17299,17300,17301,17311,17312,17313,17314,
17315,17316,17317,17318,17319,17320,17321,17334,17335,17336,17337,17338,17339,17340,17341,17350,17356,17357,17358,17359,17360,17361,17365,17366,17367,17368,17369,17370,17371,17372,17373,17374,17375,17376,17377,17378,17379,17380,17381,17385,17386,17387,17388,17389,17390,17391,17392,17393,17394,17395,
17396,17397,17398,17399,17400,17401,17415,17416,17417,17418,17419,17420,17421,17424,17425,17426,17427,17428,17429,17430,17431,17432,17433,17434,17435,17436,17437,17438,17439,17440,17441,17443,17444,17445,17446,17447,17448,17449,17450,17451,17452,17453,17454,17455,17456,17457,17458,17459,17460,17461,
17464,17465,17466,17467,17468,17469,17470,17471,17472,17473,17474,17475,17476,17477,17478,17479,17480,17481,17483,17484,17485,17486,17487,17488,17489,17490,17491,17492,17493,17494,17495,17496,17497,17498,17499,17500,17501,17509,17510,17511,17512,17513,17514,17515,17516,17517,17518,17519,17520,17521,
17524,17525,17526,17527,17528,17529,17530,17531,17532,17533,17534,17535,17536,17537,17538,17539,17540,17541,17543,17544,17545,17546,17547,17548,17549,17550,17551,17552,17553,17554,17555,17556,17557,17558,17559,17560,17561,17563,17565,17574,17575,17582,17585,17587,17589,17595,17597,17606,17609,17614,
17615,17619,17621,17627,17628,17629,17630,17631,17632,17633,17634,17635,17636,17637,17638,17639,17640,17641,17644,17645,17646,17647,17648,17649,17650,17651,17652,17653,17654,17655,17656,17657,17658,17659,17660,17661,17663,17664,17665,17666,17667,17668,17669,17670,17671,17672,17673,17674,17675,17676,
17677,17678,17679,17680,17681,17697,17698,17699,17700,17701,17729,17784,17785,17786,17787,17788,17789,17790,17791,17792,17793,17794,17795,17796,17797,17798,17799,17800,17801,17803,17804,17805,17806,17807,17808,17809,17810,17811,17812,17813,17814,17815,17816,17817,17818,17819,17820,17821,17863,17864,
17865,17866,17867,17868,17869,17870,17871,17872,17873,17874,17875,17876,17877,17878,17879,17880,17881,17912,17913,17914,17915,17916,17917,17918,17919,17920,17921,17923,17924,17925,17926,17927,17928,17929,17930,17931,17932,17933,17934,17935,17936,17937,17938,17939,17940,17941,17944,17945,17946,17947,
17948,17949,17950,17951,17952,17953,17954,17955,17956,17957,17958,17959,17960,17961,17970,17971,17972,17973,17974,17975,17976,17977,17978,17979,17980,17981,17983,17984,17985,17986,17987,17988,17989,17990,17991,17992,17993,17994,17995,17996,17997,17998,17999,18000,18001,18003,18004,18005,18006,18007,
18008,18009,18010,18011,18012,18013,18014,18015,18016,18017,18018,18019,18020,18021,18024,18025,18026,18027,18028,18029,18030,18031,18032,18033,18034,18035,18036,18037,18038,18039,18040,18041,18049,18050,18051,18052,18053,18054,18055,18056,18057,18058,18059,18060,18061,18064,18065,18066,18067,18068,
18069,18070,18071,18072,18073,18074,18075,18076,18077,18078,18079,18080,18081,18084,18085,18086,18087,18088,18089,18090,18091,18092,18093,18094,18095,18096,18097,18098,18099,18100,18101,18107,18108,18109,18110,18111,18112,18113,18114,18115,18116,18117,18118,18119,18120,18121,18124,18125,18126,18127,
18128,18129,18130,18131,18132,18133,18134,18135,18136,18137,18138,18139,18140,18141,18174,18175,18176,18177,18178,18179,18180,18181,18183,18184,18185,18186,18187,18188,18189,18190,18191,18192,18193,18194,18195,18196,18197,18198,18199,18200,18201,18210,18211,18212,18213,18214,18215,18216,18217,18218,
18219,18220,18221,18270,18271,18272,18273,18274,18275,18276,18277,18278,18279,18280,18281,18431,18433,18439,18446,18474,18548,18549,18550,18551,18552,18553,18554,18555,18556,18557,18558,18559,18560,18561,18568,18569,18570,18571,18572,18573,18574,18575,18576,18577,18578,18579,18580,18581,18613,18614,
18615,18616,18617,18618,18619,18620,18621,18732,18733,18748,18750,18751,18883,18884,18885,18886,18887,18888,18889,18890,18891,18892,18893,18894,18895,18896,18897,18898,18899,18900,18901,18903,18905,18906,18907,18908,18909,18910,18911,18912,18913,18914,18915,18916,18917,18918,18919,18920,18921,18923,
18924,18925,18926,18927,18928,18929,18930,18931,18932,18933,18934,18935,18936,18937,18938,18939,18940,18941,18973,18974,18975,18976,18977,18978,18979,18980,18981,18988,18989,18990,18991,18992,18993,18994,18995,18996,18997,18998,18999,19000,19001,19021,19063,19072,19073,19074,19075,19076,19077,19078,
19079,19080,19081,19161,19171,19172,19173,19174,19175,19176,19177,19178,19179,19180,19181,19285,19294,19359,19408,19409,19410,19411,19412,19413,19414,19415,19416,19417,19418,19419,19420,19421,19429,19458,19459,19460,19461,19463,19464,19465,19466,19467,19468,19469,19470,19471,19472,19473,19474,19475,
19476,19477,19478,19479,19480,19481,19492,19493,19494,19495,19496,19497,19498,19499,19500,19501,19624,19625,19626,19627,19628,19629,19630,19631,19632,19633,19634,19635,19636,19637,19638,19639,19640,19641,19643,19644,19645,19646,19647,19648,19649,19650,19651,19652,19653,19654,19655,19656,19657,19658,
19659,19660,19661,19663,19664,19665,19666,19667,19668,19669,19670,19671,19672,19673,19674,19675,19676,19677,19678,19679,19680,19681,19728,19729,19730,19731,19732,19733,19734,19735,19736,19737,19738,19739,19740,19741,19744,19745,19746,19747,19748,19749,19750,19751,19752,19753,19754,19755,19756,19757,
19758,19759,19760,19761,19791,19792,19793,19794,19795,19796,19797,19798,19799,19800,19801,19860,19976,19977,19985,20133,20147,20148,20221,20293,20294,20365,20366,20386,20421,20462,20484,20486,20523,20529,20583,20584,20585,20586,20587,20588,20589,20590,20592,20593,20594,20595,20597,20598,20751,20811,
20905,20968,21169,21170,21172,21231,21233,21234,21239,21556,21654,21736,21759,21787,21788,21797,21798,21799,21824,21825,21826,21827,21828,21832,21834,21922,21961,21965,21966,21967,21968,21969,21970,21971,21972,21973,21974,21976,21977,21978,22118,22124,22125,22126,22127,22129,22323,22453,22454,22455,
22486,22643,22751,23080,23102,23185,23186,23187,23188,23189,23190,23202,23204,23208,23209,23210,23245,23325,23359,23419,23496,23581,23640,23641,23674,23690,23724,23842,23913,23915,23935,23936,23956,23963,23964,23991,24070,24370,24371,24377,24574,25664,25704,25709,25851,25885,25892,27482,27504,27642,
27670,27675,27782,27810,27819,27853,28035,28036,28326,28329,28330,28382,28480,28682,28876,28877,28879,28880,28883,28884,28890,28891,28892,28893,28894,28895,28896,28897,28898,28899,28900,28901,28902,28932,28958,28961,29178,29256,29358,29392,29587,29752,30202,30203,30492,30493,30494,30495,30496,30537,
30562,31171,31385,31388,31602,31645,31738,31771,31822,31897,31970,32511,32669,32719,32815,32855,32873,32880,32881,32913,32968,32969,33000,33011,33059,33062,33080,33084,33089,33090,33098,33099,33100,33109,33111,33116,33119,33120,33121,33123,33128,33129,33130,33136,33145,33146,33164,33167,33168,33169,
33170,33171,33172,33177,33178,33179,33180,33181,33187,33188,33190,33210,33212,33213,33220,33221,33227,33238,33275,33276,33278,33282,33284,33289,33290,33294,33295,33301,33308,33310,33311,33312,33314,33316,33318,33319,33320,33321,33323,33330,33335,33336,33337,33339,33340,33341,33342,33343,33344,33345,
33346,33347,33348,33349,33350,33351,33352,33353,33355,33358,33359,33360,33361,33362,33363,33364,33365,33366,33367,33368,33369,33370,33371,33372,33373,33374,33375,33376,33377,33378,33379,33380,33381,33382,33383,33384,33385,33387,33390,33391,33392,33393,33394,33395,33396,33397,33398,33399,33400,33401,
33402,33403,33404,33405,33406,33407,33408,33409,33410,33411,33412,33413,33414,33415,33416,33417,33418,33419,33420,33422,33423,33424,33425,33426,33427,33428,33429,33430,33431,33433,33434,33435,33436,33437,33438,33439,33440,33441,33443,33444,33445,33447,33448,33449,33450,33451,33452,33454,33456,33457,
33458,33459,33460,33461,33462,33470,33472,33475,33477,33485,33486,33487,33488,33511,33525,33526,33541,33544,33545,33546,33547,33548,33549,33550,33551,33553,33554,33555,33556,33558,33560,33561,33562,33563,33564,33565,33567,33568,33569,33571,33575,33576,33581,33594,33595,33596,33597,33598,33599,33604,
33605,33606,33607,33608,33609,33610,33611,33612,33613,33614,33615,33616,33617,33618,33619,33620,33621,33627,33628,33629,33630,33631,33632,33634,33635,33636,33637,33638,33639,33641,33642,33643,33644,33645,33646,33647,33648,33649,33650,33651,33652,33653,33654,33655,33656,33657,33658,33659,33660,33773,
33774,33778,33779,33780,33781,33794,33796,33799,33800,33802,33806,33817,33819,33822,33845,33960,33961,33962,34004,34005,34006,34007,34013,34023,34024,34025,34026,34027,34030,34031,34032,34034,34035,34036,34037,34038,34040,34041,34042,34043,34051,34052,34053,34054,34055,34056,34057,34058,34069,34070,
34072,34076,34078,34079,34080,34081,34082,34083,34084,34088,34090,34091,34093,34096,34097,34101,34102,34103,34104,34108,34110,34111,34112,34115,34116,34117,34118,34119,34120,34121,34122,34123,34124,34125,34126,34127,34128,34131,34132,34133,34134,34135,34136,34137,34138,34139,34142,34143,34144,34145,
34146,34147,34148,34149,34187,34217,34219,34222,34223,34224,34225,34226,34235,34236,34237,34238,34239,34260,34387,34464,34468,34495,34597,34598,34600,34617,34618,34619,34620,34621,34623,34624,34628,34629,34630,34631,34632,34633,34634,34635,34636,34637,34638,34639,34640,34641,34642,34643,34644,34645,
34647,34648,34649,34650,34651,34652,34653,34654,34655,34656,34657,34658,34659,34660,34661,34662,34663,34668,34669,34681,34682,34687,34688,34690,34691,34692,34693,34694,34695,34696,34709,34710,34711,34713,34714,34715,34716,34717,34718,34719,34720,34721,34722,34723,34724,34725,34726,34727,34728,34729,
34730,34731,34732,34733,34734,34735,34736,34737,34738,34739,34740,34741,34742,34743,34744,34745,34746,34747,34748,34749,34750,34751,34752,34753,34754,34755,34756,34757,34758,34759,34760,34761,34762,34763,34764,34765,34766,34767,34768,34769,34770,34771,34772,34773,34774,34775,34777,34778,34779,34781,
34782,34784,34785,34786,34787,34800,34801,34802,34803,34804,34806,34811,34812,34813,34814,34815,34816,34817,34818,34819,34820,34821,34830,34842,34844,34849,34869,34870,34871,34897,34899,34908,34909,34913,34915,34920,34948,34954,34956,34957,34958,34959,34960,34961,34962,34963,34964,34965,34966,34967,
34968,34969,34970,34971,34972,34973,34974,34975,34976,34977,34978,34979,34980,34981,34982,34983,34984,35116,35118,35119,35120,35121,35122,35123,35124,35125,35126,35127,35188,35222,35224,35228,35234,35235,35272,35274,35276,35278,35281,35288,35289,35293,35312,35351,35352,35353,35354,35355,35401,35479,
35480,35481,35482,35483,35484,35486,35490,35491,35492,35493,35506,35515,35543,35547,35558,35559,35560,35561,35567,35570,35571,35572,35573,35574,35575,35576,35577,35578,35579,35580,35583,35584,35585,35586,35587,35588,35589,35590,35591,35592,35593,35594,35595,35596,35597,35598,35599,35600,35601,35602,
35603,35604,35605,35606,35607,35608,35609,35610,35611,35612,35613,35614,35615,35616,35617,35618,35619,35620,35621,35622,35623,35624,35625,35626,35627,35628,35629,35630,35631,35632,35633,35634,35635,35636,35637,35638,35639,35640,35641,35642,35643,35644,35645,35646,35647,35648,35649,35650,35651,35652,
35653,35654,35655,35656,35657,35658,35659,35660,35661,35662,35663,35664,35665,35666,35667,35668,35669,35670,35671,35672,35673,35675,35676,35677,35678,35679,35680,35681,35682,35683,35685,35686,35687,35688,35689,35690,35692,35701,35704,35705,35706,35709,35711,35715,35718,35724,35726,35727,35734,35735,
35736,35737,35738,35739,35740,35741,35742,35743,35744,35745,35746,35747,35757,35770,35771,35772,35773,35774,35775,35776,35777,35778,35779,35780,35781,35782,35783,35784,35785,35786,35787,35788,35789,35790,35791,35792,35793,35794,35795,35796,35797,35798,35799,35800,35801,35802,35803,35804,35805,35806,
35807,35808,35809,35810,35811,35812,35813,35814,35815,35816,35817,35818,35819,35820,35821,35822,35823,35824,35825,35826,35827,35829,35830,35831,35832,35833,35834,35835,35836,35837,35838,35839,35840,35841,35842,35843,35844,35845,35846,35847,35848,35849,35850,35851,35852,35853,35854,35855,35856,35857,
35858,35859,35860,35861,35862,35863,35864,35865,35866,35867,35868,35869,35870,35871,35872,35873,35875,35876,35877,35878,35879,35880,35881,35882,35883,35884,35885,35886,35887,35888,35889,35890,35891,35892,35893,35894,35895,35896,35897,35898,35899,35900,35901,35902,35903,35904,35905,35907,35908,35909,
35910,35911,35912,35913,35914,35915,35916,35917,35918,35919,35920,35921,35922,35923,35924,35925,35926,35927,35928,35929,35930,35931,35932,35933,35934,35935,35936,35937,35938,35939,35940,35941,35942,35943,35944,35946,35947,35948,35949,35950,35951,35952,35953,35954,35955,35956,35957,35958,35959,35960,
35961,35962,35963,35964,35965,35966,35967,35968,35969,35970,35971,35972,35973,35974,35975,35976,35977,35978,35979,35980,35981,35982,35983,35984,35985,35986,35987,35988,35989,35990,35991,35992,35993,35994,35995,35996,35997,35998,35999,36000,36001,36002,36003,36004,36005,36006,36007,36008,36009,36010,
36011,36012,36013,36014,36015,36016,36017,36018,36019,36020,36021,36022,36023,36024,36025,36026,36027,36028,36029,36030,36031,36032,36033,36034,36035,36036,36037,36038,36039,36040,36041,36042,36043,36044,36045,36046,36047,36048,36049,36050,36051,36052,36053,36054,36055,36056,36057,36058,36059,36060,
36061,36062,36063,36064,36065,36066,36067,36068,36069,36070,36071,36072,36073,36074,36075,36076,36077,36078,36079,36080,36081,36082,36083,36084,36085,36086,36087,36088,36089,36090,36091,36092,36093,36094,36095,36096,36097,36098,36099,36100,36101,36102,36103,36104,36105,36106,36107,36108,36109,36110,
36111,36112,36113,36114,36115,36116,36117,36118,36119,36120,36121,36122,36123,36124,36125,36126,36127,36128,36129,36130,36131,36132,36133,36134,36135,36136,36137,36138,36139,36140,36141,36142,36143,36144,36145,36146,36147,36148,36149,36150,36151,36152,36153,36154,36155,36156,36157,36158,36159,36160,
36161,36162,36163,36164,36165,36166,36167,36168,36169,36170,36171,36172,36173,36174,36175,36176,36177,36178,36179,36180,36181,36182,36183,36184,36185,36186,36187,36188,36189,36190,36191,36192,36193,36194,36195,36196,36197,36198,36199,36200,36201,36202,36203,36204,36205,36206,36207,36208,36209,36210,
36211,36212,36213,36214,36215,36216,36217,36218,36219,36220,36221,36222,36223,36224,36225,36226,36227,36228,36229,36230,36231,36232,36233,36234,36235,36236,36237,36238,36239,36240,36241,36242,36243,36244,36245,36246,36247,36248,36249,36250,36251,36252,36253,36254,36255,36256,36257,36258,36259,36260,
36261,36262,36263,36264,36265,36266,36267,36268,36269,36270,36271,36272,36273,36274,36275,36276,36277,36278,36279,36280,36281,36282,36283,36284,36285,36286,36287,36288,36289,36290,36291,36292,36293,36294,36295,36296,36297,36298,36299,36300,36301,36302,36303,36304,36305,36306,36307,36308,36309,36310,
36311,36312,36313,36314,36315,36316,36317,36318,36319,36320,36321,36322,36323,36324,36325,36326,36327,36328,36329,36330,36331,36332,36333,36334,36335,36336,36337,36338,36339,36340,36341,36342,36343,36344,36345,36346,36347,36348,36349,36350,36351,36352,36353,36354,36355,36356,36357,36358,36359,36360,
36361,36362,36363,36364,36365,36366,36367,36368,36369,36370,36371,36372,36373,36374,36375,36376,36377,36378,36379,36380,36381,36382,36383,36384,36385,36386,36387,36388,36389,36390,36391,36392,36393,36394,36395,36396,36397,36398,36399,36400,36401,36402,36403,36404,36405,36406,36407,36408,36409,36410,
36411,36412,36413,36414,36415,36416,36417,36418,36419,36420,36421,36422,36423,36424,36425,36426,36427,36428,36429,36430,36431,36432,36433,36434,36435,36436,36437,36438,36439,36440,36441,36442,36443,36444,36445,36446,36447,36448,36449,36450,36451,36452,36453,36454,36455,36456,36457,36458,36459,36460,
36461,36462,36463,36464,36465,36466,36467,36468,36469,36470,36471,36472,36473,36474,36475,36476,36477,36478,36479,36480,36481,36482,36483,36484,36485,36486,36487,36488,36489,36490,36491,36492,36493,36494,36495,36496,36497,36498,36499,36500,36501,36502,36503,36504,36505,36506,36507,36508,36509,36510,
36511,36512,36513,36514,36515,36516,36517,36518,36519,36520,36521,36522,36523,36524,36525,36526,36527,36528,36529,36530,36531,36532,36533,36534,36535,36536,36537,36538,36539,36540,36541,36542,36543,36544,36545,36546,36547,36548,36549,36550,36551,36552,36553,36554,36555,36556,36557,36558,36559,36560,
36561,36562,36563,36564,36565,36566,36567,36568,36569,36570,36571,36572,36573,36574,36575,36576,36577,36578,36579,36580,36581,36582,36583,36584,36585,36586,36587,36588,36589,36590,36591,36592,36593,36594,36595,36596,36597,36598,36599,36600,36601,36602,36603,36604,36605,36606,36607,36608,36609,36610,
36611,36612,36613,36614,36615,36616,36617,36618,36619,36620,36621,36622,36623,36624,36625,36626,36627,36628,36629,36630,36631,36632,36633,36634,36635,36636,36637,36638,36639,36640,36641,36642,36643,36644,36645,36646,36647,36648,36649,36650,36651,36652,36653,36654,36655,36656,36657,36658,36659,36660,
36661,36662,36663,36664,36665,36666,36667,36668,36669,36670,36671,36672,36673,36674,36675,36676,36677,36678,36679,36680,36681,36682,36683,36684,36685,36686,36687,36688,36689,36690,36691,36692,36693,36694,36695,36696,36697,36698,36699,36700,36701,36702,36703,36704,36705,36706,36707,36708,36709,36710,
36711,36712,36713,36714,36715,36716,36717,36718,36719,36720,36721,36722,36723,36724,36725,36726,36727,36728,36729,36730,36731,36732,36733,36734,36735,36736,36738,36739,36740,36741,36742,36743,36744,36745,36746,36747,36749,36750,36751,36752,36753,36754,36755,36756,36757,36758,36759,36760,36762,36763,
36764,36765,36766,36767,36768,36769,36770,36771,36772,36773,36774,36775,36776,36777,36778,36779,36780,36781,36782,36783,36784,36785,36786,36787,36788,36789,36790,36791,36792,36793,36794,36795,36796,36797,36798,36799,36800,36801,36802,36803,36804,36805,36806,36807,36808,36809,36810,36811,36812,36813,
36814,36815,36816,36817,36818,36819,36820,36821,36822,36823,36824,36825,36826,36827,36828,36829,36830,36831,36832,36833,36834,36835,36836,36837,36838,36839,36840,36841,36842,36843,36844,36845,36846,36847,36848,36849,36850,36851,36852,36853,36854,36855,36856,36857,36858,36859,36860,36861,36862,36863,
36864,36865,36866,36867,36868,36869,36870,36871,36872,36873,36874,36875,36878,36879,36880,36881,36882,36883,36884,36885,36886,36887,36888,36889,36890,36891,36892,36893,36894,36895,36896,36897,36898,36899,36900,36901,36902,36903,36904,36905,36906,36907,36908,36909,36910,36911,36912,36913,36914,36915,
36916,36917,36918,36919,36920,36921,36922,36923,36924,36925,36926,36927,36928,36929,36930,36931,36932,36933,36934,36935,36936,36937,36938,36939,36940,36942,36943,36944,36945,36946,36947,36948,36949,36950,36951,36952,36953,36954,36955,36956,36957,36958,36959,36960,36961,36962,36963,36964,36965,36966,
36967,36968,36969,36970,36971,36972,36973,36974,36975,36976,36977,36978,36979,36980,36981,36982,36983,36984,36985,36986,36987,36988,36989,36990,36991,36992,36993,36994,36995,36996,36997,36998,36999,37000,37001,37002,37003,37004,37005,37006,37007,37008,37009,37010,37013,37014,37015,37016,37017,37018,
37019,37020,37021,37022,37023,37024,37025,37026,37027,37028,37029,37030,37031,37032,37033,37034,37035,37036,37037,37038,37039,37040,37041,37042,37043,37044,37045,37046,37047,37048,37049,37050,37051,37052,37053,37054,37055,37056,37057,37058,37060,37061,37062,37063,37064,37065,37066,37067,37068,37069,
37070,37071,37072,37073,37074,37075,37076,37077,37078,37079,37080,37081,37082,37083,37084,37085,37086,37087,37088,37089,37090,37091,37092,37093,37094,37095,37096,37097,37098,37099,37100,37101,37102,37103,37104,37105,37106,37107,37108,37109,37110,37111,37112,37113,37114,37115,37116,37117,37118,37119,
37120,37121,37122,37123,37124,37125,37126,37129,37130,37131,37132,37133,37134,37135,37136,37137,37138,37139,37140,37141,37142,37143,37144,37145,37146,37147,37149,37150,37151,37152,37153,37154,37155,37156,37157,37158,37159,37160,37161,37162,37163,37164,37165,37166,37167,37168,37169,37170,37171,37172,
37173,37174,37175,37176,37177,37178,37179,37180,37181,37182,37183,37184,37185,37186,37187,37188,37189,37190,37191,37192,37193,37194,37195,37196,37197,37198,37199,37200,37201,37202,37203,37204,37205,37206,37207,37208,37209,37210,37211,37212,37213,37214,37215,37216,37217,37218,37219,37220,37221,37222,
37223,37224,37225,37226,37227,37228,37229,37230,37231,37232,37233,37234,37235,37236,37237,37238,37239,37240,37241,37242,37243,37244,37245,37246,37247,37248,37249,37250,37251,37252,37253,37254,37255,37256,37257,37258,37259,37260,37261,37262,37263,37264,37265,37266,37267,37268,37269,37270,37271,37272,
37273,37274,37275,37276,37277,37278,37279,37280,37281,37282,37283,37284,37285,37286,37287,37288,37289,37290,37291,37292,37293,37294,37295,37296,37299,37300,37301,37302,37303,37304,37305,37306,37307,37308,37309,37310,37314,37315,37316,37317,37318,37319,37320,37321,37322,37323,37324,37325,37326,37327,
37328,37329,37330,37331,37332,37333,37334,37335,37336,37337,37338,37339,37340,37341,37342,37343,37344,37345,37346,37347,37348,37349,37350,37351,37352,37353,37354,37355,37356,37357,37358,37359,37360,37361,37362,37363,37364,37365,37366,37367,37368,37369,37370,37371,37372,37373,37374,37375,37376,37377,
37378,37379,37380,37381,37382,37383,37384,37385,37386,37387,37388,37389,37390,37391,37392,37393,37394,37395,37396,37397,37398,37399,37400,37401,37402,37403,37404,37405,37406,37407,37408,37409,37410,37411,37412,37413,37414,37415,37416,37417,37418,37419,37420,37421,37422,37423,37424,37425,37426,37427,
37428,37429,37430,37431,37432,37433,37434,37435,37436,37437,37438,37439,37440,37441,37442,37443,37444,37445,37446,37447,37448,37449,37450,37451,37452,37453,37454,37455,37456,37457,37458,37459,37461,37462,37463,37464,37465,37466,37467,37468,37469,37470,37471,37472,37473,37474,37475,37476,37477,37478,
37479,37480,37481,37482,37483,37484,37485,37486,37487,37500,37501,37502,37505,37506,37507,37508,37509,37510,37511,37512,37513,37514,37515,37516,37517,37518,37519,37520,37521,37522,37523,37524,37525,37526,37527,37528,37529,37530,37531,37532,37533,37534,37535,37536,37537,37538,37539,37540,37541,37542,
37543,37544,37545,37546,37547,37548,37549,37550,37551,37552,37553,37554,37555,37556,37557,37558,37559,37560,37561,37562,37563,37564,37565,37566,37568,37569,37570,37572,37573,37574,37575,37576,37577,37578,37579,37580,37581,37587,37589,37590,37591,37592,37593,37594,37595,37600,37601,37602,37603,37607,
37608,37609,37610,37611,37612,37613,37614,37615,37616,37617,37618,37619,37620,37621,37622,37623,37624,37625,37626,37627,37628,37629,37630,37631,37632,37633,37634,37635,37636,37637,37638,37639,37640,37641,37642,37643,37644,37645,37646,37647,37648,37649,37650,37651,37652,37653,37654,37655,37656,37657,
37658,37659,37660,37661,37662,37663,37664,37665,37666,37667,37668,37669,37670,37671,37672,37673,37674,37675,37677,37678,37679,37680,37681,37682,37683,37684,37685,37686,37687,37688,37689,37690,37691,37692,37693,37694,37695,37696,37697,37698,37699,37700,37701,37702,37703,37704,37705,37706,37707,37708,
37709,37711,37712,37713,37714,37715,37716,37717,37718,37720,37721,37722,37723,37724,37725,37726,37727,37728,37729,37730,37731,37732,37733,37734,37735,37738,37741,37742,37743,37744,37745,37746,37747,37748,37749,37751,37752,37753,37754,37755,37756,37757,37758,37759,37760,37761,37762,37763,37764,37765,
37766,37767,37768,37769,37770,37771,37772,37773,37774,37775,37776,37777,37778,37779,37780,37781,37782,37783,37784,37785,37786,37787,37788,37789,37790,37791,37792,37793,37794,37795,37796,37797,37798,37799,37800,37801,37802,37803,37804,37805,37806,37807,37808,37809,37810,37811,37812,37813,37814,37815,
37817,37818,37819,37820,37821,37822,37823,37824,37825,37826,37830,37831,37832,37833,37834,37835,37836,37837,37838,37839,37840,37841,37842,37843,37844,37845,37846,37847,37848,37849,37850,37851,37852,37853,37854,37855,37856,37857,37858,37859,37860,37861,37862,37866,37867,37868,37869,37870,37871,37872,
37873,37874,37875,37876,37877,37878,37879,37880,37881,37882,37883,37884,37885,37886,37887,37888,37889,37890,37891,37910,37911,37912,37913,37914,37916,37917,37918,37919,37920,37921,37922,37923,37924,37925,37926,37930,37931,37932,37933,37935,37936,37937,37938,37939,37940,37941,37942,37943,37944,37945,
37946,37947,37948,37949,37950,37951,37952,37953,37954,37955,37956,37957,37958,37959,37960,37961,37962,37963,37964,37965,37966,37967,37968,37969,37970,37971,37972,37973,37974,37975,37976,37977,37978,37979,37980,37981,37982,37983,37984,37985,37986,37987,37988,37989,37990,37991,37992,37993,37994,37995,
37996,37997,37998,37999,38000,38001,38002,38003,38004,38005,38006,38007,38008,38009,38010,38011,38012,38013,38014,38015,38016,38017,38018,38019,38020,38021,38022,38023,38024,38025,38026,38027,38028,38029,38030,38031,38032,38033,38034,38035,38036,38037,38038,38039,38040,38041,38042,38043,38044,38045,
38046,38047,38048,38049,38051,38052,38053,38054,38055,38056,38057,38058,38059,38060,38061,38062,38063,38064,38065,38066,38067,38068,38069,38070,38071,38072,38073,38074,38075,38076,38077,38078,38079,38080,38081,38083,38084,38085,38086,38087,38088,38092,38093,38094,38095,38096,38097,38098,38099,38100,
38101,38102,38103,38104,38105,38106,38107,38108,38109,38110,38111,38112,38113,38114,38115,38116,38117,38118,38119,38120,38121,38122,38123,38124,38125,38126,38127,38128,38129,38130,38131,38132,38133,38134,38135,38136,38137,38138,38139,38140,38141,38142,38143,38144,38145,38146,38147,38148,38149,38150,
38151,38152,38153,38154,38155,38156,38157,38158,38159,38164,38165,38166,38167,38168,38169,38170,38171,38172,38173,38174,38176,38177,38178,38179,38180,38181,38182,38183,38184,38185,38187,38188,38189,38190,38191,38192,38193,38194,38195,38196,38197,38198,38199,38200,38201,38202,38203,38204,38205,38206,
38207,38208,38209,38210,38211,38212,38213,38214,38215,38216,38217,38218,38219,38220,38221,38222,38223,38224,38226,38227,38228,38230,38231,38232,38234,38235,38236,38237,38238,38239,38240,38241,38242,38243,38244,38245,38246,38247,38248,38249,38250,38251,38252,38253,38254,38255,38256,38257,38258,38259,
38260,38261,38262,38263,38264,38265,38266,38267,38268,38269,38270,38271,38272,38273,38274,38275,38279,38282,38283,38284,38292,38293,38295,38296,38297,38298,38299,38302,38303,38304,38305,38306,38307,38315,38316,38317,38318,38319,38321,38322,38323,38324,38325,38326,38330,38331,38332,38333,38334,38335,
38336,38337,38338,38339,38340,38341,38342,38343,38344,38345,38346,38347,38348,38349,38350,38351,38352,38353,38354,38355,38356,38357,38358,38359,38360,38361,38362,38363,38364,38365,38366,38367,38368,38369,38370,38371,38372,38373,38374,38375,38376,38377,38378,38379,38380,38381,38382,38383,38384,38385,
38386,38387,38388,38389,38390,38391,38392,38393,38394,38395,38396,38397,38398,38399,38400,38401,38402,38403,38404,38405,38406,38407,38408,38409,38410,38411,38412,38413,38414,38415,38416,38417,38418,38419,38420,38421,38422,38423,38424,38425,38426,38433,38434,38435,38436,38437,38438,38439,38440,38441,
38442,38443,38444,38445,38446,38447,38448,38449,38450,38451,38452,38453,38454,38455,38456,38457,38458,38459,38460,38461,38462,38463,38464,38465,38467,38468,38469,38470,38471,38472,38473,38474,38475,38476,38477,38478,38479,38480,38481,38482,38483,38484,38485,38486,38487,38488,38489,38490,38491,38492,
38493,38494,38495,38496,38497,38498,38499,38500,38501,38502,38503,38504,38505,38507,38508,38509,38510,38511,38512,38513,38514,38515,38516,38517,38519,38520,38521,38522,38523,38524,38525,38526,38527,38528,38529,38530,38531,38532,38533,38534,38535,38536,38537,38538,38539,38540,38541,38542,38543,38544,
38551,38552,38553,38554,38555,38556,38557,38558,38559,38560,38561,38562,38563,38564,38565,38566,38567,38568,38569,38570,38571,38572,38573,38574,38575,38580,38581,38582,38583,38584,38585,38586,38588,38589,38590,38591,38592,38593,38594,38595,38596,38597,38598,38599,38600,38601,38602,38603,38604,38605,
38606,38607,38608,38609,38610,38611,38612,38613,38614,38615,38616,38617,38618,38619,38620,38621,38622,38623,38624,38625,38627,38629,38630,38631,38632,38633,38634,38635,38636,38637,38638,38639,38640,38641,38642,38643,38644,38645,38646,38647,38648,38649,38650,38651,38652,38653,38654,38655,38656,38657,
38658,38659,38660,38661,38662,38663,38664,38665,38666,38667,38668,38669,38670,38671,38672,38673,38674,38675,38676,38677,38678,38679,38680,38681,38682,38683,38684,38685,38686,38687,38688,38689,38690,38691,38692,38693,38694,38695,38696,38697,38698,38699,38700,38701,38702,38703,38704,38705,38706,38707,
38708,38709,38710,38711,38712,38713,38714,38715,38716,38717,38718,38719,38720,38721,38722,38723,38724,38725,38726,38727,38728,38729,38730,38731,38732,38733,38734,38735,38736,38737,38738,38739,38740,38741,38742,38743,38744,38745,38746,38747,38748,38749,38750,38751,38752,38753,38754,38755,38756,38757,
38758,38759,38760,38761,38762,38763,38764,38765,38766,38767,38768,38769,38770,38771,38772,38773,38774,38775,38776,38777,38778,38779,38780,38781,38782,38783,38784,38785,38786,38787,38788,38789,38790,38791,38792,38793,38794,38795,38796,38797,38798,38799,38800,38801,38802,38803,38804,38805,38806,38807,
38808,38809,38810,38811,38812,38813,38814,38815,38816,38817,38818,38819,38820,38821,38822,38823,38824,38825,38826,38827,38828,38829,38830,38831,38832,38833,38834,38835,38836,38837,38838,38839,38840,38841,38842,38843,38844,38845,38846,38847,38848,38849,38850,38851,38852,38853,38854,38855,38856,38857,
38858,38859,38860,38861,38862,38863,38864,38865,38866,38867,38868,38869,38870,38871,38872,38873,38874,38875,38876,38877,38878,38879,38880,38881,38882,38883,38884,38885,38886,38887,38888,38889,38890,38891,38892,38893,38894,38895,38896,38897,38898,38899,38900,38901,38902,38903,38904,38905,38906,38907,
38908,38909,38910,38911,38912,38913,38914,38915,38916,38917,38918,38919,38920,38921,38922,38923,38924,38925,38926,38927,38928,38929,38930,38931,38932,38933,38934,38935,38936,38937,38938,38939,38940,38941,38942,38943,38944,38945,38946,38947,38948,38949,38950,38951,38952,38953,38954,38955,38956,38957,
38958,38959,38960,38961,38962,38963,38964,38965,38966,38967,38968,38969,38970,38971,38972,38973,38974,38975,38976,38977,38978,38979,38980,38981,38982,38983,38984,38985,38986,38987,38988,38989,38990,38991,38992,38993,38994,38995,38996,38997,38998,38999,39000,39001,39002,39003,39004,39005,39006,39007,
39008,39009,39010,39011,39012,39013,39014,39015,39016,39017,39018,39019,39020,39021,39022,39023,39024,39025,39026,39027,39028,39029,39030,39031,39032,39033,39034,39035,39036,39037,39038,39039,39040,39041,39042,39043,39044,39045,39046,39047,39048,39049,39050,39051,39052,39053,39054,39055,39056,39057,
39058,39059,39060,39061,39062,39063,39064,39065,39066,39067,39068,39069,39070,39071,39072,39073,39074,39075,39076,39077,39078,39079,39080,39081,39082,39083,39084,39085,39086,39087,39088,39089,39090,39091,39092,39093,39094,39095,39096,39097,39098,39099,39100,39101,39102,39103,39104,39105,39106,39107,
39108,39109,39110,39111,39112,39113,39114,39115,39116,39117,39118,39119,39120,39121,39122,39123,39124,39125,39126,39127,39128,39129,39130,39131,39132,39133,39134,39135,39136,39137,39138,39139,39140,39141,39142,39143,39144,39145,39146,39147,39148,39150,39151,39152,39153,39154,39155,39156,39157,39158,
39159,39160,39161,39162,39163,39164,39165,39166,39167,39168,39169,39170,39171,39172,39173,39174,39175,39176,39177,39178,39179,39180,39181,39182,39183,39184,39185,39186,39187,39188,39189,39190,39191,39192,39193,39194,39195,39196,39197,39198,39199,39200,39201,39202,39203,39204,39205,39206,39207,39208,
39209,39210,39211,39212,39213,39214,39215,39216,39217,39218,39219,39220,39221,39222,39223,39224,39225,39226,39227,39228,39229,39230,39231,39232,39233,39234,39235,39236,39237,39238,39239,39240,39241,39242,39243,39244,39245,39246,39247,39248,39249,39250,39251,39252,39253,39254,39255,39256,39257,39258,
39259,39260,39261,39262,39263,39264,39265,39266,39267,39268,39269,39270,39271,39272,39273,39274,39275,39276,39277,39278,39279,39280,39281,39282,39283,39284,39285,39286,39287,39288,39289,39290,39291,39292,39293,39294,39295,39296,39297,39298,39299,39300,39301,39302,39303,39304,39305,39306,39307,39308,
39309,39310,39311,39312,39313,39314,39315,39316,39317,39318,39319,39320,39321,39322,39323,39324,39325,39326,39327,39328,39329,39330,39331,39332,39333,39334,39335,39336,39337,39338,39339,39340,39341,39342,39343,39344,39345,39346,39347,39348,39349,39350,39351,39352,39353,39354,39355,39356,39357,39358,
39359,39360,39361,39362,39363,39364,39365,39366,39367,39368,39369,39370,39371,39372,39373,39374,39375,39376,39377,39378,39379,39380,39381,39382,39383,39384,39385,39386,39387,39388,39389,39390,39391,39392,39393,39394,39395,39396,39397,39398,39399,39400,39401,39402,39403,39404,39405,39406,39407,39408,
39409,39410,39411,39412,39413,39414,39415,39416,39417,39418,39419,39420,39421,39422,39423,39424,39425,39426,39427,39428,39429,39430,39431,39432,39433,39434,39435,39436,39437,39438,39439,39440,39441,39442,39443,39444,39445,39446,39447,39448,39449,39450,39451,39452,39453,39454,39455,39456,39457,39458,
39459,39460,39461,39462,39463,39464,39465,39466,39467,39468,39469,39470,39471,39472,39473,39474,39475,39478,39479,39480,39481,39482,39483,39484,39485,39486,39487,39488,39489,39490,39491,39492,39493,39494,39495,39496,39497,39498,39499,39500,39501,39502,39503,39504,39505,39506,39507,39508,39509,39510,
39511,39512,39513,39514,39515,39516,39517,39518,39519,39520,39521,39522,39523,39524,39525,39526,39527,39528,39529,39530,39531,39532,39533,39534,39535,39536,39537,39538,39539,39540,39541,39542,39543,39544,39545,39546,39547,39548,39549,39550,39551,39552,39553,39554,39555,39556,39557,39558,39559,39560,
39561,39562,39563,39564,39565,39566,39567,39568,39569,39570,39571,39572,39573,39574,39575,39576,39577,39578,39579,39580,39581,39582,39583,39584,39585,39586,39587,39588,39589,39590,39591,39592,39593,39594,39595,39596,39597,39598,39599,39600,39601,39602,39603,39604,39605,39606,39607,39608,39609,39610,
39611,39612,39613,39614,39615,39616,39617,39618,39619,39620,39621,39622,39623,39624,39625,39626,39627,39628,39629,39630,39631,39632,39633,39634,39635,39636,39637,39638,39639,39640,39641,39642,39643,39644,39645,39646,39647,39648,39649,39650,39651,39652,39653,39654,39655
}
local itemsWotLK = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,23,24,26,27,28,29,30,31,32,33,34,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,81,82,83,
84,96,106,107,108,109,110,111,112,116,142,144,145,158,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,183,185,186,187,188,189,190,191,196,197,198,199,204,205,
206,207,208,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,
262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,280,281,282,283,284,288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,303,304,305,306,307,308,309,310,311,312,313,314,
315,316,317,318,319,320,321,322,323,324,325,326,327,328,329,330,331,332,333,334,335,336,337,338,339,340,341,342,343,344,345,346,347,348,349,350,351,352,353,354,355,356,357,358,359,360,361,362,363,364,
365,366,367,368,369,370,371,372,373,374,375,376,377,378,379,380,381,382,383,384,385,386,387,388,389,390,391,392,393,394,395,396,397,398,399,400,401,402,403,404,405,406,407,408,409,410,411,412,413,415,
416,417,418,419,420,421,423,424,425,426,427,428,429,430,431,432,433,434,435,436,437,438,439,440,441,442,443,444,445,446,447,448,449,450,451,452,453,454,455,456,457,458,459,460,461,462,463,464,465,466,
467,468,469,470,471,472,473,474,475,476,477,478,479,480,481,482,483,484,485,486,487,488,489,490,491,492,493,494,495,496,497,498,499,500,501,502,503,504,505,506,507,508,509,510,511,512,513,514,515,516,
517,518,519,520,521,522,523,524,525,526,528,529,530,531,532,533,534,535,536,538,539,540,541,542,543,544,545,546,547,548,549,550,551,552,553,554,557,558,559,560,561,562,563,564,565,566,567,568,569,570,
571,572,573,574,575,576,577,578,579,580,581,582,583,584,585,586,587,588,589,590,591,592,593,594,595,596,597,598,599,600,601,602,603,604,605,606,607,608,609,610,611,612,613,614,615,616,617,618,619,620,
621,622,623,624,625,626,627,628,629,630,631,632,633,634,635,636,637,638,639,640,641,642,643,644,645,646,648,649,650,651,652,653,654,655,656,657,658,659,660,661,662,663,664,665,666,667,668,669,670,671,
672,673,674,675,676,677,678,679,680,681,682,683,684,685,686,687,688,689,690,691,692,693,694,695,696,697,698,699,700,701,702,703,704,705,706,707,708,709,712,713,715,716,717,721,722,726,736,747,749,757,
758,760,762,764,775,800,801,802,803,815,817,819,822,824,825,830,831,834,861,874,879,881,882,891,904,912,919,946,947,949,950,952,953,959,963,969,970,971,972,977,978,979,982,984,987,988,990,991,993,995,
998,999,1000,1001,1003,1005,1007,1012,1039,1040,1045,1050,1051,1054,1055,1056,1059,1060,1062,1064,1065,1066,1067,1068,1069,1070,1071,1073,1079,1094,1097,1098,1103,1104,1106,1107,1110,1118,1120,1126,1135,1137,1140,1142,1143,1145,1147,1148,1152,1153,
1160,1185,1188,1209,1223,1225,1226,1227,1230,1233,1234,1235,1236,1237,1240,1241,1242,1247,1248,1249,1271,1277,1278,1285,1286,1289,1290,1291,1295,1301,1305,1308,1316,1320,1329,1330,1331,1333,1336,1337,1338,1340,1342,1343,1344,1345,1346,1347,1348,1365,
1373,1375,1390,1393,1426,1428,1437,1439,1441,1442,1452,1456,1463,1466,1471,1474,1494,1496,1517,1525,1526,1530,1531,1538,1540,1541,1542,1543,1546,1548,1549,1550,1551,1552,1553,1555,1556,1558,1562,1563,1564,1565,1569,1570,1572,1573,1575,1576,1577,1578,
1579,1580,1581,1582,1583,1584,1585,1586,1587,1590,1592,1593,1594,1595,1600,1601,1605,1606,1609,1610,1611,1614,1615,1616,1617,1618,1620,1621,1626,1627,1628,1629,1631,1632,1633,1634,1635,1636,1642,1643,1644,1646,1647,1650,1653,1660,1661,1662,1665,1666,
1667,1668,1669,1670,1671,1673,1674,1675,1682,1683,1709,1723,1762,1763,1765,1771,1773,1779,1781,1833,1834,1837,1838,1841,1842,1847,1848,1855,1856,1857,1858,1859,1860,1861,1862,1863,1864,1865,1866,1867,1868,1869,1870,1871,1872,1873,1874,1876,1879,1881,
1883,1884,1885,1887,1888,1889,1890,1891,1892,1898,1916,1919,1920,1921,1932,1947,1949,1952,1953,1954,1964,1966,1967,1989,2001,2009,2010,2019,2022,2031,2049,2061,2062,2063,2068,2076,2083,2086,2090,2093,2094,2095,2096,2097,2111,2116,2118,2135,2155,2157,
2171,2174,2185,2190,2192,2193,2228,2229,2242,2247,2253,2261,2269,2270,2272,2279,2285,2286,2293,2294,2297,2298,2328,2329,2330,2331,2332,2333,2334,2335,2336,2337,2338,2339,2340,2341,2342,2343,2344,2345,2346,2347,2348,2349,2350,2351,2352,2353,2354,2355,
2356,2357,2358,2359,2360,2365,2368,2416,2430,2433,2436,2439,2537,2538,2539,2540,2541,2542,2544,2597,2603,2626,2627,2630,2631,2641,2670,2689,2726,2727,2729,2731,2733,2736,2737,2739,2741,2743,2746,2747,2752,2753,2768,2769,2796,2860,2861,2873,2897,2914,
2938,3009,3178,5492,5496,5499,5885,5886,5887,5888,5889,5890,5891,5892,5893,5894,5895,5898,5899,5900,5901,5902,5903,5904,5905,5906,5907,5908,5909,5910,5911,5912,5913,5914,5915,5920,5921,5922,5923,5924,5925,5926,5927,5928,5929,5930,5931,5932,5933,5934,
5935,5955,5977,5978,5979,5980,5981,5982,5983,5984,5985,5986,5987,5988,5989,5990,5991,5992,5993,5994,5995,5999,6000,6001,6002,6003,6004,6005,6006,6007,6008,6009,6010,6011,6012,6013,6014,6015,6017,6018,6019,6020,6021,6022,6023,6024,6025,6026,6027,6028,
6029,6030,6031,6032,6033,6034,6035,6099,6100,6101,6102,6103,6104,6105,6106,6107,6108,6109,6110,6111,6112,6113,6114,6115,6151,6152,6153,6154,6155,6156,6157,6158,6159,6160,6161,6162,6163,6164,6165,6483,6484,6485,6699,6700,6701,6702,6703,6704,6705,6758,
6759,6760,6761,6762,6763,6764,6765,6813,6814,6815,6816,6817,6818,6819,6820,6821,6822,6823,6824,6825,6853,6854,6855,6856,6857,6858,6859,6860,6861,6862,6863,6864,6865,6867,6868,6869,6870,6871,6872,6873,6874,6875,6876,6877,6878,6879,6880,6881,6882,6883,
6884,6885,6917,6918,6919,6920,6921,6922,6923,6924,6925,6932,6933,6934,6935,6936,6937,6938,6939,6940,6941,6942,6943,6944,6945,6954,6955,6956,6957,6958,6959,6960,6961,6962,6963,6964,6965,7008,7009,7010,7011,7012,7013,7014,7015,7016,7017,7018,7019,7020,
7021,7022,7023,7024,7025,7028,7029,7030,7031,7032,7033,7034,7035,7036,7037,7038,7039,7040,7041,7042,7043,7044,7045,7102,7103,7104,7105,7121,7122,7123,7124,7125,7136,7137,7138,7139,7140,7141,7142,7143,7144,7145,7149,7150,7151,7152,7153,7154,7155,7156,
7157,7158,7159,7160,7161,7162,7163,7164,7165,7172,7173,7174,7175,7176,7177,7178,7179,7180,7181,7182,7183,7184,7185,7193,7194,7195,7196,7197,7198,7199,7200,7201,7202,7203,7204,7205,7210,7211,7212,7213,7214,7215,7216,7217,7218,7219,7220,7221,7222,7223,
7224,7225,7232,7233,7234,7235,7236,7237,7238,7239,7240,7241,7242,7243,7244,7245,7250,7251,7252,7253,7254,7255,7256,7257,7258,7259,7260,7261,7262,7263,7264,7265,7300,7301,7302,7303,7304,7305,7310,7311,7312,7313,7314,7315,7316,7317,7318,7319,7320,7321,
7322,7323,7324,7325,7379,7380,7381,7382,7383,7384,7385,7393,7394,7395,7396,7397,7398,7399,7400,7401,7402,7403,7404,7405,7501,7502,7503,7504,7505,7562,7563,7564,7565,7570,7571,7572,7573,7574,7575,7576,7577,7578,7579,7580,7581,7582,7583,7584,7585,7588,
7589,7590,7591,7592,7593,7594,7595,7596,7597,7598,7599,7600,7601,7602,7603,7604,7605,7614,7615,7616,7617,7618,7619,7620,7621,7622,7623,7624,7625,7630,7631,7632,7633,7634,7635,7636,7637,7638,7639,7640,7641,7642,7643,7644,7645,7647,7648,7649,7650,7651,
7652,7653,7654,7655,7656,7657,7658,7659,7660,7661,7662,7663,7664,7665,7692,7693,7694,7695,7696,7697,7698,7699,7700,7701,7702,7703,7704,7705,7743,7744,7745,7762,7763,7764,7765,7772,7773,7774,7775,7776,7777,7778,7779,7780,7781,7782,7783,7784,7785,7788,
7789,7790,7791,7792,7793,7794,7795,7796,7797,7798,7799,7800,7801,7802,7803,7804,7805,7814,7815,7816,7817,7818,7819,7820,7821,7822,7823,7824,7825,7827,7828,7829,7830,7831,7832,7833,7834,7835,7836,7837,7838,7839,7840,7841,7842,7843,7844,7845,7849,7850,
7851,7852,7853,7854,7855,7856,7857,7858,7859,7860,7861,7862,7863,7864,7865,7873,7874,7875,7876,7877,7878,7879,7880,7881,7882,7883,7884,7885,7889,7890,7891,7892,7893,7894,7895,7896,7897,7898,7899,7900,7901,7902,7903,7904,7905,7998,7999,8000,8001,8002,
8003,8004,8005,8010,8011,8012,8013,8014,8015,8016,8017,8018,8019,8020,8021,8022,8023,8024,8025,8031,8032,8033,8034,8035,8036,8037,8038,8039,8040,8041,8042,8043,8044,8045,8054,8055,8056,8057,8058,8059,8060,8061,8062,8063,8064,8065,8096,8097,8098,8099,
8100,8101,8102,8103,8104,8105,8145,8219,8220,8221,8222,8227,8228,8229,8230,8231,8232,8233,8234,8235,8236,8237,8238,8239,8240,8241,8242,8321,8322,8324,8325,8326,8327,8328,8329,8330,8331,8332,8333,8334,8335,8336,8337,8338,8339,8340,8341,8342,8351,8352,
8353,8354,8355,8356,8357,8358,8359,8360,8361,8362,8369,8370,8371,8372,8373,8374,8375,8376,8377,8378,8379,8380,8381,8382,8413,8414,8415,8416,8417,8418,8419,8420,8421,8422,8433,8434,8435,8436,8437,8438,8439,8440,8441,8442,8445,8446,8447,8448,8449,8450,
8451,8452,8453,8454,8455,8456,8457,8458,8459,8460,8461,8462,8464,8465,8466,8467,8468,8469,8470,8471,8472,8473,8474,8475,8476,8477,8478,8479,8480,8481,8482,8509,8510,8511,8512,8513,8514,8515,8516,8517,8518,8519,8520,8521,8522,8530,8531,8532,8533,8534,
8535,8536,8537,8538,8539,8540,8541,8542,8549,8550,8551,8552,8553,8554,8555,8556,8557,8558,8559,8560,8561,8562,8565,8566,8567,8568,8569,8570,8571,8572,8573,8574,8575,8576,8577,8578,8579,8580,8581,8582,8596,8597,8598,8599,8600,8601,8602,8604,8605,8606,
8607,8608,8609,8610,8611,8612,8613,8614,8615,8616,8617,8618,8619,8620,8621,8622,8634,8635,8636,8637,8638,8639,8640,8641,8642,8648,8649,8650,8651,8652,8653,8654,8655,8656,8657,8658,8659,8660,8661,8662,8664,8665,8666,8667,8668,8669,8670,8671,8672,8673,
8674,8675,8676,8677,8678,8679,8680,8681,8682,8689,8690,8691,8692,8693,8694,8695,8696,8697,8698,8699,8700,8701,8702,8709,8710,8711,8712,8713,8714,8715,8716,8717,8718,8719,8720,8721,8722,8725,8726,8727,8728,8729,8730,8731,8732,8733,8734,8735,8736,8737,
8738,8739,8740,8741,8742,9106,9107,9108,9109,9110,9111,9112,9113,9114,9115,9116,9117,9118,9119,9120,9121,9122,9267,9268,9269,9270,9271,9272,9273,9274,9337,9338,9339,9340,9341,9342,9343,9344,9345,9346,9347,9348,9349,9350,9351,9352,9353,9354,9373,9374,
9493,9494,9495,9496,9497,9498,9499,9500,9501,9502,9503,9504,9505,9506,9524,9525,9526,9582,9583,9584,9585,9586,9610,9611,9612,9613,9614,9615,9616,9617,9667,9668,9669,9670,9671,9672,9673,9674,9675,9676,9677,9688,9689,9690,9691,9692,9693,9694,9695,9696,
9697,9707,9708,9709,9710,9711,9712,9713,9714,9715,9716,9717,9720,9721,9722,9723,9724,9725,9726,9727,9728,9729,9730,9731,9732,9733,9734,9735,9736,9737,9975,9976,9977,9979,9980,9981,9982,9983,9984,9985,9986,9987,9988,9989,9990,9991,9992,9993,9994,9995,
9996,9997,10012,10013,10014,10015,10016,10017,10114,10115,10116,10117,10291,10292,10293,10294,10295,10296,10297,10334,10335,10336,10337,10339,10340,10341,10342,10343,10344,10345,10346,10347,10348,10349,10350,10351,10352,10353,10354,10355,10356,10357,10395,10396,10397,10415,10416,10417,10425,10426,
10427,10428,10429,10430,10431,10432,10433,10434,10435,10436,10437,10468,10469,10470,10471,10472,10473,10474,10475,10476,10477,10480,10481,10482,10483,10484,10485,10486,10487,10488,10489,10490,10491,10492,10493,10494,10495,10496,10497,10516,10517,10519,10520,10521,10522,10523,10524,10525,10526,10527,
10528,10529,10530,10531,10532,10533,10534,10535,10536,10537,10557,10665,10666,10667,10668,10669,10670,10671,10672,10673,10674,10675,10676,10677,10729,10730,10731,10732,10733,10734,10735,10736,10737,10809,10810,10811,10812,10813,10814,10815,10816,10817,10848,10849,10850,10851,10852,10853,10854,10855,
10856,10857,10859,10860,10861,10862,10863,10864,10865,10866,10867,10868,10869,10870,10871,10872,10873,10874,10875,10876,10877,10879,10880,10881,10882,10883,10884,10885,10886,10887,10888,10889,10890,10891,10892,10893,10894,10895,10896,10897,10899,10900,10901,10902,10903,10904,10905,10906,10907,10908,
10909,10910,10911,10912,10913,10914,10915,10916,10917,10923,10924,10925,10926,10927,10928,10929,10930,10931,10932,10933,10934,10935,10936,10937,10941,10942,10943,10944,10945,10946,10947,10948,10949,10950,10951,10952,10953,10954,10955,10956,10957,10960,10961,10962,10963,10964,10965,10966,10967,10968,
10969,10970,10971,10972,10973,10974,10975,10976,10977,10979,10980,10981,10982,10983,10984,10985,10986,10987,10988,10989,10990,10991,10992,10993,10994,10995,10996,10997,11001,11002,11003,11004,11005,11006,11007,11008,11009,11010,11011,11012,11013,11014,11015,11016,11017,11028,11029,11030,11031,11032,
11033,11034,11035,11036,11037,11043,11044,11045,11046,11047,11048,11049,11050,11051,11052,11053,11054,11055,11056,11057,11059,11060,11061,11062,11063,11064,11065,11066,11067,11068,11069,11070,11071,11072,11073,11074,11075,11076,11077,11088,11089,11090,11091,11092,11093,11094,11095,11096,11097,11117,
11153,11154,11155,11156,11157,11158,11159,11160,11161,11180,11181,11209,11210,11211,11212,11213,11214,11215,11216,11217,11218,11219,11220,11221,11232,11233,11234,11235,11236,11237,11238,11239,11240,11241,11244,11245,11246,11247,11248,11249,11250,11251,11252,11253,11254,11255,11256,11257,11258,11259,
11260,11261,11271,11272,11273,11274,11275,11276,11277,11278,11279,11280,11281,11292,11293,11294,11295,11296,11297,11298,11299,11300,11301,11326,11327,11328,11329,11330,11331,11332,11333,11334,11335,11336,11337,11338,11339,11340,11341,11346,11347,11348,11349,11350,11351,11352,11353,11354,11355,11356,
11357,11358,11359,11360,11361,11372,11373,11374,11375,11376,11377,11378,11379,11380,11381,11396,11397,11398,11399,11400,11401,11421,11425,11426,11427,11428,11429,11430,11431,11432,11433,11434,11435,11436,11437,11438,11439,11440,11441,11447,11448,11449,11450,11451,11452,11453,11454,11455,11456,11457,
11458,11459,11460,11461,11481,11483,11484,11485,11486,11487,11488,11489,11490,11491,11492,11493,11494,11495,11496,11497,11498,11499,11500,11501,11517,11518,11519,11520,11521,11523,11524,11525,11526,11527,11528,11529,11530,11531,11532,11533,11534,11535,11536,11537,11538,11539,11540,11541,11543,11544,
11545,11546,11547,11548,11549,11550,11551,11552,11553,11554,11555,11556,11557,11558,11559,11560,11561,11571,11572,11573,11574,11575,11576,11577,11578,11579,11580,11581,11592,11593,11594,11595,11596,11597,11598,11599,11600,11601,11618,11619,11620,11621,11636,11637,11638,11639,11640,11641,11650,11651,
11652,11653,11654,11655,11656,11657,11658,11659,11660,11661,11680,11681,11687,11688,11689,11690,11691,11692,11693,11694,11695,11696,11697,11698,11699,11700,11701,11704,11705,11706,11707,11708,11709,11710,11711,11712,11713,11714,11715,11716,11717,11718,11719,11720,11721,11738,11739,11740,11741,11756,
11757,11758,11759,11760,11761,11769,11770,11771,11772,11773,11774,11775,11776,11777,11778,11779,11780,11781,11788,11789,11790,11791,11792,11793,11794,11795,11796,11797,11798,11799,11800,11801,11877,11878,11879,11880,11881,11890,11891,11892,11893,11894,11895,11896,11897,11898,11899,11900,11901,11956,
11957,11958,11959,11960,11961,12067,12068,12069,12070,12071,12072,12073,12074,12075,12076,12077,12078,12079,12080,12081,12084,12085,12086,12087,12088,12089,12090,12091,12092,12093,12094,12095,12096,12097,12098,12099,12100,12101,12116,12117,12118,12119,12120,12121,12123,12124,12125,12126,12127,12128,
12129,12130,12131,12132,12133,12134,12135,12136,12137,12138,12139,12140,12141,12145,12146,12147,12148,12149,12150,12151,12152,12153,12154,12155,12156,12157,12158,12159,12160,12161,12165,12166,12167,12168,12169,12170,12171,12172,12173,12174,12175,12176,12177,12178,12179,12180,12181,12193,12194,12195,
12196,12197,12198,12199,12200,12201,12265,12266,12267,12268,12269,12270,12271,12272,12273,12274,12275,12276,12277,12278,12279,12280,12281,12305,12306,12307,12308,12309,12310,12311,12312,12313,12314,12315,12316,12317,12318,12319,12320,12321,12370,12371,12372,12373,12374,12375,12376,12377,12378,12379,
12380,12381,12386,12387,12388,12389,12390,12391,12392,12393,12394,12395,12396,12397,12398,12399,12400,12401,12473,12474,12475,12476,12477,12478,12479,12480,12481,12483,12484,12485,12486,12487,12488,12489,12490,12491,12492,12493,12494,12495,12496,12497,12498,12499,12500,12501,12503,12504,12505,12506,
12507,12508,12509,12510,12511,12512,12513,12514,12515,12516,12517,12518,12519,12520,12521,12536,12537,12538,12539,12540,12541,12559,12560,12561,12568,12569,12570,12571,12572,12573,12574,12575,12576,12577,12578,12579,12580,12581,12594,12595,12596,12597,12598,12599,12600,12601,12656,12657,12658,12659,
12660,12661,12664,12665,12666,12667,12668,12669,12670,12671,12672,12673,12674,12675,12676,12677,12678,12679,12680,12681,12758,12759,12760,12761,12872,12873,12874,12875,12876,12877,12878,12879,12880,12881,12908,12909,12910,12911,12912,12913,12914,12915,12916,12917,12918,12919,12920,12921,13200,13201,
13224,13225,13226,13227,13228,13229,13230,13231,13232,13233,13234,13235,13236,13237,13238,13239,13240,13241,13263,13264,13265,13266,13267,13268,13269,13270,13271,13272,13273,13274,13275,13276,13277,13278,13279,13280,13281,13295,13296,13297,13298,13299,13300,13301,13410,13411,13412,13413,13414,13415,
13416,13417,13418,13419,13420,13421,13424,13425,13426,13427,13428,13429,13430,13431,13432,13433,13434,13435,13436,13437,13438,13439,13440,13441,13540,13541,13547,13548,13549,13550,13551,13552,13553,13554,13555,13556,13557,13558,13559,13560,13561,13563,13564,13565,13566,13567,13568,13569,13570,13571,
13572,13573,13574,13575,13576,13577,13578,13579,13580,13581,13587,13588,13589,13590,13591,13592,13593,13594,13595,13596,13597,13598,13599,13600,13601,13613,13614,13615,13616,13617,13618,13619,13620,13621,13633,13634,13635,13636,13637,13638,13639,13640,13641,13826,13827,13828,13829,13830,13831,13832,
13833,13834,13835,13836,13837,13838,13839,13840,13841,13921,13970,13971,13972,13973,13974,13975,13976,13977,13978,13979,13980,13981,13987,13988,13989,13990,13991,13992,13993,13994,13995,13996,13997,13998,13999,14000,14001,14003,14004,14005,14006,14007,14008,14009,14010,14011,14012,14013,14014,14015,
14016,14017,14018,14019,14020,14021,14026,14027,14028,14029,14030,14031,14032,14033,14034,14035,14036,14037,14038,14039,14040,14041,14049,14050,14051,14052,14053,14054,14055,14056,14057,14058,14059,14060,14061,14063,14064,14065,14066,14067,14068,14069,14070,14071,14072,14073,14074,14075,14076,14077,
14078,14079,14080,14081,14345,14346,14347,14348,14349,14350,14351,14352,14353,14354,14355,14356,14357,14358,14359,14360,14361,14515,14516,14517,14518,14519,14520,14521,14708,14709,14710,14711,14712,14713,14714,14715,14716,14717,14718,14719,14720,14721,14731,14732,14733,14734,14735,14736,14737,14738,
14739,14740,14741,14984,14985,14986,14987,14988,14989,14990,14991,14992,14993,14994,14995,14996,14997,14998,14999,15000,15001,15020,15021,15023,15024,15025,15026,15027,15028,15029,15030,15031,15032,15033,15034,15035,15036,15037,15038,15039,15040,15041,15097,15098,15099,15100,15101,15201,15315,15316,
15317,15318,15319,15320,15321,15700,15701,15711,15712,15713,15714,15715,15716,15717,15718,15719,15720,15721,15816,15817,15818,15819,15820,15821,15828,15829,15830,15831,15832,15833,15834,15835,15836,15837,15838,15839,15840,15841,15896,15897,15898,15899,15900,15901,15948,15949,15950,15951,15952,15953,
15954,15955,15956,15957,15958,15959,15960,15961,16010,16011,16012,16013,16014,16015,16016,16017,16018,16019,16020,16021,16087,16088,16089,16090,16091,16092,16093,16094,16095,16096,16097,16098,16099,16100,16101,16193,16194,16195,16196,16197,16198,16199,16200,16201,16225,16226,16227,16228,16229,16230,
16231,16232,16233,16234,16235,16236,16237,16238,16239,16240,16241,16256,16257,16258,16259,16260,16261,16264,16265,16266,16267,16268,16269,16270,16271,16272,16273,16274,16275,16276,16277,16278,16279,16280,16281,16284,16285,16286,16287,16288,16289,16290,16291,16292,16293,16294,16295,16296,16297,16298,
16299,16300,16301,16584,16585,16586,16587,16588,16589,16590,16591,16592,16593,16594,16595,16596,16597,16598,16599,16600,16601,16609,16610,16611,16612,16613,16614,16615,16616,16617,16618,16619,16620,16621,16624,16625,16626,16627,16628,16629,16630,16631,16632,16633,16634,16635,16636,16637,16638,16639,
16640,16641,16749,16750,16751,16752,16753,16754,16755,16756,16757,16758,16759,16760,16761,16770,16771,16772,16773,16774,16775,16776,16777,16778,16779,16780,16781,16874,16875,16876,16877,16878,16879,16880,16881,17079,17080,17081,17083,17084,17085,17086,17087,17088,17089,17090,17091,17092,17093,17094,
17095,17096,17097,17098,17099,17100,17101,17120,17121,17127,17128,17129,17130,17131,17132,17133,17134,17135,17136,17137,17138,17139,17140,17141,17143,17144,17145,17146,17147,17148,17149,17150,17151,17152,17153,17154,17155,17156,17157,17158,17159,17160,17161,17164,17165,17166,17167,17168,17169,17170,
17171,17172,17173,17174,17175,17176,17177,17178,17179,17180,17181,17205,17206,17207,17208,17209,17210,17211,17212,17213,17214,17215,17216,17217,17218,17219,17220,17221,17225,17226,17227,17228,17229,17230,17231,17232,17233,17234,17235,17236,17237,17238,17239,17240,17241,17243,17244,17245,17246,17247,
17248,17249,17250,17251,17252,17253,17254,17255,17256,17257,17258,17259,17260,17261,17263,17264,17265,17266,17267,17268,17269,17270,17271,17272,17273,17274,17275,17276,17277,17278,17279,17280,17281,17284,17285,17286,17287,17288,17289,17290,17291,17292,17293,17294,17295,17296,17297,17298,17299,17300,
17301,17311,17312,17313,17314,17315,17316,17317,17318,17319,17320,17321,17334,17335,17336,17337,17338,17339,17340,17341,17356,17357,17358,17359,17360,17361,17365,17366,17367,17368,17369,17370,17371,17372,17373,17374,17375,17376,17377,17378,17379,17380,17381,17385,17386,17387,17388,17389,17390,17391,
17392,17393,17394,17395,17396,17397,17398,17399,17400,17401,17415,17416,17417,17418,17419,17420,17421,17424,17425,17426,17427,17428,17429,17430,17431,17432,17433,17434,17435,17436,17437,17438,17439,17440,17441,17443,17444,17445,17446,17447,17448,17449,17450,17451,17452,17453,17454,17455,17456,17457,
17458,17459,17460,17461,17464,17465,17466,17467,17468,17469,17470,17471,17472,17473,17474,17475,17476,17477,17478,17479,17480,17481,17483,17484,17485,17486,17487,17488,17489,17490,17491,17492,17493,17494,17495,17496,17497,17498,17499,17500,17501,17509,17510,17511,17512,17513,17514,17515,17516,17517,
17518,17519,17520,17521,17524,17525,17526,17527,17528,17529,17530,17531,17532,17533,17534,17535,17536,17537,17538,17539,17540,17541,17543,17544,17545,17546,17547,17548,17549,17550,17551,17552,17553,17554,17555,17556,17557,17558,17559,17560,17561,17627,17628,17629,17630,17631,17632,17633,17634,17635,
17636,17637,17638,17639,17640,17641,17644,17645,17646,17647,17648,17649,17650,17651,17652,17653,17654,17655,17656,17657,17658,17659,17660,17661,17663,17664,17665,17666,17667,17668,17669,17670,17671,17672,17673,17674,17675,17676,17677,17678,17679,17680,17681,17697,17698,17699,17700,17701,17784,17785,
17786,17787,17788,17789,17790,17791,17792,17793,17794,17795,17796,17797,17798,17799,17800,17801,17803,17804,17805,17806,17807,17808,17809,17810,17811,17812,17813,17814,17815,17816,17817,17818,17819,17820,17821,17863,17864,17865,17866,17867,17868,17869,17870,17871,17872,17873,17874,17875,17876,17877,
17878,17879,17880,17881,17912,17913,17914,17915,17916,17917,17918,17919,17920,17921,17923,17924,17925,17926,17927,17928,17929,17930,17931,17932,17933,17934,17935,17936,17937,17938,17939,17940,17941,17944,17945,17946,17947,17948,17949,17950,17951,17952,17953,17954,17955,17956,17957,17958,17959,17960,
17961,17970,17971,17972,17973,17974,17975,17976,17977,17978,17979,17980,17981,17983,17984,17985,17986,17987,17988,17989,17990,17991,17992,17993,17994,17995,17996,17997,17998,17999,18000,18001,18003,18004,18005,18006,18007,18008,18009,18010,18011,18012,18013,18014,18015,18016,18017,18018,18019,18020,
18021,18024,18025,18026,18027,18028,18029,18030,18031,18032,18033,18034,18035,18036,18037,18038,18039,18040,18041,18049,18050,18051,18052,18053,18054,18055,18056,18057,18058,18059,18060,18061,18064,18065,18066,18067,18068,18069,18070,18071,18072,18073,18074,18075,18076,18077,18078,18079,18080,18081,
18084,18085,18086,18087,18088,18089,18090,18091,18092,18093,18094,18095,18096,18097,18098,18099,18100,18101,18107,18108,18109,18110,18111,18112,18113,18114,18115,18116,18117,18118,18119,18120,18121,18124,18125,18126,18127,18128,18129,18130,18131,18132,18133,18134,18135,18136,18137,18138,18139,18140,
18141,18174,18175,18176,18177,18178,18179,18180,18181,18183,18184,18185,18186,18187,18188,18189,18190,18191,18192,18193,18194,18195,18196,18197,18198,18199,18200,18201,18210,18211,18212,18213,18214,18215,18216,18217,18218,18219,18220,18221,18270,18271,18272,18273,18274,18275,18276,18277,18278,18279,
18280,18281,18548,18549,18550,18551,18552,18553,18554,18555,18556,18557,18558,18559,18560,18561,18568,18569,18570,18571,18572,18573,18574,18575,18576,18577,18578,18579,18580,18581,18613,18614,18615,18616,18617,18618,18619,18620,18621,18883,18884,18885,18886,18887,18888,18889,18890,18891,18892,18893,
18894,18895,18896,18897,18898,18899,18900,18901,18905,18906,18907,18908,18909,18910,18911,18912,18913,18914,18915,18916,18917,18918,18919,18920,18921,18923,18924,18925,18926,18927,18928,18929,18930,18931,18932,18933,18934,18935,18936,18937,18938,18939,18940,18941,18973,18974,18975,18976,18977,18978,
18979,18980,18981,18988,18989,18990,18991,18992,18993,18994,18995,18996,18997,18998,18999,19000,19001,19021,19072,19073,19074,19075,19076,19077,19078,19079,19080,19081,19161,19171,19172,19173,19174,19175,19176,19177,19178,19179,19180,19181,19408,19409,19410,19411,19412,19413,19414,19415,19416,19417,
19418,19419,19420,19421,19458,19459,19460,19461,19463,19464,19465,19466,19467,19468,19469,19470,19471,19472,19473,19474,19475,19476,19477,19478,19479,19480,19481,19492,19493,19494,19495,19496,19497,19498,19499,19500,19501,19624,19625,19626,19627,19628,19629,19630,19631,19632,19633,19634,19635,19636,
19637,19638,19639,19640,19641,19643,19644,19645,19646,19647,19648,19649,19650,19651,19652,19653,19654,19655,19656,19657,19658,19659,19660,19661,19663,19664,19665,19666,19667,19668,19669,19670,19671,19672,19673,19674,19675,19676,19677,19678,19679,19680,19681,19728,19729,19730,19731,19732,19733,19734,
19735,19736,19737,19738,19739,19740,19741,19744,19745,19746,19747,19748,19749,19750,19751,19752,19753,19754,19755,19756,19757,19758,19759,19760,19761,19791,19792,19793,19794,19795,19796,19797,19798,19799,19800,19801,20293,21824,21825,21826,21827,21828,24574,37918,37935,38634,39755,41700,44830,44831,
44850,44863,44864,44868,44886,44887,44888,44889,44911,44913,44925,44927,44929,44942,44959,44960,44961,44962,44966,44967,44968,44969,44975,44976,44979,44985,44995,44999,45001,45004,45012,45023,45024,45025,45027,45040,45042,45043,45044,45051,45065,45066,45068,45069,45071,45079,45465,45475,45476,45477,
45478,45526,45545,45546,45571,45572,45573,45576,45598,45600,45662,45678,45681,45683,45684,45710,45807,45818,45885,45898,45906,45911,45944,46056,46091,46094,46128,46147,46310,46311,46314,46315,46316,46317,46318,46325,46337,46338,46352,46353,46354,46355,46356,46357,46363,46365,46366,46370,46383,46384,
46385,46386,46387,46388,46389,46390,46391,46392,46404,46405,46406,46407,46408,46409,46410,46411,46412,46413,46414,46415,46416,46417,46418,46419,46420,46421,46422,46423,46424,46425,46426,46427,46428,46429,46430,46431,46432,46433,46434,46435,46436,46437,46438,46439,46440,46441,46442,46443,46444,46445,
46446,46447,46448,46449,46450,46451,46452,46453,46454,46455,46456,46457,46458,46459,46460,46461,46462,46463,46464,46465,46466,46467,46468,46469,46470,46471,46472,46473,46474,46475,46476,46477,46478,46479,46480,46481,46482,46483,46484,46485,46486,46487,46488,46489,46490,46491,46492,46493,46494,46495,
46496,46497,46498,46499,46500,46501,46502,46503,46504,46505,46506,46507,46508,46509,46510,46511,46512,46513,46514,46515,46516,46517,46518,46519,46520,46521,46522,46523,46524,46525,46526,46527,46528,46529,46530,46531,46532,46533,46534,46535,46536,46537,46538,46539,46540,46541,46542,46543,46546,46548,
46549,46550,46551,46552,46553,46554,46555,46556,46557,46558,46559,46560,46561,46562,46563,46564,46565,46566,46567,46568,46569,46570,46571,46572,46573,46574,46575,46576,46577,46578,46579,46580,46581,46582,46583,46584,46585,46586,46587,46588,46589,46590,46591,46592,46593,46594,46595,46596,46597,46598,
46599,46600,46601,46602,46603,46604,46605,46606,46607,46608,46609,46610,46611,46612,46613,46614,46615,46616,46617,46618,46619,46620,46621,46622,46623,46624,46625,46626,46627,46628,46629,46630,46631,46632,46633,46634,46635,46636,46637,46638,46639,46640,46641,46642,46643,46644,46645,46646,46647,46648,
46649,46650,46651,46652,46653,46654,46655,46656,46657,46658,46659,46660,46661,46662,46663,46664,46665,46666,46667,46668,46669,46670,46671,46672,46673,46674,46675,46676,46677,46678,46679,46680,46681,46682,46683,46684,46685,46686,46687,46688,46692,46694,46695,46696,46697,46698,46699,46700,46701,46702,
46703,46704,46705,46706,46713,46714,46715,46716,46719,46720,46721,46722,46724,46726,46727,46728,46729,46730,46731,46732,46734,46739,46741,46742,46753,46754,46768,46769,46770,46771,46772,46773,46774,46776,46777,46781,46782,46785,46786,46787,46788,46789,46790,46791,46792,46794,46795,46798,46801,46808,
46811,46819,46822,46823,46825,46826,46827,46828,46829,46832,46833,46834,46835,46836,46838,46848,46850,46851,46853,46855,46856,46857,46858,46867,46868,46869,46871,46872,46896,47038,47039,47040,47044,47045,47046,47047,47049,47050,47058,47091,47163,47164,47165,47166,47167,47168,47169,47198,47530,47531,
47532,47533,47534,47535,47536,47537,47538,47539,47540,47722,47723,47817,47818,47819,47820,47821,47822,47823,47824,47825,47826,47827,47831,47833,47839,47841,47843,47845,47847,47848,47912,48103,48104,48105,48106,48107,48108,48109,48110,48111,48113,48115,48117,48119,48121,48123,48125,48127,48128,48248,
48249,48401,48403,48405,48407,48409,48411,48413,48415,48417,48419,48421,48423,48425,48427,48431,48434,48437,48439,48441,48443,48471,48473,48475,48477,48479,48506,48508,48510,48512,48514,48516,48518,48520,48522,48524,48525,48526,48528,48530,48532,48534,48536,48563,48565,48567,48569,48570,48571,48573,
48600,48662,48664,48665,48676,48678,48680,48682,48684,48686,48688,48690,48692,48694,48696,48698,48700,48702,48704,48706,48707,48715,48717,48719,48721,48723,48765,48766,48767,48768,48779,48780,48791,48792,48793,48834,48835,48856,48857,48858,48859,48920,48921,48932,48934,48935,48936,48937,48938,48939,
48940,48941,48942,48943,48944,48946,48948,48950,48951,48952,48953,48958,48959,48960,48961,48962,48963,48964,48965,48966,48967,48968,48969,48970,48971,48972,48973,49001,49002,49003,49004,49005,49006,49007,49008,49009,49010,49011,49012,49013,49014,49015,49017,49019,49021,49023,49025,49026,49027,49028,
49029,49030,49031,49032,49033,49034,49035,49036,49037,49038,49039,49041,49042,49043,49045,49047,49048,49049,49051,49053,49055,49056,49057,49058,49059,49060,49061,49062,49063,49064,49065,49066,49067,49068,49069,49071,49073,49075,49077,49079,49081,49082,49083,49085,49087,49088,49089,49090,49091,49092,
49093,49094,49095,49097,49099,49100,49101,49102,49103,49104,49105,49107,49108,49109,49111,49113,49114,49115,49117,49119,49125,49127,49129,49130,49131,49132,49133,49134,49135,49136,49137,49138,49139,49140,49141,49142,49143,49144,49145,49146,49147,49149,49150,49151,49153,49155,49157,49159,49161,49162,
49163,49164,49165,49166,49167,49168,49169,49170,49171,49172,49173,49174,49175,49176,49178,49180,49182,49184,49186,49188,49190,49194,49195,49196,49197,49199,49200,49201,49202,49203,49204,49207,49208,49210,49211,49212,49213,49214,49215,49216,49217,49218,49219,49220,49221,49222,49226,49228,49229,49230,
49239,49240,49241,49242,49243,49244,49245,49246,49247,49248,49249,49250,49251,49252,49253,49254,49255,49256,49257,49258,49259,49260,49261,49262,49263,49264,49265,49266,49267,49268,49269,49270,49271,49272,49273,49274,49275,49276,49277,49279,49280,49281,49300,49336,49337,49338,49339,49347,49348,49350,
49354,49355,49356,49359,49360,49361,49364,49365,49366,49367,49368,49369,49370,49371,49375,49376,49378,49379,49380,49381,49382,49383,49384,49385,49386,49387,49388,49389,49390,49391,49392,49393,49394,49395,49396,49397,49398,49399,49400,49401,49402,49403,49404,49405,49406,49407,49408,49409,49410,49411,
49412,49413,49414,49415,49416,49417,49418,49419,49420,49421,49422,49423,49424,49425,49427,49428,49429,49430,49431,49432,49433,49434,49435,49436,49438,49439,49440,49441,49442,49443,49444,49445,49446,49447,49448,49449,49450,49451,49452,49453,49454,49455,49456,49457,49458,49459,49460,49461,49462,49502,
49503,49504,49505,49506,49507,49508,49509,49510,49511,49512,49513,49514,49515,49516,49517,49518,49519,49520,49521,49522,49523,49524,49525,49526,49527,49528,49529,49530,49531,49532,49533,49534,49535,49537,49538,49539,49540,49541,49542,49543,49544,49545,49546,49547,49548,49549,49550,49551,49552,49553,
49554,49555,49556,49557,49558,49559,49560,49561,49562,49563,49564,49565,49566,49567,49568,49569,49570,49571,49572,49573,49574,49575,49576,49577,49578,49579,49580,49581,49582,49583,49584,49585,49586,49587,49588,49589,49590,49591,49592,49593,49594,49595,49596,49597,49598,49599,49600,49601,49602,49603,
49604,49605,49606,49607,49608,49609,49610,49611,49612,49613,49614,49615,49616,49617,49618,49619,49620,49621,49622,49624,49625,49626,49627,49628,49629,49630,49639,49642,49647,49649,49650,49651,49652,49656,49657,49671,49672,49673,49674,49679,49683,49685,49688,49694,49695,49696,49697,49699,49700,49701,
49705,49707,49710,49711,49712,49742,49743,49744,49745,49746,49747,49748,49749,49751,49752,49753,49754,49755,49756,49757,49758,49759,49760,49765,49769,49770,49771,49772,49776,49779,49780,49781,49782,49815,49850,49866,49874,49875,49876,49877,49878,49880,49881,49882,49883,49884,49885,49887,49910,49921,
49928,49929,49930,49932,49934,49944,49945,49946,49947,49948,50017,50018,50031,50044,50053,50054,50086,50122,50126,50127,50128,50134,50135,50136,50137,50138,50139,50140,50141,50142,50143,50144,50145,50146,50147,50148,50149,50150,50152,50153,50154,50155,50156,50157,50158,50159,50162,50165,50189,50200,
50218,50219,50220,50222,50223,50232,50236,50237,50238,50239,50253,50258,50261,50288,50334,50371,50374,50381,50382,50383,50385,50405,50407,50408,50409,50410,50420,50430,50436,50437,50438,50439,50440,50441,50443,50445,50448,50465,50473,50602,50739,50740,50742,50743,50744,50745,50746,50770,50813,50829,
51546,51547,51549,51567,51778,51780,51781,51793,51794,51810,51948,51950,51951,51952,51953,51956,51957,52013,52014,52017,52018,52024,52031,52032,52035,52036,52038,52039,52040,52041,52043,52044,52045,52046,52047,52048,52049,52050,52051,52052,52053,52054,52055,52056,52057,52059,52060,52061,52063,52064,
52065,52066,52067,52068,52069,52070,52071,52072,52073,52074,52075,52076,52077,52078,52079,52080,52081,52082,52083,52084,52085,52086,52087,52088,52089,52090,52091,52092,52093,52094,52095,52096,52097,52098,52099,52100,52101,52102,52103,52104,52105,52106,52107,52108,52109,52110,52111,52112,52113,52114,
52115,52116,52117,52118,52119,52120,52121,52122,52123,52124,52125,52126,52127,52128,52129,52130,52131,52132,52133,52134,52135,52136,52137,52138,52139,52140,52141,52142,52143,52144,52145,52146,52147,52148,52149,52150,52151,52152,52153,52154,52155,52156,52157,52158,52159,52160,52161,52162,52163,52164,
52165,52166,52167,52168,52169,52170,52171,52172,52173,52174,52175,52176,52177,52178,52179,52180,52181,52182,52183,52184,52185,52186,52187,52188,52190,52191,52192,52193,52194,52195,52196,52197,52198,52199,52203,52204,52205,52206,52207,52208,52209,52210,52211,52212,52213,52214,52215,52216,52217,52218,
52219,52220,52221,52222,52223,52224,52225,52226,52227,52228,52229,52230,52231,52232,52233,52234,52235,52236,52237,52238,52239,52240,52241,52242,52243,52244,52245,52246,52247,52248,52249,52250,52254,52255,52256,52257,52258,52259,52260,52261,52262,52263,52264,52265,52266,52267,52268,52269,52270,52271,
52273,52277,52278,52279,52280,52281,52282,52283,52284,52285,52286,52287,52288,52289,52290,52291,52292,52293,52294,52295,52296,52297,52298,52299,52300,52301,52302,52303,52304,52305,52306,52307,52308,52309,52310,52311,52312,52313,52314,52315,52316,52317,52318,52319,52320,52321,52322,52323,52324,52325,
52326,52327,52328,52329,52330,52331,52332,52333,52334,52335,52336,52337,52338,52339,52340,52341,52342,52343,52346,52347,52348,52349,52350,52351,52352,52353,52354,52355,52360,52362,52363,52364,52365,52366,52367,52368,52369,52370,52371,52372,52373,52374,52375,52376,52377,52378,52379,52380,52381,52382,
52383,52384,52385,52386,52387,52388,52389,52390,52391,52392,52393,52394,52395,52396,52397,52398,52399,52400,52401,52402,52403,52404,52405,52406,52407,52408,52409,52410,52411,52412,52413,52414,52415,52416,52417,52418,52419,52420,52421,52422,52423,52424,52425,52426,52427,52428,52429,52430,52431,52432,
52433,52434,52435,52436,52437,52438,52439,52440,52441,52442,52443,52444,52445,52446,52447,52448,52449,52450,52451,52452,52453,52454,52455,52456,52457,52458,52459,52460,52461,52462,52463,52464,52465,52466,52467,52468,52469,52470,52471,52472,52473,52474,52475,52476,52477,52478,52479,52480,52481,52482,
52483,52484,52485,52486,52487,52488,52489,52490,52491,52492,52493,52494,52495,52496,52497,52498,52499,52500,52501,52502,52503,52504,52505,52506,52507,52508,52509,52510,52511,52512,52513,52514,52515,52516,52517,52518,52519,52520,52521,52522,52523,52524,52525,52526,52527,52528,52529,52530,52531,52532,
52533,52534,52535,52536,52537,52538,52539,52540,52542,52543,52544,52545,52546,52547,52548,52549,52550,52551,52552,52553,52554,52555,52556,52557,52558,52559,52560,52561,52564,52568,52573,52574,52575,52576,52577,52578,52579,52580,52581,52582,52583,52584,52585,52586,52587,52588,52589,52590,52591,52592,
52593,52594,52595,52596,52597,52598,52599,52600,52601,52602,52603,52604,52605,52606,52607,52608,52609,52610,52611,52612,52613,52614,52615,52616,52617,52618,52619,52620,52621,52622,52623,52624,52625,52626,52627,52628,52629,52630,52631,52632,52633,52634,52635,52636,52637,52638,52639,52640,52641,52642,
52643,52644,52645,52646,52647,52648,52649,52650,52651,52652,52653,52654,52655,52656,52657,52658,52659,52660,52661,52662,52663,52664,52665,52666,52667,52668,52669,52670,52671,52672,52673,52674,52675,52677,52678,52679,52680,52681,52682,52683,52684,52685,52687,52688,52689,52690,52691,52692,52693,52694,
52695,52696,52697,52698,52699,52700,52701,52702,52703,52704,52705,52708,52710,52711,52712,52714,52715,52716,52717,52718,52719,52720,52721,52722,52723,52724,52725,52726,52727,52728,52730,52732,52733,52734,52735,52736,52737,52738,52739,52740,52741,52742,52743,52744,52745,52746,52747,52748,52749,52750,
52751,52752,52753,52754,52755,52756,52757,52758,52759,52760,52761,52762,52763,52764,52765,52766,52767,52768,52769,52770,52771,52772,52773,52774,52775,52776,52777,52778,52779,52780,52781,52782,52783,52784,52785,52786,52787,52788,52789,52790,52791,52792,52793,52794,52795,52796,52797,52798,52799,52800,
52801,52802,52803,52804,52805,52806,52807,52808,52809,52810,52811,52812,52813,52814,52815,52816,52817,52818,52819,52820,52821,52822,52823,52824,52825,52826,52827,52828,52829,52830,52831,52832,52833,52834,52836,52837,52838,52839,52840,52841,52842,52843,52844,52845,52846,52847,52848,52849,52850,52851,
52852,52853,52854,52855,52856,52857,52858,52859,52860,52861,52862,52863,52864,52865,52866,52867,52868,52869,52870,52871,52872,52873,52874,52875,52876,52877,52878,52879,52880,52881,52882,52883,52884,52885,52886,52887,52888,52889,52890,52891,52892,52893,52894,52895,52896,52897,52898,52899,52900,52901,
52902,52903,52904,52905,52906,52907,52908,52909,52910,52911,52912,52913,52914,52915,52916,52917,52918,52919,52920,52921,52922,52923,52924,52925,52926,52927,52928,52929,52930,52931,52932,52933,52934,52935,52936,52937,52938,52939,52940,52941,52942,52943,52944,52945,52946,52947,52948,52949,52950,52951,
52952,52953,52954,52955,52956,52957,52958,52959,52960,52961,52962,52963,52964,52965,52966,52967,52968,52969,52970,52971,52972,52973,52974,52975,52976,52977,52978,52979,52980,52981,52982,52983,52984,52985,52986,52987,52988,52989,52990,52991,52992,52993,52994,52995,52996,52997,52998,52999,53000,53001,
53002,53003,53004,53005,53006,53007,53008,53009,53010,53011,53012,53013,53014,53015,53016,53017,53018,53019,53020,53021,53022,53023,53024,53025,53026,53027,53028,53029,53030,53031,53032,53033,53034,53035,53036,53037,53038,53039,53040,53041,53042,53043,53044,53045,53046,53047,53049,53050,53051,53052,
53053,53054,53057,53058,53059,53060,53061,53062,53063,53064,53065,53066,53067,53068,53069,53070,53071,53072,53073,53074,53075,53076,53077,53078,53079,53080,53081,53082,53083,53084,53085,53086,53087,53088,53089,53090,53091,53092,53093,53094,53095,53098,53099,53100,53101,53102,53104,53105,53106,53107,
53108,53109,53120,53122,53123,53124,53128,53130,53131,53135,53136,53137,53138,53139,53140,53141,53142,53143,53144,53145,53146,53147,53148,53149,53150,53151,53152,53153,53154,53155,53156,53157,53158,53159,53160,53161,53162,53163,53164,53165,53166,53167,53168,53169,53170,53171,53172,53173,53174,53175,
53176,53177,53178,53179,53180,53181,53182,53183,53184,53185,53186,53187,53188,53189,53190,53191,53192,53193,53194,53195,53196,53197,53198,53199,53200,53201,53202,53203,53204,53205,53206,53207,53208,53209,53210,53211,53212,53213,53214,53215,53216,53217,53218,53219,53220,53221,53222,53223,53224,53225,
53226,53227,53228,53229,53230,53231,53232,53233,53234,53235,53236,53237,53238,53239,53240,53241,53242,53243,53244,53245,53246,53247,53248,53249,53250,53251,53252,53253,53254,53255,53256,53257,53258,53259,53260,53261,53262,53263,53264,53265,53266,53267,53268,53269,53270,53271,53272,53273,53274,53275,
53276,53277,53278,53279,53280,53281,53282,53283,53284,53285,53286,53287,53288,53289,53290,53291,53292,53293,53294,53295,53296,53297,53298,53299,53300,53301,53302,53303,53304,53305,53306,53307,53308,53309,53310,53311,53312,53313,53314,53315,53316,53317,53318,53319,53320,53321,53322,53323,53324,53325,
53326,53327,53328,53329,53330,53331,53332,53333,53334,53335,53336,53337,53338,53339,53340,53341,53342,53343,53344,53345,53346,53347,53348,53349,53350,53351,53352,53353,53354,53355,53356,53357,53358,53359,53360,53361,53362,53363,53364,53365,53366,53367,53368,53369,53370,53371,53372,53373,53374,53375,
53376,53377,53378,53379,53380,53381,53382,53383,53384,53385,53386,53387,53388,53389,53390,53391,53392,53393,53394,53395,53396,53397,53398,53399,53400,53401,53402,53403,53404,53405,53406,53407,53408,53409,53410,53411,53412,53413,53414,53415,53416,53417,53418,53419,53420,53421,53422,53423,53424,53425,
53426,53427,53428,53429,53430,53431,53432,53433,53434,53435,53436,53437,53438,53439,53440,53441,53442,53443,53444,53445,53446,53447,53448,53449,53450,53451,53452,53453,53454,53455,53456,53457,53458,53459,53460,53461,53462,53463,53464,53465,53466,53467,53468,53469,53470,53471,53472,53478,53479,53480,
53481,53482,53483,53484,53485,53511,53512,53513,53514,53515,53516,53517,53518,53519,53520,53521,53522,53523,53524,53525,53526,53527,53528,53529,53530,53531,53532,53533,53534,53535,53536,53537,53538,53539,53540,53541,53542,53543,53544,53545,53546,53547,53548,53549,53550,53551,53552,53553,53554,53555,
53556,53557,53558,53559,53560,53561,53562,53563,53564,53565,53566,53567,53568,53569,53570,53571,53572,53573,53574,53575,53576,53577,53578,53579,53580,53581,53582,53583,53584,53585,53586,53587,53588,53589,53590,53591,53592,53593,53594,53595,53596,53597,53598,53599,53600,53601,53602,53603,53604,53605,
53606,53607,53608,53609,53610,53611,53612,53613,53614,53615,53616,53617,53618,53619,53620,53621,53622,53623,53624,53625,53626,53627,53628,53629,53630,53631,53632,53633,53634,53635,53636,53638,53639,53640,53642,53643,53644,53645,53646,53647,53648,53649,53650,53651,53652,53653,53654,53655,53656,53657,
53658,53659,53660,53661,53662,53663,53664,53665,53666,53667,53668,53669,53670,53671,53672,53673,53674,53675,53676,53677,53678,53679,53680,53681,53682,53683,53684,53685,53686,53687,53688,53689,53690,53691,53692,53693,53694,53695,53696,53697,53698,53699,53700,53701,53702,53703,53704,53705,53706,53707,
53708,53709,53710,53711,53712,53713,53714,53715,53716,53717,53718,53719,53720,53721,53722,53723,53724,53725,53726,53727,53728,53729,53730,53731,53732,53733,53734,53735,53736,53737,53738,53739,53740,53741,53742,53743,53744,53745,53746,53747,53748,53749,53750,53751,53752,53753,53754,53755,53756,53757,
53758,53759,53760,53761,53762,53763,53764,53765,53766,53767,53768,53769,53770,53771,53772,53773,53774,53775,53776,53777,53778,53779,53780,53781,53782,53783,53784,53786,53787,53788,53789,53790,53791,53792,53793,53794,53795,53796,53797,53798,53799,53800,53801,53802,53803,53804,53805,53806,53807,53808,
53809,53810,53811,53812,53813,53814,53815,53816,53817,53818,53819,53820,53821,53822,53823,53824,53825,53826,53827,53828,53829,53830,53831,53832,53833,53834,53836,53837,53838,53839,53840,53841,53842,53843,53844,53845,53846,53847,53848,53849,53850,53851,53852,53853,53854,53855,53856,53857,53858,53859,
53860,53861,53862,53863,53864,53865,53866,53867,53868,53869,53870,53871,53872,53873,53874,53875,53876,53877,53878,53879,53880,53881,53882,53883,53884,53885,53886,53887,53888,53892,53893,53894,53895,53896,53897,53898,53899,53900,53901,53902,53903,53904,53905,53906,53907,53908,53909,53910,53911,53912,
53913,53914,53915,53916,53917,53918,53919,53920,53921,53922,53923,53925,53926,53927,53928,53929,53930,53931,53932,53939,53940,53941,53942,53943,53944,53945,53946,53947,53948,53949,53950,53951,53952,53953,53954,53955,53956,53957,53958,53959,53960,53961,53962,53964,53965,53966,53967,53968,53969,53970,
53971,53972,53973,53974,53975,53976,53977,53978,53979,53980,53981,53982,53983,53984,53985,53986,53987,53988,53989,53990,53991,53992,53993,53994,53995,53996,53997,53998,53999,54000,54001,54002,54003,54004,54005,54006,54007,54008,54009,54010,54011,54012,54013,54014,54015,54016,54017,54018,54019,54020,
54021,54022,54023,54024,54025,54026,54027,54028,54029,54030,54031,54032,54033,54034,54035,54036,54037,54038,54039,54040,54041,54042,54043,54044,54045,54046,54047,54048,54049,54050,54051,54052,54053,54054,54055,54056,54057,54058,54059,54060,54061,54062,54063,54064,54065,54066,54067,54070,54071,54072,
54073,54074,54075,54076,54077,54078,54079,54080,54081,54082,54083,54084,54085,54086,54087,54088,54089,54090,54091,54092,54093,54094,54095,54096,54097,54098,54099,54100,54101,54102,54103,54104,54105,54106,54107,54108,54109,54110,54111,54112,54113,54114,54115,54116,54117,54118,54119,54120,54121,54122,
54123,54124,54125,54126,54127,54128,54129,54130,54131,54132,54133,54134,54135,54136,54137,54138,54139,54140,54141,54142,54143,54144,54145,54146,54147,54148,54149,54150,54151,54152,54153,54154,54155,54156,54157,54158,54159,54160,54161,54162,54163,54164,54165,54166,54167,54168,54169,54170,54171,54172,
54173,54174,54175,54176,54177,54178,54179,54180,54181,54182,54183,54184,54185,54186,54187,54188,54189,54190,54191,54192,54193,54194,54195,54196,54197,54198,54199,54200,54201,54202,54203,54204,54205,54206,54207,54208,54209,54210,54211,54213,54214,54216,54217,54219,54220,54221,54222,54223,54224,54225,
54226,54227,54228,54229,54230,54231,54232,54233,54234,54235,54236,54237,54238,54239,54240,54241,54242,54243,54244,54245,54246,54247,54248,54249,54250,54251,54252,54253,54254,54255,54256,54257,54258,54259,54260,54261,54262,54263,54264,54265,54266,54267,54268,54269,54270,54271,54272,54273,54274,54275,
54276,54277,54278,54279,54280,54281,54282,54283,54284,54285,54286,54287,54288,54289,54290,54292,54293,54294,54295,54296,54297,54298,54299,54300,54301,54302,54303,54304,54305,54306,54307,54308,54309,54310,54311,54312,54313,54314,54315,54316,54317,54318,54319,54320,54321,54322,54323,54324,54325,54326,
54327,54328,54329,54330,54331,54332,54333,54334,54335,54336,54337,54338,54339,54340,54341,54342,54344,54345,54346,54347,54348,54349,54350,54351,54352,54353,54354,54355,54356,54357,54358,54359,54360,54361,54362,54363,54364,54365,54366,54367,54368,54369,54370,54371,54372,54373,54374,54375,54376,54377,
54378,54379,54380,54381,54382,54383,54384,54385,54386,54387,54388,54389,54390,54391,54392,54393,54394,54395,54396,54397,54398,54399,54400,54401,54402,54403,54404,54405,54406,54407,54408,54409,54410,54411,54412,54413,54414,54415,54416,54417,54418,54419,54420,54421,54422,54423,54424,54425,54426,54427,
54428,54429,54430,54431,54432,54433,54434,54435,54439,54440,54441,54442,54443,54444,54445,54446,54447,54448,54449,54450,54451,54453,54454,54456,54457,54458,54459,54460,54461,54462,54463,54464,54465,54466,54471,54472,54473,54474,54475,54476,54477,54478,54479,54480,54481,54482,54483,54484,54485,54486,
54487,54488,54489,54490,54491,54492,54493,54494,54495,54496,54497,54498,54499,54500,54501,54502,54503,54504,54505,54506,54507,54508,54509,54510,54511,54512,54513,54514,54515,54517,54518,54519,54520,54521,54522,54523,54524,54525,54526,54527,54528,54529,54530,54531,54532,54533,54534,54538,54539,54540,
54541,54542,54543,54544,54545,54546,54547,54548,54549,54550,54551,54552,54553,54554,54568,54570,54574,54575,54593,54594,54595,54596,54597,54598,54599,54600,54601,54602,54603,54604,54605,54606,54607,54608,54609,54610,54611,54613,54614,54615,54616,54618,54619,54620,54621,54622,54623,54624,54625,54626,
54627,54628,54629,54630,54631,54632,54633,54634,54635,54636,54638,54639,54640,54641,54642,54643,54644,54645,54646,54648,54649,54650,54652,54654,54655,54656,54657,54658,54659,54660,54661,54662,54663,54664,54665,54666,54667,54668,54669,54670,54671,54672,54673,54674,54675,54676,54677,54678,54679,54680,
54681,54682,54683,54684,54685,54686,54687,54688,54689,54690,54691,54692,54693,54694,54695,54696,54697,54698,54699,54700,54701,54702,54703,54704,54705,54706,54707,54708,54709,54710,54711,54712,54713,54714,54715,54716,54717,54718,54719,54720,54721,54722,54723,54724,54725,54726,54727,54728,54729,54730,
54731,54732,54733,54734,54735,54736,54737,54738,54739,54740,54741,54742,54743,54744,54745,54746,54747,54748,54749,54750,54751,54752,54753,54754,54755,54756,54757,54758,54759,54760,54761,54762,54763,54764,54765,54766,54767,54768,54769,54770,54771,54772,54773,54774,54775,54776,54777,54778,54779,54780,
54781,54782,54783,54784,54785,54786,54787,54788,54789,54790,54791,54792,54793,54794,54795,54796,54799,54800,54807,54808,54809,54812,54813,54814,54815,54816,54817,54818,54819,54820,54821,54823,54824,54825,54826,54827,54828,54829,54830,54831,54832,54833,54834,54835,54836,54837,54838,54839,54840,54841,
54842,54843,54844,54845,54846,54849,54850,54851,54852,54853,54854,54855,54856,54858,54859,54861,54862,54863,54864,54865,54866,54867,54868,54869,54870,54871,54872,54873,54874,54875,54876,54877,54878,54879,54880,54881,54882,54883,54884,54885,54886,54887,54888,54889,54890,54891,54892,54893,54894,54895,
54896,54897,54898,54899,54900,54901,54902,54903,54904,54905,54906,54907,54908,54909,54910,54911,54912,54913,54914,54915,54916,54917,54918,54919,54920,54921,54922,54923,54924,54925,54926,54927,54928,54929,54930,54931,54932,54933,54934,54935,54936,54937,54938,54939,54940,54941,54942,54943,54944,54945,
54946,54947,54948,54949,54950,54951,54952,54953,54954,54955,54956,54957,54958,54959,54960,54961,54962,54963,54964,54965,54966,54967,54968,54969,54970,54971,54972,54973,54974,54975,54976,54977,54978,54979,54980,54981,54982,54983,54984,54985,54986,54987,54988,54989,54990,54991,54992,54993,54994,54995,
54996,54997,54998,54999,55000,55001,55002,55003,55004,55005,55006,55007,55008,55009,55010,55011,55012,55013,55014,55015,55016,55017,55018,55019,55020,55021,55022,55023,55024,55025,55026,55027,55028,55029,55030,55031,55032,55033,55034,55035,55036,55037,55038,55039,55040,55041,55042,55043,55044,55045,
55046,55047,55048,55049,55050,55051,55052,55053,55054,55055,55056,55057,55058,55059,55060,55061,55062,55063,55064,55065,55066,55067,55068,55069,55070,55071,55072,55073,55074,55075,55076,55077,55078,55079,55080,55081,55082,55083,55084,55085,55086,55087,55088,55089,55090,55091,55092,55093,55094,55095,
55096,55097,55098,55099,55100,55101,55102,55103,55104,55105,55106,55107,55108,55109,55110,55111,55112,55113,55114,55115,55116,55117,55118,55119,55120,55121,55122,55123,55124,55125,55126,55127,55128,55129,55130,55131,55132,55133,55134,55135,55136,55137,55138,55139,55140,55141,55142,55143,55144,55145,
55146,55147,55148,55149,55150,55151,55152,55153,55154,55155,55156,55157,55158,55159,55160,55161,55162,55163,55164,55165,55166,55167,55168,55169,55170,55171,55172,55173,55174,55175,55176,55177,55178,55179,55180,55181,55182,55183,55184,55185,55186,55187,55188,55189,55190,55191,55192,55193,55194,55195,
55196,55197,55198,55199,55200,55201,55202,55203,55204,55205,55206,55207,55208,55209,55210,55211,55212,55213,55214,55215,55216,55217,55218,55219,55220,55221,55222,55223,55224,55225,55226,55227,55228,55229,55230,55231,55232,55233,55234,55235,55236,55237,55238,55239,55240,55241,55242,55243,55244,55245,
55246,55247,55248,55249,55250,55251,55252,55253,55254,55255,55256,55257,55258,55259,55260,55261,55262,55263,55264,55265,55266,55267,55268,55269,55270,55271,55272,55273,55274,55275,55276,55277,55278,55279,55280,55281,55282,55283,55284,55285,55286,55287,55288,55289,55290,55291,55292,55293,55294,55295,
55296,55297,55298,55299,55300,55301,55302,55303,55304,55305,55306,55307,55308,55309,55310,55311,55312,55313,55314,55315,55316,55317,55318,55319,55320,55321,55322,55323,55324,55325,55326,55327,55328,55329,55330,55331,55332,55333,55334,55335,55336,55337,55338,55339,55340,55341,55342,55343,55344,55345,
55346,55347,55348,55349,55350,55351,55352,55353,55354,55355,55356,55357,55358,55359,55360,55361,55362,55363,55364,55365,55366,55367,55368,55369,55370,55371,55372,55373,55374,55375,55376,55377,55378,55379,55380,55381,55382,55383,55384,55385,55386,55387,55388,55389,55390,55391,55392,55393,55394,55395,
55396,55397,55398,55399,55400,55401,55402,55403,55404,55405,55406,55407,55408,55409,55410,55411,55412,55413,55414,55415,55416,55417,55418,55419,55420,55421,55422,55423,55424,55425,55426,55427,55428,55429,55430,55431,55432,55433,55434,55435,55436,55437,55438,55439,55440,55441,55442,55443,55444,55445,
55446,55447,55448,55449,55450,55451,55452,55453,55454,55455,55456,55457,55458,55459,55460,55461,55462,55463,55464,55465,55466,55467,55468,55469,55470,55471,55472,55473,55474,55475,55476,55477,55478,55479,55480,55481,55482,55483,55484,55485,55486,55487,55488,55489,55490,55491,55492,55493,55494,55495,
55496,55497,55498,55499,55500,55501,55502,55503,55504,55505,55506,55507,55508,55509,55510,55511,55512,55513,55514,55515,55516,55517,55518,55519,55520,55521,55522,55523,55524,55525,55526,55527,55528,55529,55530,55531,55532,55533,55534,55535,55536,55537,55538,55539,55540,55541,55542,55543,55544,55545,
55546,55547,55548,55549,55550,55551,55552,55553,55554,55555,55556,55557,55558,55559,55560,55561,55562,55563,55564,55565,55566,55567,55568,55569,55570,55571,55572,55573,55574,55575,55576,55577,55578,55579,55580,55581,55582,55583,55584,55585,55586,55587,55588,55589,55590,55591,55592,55593,55594,55595,
55596,55597,55598,55599,55600,55601,55602,55603,55604,55605,55606,55607,55608,55609,55610,55611,55612,55613,55614,55615,55616,55617,55618,55619,55620,55621,55622,55623,55624,55625,55626,55627,55628,55629,55630,55631,55632,55633,55634,55635,55636,55637,55638,55639,55640,55641,55642,55643,55644,55645,
55646,55647,55648,55649,55650,55651,55652,55653,55654,55655,55656,55657,55658,55659,55660,55661,55662,55663,55664,55665,55666,55667,55668,55669,55670,55671,55672,55673,55674,55675,55676,55677,55678,55679,55680,55681,55682,55683,55684,55685,55686,55687,55688,55689,55690,55691,55692,55693,55694,55695,
55696,55697,55698,55699,55700,55701,55702,55703,55704,55705,55706,55707,55708,55709,55710,55711,55712,55713,55714,55715,55716,55717,55718,55719,55720,55721,55722,55723,55724,55725,55726,55727,55728,55729,55730,55731,55732,55733,55734,55735,55736,55737,55738,55739,55740,55741,55742,55743,55744,55745,
55746,55747,55748,55749,55750,55751,55752,55753,55754,55755,55756,55757,55758,55759,55760,55761,55762,55763,55764,55765,55766,55767,55768,55769,55770,55771,55772,55773,55774,55775,55776,55777,55778,55779,55780,55781,55782,55783,55784,55785,55786,55787,55788,55789,55790,55791,55792,55793,55794,55795,
55796,55797,55798,55799,55800,55801,55802,55803,55804,55805,55806,55807,55808,55809,55810,55811,55812,55813,55814,55815,55816,55817,55818,55819,55820,55821,55822,55823,55824,55825,55826,55827,55828,55829,55830,55831,55832,55833,55834,55835,55836,55837,55838,55839,55840,55841,55842,55843,55844,55845,
55846,55847,55848,55849,55850,55851,55852,55853,55854,55855,55856,55857,55858,55859,55860,55861,55862,55863,55864,55865,55866,55867,55868,55869,55870,55871,55872,55873,55874,55875,55876,55877,55878,55879,55880,55881,55882,55883,55884,55885,55886,55887,55888,55889,55890,55891,55892,55893,55894,55895,
55896,55897,55898,55899,55900,55901,55902,55903,55904,55905,55906,55907,55908,55909,55910,55911,55912,55913,55914,55915,55916,55917,55918,55919,55920,55921,55922,55923,55924,55925,55926,55927,55928,55929,55930,55931,55932,55933,55934,55935,55936,55937,55938,55939,55940,55941,55942,55943,55944,55945,
55946,55947,55948,55949,55950,55951,55952,55953,55954,55955,55956,55957,55958,55959,55960,55961,55962,55963,55964,55965,55966,55967,55968,55969,55970,55971,55972,55973,55974,55975,55976,55977,55978,55979,55980,55981,55982,55983,55984,55985,55986,55987,55988,55989,55990,55991,55992,55993,55994,55995,
55996,55997,55998,55999,56000,56001,56002,56003,56004,56005,56006,56007,56008,56009,56010,56011,56012,56013,56014,56015,56016,56017,56018,56019,56020,56021,56022,56023,56024,56025,56026,56027,56028,56029,56030,56031,56032,56033,56034,56035,56036,56037,56038,56039,56040,56041,56042,56043,56044,56045,
56046,56047,56048,56049,56050,56051,56052,56053,56054,56055,56056,56057,56058,56059,56060,56061,56062,56063,56064,56065,56066,56067,56068,56069,56070,56071,56072,56073,56074,56075,56076,56077,56078,56079,56080,56081,56082,56083,56084,56085,56086,56087,56088,56089,56090,56091,56092,56093,56094,56095,
56096,56097,56098,56099,56100,56101,56102,56103,56104,56105,56106,56107,56108,56109,56110,56111,56112,56113,56114,56115,56116,56117,56118,56119,56120,56121,56122,56123,56124,56125,56126,56127,56128,56129,56130,56131,56132,56133,56134,56135,56136,56137,56138,56139,56140,56141,56142,56143,56144,56145,
56146,56147,56148,56149,56150,56151,56152,56153,56154,56155,56156,56157,56158,56159,56160,56161,56162,56163,56164,56165,56166,56167,56168,56169,56170,56171,56172,56173,56174,56175,56176,56177,56178,56179,56180,56181,56182,56183,56184,56185,56186,56187,56188,56189,56190,56191,56192,56193,56194,56195,
56196,56197,56198,56199,56200,56201,56202,56203,56204,56205,56206,56207,56208,56209,56210,56211,56212,56213,56214,56215,56216,56217,56218,56219,56220,56221,56222,56223,56224,56225,56226,56227,56228,56229,56230,56231,56232,56233,56234,56235,56236,56237,56238,56239,56240,56241,56242,56243,56244,56245,
56246,56247,56248,56249,56250,56251,56252,56253,56254,56255,56256,56257,56258,56259,56260,56261,56262,56263,56264,56265,56266,56267,56268,56269,56270,56271,56272,56273,56274,56275,56276,56277,56278,56279,56280,56281,56282,56283,56284,56285,56286,56287,56288,56289,56290,56291,56292,56293,56294,56295,
56296,56297,56298,56299,56300,56301,56302,56303,56304,56305,56306,56307,56308,56309,56310,56311,56312,56313,56314,56315,56316,56317,56318,56319,56320,56321,56322,56323,56324,56325,56326,56327,56328,56329,56330,56331,56332,56333,56334,56335,56336,56337,56338,56339,56340,56341,56342,56343,56344,56345,
56346,56347,56348,56349,56350,56351,56352,56353,56354,56355,56356,56357,56358,56359,56360,56361,56362,56363,56364,56365,56366,56367,56368,56369,56370,56371,56372,56373,56374,56375,56376,56377,56378,56379,56380,56381,56382,56383,56384,56385,56386,56387,56388,56389,56390,56391,56392,56393,56394,56395,
56396,56397,56398,56399,56400,56401,56402,56403,56404,56405,56406,56407,56408,56409,56410,56411,56412,56413,56414,56415,56416,56417,56418,56419,56420,56421,56422,56423,56424,56425,56426,56427,56428,56429,56430,56431,56432,56433,56434,56435,56436,56437,56438,56439,56440,56441,56442,56443,56444,56445,
56446,56447,56448,56449,56450,56451,56452,56453,56454,56455,56456,56457,56458,56459,56460,56461,56462,56463,56464,56465,56466,56467,56468,56469,56470,56471,56472,56473,56474,56475,56476,56477,56478,56479,56480,56481,56482,56483,56484,56485,56486,56487,56488,56489,56490,56491,56492,56493,56494,56495,
56496,56497,56498,56499,56500,56501,56502,56503,56504,56505,56506,56507,56508,56509,56510,56511,56512,56513,56514,56515,56516,56517,56518,56519,56520,56521,56522,56523,56524,56525,56526,56527,56528,56529,56530,56531,56532,56533,56534,56535,56536,56537,56538,56539,56540,56541,56542,56543,56544,56545,
56546,56547,56548,56549,56550,56551,56552,56553,56554,56555,56556,56557,56558,56559,56560,56561,56562,56563,56564,56565,56566,56567,56568,56569,56570,56571,56572,56573,56574,56575,56576,56577,56578,56579,56580,56581,56582,56583,56584,56585,56586,56587,56588,56589,56590,56591,56592,56593,56594,56595,
56596,56597,56598,56599,56600,56601,56602,56603,56604,56605,56606,56607,56608,56609,56610,56611,56612,56613,56614,56615,56616,56617,56618,56619,56620,56621,56622,56623,56624,56625,56626,56627,56628,56629,56630,56631,56632,56633,56634,56635,56636,56637,56638,56639,56640,56641,56642,56643,56644,56645,
56646,56647,56648,56649,56650,56651,56652,56653,56654,56655,56656,56657,56658,56659,56660,56661,56662,56663,56664,56665,56666,56667,56668,56669,56670,56671,56672,56673,56674,56675,56676,56677,56678,56679,56680,56681,56682,56683,56684,56685,56686,56687,56688,56689,56690,56691,56692,56693,56694,56695,
56696,56697,56698,56699,56700,56701,56702,56703,56704,56705,56706,56707,56708,56709,56710,56711,56712,56713,56714,56715,56716,56717,56718,56719,56720,56721,56722,56723,56724,56725,56726,56727,56728,56729,56730,56731,56732,56733,56734,56735,56736,56737,56738,56739,56740,56741,56742,56743,56744,56745,
56746,56747,56748,56749,56750,56751,56752,56753,56754,56755,56756,56757,56758,56759,56760,56761,56762,56763,56764,56765,56766,56767,56768,56769,56770,56771,56772,56773,56774,56775,56776,56777,56778,56779,56780,56781,56782,56783,56784,56785,56786,56787,56788,56789,56790,56791,56792,56793,56794,56795,
56796,56797,56798,56799,56800,56801,56802,56803,56804,56805,56807,56808,56809,56810,56811,56812,56813,56814,56815,56816,56817,56818,56819,56820,56821,56822,56823,56824,56825,56826,56827,56828,56829,56830,56831,56832,56833,56834,56835,56836,56837,56838,56839,56840,56841,56842,56843,56844,56845,56846,
56847,56848,56849,56850,56851,56852,56853,56854,56855,56856,56857,56858,56859,56860,56861,56862,56863,56864,56865,56866,56867,56868,56869,56870,56871,56872,56873,56874,56875,56876,56877,56878,56879,56880,56881,56882,56883,56884,56885,56886,56887,56888,56889,56890,56891,56892,56893,56894,56895,56896,
56897,56898,56899,56900,56901,56902,56903,56904,56905,56906,56907,56908,56909,56910,56911,56912,56913,56914,56915,56916,56917,56918,56919,56920,56921,56922,56923,56924,56925,56926,56927,56928,56929,56930,56931,56932,56933,56934,56935,56936,56937,56938,56939,56940,56941,56942,56943,56944,56945,56946,
56947,56948,56949,56950,56951,56952,56953,56954,56955,56956,56957,56958,56959,56960,56961,56962,56963,56964,56965,56966,56967,56968,56969,56970,56971,56972,56973,56974,56975,56976,56977,56978,56979,56980,56981,56982,56983,56984,56985,56986,56987,56988,56989,56990,56991,56992,56993,56994,56995,56996,
56997,56998,56999,57000,57001,57002,57003,57004,57005,57006,57007,57008,57009,57010,57011,57012,57013,57014,57015,57016,57017,57018,57019,57020,57021,57022,57023,57024,57025,57026,57027,57028,57029,57030,57031,57032,57033,57034,57035,57036,57037,57038,57039,57040,57041,57042,57043,57044,57045,57046,
57047,57048,57049,57050,57051,57052,57053,57054,57055,57056,57057,57058,57059,57060,57061,57062,57063,57064,57065,57066,57067,57068,57069,57070,57071,57072,57073,57074,57075,57076,57077,57078,57079,57080,57081,57082,57083,57084,57085,57086,57087,57088,57089,57090,57091,57092,57093,57094,57095,57096,
57097,57098,57099,57100,57101,57102,57103,57104,57105,57106,57107,57108,57109,57110,57111,57112,57113,57114,57115,57116,57117,57118,57119,57120,57121,57122,57123,57124,57125,57126,57127,57128,57129,57130,57131,57132,57133,57134,57135,57136,57137,57138,57139,57140,57141,57142,57143,57144,57145,57146,
57147,57148,57149,57150,57151,57152,57153,57154,57155,57156,57157,57158,57159,57160,57161,57162,57163,57164,57165,57166,57167,57168,57169,57170,57171,57172,57173,57174,57175,57176,57177,57178,57179,57180,57181,57182,57183,57184,57185,57186,57187,57188,57189,57190,57191,57192,57193,57194,57195,57196,
57197,57198,57199,57200,57201,57202,57203,57204,57205,57206,57207,57208,57209,57210,57211,57212,57213,57214,57215,57216,57217,57218,57219,57220,57221,57222,57223,57224,57225,57226,57227,57228,57229,57230,57231,57232,57233,57234,57235,57236,57237,57238,57239,57240,57241,57242,57243,57244,57245,57246,
57247,57248,57249,57250,57251,57252,57253,57254,57255,57256,57257,57258,57259,57260,57261,57262,57263,57264,57265,57266,57267,57268,57269,57270,57271,57272,57273,57274,57275,57276,57277,57278,57279,57280,57281,57282,57283,57284,57285,57286,57287,57288,57289,57290,57291,57292,57293,57294,57295,57296,
57297,57298,57299,57300,57301,57302,57303,57304,57305,57306,57307,57308,57309,57310,57311,57312,57313,57314,57315,57316,57317,57318,57319,57320,57321,57322,57323,57324,57325,57326,57327,57328,57329,57330,57331,57332,57333,57334,57335,57336,57337,57338,57339,57340,57341,57342,57343,57344,57345,57346,
57347,57348,57349,57350,57351,57352,57353,57354,57355,57356,57357,57358,57359,57360,57361,57362,57363,57364,57365,57366,57367,57368,57369,57370,57371,57372,57373,57374,57375,57376,57377,57378,57379,57380,57381,57382,57383,57384,57385,57386,57387,57388,57389,57390,57391,57392,57393,57394,57395,57396,
57397,57398,57399,57400,57401,57402,57403,57404,57405,57406,57407,57408,57409,57410,57411,57412,57413,57414,57415,57416,57417,57418,57419,57420,57421,57422,57423,57424,57425,57426,57427,57428,57429,57430,57431,57432,57433,57434,57435,57436,57437,57438,57439,57440,57441,57442,57443,57444,57445,57446,
57447,57448,57449,57450,57451,57452,57453,57454,57455,57456,57457,57458,57459,57460,57461,57462,57463,57464,57465,57466,57467,57468,57469,57470,57471,57472,57473,57474,57475,57476,57477,57478,57479,57480,57481,57482,57483,57484,57485,57486,57487,57488,57489,57490,57491,57492,57493,57494,57495,57496,
57497,57498,57499,57500,57501,57502,57503,57504,57505,57506,57507,57508,57509,57510,57511,57512,57513,57514,57515,57516,57517,57518,57519,57520,57521,57522,57523,57524,57525,57526,57527,57528,57529,57530,57531,57532,57533,57534,57535,57536,57537,57538,57539,57540,57541,57542,57543,57544,57545,57546,
57547,57548,57549,57550,57551,57552,57553,57554,57555,57556,57557,57558,57559,57560,57561,57562,57563,57564,57565,57566,57567,57568,57569,57570,57571,57572,57573,57574
}

-- Static tables of ItemRandomPropeties.dbc and ItemRandomSuffix.dbc to assign enchant IDs to random property items
-- There's currently no convenient way for Eluna to get this information the core as it's set by dbc files. For servers that don't have the dbc files database-loaded, we need to have a cached table for reference. 
-- We don't really need InternalName here but it's useful to debug why a random suffix may have the wrong stats for the item in question.
local ItemRandomSuffix = { -- 48 is a paladin test ID, and 94-98 are related to Darkmoon Faire, removed.
    [5] = {InternalName = "Monkey", Enchantment = {2802, 2803, 0, 0, 0}}, 			 [6] = {InternalName = "Eagle", Enchantment = {2804, 2803, 0, 0, 0}},
    [7] = {InternalName = "Bear", Enchantment = {2803, 2805, 0, 0, 0}},				 [8] = {InternalName = "Whale", Enchantment = {2806, 2803, 0, 0, 0}},
    [9] = {InternalName = "Owl", Enchantment = {2804, 2806, 0, 0, 0}}, 				 [10] = {InternalName = "Gorilla", Enchantment = {2804, 2805, 0, 0, 0}},
    [11] = {InternalName = "Falcon", Enchantment = {2802, 2804, 0, 0, 0}}, 			 [12] = {InternalName = "Boar", Enchantment = {2806, 2805, 0, 0, 0}},
    [13] = {InternalName = "Wolf", Enchantment = {2802, 2806, 0, 0, 0}}, 			 [14] = {InternalName = "Tiger", Enchantment = {2802, 2805, 0, 0, 0}},
    [15] = {InternalName = "Spirit", Enchantment = {2806, 0, 0, 0, 0}}, 			 [16] = {InternalName = "Stamina", Enchantment = {2803, 0, 0, 0, 0}},
    [17] = {InternalName = "Strength", Enchantment = {2805, 0, 0, 0, 0}}, 			 [18] = {InternalName = "Agility", Enchantment = {2802, 0, 0, 0, 0}},
    [19] = {InternalName = "Intellect", Enchantment = {2804, 0, 0, 0, 0}}, 			 [20] = {InternalName = "Power", Enchantment = {2825, 0, 0, 0, 0}},
    [21] = {InternalName = "Arcane Wrath (SP)", Enchantment = {2824, 0, 0, 0, 0}},	 [22] = {InternalName = "Fiery Wrath (SP)", Enchantment = {2824, 0, 0, 0, 0}},
    [23] = {InternalName = "Frozen Wrath (SP)", Enchantment = {2824, 0, 0, 0, 0}}, 	 [24] = {InternalName = "Nature's Wrath (SP)", Enchantment = {2824, 0, 0, 0, 0}},
    [25] = {InternalName = "Shadow Wrath (SP)", Enchantment = {2824, 0, 0, 0, 0}}, 	 [26] = {InternalName = "Spell Power", Enchantment = {2824, 0, 0, 0, 0}},
	[27] = {InternalName = "Defense", Enchantment = {2813, 0, 0, 0, 0}}, 			 [28] = {InternalName = "Regeneration", Enchantment = {2814, 0, 0, 0, 0}},
	[29] = {InternalName = "Eluding", Enchantment = {2815, 2802, 0, 0, 0}},			 [30] = {InternalName = "Concentration", Enchantment = {2816, 0, 0, 0, 0}},
	[31] = {InternalName = "Arcane Protection", Enchantment = {2803, 2817, 0, 0, 0}},[32] = {InternalName = "Fire Protection", Enchantment = {2803, 2818, 0, 0, 0}},
	[33] = {InternalName = "Frost Protection", Enchantment = {2803, 2819, 0, 0, 0}}, [34] = {InternalName = "Nature Protection", Enchantment = {2803, 2820, 0, 0, 0}},
	[35] = {InternalName = "Shadow Protection", Enchantment = {2803, 2821, 0, 0, 0}},[36] = {InternalName = "Sorcerer", Enchantment = {2803, 2804, 2824, 0, 0}},
	[37] = {InternalName = "Physician", Enchantment = {2803, 2804, 2824, 0, 0}},     [38] = {InternalName = "Prophet", Enchantment = {2804, 2806, 2824, 0, 0}},
	[39] = {InternalName = "Invoker", Enchantment = {2804, 2824, 2822, 0, 0}}, 	     [40] = {InternalName = "Bandit", Enchantment = {2802, 2803, 2825, 0, 0}},
	[41] = {InternalName = "Beast", Enchantment = {2805, 2802, 2803, 0, 0}},     	 [42] = {InternalName = "Hierophant", Enchantment = {2803, 2806, 2824, 0, 0}},
    [43] = {InternalName = "Soldier", Enchantment = {2805, 2803, 2823, 0, 0}},       [44] = {InternalName = "Elder", Enchantment = {2803, 2804, 2816, 0, 0}},
    [45] = {InternalName = "Champion", Enchantment = {2805, 2803, 2813, 0, 0}},      [46] = {InternalName = "Test", Enchantment = {2798, 2799, 2800, 2802, 2806}},
    [47] = {InternalName = "Blocking", Enchantment = {2826, 2805, 0, 0, 0}},    	 --[[48 is a test suffix, skipping]]
	[49] = {InternalName = "Grove", Enchantment = {2805, 2802, 2803, 0, 0}},		 [50] = {InternalName = "Hunt", Enchantment = {2825, 2802, 2804, 0, 0}},    		 
    [51] = {InternalName = "Mind", Enchantment = {2824, 2822, 2804, 0, 0}},			 [52] = {InternalName = "Crusade", Enchantment = {2824, 2804, 2813, 0, 0}},
	[53] = {InternalName = "Vision", Enchantment = {2824, 2804, 2803, 0, 0}},		 [54] = {InternalName = "Ancestor", Enchantment = {2805, 2823, 2803, 0, 0}},
	[55] = {InternalName = "Nightmare", Enchantment = {2811, 2803, 2804, 0, 0}},     [56] = {InternalName = "Battle", Enchantment = {2805, 2803, 2823, 0, 0}},
	[57] = {InternalName = "Shadow", Enchantment = {2825, 2802, 2803, 0, 0}},        [58] = {InternalName = "Sun", Enchantment = {2824, 2803, 2804, 0, 0}},
	[59] = {InternalName = "Moon", Enchantment = {2804, 2803, 2806, 0, 0}},		     [60] = {InternalName = "Wild", Enchantment = {2825, 2803, 2802, 0, 0}},
	[61] = {InternalName = "Spell Power (Resist)", Enchantment = {2824, 0, 0, 0, 0}},[62] = {InternalName = "Strength resistance", Enchantment = {2805, 0, 0, 0, 0}},
	[63] = {InternalName = "Agility (resistance)", Enchantment = {2802, 0, 0, 0, 0}},[64] = {InternalName = "Power (resistance)", Enchantment = {2825, 0, 0, 0, 0}},
	[65] = {InternalName = "Magic (resistance)", Enchantment = {2824, 0, 0, 0, 0}},  [66] = {InternalName = "Knight", Enchantment = {2803, 2813, 2824, 0, 0}},
	[67] = {InternalName = "Seer", Enchantment = {2803, 2822, 2824, 0, 0}},		     [68] = {InternalName = "Bear (<60)", Enchantment = {2805, 2803, 0, 0, 0}},
	[69] = {InternalName = "Eagle (<60)", Enchantment = {2803, 2804, 0, 0, 0}},      [70] = {InternalName = "Ancestor (<60)", Enchantment = {2805, 2822, 2803, 0, 0}},
	[71] = {InternalName = "Bandit (<60)", Enchantment = {2802, 2803, 2825, 0, 0}},  [72] = {InternalName = "Battle (<60)", Enchantment = {2805, 2803, 2822, 0, 0}},
	[73] = {InternalName = "Elder (<60)", Enchantment = {2803, 2804, 2816, 0, 0}},   [74] = {InternalName = "Beast (<60)", Enchantment = {2805, 2802, 2803, 0, 0}},
	[75] = {InternalName = "Champion (<60)", Enchantment = {2805, 2803, 2813, 0, 0}}, --[[76 doesn't exist]]
	--[[77-79 don't exist]]															 [80] = {InternalName = "Wild (<60)", Enchantment = {2825, 2803, 2802, 0, 0}},
	[81] = {InternalName = "Whale (<60)", Enchantment = {2803, 2806, 0, 0, 0}},	     [82] = {InternalName = "Vision (<60)", Enchantment = {2824, 2804, 2803, 0, 0}},
	[83] = {InternalName = "Sun (<60)", Enchantment = {2824, 2803, 2804, 0, 0}},     [84] = {InternalName = "Stamina (<60)", Enchantment = {2803, 0, 0, 0, 0}},
	[85] = {InternalName = "Sorcerer (<60)", Enchantment = {2803, 2804, 2824, 0, 0}},[86] = {InternalName = "Soldier (<60)", Enchantment = {2805, 2803, 2822, 0, 0}},
	[87] = {InternalName = "Shadow (<60)", Enchantment = {2825, 2802, 2803, 0, 0}},  [88] = {InternalName = "Foreseer", Enchantment = {2804, 3726, 2824, 0, 0}},
	[89] = {InternalName = "Thief", Enchantment = {2803, 2825, 3726, 0, 0}},	     [90] = {InternalName = "Necromancer", Enchantment = {2803, 3727, 2824, 0, 0}},
	[91] = {InternalName = "Marksman", Enchantment = {2803, 2802, 3727, 0, 0}},	     [92] = {InternalName = "Squire", Enchantment = {2803, 3727, 2805, 0, 0}},
	[93] = {InternalName = "Restoration", Enchantment = {2803, 2824, 2816, 0, 0}},   [99] = {InternalName = "Haste", Enchantment = {3726, 0, 0, 0, 0}}
}

local ItemRandomProperties = {
	[5] = {79, 0, 0}, [6] = {68, 0, 0}, [14] = {74, 0, 0}, [15] = {71, 0, 0}, [16] = {82, 0, 0}, [17] = {75, 0, 0},
    [18] = {76, 0, 0}, [19] = {72, 0, 0}, [22] = {73, 0, 0}, [23] = {69, 0, 0}, [24] = {70, 0, 0}, [25] = {80, 0, 0},
    [26] = {81, 0, 0}, [27] = {83, 0, 0}, [28] = {84, 0, 0}, [29] = {85, 0, 0}, [30] = {87, 0, 0}, [31] = {86, 0, 0},
    [32] = {67, 0, 0}, [33] = {77, 0, 0}, [34] = {78, 0, 0}, [39] = {153, 0, 0}, [40] = {139, 0, 0}, [41] = {125, 0, 0},
    [42] = {160, 0, 0}, [43] = {146, 0, 0}, [44] = {132, 0, 0}, [45] = {181, 0, 0}, [46] = {167, 0, 0}, [47] = {174, 0, 0},
    [48] = {110, 0, 0}, [49] = {188, 0, 0}, [50] = {199, 0, 0}, [51] = {195, 0, 0}, [52] = {154, 0, 0}, [53] = {140, 0, 0},
    [54] = {126, 0, 0}, [56] = {161, 0, 0}, [57] = {147, 0, 0}, [58] = {133, 0, 0}, [59] = {182, 0, 0}, [60] = {168, 0, 0},
    [62] = {111, 0, 0}, [63] = {175, 0, 0}, [64] = {189, 0, 0}, [65] = {200, 0, 0}, [66] = {155, 0, 0}, [67] = {141, 0, 0},
    [68] = {127, 0, 0}, [69] = {162, 0, 0}, [70] = {148, 0, 0}, [71] = {134, 0, 0}, [72] = {183, 0, 0}, [73] = {169, 0, 0},
    [74] = {112, 0, 0}, [75] = {176, 0, 0}, [76] = {190, 0, 0}, [77] = {201, 0, 0}, [78] = {196, 0, 0}, [79] = {89, 0, 0},
    [80] = {117, 0, 0}, [81] = {156, 0, 0}, [82] = {142, 0, 0}, [83] = {128, 0, 0}, [84] = {163, 0, 0}, [85] = {149, 0, 0},
    [86] = {135, 0, 0}, [87] = {184, 0, 0}, [88] = {170, 0, 0}, [89] = {113, 0, 0}, [90] = {177, 0, 0}, [91] = {191, 0, 0},
    [92] = {202, 0, 0}, [93] = {90, 0, 0}, [94] = {94, 0, 0}, [95] = {98, 0, 0}, [96] = {102, 0, 0}, [97] = {106, 0, 0},
    [98] = {121, 0, 0}, [99] = {118, 0, 0}, [100] = {157, 0, 0}, [101] = {143, 0, 0}, [102] = {129, 0, 0}, [103] = {164, 0, 0},
    [104] = {150, 0, 0}, [105] = {136, 0, 0}, [106] = {185, 0, 0}, [107] = {171, 0, 0}, [108] = {114, 0, 0}, [109] = {178, 0, 0},
    [110] = {192, 0, 0}, [111] = {91, 0, 0}, [112] = {95, 0, 0}, [113] = {99, 0, 0}, [114] = {103, 0, 0}, [115] = {107, 0, 0},
    [116] = {197, 0, 0}, [117] = {200, 188, 110}, [118] = {122, 0, 0}, [119] = {119, 0, 0}, [120] = {158, 0, 0}, [121] = {144, 0, 0},
    [122] = {130, 0, 0}, [123] = {165, 0, 0}, [124] = {151, 0, 0}, [125] = {137, 0, 0}, [126] = {186, 0, 0}, [127] = {172, 0, 0},
    [128] = {115, 0, 0}, [129] = {179, 0, 0}, [130] = {193, 0, 0}, [131] = {204, 0, 0}, [132] = {92, 0, 0}, [133] = {96, 0, 0},
    [134] = {100, 0, 0}, [135] = {104, 0, 0}, [136] = {108, 0, 0}, [137] = {123, 0, 0}, [138] = {120, 0, 0}, [139] = {159, 0, 0},
    [140] = {145, 0, 0}, [141] = {131, 0, 0}, [142] = {166, 0, 0}, [143] = {152, 0, 0}, [144] = {138, 0, 0}, [145] = {187, 0, 0},
    [146] = {173, 0, 0}, [147] = {116, 0, 0}, [148] = {180, 0, 0}, [149] = {194, 0, 0}, [150] = {205, 0, 0}, [151] = {93, 0, 0},
    [152] = {97, 0, 0}, [153] = {101, 0, 0}, [154] = {105, 0, 0}, [155] = {109, 0, 0}, [156] = {198, 0, 0}, [167] = {343, 0, 0},
    [168] = {349, 0, 0}, [171] = {358, 0, 0}, [172] = {363, 0, 0}, [173] = {368, 0, 0}, [174] = {350, 0, 0}, [175] = {354, 0, 0},
    [176] = {359, 0, 0}, [177] = {364, 0, 0}, [178] = {369, 0, 0}, [179] = {351, 0, 0}, [180] = {355, 0, 0}, [181] = {360, 0, 0},
    [182] = {365, 0, 0}, [183] = {370, 0, 0}, [184] = {353, 0, 0}, [185] = {356, 0, 0}, [186] = {361, 0, 0}, [187] = {366, 0, 0},
    [188] = {371, 0, 0}, [189] = {352, 0, 0}, [190] = {357, 0, 0}, [191] = {362, 0, 0}, [192] = {367, 0, 0}, [193] = {372, 0, 0},
    [194] = {344, 0, 0}, [195] = {346, 0, 0}, [196] = {345, 0, 0}, [197] = {347, 0, 0}, [198] = {348, 0, 0}, [207] = {383, 0, 0},
    [210] = {384, 0, 0}, [211] = {403, 0, 0}, [212] = {404, 0, 0}, [213] = {405, 0, 0}, [214] = {406, 0, 0}, [215] = {407, 0, 0},
    [216] = {408, 0, 0}, [217] = {409, 0, 0}, [218] = {411, 0, 0}, [219] = {410, 0, 0}, [220] = {412, 0, 0}, [227] = {74, 79, 0},
    [228] = {74, 82, 0}, [229] = {75, 79, 0}, [231] = {74, 80, 0}, [232] = {75, 81, 0}, [233] = {76, 80, 0}, [234] = {76, 81, 0},
    [235] = {90, 81, 0}, [236] = {76, 94, 0}, [237] = {90, 95, 0}, [238] = {75, 80, 0}, [247] = {91, 95, 0}, [248] = {90, 94, 0},
    [249] = {91, 94, 0}, [250] = {91, 96, 0}, [251] = {92, 96, 0}, [252] = {92, 95, 0}, [253] = {92, 97, 0}, [254] = {93, 97, 0},
    [255] = {93, 96, 0}, [256] = {74, 83, 0}, [267] = {883, 0, 0}, [287] = {1068, 0, 0}, [307] = {684, 0, 0}, [308] = {1043, 0, 0},
    [309] = {1044, 0, 0}, [310] = {1045, 0, 0}, [311] = {1046, 0, 0}, [312] = {1047, 0, 0}, [313] = {1048, 0, 0}, [314] = {1049, 0, 0},
    [315] = {1050, 0, 0}, [316] = {1051, 0, 0}, [317] = {1052, 0, 0}, [318] = {1053, 0, 0}, [319] = {1054, 0, 0}, [320] = {1055, 0, 0},
    [321] = {1056, 0, 0}, [322] = {1057, 0, 0}, [323] = {1058, 0, 0}, [324] = {1059, 0, 0}, [325] = {1060, 0, 0}, [326] = {1061, 0, 0},
    [327] = {1062, 0, 0}, [328] = {1063, 0, 0}, [329] = {1064, 0, 0}, [330] = {1065, 0, 0}, [331] = {1066, 0, 0}, [332] = {1067, 0, 0},
    [333] = {1069, 0, 0}, [334] = {1070, 0, 0}, [335] = {1071, 0, 0}, [336] = {1072, 0, 0}, [337] = {1073, 0, 0}, [338] = {1074, 0, 0},
    [339] = {1075, 0, 0}, [340] = {1076, 0, 0}, [341] = {1077, 0, 0}, [342] = {1078, 0, 0}, [343] = {1079, 0, 0}, [344] = {1080, 0, 0},
    [345] = {1081, 0, 0}, [346] = {1082, 0, 0}, [347] = {1083, 0, 0}, [348] = {1084, 0, 0}, [349] = {1085, 0, 0}, [350] = {1086, 0, 0},
    [351] = {1087, 0, 0}, [352] = {1088, 0, 0}, [353] = {1089, 0, 0}, [354] = {1090, 0, 0}, [355] = {1091, 0, 0}, [356] = {1092, 0, 0},
    [357] = {1093, 0, 0}, [358] = {983, 0, 0}, [359] = {1094, 0, 0}, [360] = {1095, 0, 0}, [361] = {1096, 0, 0}, [362] = {1097, 0, 0},
    [363] = {1098, 0, 0}, [364] = {1099, 0, 0}, [365] = {1100, 0, 0}, [366] = {1101, 0, 0}, [367] = {1102, 0, 0}, [368] = {1103, 0, 0},
    [369] = {1104, 0, 0}, [370] = {1105, 0, 0}, [371] = {1106, 0, 0}, [372] = {1107, 0, 0}, [373] = {1108, 0, 0}, [374] = {1109, 0, 0},
    [375] = {1110, 0, 0}, [376] = {1111, 0, 0}, [377] = {1112, 0, 0}, [378] = {1113, 0, 0}, [379] = {1114, 0, 0}, [380] = {1115, 0, 0},
    [381] = {1116, 0, 0}, [382] = {1117, 0, 0}, [383] = {1118, 0, 0}, [384] = {1119, 0, 0}, [385] = {1120, 0, 0}, [386] = {1121, 0, 0},
    [387] = {1122, 0, 0}, [388] = {1123, 0, 0}, [389] = {1124, 0, 0}, [390] = {1125, 0, 0}, [391] = {1126, 0, 0}, [392] = {1127, 0, 0},
    [393] = {1128, 0, 0}, [394] = {1129, 0, 0}, [395] = {1130, 0, 0}, [396] = {1131, 0, 0}, [397] = {1132, 0, 0}, [398] = {1133, 0, 0},
    [399] = {1134, 0, 0}, [400] = {1135, 0, 0}, [401] = {1136, 0, 0}, [402] = {1137, 0, 0}, [403] = {1138, 0, 0}, [404] = {1139, 0, 0},
    [405] = {1140, 0, 0}, [406] = {1141, 0, 0}, [407] = {1142, 0, 0}, [408] = {1143, 0, 0}, [409] = {1144, 0, 0}, [410] = {1145, 0, 0},
    [411] = {1146, 0, 0}, [412] = {1147, 0, 0}, [413] = {1148, 0, 0}, [414] = {1149, 0, 0}, [415] = {1150, 0, 0}, [416] = {1151, 0, 0},
    [417] = {1152, 0, 0}, [418] = {1153, 0, 0}, [419] = {1154, 0, 0}, [420] = {1155, 0, 0}, [421] = {1156, 0, 0}, [422] = {1157, 0, 0},
    [423] = {1158, 0, 0}, [424] = {1159, 0, 0}, [425] = {1160, 0, 0}, [426] = {1161, 0, 0}, [427] = {1162, 0, 0}, [428] = {1163, 0, 0},
    [429] = {1164, 0, 0}, [430] = {1165, 0, 0}, [431] = {1166, 0, 0}, [432] = {1167, 0, 0}, [433] = {1168, 0, 0}, [434] = {1183, 0, 0},
    [435] = {343, 97, 0}, [436] = {93, 350, 0}, [437] = {343, 350, 0}, [438] = {349, 350, 0}, [439] = {343, 354, 0}, [440] = {349, 354, 0},
    [441] = {358, 354, 0}, [442] = {349, 359, 0}, [443] = {358, 359, 0}, [444] = {363, 359, 0}, [445] = {358, 364, 0}, [446] = {363, 364, 0},
    [447] = {368, 364, 0}, [448] = {363, 369, 0}, [449] = {368, 369, 0}, [450] = {403, 369, 0}, [451] = {368, 405, 0}, [452] = {403, 405, 0},
    [453] = {404, 405, 0}, [454] = {403, 406, 0}, [455] = {404, 406, 0}, [456] = {883, 406, 0}, [457] = {404, 1118, 0}, [458] = {883, 1118, 0},
    [459] = {983, 1118, 0}, [460] = {883, 1119, 0}, [461] = {983, 1119, 0}, [462] = {1094, 1119, 0}, [463] = {983, 1120, 0}, [464] = {1094, 1120, 0},
    [465] = {1095, 1120, 0}, [466] = {1094, 1121, 0}, [467] = {1095, 1121, 0}, [468] = {1096, 1121, 0}, [469] = {1095, 1122, 0}, [470] = {1096, 1122, 0},
    [471] = {1097, 1122, 0}, [472] = {1096, 1123, 0}, [473] = {1097, 1123, 0}, [474] = {1098, 1123, 0}, [475] = {1097, 1124, 0}, [476] = {1098, 1124, 0},
    [477] = {1099, 1124, 0}, [478] = {1098, 1125, 0}, [479] = {1099, 1125, 0}, [480] = {1100, 1125, 0}, [481] = {1099, 1126, 0}, [482] = {1100, 1126, 0},
    [483] = {1101, 1126, 0}, [484] = {1100, 1127, 0}, [485] = {1101, 1127, 0}, [486] = {1102, 1127, 0}, [487] = {1101, 1128, 0}, [488] = {1102, 1128, 0},
    [489] = {1103, 1128, 0}, [490] = {1102, 1129, 0}, [491] = {1103, 1129, 0}, [492] = {1104, 1129, 0}, [493] = {1103, 1130, 0}, [494] = {1104, 1130, 0},
    [495] = {1105, 1130, 0}, [496] = {1104, 1131, 0}, [497] = {1105, 1131, 0}, [498] = {1106, 1131, 0}, [499] = {1105, 1132, 0}, [500] = {1106, 1132, 0},
    [501] = {75, 82, 0}, [502] = {75, 83, 0}, [503] = {76, 83, 0}, [504] = {75, 84, 0}, [505] = {76, 84, 0}, [506] = {90, 84, 0},
    [507] = {76, 98, 0}, [508] = {90, 98, 0}, [509] = {91, 98, 0}, [510] = {90, 99, 0}, [511] = {91, 99, 0}, [512] = {92, 99, 0},
    [513] = {91, 100, 0}, [514] = {92, 100, 0}, [515] = {93, 100, 0}, [516] = {92, 101, 0}, [517] = {93, 101, 0}, [518] = {343, 101, 0},
    [519] = {93, 351, 0}, [520] = {343, 351, 0}, [521] = {349, 351, 0}, [522] = {343, 355, 0}, [523] = {349, 355, 0}, [524] = {358, 355, 0},
    [525] = {349, 360, 0}, [526] = {358, 360, 0}, [527] = {363, 360, 0}, [528] = {358, 365, 0}, [529] = {363, 365, 0}, [530] = {368, 365, 0},
    [531] = {363, 370, 0}, [532] = {368, 370, 0}, [533] = {403, 370, 0}, [534] = {368, 407, 0}, [535] = {403, 407, 0}, [536] = {404, 407, 0},
    [537] = {403, 408, 0}, [538] = {404, 408, 0}, [539] = {883, 408, 0}, [540] = {404, 1144, 0}, [541] = {883, 1144, 0}, [542] = {983, 1144, 0},
    [543] = {883, 1145, 0}, [544] = {983, 1145, 0}, [545] = {1094, 1145, 0}, [546] = {983, 1146, 0}, [547] = {1094, 1146, 0}, [548] = {1095, 1146, 0},
    [549] = {1094, 1147, 0}, [550] = {1095, 1147, 0}, [551] = {1096, 1147, 0}, [552] = {1095, 1148, 0}, [553] = {1096, 1148, 0}, [554] = {1097, 1148, 0},
    [555] = {1096, 1149, 0}, [556] = {1097, 1149, 0}, [557] = {1098, 1149, 0}, [558] = {1097, 1150, 0}, [559] = {1098, 1150, 0}, [560] = {1099, 1150, 0},
    [561] = {1098, 1151, 0}, [562] = {1099, 1151, 0}, [563] = {1100, 1151, 0}, [564] = {1099, 1152, 0}, [565] = {1100, 1152, 0}, [566] = {1101, 1152, 0},
    [567] = {1100, 1153, 0}, [568] = {1101, 1153, 0}, [569] = {1102, 1153, 0}, [570] = {1101, 1154, 0}, [571] = {1102, 1154, 0}, [572] = {1103, 1154, 0},
    [573] = {1102, 1155, 0}, [574] = {1103, 1155, 0}, [575] = {1104, 1155, 0}, [576] = {1103, 1156, 0}, [577] = {1104, 1156, 0}, [578] = {1105, 1156, 0},
    [579] = {1104, 1157, 0}, [580] = {1105, 1157, 0}, [581] = {1106, 1157, 0}, [582] = {1105, 1158, 0}, [583] = {1106, 1158, 0}, [584] = {74, 71, 0},
    [585] = {75, 71, 0}, [586] = {74, 72, 0}, [587] = {75, 72, 0}, [588] = {76, 72, 0}, [589] = {75, 73, 0}, [590] = {76, 73, 0},
    [591] = {90, 73, 0}, [592] = {76, 102, 0}, [593] = {90, 102, 0}, [594] = {91, 102, 0}, [595] = {90, 103, 0}, [596] = {91, 103, 0},
    [597] = {92, 103, 0}, [598] = {91, 104, 0}, [599] = {92, 104, 0}, [600] = {93, 104, 0}, [601] = {92, 105, 0}, [602] = {93, 105, 0},
    [603] = {343, 105, 0}, [604] = {93, 353, 0}, [605] = {343, 353, 0}, [606] = {349, 353, 0}, [607] = {343, 356, 0}, [608] = {349, 356, 0},
    [609] = {358, 356, 0}, [610] = {349, 361, 0}, [611] = {358, 361, 0}, [612] = {363, 361, 0}, [613] = {358, 366, 0}, [614] = {363, 366, 0},
    [615] = {368, 366, 0}, [616] = {363, 371, 0}, [617] = {368, 371, 0}, [618] = {403, 371, 0}, [619] = {368, 409, 0}, [620] = {403, 409, 0},
    [621] = {404, 409, 0}, [622] = {403, 411, 0}, [623] = {404, 411, 0}, [624] = {883, 411, 0}, [625] = {404, 1068, 0}, [626] = {883, 1068, 0},
    [627] = {983, 1068, 0}, [628] = {883, 1069, 0}, [629] = {983, 1069, 0}, [630] = {1094, 1069, 0}, [631] = {983, 1070, 0}, [632] = {1094, 1070, 0},
    [633] = {1095, 1070, 0}, [634] = {1094, 1071, 0}, [635] = {1095, 1071, 0}, [636] = {1096, 1071, 0}, [637] = {1095, 1072, 0}, [638] = {1096, 1072, 0},
    [639] = {1097, 1072, 0}, [640] = {1096, 1073, 0}, [641] = {1097, 1073, 0}, [642] = {1098, 1073, 0}, [643] = {1097, 1074, 0}, [644] = {1098, 1074, 0},
    [645] = {1099, 1074, 0}, [646] = {1098, 1075, 0}, [647] = {1099, 1075, 0}, [648] = {1100, 1075, 0}, [649] = {1099, 1076, 0}, [650] = {1100, 1076, 0},
    [651] = {1101, 1076, 0}, [652] = {1100, 1077, 0}, [653] = {1101, 1077, 0}, [654] = {1102, 1077, 0}, [655] = {1101, 1078, 0}, [656] = {1102, 1078, 0},
    [657] = {1103, 1078, 0}, [658] = {1102, 1079, 0}, [659] = {1103, 1079, 0}, [660] = {1104, 1079, 0}, [661] = {1103, 1080, 0}, [662] = {1104, 1080, 0},
    [663] = {1105, 1080, 0}, [664] = {1104, 1081, 0}, [665] = {1105, 1081, 0}, [666] = {1106, 1081, 0}, [667] = {1105, 1082, 0}, [668] = {1106, 1082, 0},
    [669] = {74, 68, 0}, [670] = {75, 68, 0}, [671] = {74, 69, 0}, [672] = {75, 69, 0}, [673] = {76, 69, 0}, [674] = {75, 70, 0},
    [675] = {76, 70, 0}, [676] = {90, 70, 0}, [677] = {76, 106, 0}, [678] = {90, 106, 0}, [679] = {91, 106, 0}, [680] = {90, 107, 0},
    [681] = {91, 107, 0}, [682] = {92, 107, 0}, [683] = {91, 108, 0}, [684] = {92, 108, 0}, [685] = {93, 108, 0}, [686] = {92, 109, 0},
    [687] = {93, 109, 0}, [688] = {343, 109, 0}, [689] = {93, 352, 0}, [690] = {343, 352, 0}, [691] = {349, 352, 0}, [692] = {343, 357, 0},
    [693] = {349, 357, 0}, [694] = {358, 357, 0}, [695] = {349, 362, 0}, [696] = {358, 362, 0}, [697] = {363, 362, 0}, [698] = {358, 367, 0},
    [699] = {363, 367, 0}, [700] = {368, 367, 0}, [701] = {363, 372, 0}, [702] = {368, 372, 0}, [703] = {403, 372, 0}, [704] = {368, 410, 0},
    [705] = {403, 410, 0}, [706] = {404, 410, 0}, [707] = {403, 412, 0}, [708] = {404, 412, 0}, [709] = {883, 412, 0}, [710] = {404, 684, 0},
    [711] = {883, 684, 0}, [712] = {983, 684, 0}, [713] = {883, 1043, 0}, [714] = {983, 1043, 0}, [715] = {1094, 1043, 0}, [716] = {983, 1044, 0},
    [717] = {1094, 1044, 0}, [718] = {1095, 1044, 0}, [719] = {1094, 1045, 0}, [720] = {1095, 1045, 0}, [721] = {1096, 1045, 0}, [722] = {1095, 1046, 0},
    [723] = {1096, 1046, 0}, [724] = {1097, 1046, 0}, [725] = {1096, 1047, 0}, [726] = {1097, 1047, 0}, [727] = {1098, 1047, 0}, [728] = {1097, 1048, 0},
    [729] = {1098, 1048, 0}, [730] = {1099, 1048, 0}, [731] = {1098, 1049, 0}, [732] = {1099, 1049, 0}, [733] = {1100, 1049, 0}, [734] = {1099, 1050, 0},
    [735] = {1100, 1050, 0}, [736] = {1101, 1050, 0}, [737] = {1100, 1051, 0}, [738] = {1101, 1051, 0}, [739] = {1102, 1051, 0}, [740] = {1101, 1052, 0},
    [741] = {1102, 1052, 0}, [742] = {1103, 1052, 0}, [743] = {1102, 1053, 0}, [744] = {1103, 1053, 0}, [745] = {1104, 1053, 0}, [746] = {1103, 1054, 0},
    [747] = {1104, 1054, 0}, [748] = {1105, 1054, 0}, [749] = {1104, 1055, 0}, [750] = {1105, 1055, 0}, [751] = {1106, 1055, 0}, [752] = {1105, 1056, 0},
    [753] = {1106, 1056, 0}, [754] = {79, 82, 0}, [755] = {80, 82, 0}, [756] = {79, 83, 0}, [757] = {80, 83, 0}, [758] = {81, 83, 0},
    [759] = {80, 84, 0}, [760] = {81, 84, 0}, [761] = {94, 84, 0}, [762] = {81, 98, 0}, [763] = {94, 98, 0}, [764] = {95, 98, 0},
    [765] = {94, 99, 0}, [766] = {95, 99, 0}, [767] = {96, 99, 0}, [768] = {95, 100, 0}, [769] = {96, 100, 0}, [770] = {97, 100, 0},
    [771] = {96, 101, 0}, [772] = {97, 101, 0}, [773] = {350, 101, 0}, [774] = {97, 351, 0}, [775] = {350, 351, 0}, [776] = {354, 351, 0},
    [777] = {350, 355, 0}, [778] = {354, 355, 0}, [779] = {359, 355, 0}, [780] = {354, 360, 0}, [781] = {359, 360, 0}, [782] = {364, 360, 0},
    [783] = {359, 365, 0}, [784] = {364, 365, 0}, [785] = {369, 365, 0}, [786] = {364, 370, 0}, [787] = {369, 370, 0}, [788] = {405, 370, 0},
    [789] = {369, 407, 0}, [790] = {405, 407, 0}, [791] = {406, 407, 0}, [792] = {405, 408, 0}, [793] = {406, 408, 0}, [794] = {1118, 408, 0},
    [795] = {406, 1144, 0}, [796] = {1118, 1144, 0}, [797] = {1119, 1144, 0}, [798] = {1118, 1145, 0}, [799] = {1119, 1145, 0}, [800] = {1120, 1145, 0},
    [801] = {1119, 1146, 0}, [802] = {1120, 1146, 0}, [803] = {1121, 1146, 0}, [804] = {1120, 1147, 0}, [805] = {1121, 1147, 0}, [806] = {1122, 1147, 0},
    [807] = {1121, 1148, 0}, [808] = {1122, 1148, 0}, [809] = {1123, 1148, 0}, [810] = {1122, 1149, 0}, [811] = {1123, 1149, 0}, [812] = {1124, 1149, 0},
    [813] = {1123, 1150, 0}, [814] = {1124, 1150, 0}, [815] = {1125, 1150, 0}, [816] = {1124, 1151, 0}, [817] = {1125, 1151, 0}, [818] = {1126, 1151, 0},
    [819] = {1125, 1152, 0}, [820] = {1126, 1152, 0}, [821] = {1127, 1152, 0}, [822] = {1126, 1153, 0}, [823] = {1127, 1153, 0}, [824] = {1128, 1153, 0},
    [825] = {1127, 1154, 0}, [826] = {1128, 1154, 0}, [827] = {1129, 1154, 0}, [828] = {1128, 1155, 0}, [829] = {1129, 1155, 0}, [830] = {1130, 1155, 0},
    [831] = {1129, 1156, 0}, [832] = {1130, 1156, 0}, [833] = {1131, 1156, 0}, [834] = {1130, 1157, 0}, [835] = {1131, 1157, 0}, [836] = {1132, 1157, 0},
    [837] = {1131, 1158, 0}, [838] = {1132, 1158, 0}, [839] = {79, 71, 0}, [840] = {80, 71, 0}, [841] = {79, 72, 0}, [842] = {80, 72, 0},
    [843] = {81, 72, 0}, [844] = {80, 73, 0}, [845] = {81, 73, 0}, [846] = {94, 73, 0}, [847] = {81, 102, 0}, [848] = {94, 102, 0},
    [849] = {95, 102, 0}, [850] = {94, 103, 0}, [851] = {95, 103, 0}, [852] = {96, 103, 0}, [853] = {95, 104, 0}, [854] = {96, 104, 0},
    [855] = {97, 104, 0}, [856] = {96, 105, 0}, [857] = {97, 105, 0}, [858] = {350, 105, 0}, [859] = {97, 353, 0}, [860] = {350, 353, 0},
    [861] = {354, 353, 0}, [862] = {350, 356, 0}, [863] = {354, 356, 0}, [864] = {359, 356, 0}, [865] = {354, 361, 0}, [866] = {359, 361, 0},
    [867] = {364, 361, 0}, [868] = {359, 366, 0}, [869] = {364, 366, 0}, [870] = {369, 366, 0}, [871] = {364, 371, 0}, [872] = {369, 371, 0},
    [873] = {405, 371, 0}, [874] = {369, 409, 0}, [875] = {405, 409, 0}, [876] = {406, 409, 0}, [877] = {405, 411, 0}, [878] = {406, 411, 0},
    [879] = {1118, 411, 0}, [880] = {406, 1068, 0}, [881] = {1118, 1068, 0}, [882] = {1119, 1068, 0}, [883] = {1118, 1069, 0}, [884] = {1119, 1069, 0},
    [885] = {1120, 1069, 0}, [886] = {1119, 1070, 0}, [887] = {1120, 1070, 0}, [888] = {1121, 1070, 0}, [889] = {1120, 1071, 0}, [890] = {1121, 1071, 0},
    [891] = {1122, 1071, 0}, [892] = {1121, 1072, 0}, [893] = {1122, 1072, 0}, [894] = {1123, 1072, 0}, [895] = {1122, 1073, 0}, [896] = {1123, 1073, 0},
    [897] = {1124, 1073, 0}, [898] = {1123, 1074, 0}, [899] = {1124, 1074, 0}, [900] = {1125, 1074, 0}, [901] = {1124, 1075, 0}, [902] = {1125, 1075, 0},
    [903] = {1126, 1075, 0}, [904] = {1125, 1076, 0}, [905] = {1126, 1076, 0}, [906] = {1127, 1076, 0}, [907] = {1126, 1077, 0}, [908] = {1127, 1077, 0},
    [909] = {1128, 1077, 0}, [910] = {1127, 1078, 0}, [911] = {1128, 1078, 0}, [912] = {1129, 1078, 0}, [913] = {1128, 1079, 0}, [914] = {1129, 1079, 0},
    [915] = {1130, 1079, 0}, [916] = {1129, 1080, 0}, [917] = {1130, 1080, 0}, [918] = {1131, 1080, 0}, [919] = {1130, 1081, 0}, [920] = {1131, 1081, 0},
    [921] = {1132, 1081, 0}, [922] = {1131, 1082, 0}, [923] = {1132, 1082, 0}, [924] = {79, 68, 0}, [925] = {80, 68, 0}, [926] = {79, 69, 0},
    [927] = {80, 69, 0}, [928] = {81, 69, 0}, [929] = {80, 70, 0}, [930] = {81, 70, 0}, [931] = {94, 70, 0}, [932] = {81, 106, 0},
    [933] = {94, 106, 0}, [934] = {95, 106, 0}, [935] = {94, 107, 0}, [936] = {95, 107, 0}, [937] = {96, 107, 0}, [938] = {95, 108, 0},
    [939] = {96, 108, 0}, [940] = {97, 108, 0}, [941] = {96, 109, 0}, [942] = {97, 109, 0}, [943] = {350, 109, 0}, [944] = {97, 352, 0},
    [945] = {350, 352, 0}, [946] = {354, 352, 0}, [947] = {350, 357, 0}, [948] = {354, 357, 0}, [949] = {359, 357, 0}, [950] = {354, 362, 0},
    [951] = {359, 362, 0}, [952] = {364, 362, 0}, [953] = {359, 367, 0}, [954] = {364, 367, 0}, [955] = {369, 367, 0}, [956] = {364, 372, 0},
    [957] = {369, 372, 0}, [958] = {405, 372, 0}, [959] = {369, 410, 0}, [960] = {405, 410, 0}, [961] = {406, 410, 0}, [962] = {405, 412, 0},
    [963] = {406, 412, 0}, [964] = {1118, 412, 0}, [965] = {406, 684, 0}, [966] = {1118, 684, 0}, [967] = {1119, 684, 0}, [968] = {1118, 1043, 0},
    [969] = {1119, 1043, 0}, [970] = {1120, 1043, 0}, [971] = {1119, 1044, 0}, [972] = {1120, 1044, 0}, [973] = {1121, 1044, 0}, [974] = {1120, 1045, 0},
    [975] = {1121, 1045, 0}, [976] = {1122, 1045, 0}, [977] = {1121, 1046, 0}, [978] = {1122, 1046, 0}, [979] = {1123, 1046, 0}, [980] = {1122, 1047, 0},
    [981] = {1123, 1047, 0}, [982] = {1124, 1047, 0}, [983] = {1123, 1048, 0}, [984] = {1124, 1048, 0}, [985] = {1125, 1048, 0}, [986] = {1124, 1049, 0},
    [987] = {1125, 1049, 0}, [988] = {1126, 1049, 0}, [989] = {1125, 1050, 0}, [990] = {1126, 1050, 0}, [991] = {1127, 1050, 0}, [992] = {1126, 1051, 0},
    [993] = {1127, 1051, 0}, [994] = {1128, 1051, 0}, [995] = {1127, 1052, 0}, [996] = {1128, 1052, 0}, [997] = {1129, 1052, 0}, [998] = {1128, 1053, 0},
    [999] = {1129, 1053, 0}, [1000] = {1130, 1053, 0}, [1001] = {1129, 1054, 0}, [1002] = {1130, 1054, 0}, [1003] = {1131, 1054, 0}, [1004] = {1130, 1055, 0},
    [1005] = {1131, 1055, 0}, [1006] = {1132, 1055, 0}, [1007] = {1131, 1056, 0}, [1008] = {1132, 1056, 0}, [1009] = {82, 71, 0}, [1010] = {83, 71, 0},
    [1011] = {82, 72, 0}, [1012] = {83, 72, 0}, [1013] = {84, 72, 0}, [1014] = {83, 73, 0}, [1015] = {84, 73, 0}, [1016] = {98, 73, 0},
    [1017] = {84, 102, 0}, [1018] = {98, 102, 0}, [1019] = {99, 102, 0}, [1020] = {98, 103, 0}, [1021] = {99, 103, 0}, [1022] = {100, 103, 0},
    [1023] = {99, 104, 0}, [1024] = {100, 104, 0}, [1025] = {101, 104, 0}, [1026] = {100, 105, 0}, [1027] = {101, 105, 0}, [1028] = {351, 105, 0},
    [1029] = {101, 353, 0}, [1030] = {351, 353, 0}, [1031] = {355, 353, 0}, [1032] = {351, 356, 0}, [1033] = {355, 356, 0}, [1034] = {360, 356, 0},
    [1035] = {355, 361, 0}, [1036] = {360, 361, 0}, [1037] = {365, 361, 0}, [1038] = {360, 366, 0}, [1039] = {365, 366, 0}, [1040] = {370, 366, 0},
    [1041] = {365, 371, 0}, [1042] = {370, 371, 0}, [1043] = {407, 371, 0}, [1044] = {370, 409, 0}, [1045] = {407, 409, 0}, [1046] = {408, 409, 0},
    [1047] = {407, 411, 0}, [1048] = {408, 411, 0}, [1049] = {1144, 411, 0}, [1050] = {408, 1068, 0}, [1051] = {1144, 1068, 0}, [1052] = {1145, 1068, 0},
    [1053] = {1144, 1069, 0}, [1054] = {1145, 1069, 0}, [1055] = {1146, 1069, 0}, [1056] = {1145, 1070, 0}, [1057] = {1146, 1070, 0}, [1058] = {1147, 1070, 0},
    [1059] = {1146, 1071, 0}, [1060] = {1147, 1071, 0}, [1061] = {1148, 1071, 0}, [1062] = {1147, 1072, 0}, [1063] = {1148, 1072, 0}, [1064] = {1149, 1072, 0},
    [1065] = {1148, 1073, 0}, [1066] = {1149, 1073, 0}, [1067] = {1150, 1073, 0}, [1068] = {1149, 1074, 0}, [1069] = {1150, 1074, 0}, [1070] = {1151, 1074, 0},
    [1071] = {1150, 1075, 0}, [1072] = {1151, 1075, 0}, [1073] = {1152, 1075, 0}, [1074] = {1151, 1076, 0}, [1075] = {1152, 1076, 0}, [1076] = {1153, 1076, 0},
    [1077] = {1152, 1077, 0}, [1078] = {1153, 1077, 0}, [1079] = {1154, 1077, 0}, [1080] = {1153, 1078, 0}, [1081] = {1154, 1078, 0}, [1082] = {1155, 1078, 0},
    [1083] = {1154, 1079, 0}, [1084] = {1155, 1079, 0}, [1085] = {1156, 1079, 0}, [1086] = {1155, 1080, 0}, [1087] = {1156, 1080, 0}, [1088] = {1157, 1080, 0},
    [1089] = {1156, 1081, 0}, [1090] = {1157, 1081, 0}, [1091] = {1158, 1081, 0}, [1092] = {1157, 1082, 0}, [1093] = {1158, 1082, 0}, [1094] = {82, 68, 0},
    [1095] = {83, 68, 0}, [1096] = {82, 69, 0}, [1097] = {83, 69, 0}, [1098] = {84, 69, 0}, [1099] = {83, 70, 0}, [1100] = {84, 70, 0},
    [1101] = {98, 70, 0}, [1102] = {84, 106, 0}, [1103] = {98, 106, 0}, [1104] = {99, 106, 0}, [1105] = {98, 107, 0}, [1106] = {99, 107, 0},
    [1107] = {100, 107, 0}, [1108] = {99, 108, 0}, [1109] = {100, 108, 0}, [1110] = {101, 108, 0}, [1111] = {100, 109, 0}, [1112] = {101, 109, 0},
    [1113] = {351, 109, 0}, [1114] = {101, 352, 0}, [1115] = {351, 352, 0}, [1116] = {355, 352, 0}, [1117] = {351, 357, 0}, [1118] = {355, 357, 0},
    [1119] = {360, 357, 0}, [1120] = {355, 362, 0}, [1121] = {360, 362, 0}, [1122] = {365, 362, 0}, [1123] = {360, 367, 0}, [1124] = {365, 367, 0},
    [1125] = {370, 367, 0}, [1126] = {365, 372, 0}, [1127] = {370, 372, 0}, [1128] = {407, 372, 0}, [1129] = {370, 410, 0}, [1130] = {407, 410, 0},
    [1131] = {408, 410, 0}, [1132] = {407, 412, 0}, [1133] = {408, 412, 0}, [1134] = {1144, 412, 0}, [1135] = {408, 684, 0}, [1136] = {1144, 684, 0},
    [1137] = {1145, 684, 0}, [1138] = {1144, 1043, 0}, [1139] = {1145, 1043, 0}, [1140] = {1146, 1043, 0}, [1141] = {1145, 1044, 0}, [1142] = {1146, 1044, 0},
    [1143] = {1147, 1044, 0}, [1144] = {1146, 1045, 0}, [1145] = {1147, 1045, 0}, [1146] = {1148, 1045, 0}, [1147] = {1147, 1046, 0}, [1148] = {1148, 1046, 0},
    [1149] = {1149, 1046, 0}, [1150] = {1148, 1047, 0}, [1151] = {1149, 1047, 0}, [1152] = {1150, 1047, 0}, [1153] = {1149, 1048, 0}, [1154] = {1150, 1048, 0},
    [1155] = {1151, 1048, 0}, [1156] = {1150, 1049, 0}, [1157] = {1151, 1049, 0}, [1158] = {1152, 1049, 0}, [1159] = {1151, 1050, 0}, [1160] = {1152, 1050, 0},
    [1161] = {1153, 1050, 0}, [1162] = {1152, 1051, 0}, [1163] = {1153, 1051, 0}, [1164] = {1154, 1051, 0}, [1165] = {1153, 1052, 0}, [1166] = {1154, 1052, 0},
    [1167] = {1155, 1052, 0}, [1168] = {1154, 1053, 0}, [1169] = {1155, 1053, 0}, [1170] = {1156, 1053, 0}, [1171] = {1155, 1054, 0}, [1172] = {1156, 1054, 0},
    [1173] = {1157, 1054, 0}, [1174] = {1156, 1055, 0}, [1175] = {1157, 1055, 0}, [1176] = {1158, 1055, 0}, [1177] = {1157, 1056, 0}, [1178] = {1158, 1056, 0},
    [1179] = {71, 68, 0}, [1180] = {72, 68, 0}, [1181] = {71, 69, 0}, [1182] = {72, 69, 0}, [1183] = {73, 69, 0}, [1184] = {72, 70, 0},
    [1185] = {73, 70, 0}, [1186] = {102, 70, 0}, [1187] = {73, 106, 0}, [1188] = {102, 106, 0}, [1189] = {103, 106, 0}, [1190] = {102, 107, 0},
    [1191] = {103, 107, 0}, [1192] = {104, 107, 0}, [1193] = {103, 108, 0}, [1194] = {104, 108, 0}, [1195] = {105, 108, 0}, [1196] = {104, 109, 0},
    [1197] = {105, 109, 0}, [1198] = {353, 109, 0}, [1199] = {105, 352, 0}, [1200] = {353, 352, 0}, [1201] = {356, 352, 0}, [1202] = {353, 357, 0},
    [1203] = {356, 357, 0}, [1204] = {361, 357, 0}, [1205] = {356, 362, 0}, [1206] = {361, 362, 0}, [1207] = {366, 362, 0}, [1208] = {361, 367, 0},
    [1209] = {366, 367, 0}, [1210] = {371, 367, 0}, [1211] = {366, 372, 0}, [1212] = {371, 372, 0}, [1213] = {409, 372, 0}, [1214] = {371, 410, 0},
    [1215] = {409, 410, 0}, [1216] = {411, 410, 0}, [1217] = {409, 412, 0}, [1218] = {411, 412, 0}, [1219] = {1068, 412, 0}, [1220] = {411, 684, 0},
    [1221] = {1068, 684, 0}, [1222] = {1069, 684, 0}, [1223] = {1068, 1043, 0}, [1224] = {1069, 1043, 0}, [1225] = {1070, 1043, 0}, [1226] = {1069, 1044, 0},
    [1227] = {1070, 1044, 0}, [1228] = {1071, 1044, 0}, [1229] = {1070, 1045, 0}, [1230] = {1071, 1045, 0}, [1231] = {1072, 1045, 0}, [1232] = {1071, 1046, 0},
    [1233] = {1072, 1046, 0}, [1234] = {1073, 1046, 0}, [1235] = {1072, 1047, 0}, [1236] = {1073, 1047, 0}, [1237] = {1074, 1047, 0}, [1238] = {1073, 1048, 0},
    [1239] = {1074, 1048, 0}, [1240] = {1075, 1048, 0}, [1241] = {1074, 1049, 0}, [1242] = {1075, 1049, 0}, [1243] = {1076, 1049, 0}, [1244] = {1075, 1050, 0},
    [1245] = {1076, 1050, 0}, [1246] = {1077, 1050, 0}, [1247] = {1076, 1051, 0}, [1248] = {1077, 1051, 0}, [1249] = {1078, 1051, 0}, [1250] = {1077, 1052, 0},
    [1251] = {1078, 1052, 0}, [1252] = {1079, 1052, 0}, [1253] = {1078, 1053, 0}, [1254] = {1079, 1053, 0}, [1255] = {1080, 1053, 0}, [1256] = {1079, 1054, 0},
    [1257] = {1080, 1054, 0}, [1258] = {1081, 1054, 0}, [1259] = {1080, 1055, 0}, [1260] = {1081, 1055, 0}, [1261] = {1082, 1055, 0}, [1262] = {1081, 1056, 0},
    [1263] = {1082, 1056, 0}, [1267] = {1209, 0, 0}, [1268] = {1210, 0, 0}, [1269] = {1211, 0, 0}, [1270] = {1212, 0, 0}, [1271] = {1213, 0, 0},
    [1272] = {1214, 0, 0}, [1273] = {1203, 0, 0}, [1274] = {1204, 0, 0}, [1275] = {1205, 0, 0}, [1276] = {1206, 0, 0}, [1277] = {1207, 0, 0},
    [1278] = {1208, 0, 0}, [1279] = {1215, 0, 0}, [1280] = {1216, 0, 0}, [1281] = {1217, 0, 0}, [1282] = {1218, 0, 0}, [1283] = {1219, 0, 0},
    [1284] = {1220, 0, 0}, [1285] = {1221, 0, 0}, [1286] = {1222, 0, 0}, [1287] = {1223, 0, 0}, [1288] = {1224, 0, 0}, [1289] = {1225, 0, 0},
    [1290] = {1226, 0, 0}, [1291] = {1227, 0, 0}, [1292] = {1228, 0, 0}, [1293] = {1229, 0, 0}, [1294] = {1230, 0, 0}, [1295] = {1231, 0, 0},
    [1296] = {1232, 0, 0}, [1307] = {1243, 0, 0}, [1308] = {1244, 0, 0}, [1309] = {1245, 0, 0}, [1310] = {1246, 0, 0}, [1311] = {1247, 0, 0},
    [1312] = {1248, 0, 0}, [1313] = {1249, 0, 0}, [1314] = {1250, 0, 0}, [1315] = {1251, 0, 0}, [1316] = {1252, 0, 0}, [1317] = {1253, 0, 0},
    [1318] = {1254, 0, 0}, [1319] = {1255, 0, 0}, [1320] = {1256, 0, 0}, [1321] = {1257, 0, 0}, [1322] = {1258, 0, 0}, [1323] = {1259, 0, 0},
    [1324] = {1260, 0, 0}, [1325] = {1261, 0, 0}, [1326] = {1262, 0, 0}, [1327] = {1263, 0, 0}, [1328] = {1264, 0, 0}, [1329] = {1265, 0, 0},
    [1330] = {1266, 0, 0}, [1331] = {1267, 0, 0}, [1332] = {1268, 0, 0}, [1333] = {1269, 0, 0}, [1334] = {1270, 0, 0}, [1335] = {1271, 0, 0},
    [1336] = {1272, 0, 0}, [1337] = {1273, 0, 0}, [1338] = {1274, 0, 0}, [1339] = {1275, 0, 0}, [1340] = {1276, 0, 0}, [1341] = {1277, 0, 0},
    [1342] = {1278, 0, 0}, [1343] = {1279, 0, 0}, [1344] = {1280, 0, 0}, [1345] = {1281, 0, 0}, [1346] = {1282, 0, 0}, [1347] = {1283, 0, 0},
    [1348] = {1284, 0, 0}, [1349] = {1285, 0, 0}, [1350] = {1286, 0, 0}, [1351] = {1287, 0, 0}, [1352] = {1288, 0, 0}, [1353] = {1289, 0, 0},
    [1354] = {1290, 0, 0}, [1355] = {1291, 0, 0}, [1356] = {1292, 0, 0}, [1357] = {1293, 0, 0}, [1358] = {1294, 0, 0}, [1359] = {1295, 0, 0},
    [1360] = {1296, 0, 0}, [1361] = {1297, 0, 0}, [1362] = {1298, 0, 0}, [1363] = {1299, 0, 0}, [1364] = {1300, 0, 0}, [1365] = {1301, 0, 0},
    [1366] = {1302, 0, 0}, [1367] = {1303, 0, 0}, [1368] = {1304, 0, 0}, [1369] = {1305, 0, 0}, [1370] = {1306, 0, 0}, [1371] = {1307, 0, 0},
    [1372] = {1308, 0, 0}, [1373] = {1309, 0, 0}, [1374] = {1310, 0, 0}, [1375] = {1311, 0, 0}, [1376] = {1312, 0, 0}, [1377] = {1313, 0, 0},
    [1378] = {1314, 0, 0}, [1379] = {1315, 0, 0}, [1380] = {1316, 0, 0}, [1381] = {1317, 0, 0}, [1382] = {1318, 0, 0}, [1383] = {1319, 0, 0},
    [1384] = {1320, 0, 0}, [1385] = {1321, 0, 0}, [1386] = {1322, 0, 0}, [1387] = {1323, 0, 0}, [1388] = {1324, 0, 0}, [1389] = {1325, 0, 0},
    [1390] = {1326, 0, 0}, [1391] = {1327, 0, 0}, [1392] = {1328, 0, 0}, [1393] = {1329, 0, 0}, [1394] = {1330, 0, 0}, [1395] = {1331, 0, 0},
    [1396] = {1332, 0, 0}, [1397] = {1333, 0, 0}, [1398] = {1334, 0, 0}, [1399] = {1335, 0, 0}, [1400] = {1336, 0, 0}, [1401] = {1337, 0, 0},
    [1402] = {1338, 0, 0}, [1403] = {1339, 0, 0}, [1404] = {1340, 0, 0}, [1405] = {1341, 0, 0}, [1406] = {1342, 0, 0}, [1407] = {1343, 0, 0},
    [1408] = {1344, 0, 0}, [1409] = {1345, 0, 0}, [1410] = {1346, 0, 0}, [1411] = {1347, 0, 0}, [1412] = {1348, 0, 0}, [1413] = {1349, 0, 0},
    [1414] = {1350, 0, 0}, [1415] = {1351, 0, 0}, [1416] = {1352, 0, 0}, [1417] = {1353, 0, 0}, [1418] = {1354, 0, 0}, [1419] = {1355, 0, 0},
    [1420] = {1356, 0, 0}, [1421] = {1357, 0, 0}, [1422] = {1358, 0, 0}, [1423] = {1359, 0, 0}, [1424] = {1360, 0, 0}, [1425] = {1361, 0, 0},
    [1426] = {1362, 0, 0}, [1427] = {1363, 0, 0}, [1428] = {1364, 0, 0}, [1429] = {1365, 0, 0}, [1430] = {1366, 0, 0}, [1431] = {1367, 0, 0},
    [1432] = {1368, 0, 0}, [1433] = {1369, 0, 0}, [1434] = {1370, 0, 0}, [1435] = {1371, 0, 0}, [1436] = {1372, 0, 0}, [1437] = {1373, 0, 0},
    [1438] = {1374, 0, 0}, [1439] = {1375, 0, 0}, [1440] = {1376, 0, 0}, [1441] = {1377, 0, 0}, [1442] = {1378, 0, 0}, [1443] = {1379, 0, 0},
    [1444] = {1380, 0, 0}, [1445] = {1427, 0, 0}, [1446] = {1428, 0, 0}, [1447] = {1429, 0, 0}, [1448] = {1430, 0, 0}, [1449] = {1431, 0, 0},
    [1450] = {1432, 0, 0}, [1451] = {1433, 0, 0}, [1452] = {1434, 0, 0}, [1453] = {1435, 0, 0}, [1454] = {1436, 0, 0}, [1455] = {1437, 0, 0},
    [1456] = {1438, 0, 0}, [1457] = {1439, 0, 0}, [1458] = {1440, 0, 0}, [1459] = {1441, 0, 0}, [1460] = {1442, 0, 0}, [1461] = {1443, 0, 0},
    [1462] = {1444, 0, 0}, [1463] = {1445, 0, 0}, [1464] = {1446, 0, 0}, [1465] = {1447, 0, 0}, [1466] = {1448, 0, 0}, [1467] = {1449, 0, 0},
    [1468] = {1450, 0, 0}, [1469] = {1451, 0, 0}, [1470] = {1452, 0, 0}, [1471] = {1453, 0, 0}, [1472] = {1454, 0, 0}, [1473] = {1455, 0, 0},
    [1474] = {1456, 0, 0}, [1475] = {1457, 0, 0}, [1476] = {1458, 0, 0}, [1477] = {1459, 0, 0}, [1478] = {1460, 0, 0}, [1479] = {1461, 0, 0},
    [1480] = {1462, 0, 0}, [1481] = {1463, 0, 0}, [1482] = {1464, 0, 0}, [1483] = {1465, 0, 0}, [1484] = {1466, 0, 0}, [1485] = {1467, 0, 0},
    [1486] = {1468, 0, 0}, [1487] = {1469, 0, 0}, [1488] = {1470, 0, 0}, [1489] = {1471, 0, 0}, [1490] = {1472, 0, 0}, [1491] = {1381, 0, 0},
    [1492] = {1382, 0, 0}, [1493] = {1383, 0, 0}, [1494] = {1384, 0, 0}, [1495] = {1385, 0, 0}, [1496] = {1386, 0, 0}, [1497] = {1387, 0, 0},
    [1498] = {1388, 0, 0}, [1499] = {1389, 0, 0}, [1500] = {1390, 0, 0}, [1501] = {1391, 0, 0}, [1502] = {1392, 0, 0}, [1503] = {1393, 0, 0},
    [1504] = {1394, 0, 0}, [1505] = {1395, 0, 0}, [1506] = {1396, 0, 0}, [1507] = {1397, 0, 0}, [1508] = {1398, 0, 0}, [1509] = {1399, 0, 0},
    [1510] = {1400, 0, 0}, [1511] = {1401, 0, 0}, [1512] = {1402, 0, 0}, [1513] = {1403, 0, 0}, [1514] = {1404, 0, 0}, [1515] = {1405, 0, 0},
    [1516] = {1406, 0, 0}, [1517] = {1407, 0, 0}, [1518] = {1408, 0, 0}, [1519] = {1409, 0, 0}, [1520] = {1410, 0, 0}, [1521] = {1411, 0, 0},
    [1522] = {1412, 0, 0}, [1523] = {1413, 0, 0}, [1524] = {1414, 0, 0}, [1525] = {1415, 0, 0}, [1526] = {1416, 0, 0}, [1527] = {1417, 0, 0},
    [1528] = {1418, 0, 0}, [1529] = {1419, 0, 0}, [1530] = {1420, 0, 0}, [1531] = {1421, 0, 0}, [1532] = {1422, 0, 0}, [1533] = {1423, 0, 0},
    [1534] = {1424, 0, 0}, [1535] = {1425, 0, 0}, [1536] = {1426, 0, 0}, [1547] = {1563, 0, 0}, [1548] = {1583, 0, 0}, [1549] = {1584, 0, 0},
    [1550] = {1585, 0, 0}, [1551] = {1586, 0, 0}, [1552] = {1587, 0, 0}, [1553] = {1588, 0, 0}, [1554] = {1589, 0, 0}, [1555] = {1590, 0, 0},
    [1556] = {1591, 0, 0}, [1557] = {1592, 0, 0}, [1558] = {1593, 0, 0}, [1559] = {1594, 0, 0}, [1560] = {1595, 0, 0}, [1561] = {1596, 0, 0},
    [1562] = {1597, 0, 0}, [1563] = {1598, 0, 0}, [1564] = {1599, 0, 0}, [1565] = {1600, 0, 0}, [1566] = {1601, 0, 0}, [1567] = {1602, 0, 0},
    [1568] = {1603, 0, 0}, [1569] = {1604, 0, 0}, [1570] = {1605, 0, 0}, [1571] = {1606, 0, 0}, [1572] = {1607, 0, 0}, [1573] = {1608, 0, 0},
    [1574] = {1609, 0, 0}, [1575] = {1610, 0, 0}, [1576] = {1611, 0, 0}, [1577] = {1612, 0, 0}, [1578] = {1613, 0, 0}, [1579] = {1614, 0, 0},
    [1580] = {1615, 0, 0}, [1581] = {1616, 0, 0}, [1582] = {1617, 0, 0}, [1583] = {1618, 0, 0}, [1584] = {1619, 0, 0}, [1585] = {1620, 0, 0},
    [1586] = {1621, 0, 0}, [1587] = {1622, 0, 0}, [1588] = {1623, 0, 0}, [1589] = {1624, 0, 0}, [1590] = {1625, 0, 0}, [1591] = {1626, 0, 0},
    [1592] = {1627, 0, 0}, [1607] = {1943, 0, 0}, [1608] = {1944, 0, 0}, [1609] = {1945, 0, 0}, [1610] = {1946, 0, 0}, [1611] = {1947, 0, 0},
    [1612] = {1948, 0, 0}, [1613] = {1949, 0, 0}, [1614] = {1950, 0, 0}, [1615] = {1951, 0, 0}, [1616] = {1952, 0, 0}, [1617] = {1953, 0, 0},
    [1618] = {1954, 0, 0}, [1619] = {1955, 0, 0}, [1620] = {1956, 0, 0}, [1621] = {1957, 0, 0}, [1622] = {1958, 0, 0}, [1623] = {1959, 0, 0},
    [1624] = {1960, 0, 0}, [1625] = {1961, 0, 0}, [1626] = {1962, 0, 0}, [1627] = {1963, 0, 0}, [1628] = {1964, 0, 0}, [1629] = {1965, 0, 0},
    [1630] = {1966, 0, 0}, [1631] = {1967, 0, 0}, [1632] = {1968, 0, 0}, [1633] = {1969, 0, 0}, [1634] = {1970, 0, 0}, [1635] = {1971, 0, 0},
    [1636] = {1972, 0, 0}, [1637] = {1973, 0, 0}, [1647] = {1983, 0, 0}, [1648] = {1983, 68, 0}, [1649] = {1983, 68, 0}, [1650] = {1983, 69, 0},
    [1651] = {1983, 69, 0}, [1652] = {1983, 70, 0}, [1653] = {1983, 70, 0}, [1654] = {1983, 106, 0}, [1655] = {1983, 106, 0}, [1656] = {1983, 107, 0},
    [1657] = {1984, 107, 0}, [1658] = {1984, 108, 0}, [1659] = {1984, 108, 0}, [1660] = {1984, 109, 0}, [1661] = {1984, 109, 0}, [1662] = {1984, 352, 0},
    [1663] = {1984, 352, 0}, [1664] = {1984, 357, 0}, [1665] = {1984, 357, 0}, [1666] = {1984, 357, 0}, [1667] = {1985, 357, 0}, [1668] = {1985, 362, 0},
    [1669] = {1985, 362, 0}, [1670] = {1985, 362, 0}, [1671] = {1985, 362, 0}, [1672] = {1985, 367, 0}, [1673] = {1985, 367, 0}, [1674] = {1985, 372, 0},
    [1675] = {1985, 372, 0}, [1676] = {1985, 372, 0}, [1677] = {1986, 372, 0}, [1678] = {1986, 372, 0}, [1679] = {1986, 372, 0}, [1680] = {1986, 372, 0},
    [1681] = {1986, 372, 0}, [1682] = {1986, 410, 0}, [1683] = {1986, 410, 0}, [1684] = {1986, 412, 0}, [1685] = {1986, 412, 0}, [1686] = {1986, 412, 0},
    [1687] = {1986, 412, 0}, [1688] = {1986, 684, 0}, [1689] = {1986, 684, 0}, [1690] = {1986, 1043, 0}, [1691] = {1986, 1043, 0}, [1692] = {1986, 1043, 0},
    [1693] = {1986, 1043, 0}, [1694] = {1986, 1044, 0}, [1695] = {1986, 1044, 0}, [1696] = {1986, 1045, 0}, [1697] = {1986, 1045, 0}, [1698] = {1986, 1045, 0},
    [1699] = {1986, 1045, 0}, [1700] = {1986, 1046, 0}, [1701] = {1986, 1046, 0}, [1702] = {1986, 1047, 0}, [1703] = {1986, 1047, 0}, [1704] = {2040, 0, 0},
    [1705] = {2041, 0, 0}, [1706] = {2042, 0, 0}, [1707] = {2043, 0, 0}, [1708] = {2044, 0, 0}, [1709] = {2045, 0, 0}, [1710] = {2046, 0, 0},
    [1711] = {2047, 0, 0}, [1712] = {2048, 0, 0}, [1713] = {2049, 0, 0}, [1714] = {2050, 0, 0}, [1715] = {2051, 0, 0}, [1716] = {2052, 0, 0},
    [1717] = {2053, 0, 0}, [1718] = {2054, 0, 0}, [1719] = {2055, 0, 0}, [1720] = {2056, 0, 0}, [1721] = {2057, 0, 0}, [1722] = {2058, 0, 0},
    [1723] = {2059, 0, 0}, [1724] = {2060, 0, 0}, [1725] = {2061, 0, 0}, [1726] = {2062, 0, 0}, [1727] = {2063, 0, 0}, [1728] = {2064, 0, 0},
    [1729] = {2065, 0, 0}, [1730] = {2066, 0, 0}, [1731] = {2067, 0, 0}, [1732] = {2068, 0, 0}, [1733] = {2069, 0, 0}, [1734] = {2070, 0, 0},
    [1735] = {2071, 0, 0}, [1736] = {2072, 0, 0}, [1737] = {2073, 0, 0}, [1738] = {2074, 0, 0}, [1739] = {2075, 0, 0}, [1740] = {2076, 0, 0},
    [1741] = {2077, 0, 0}, [1742] = {2078, 0, 0}, [1743] = {2078, 0, 0}, [1744] = {2078, 0, 0}, [1745] = {2078, 0, 0}, [1746] = {2078, 0, 0},
    [1747] = {2078, 0, 0}, [1748] = {2078, 74, 0}, [1749] = {2078, 74, 0}, [1750] = {2078, 74, 0}, [1751] = {2078, 75, 0}, [1752] = {2078, 75, 0},
    [1753] = {2078, 75, 0}, [1754] = {2078, 76, 0}, [1755] = {2078, 76, 0}, [1756] = {2078, 76, 0}, [1757] = {2078, 90, 0}, [1758] = {2078, 90, 0},
    [1759] = {2078, 90, 0}, [1760] = {2078, 91, 0}, [1761] = {2078, 91, 0}, [1762] = {2078, 91, 0}, [1763] = {2078, 92, 0}, [1764] = {2078, 92, 0},
    [1765] = {2078, 92, 0}, [1766] = {2078, 93, 0}, [1767] = {2078, 93, 0}, [1768] = {2078, 93, 0}, [1769] = {2078, 343, 0}, [1770] = {2078, 343, 0},
    [1771] = {2078, 343, 0}, [1772] = {2078, 349, 0}, [1773] = {2078, 349, 0}, [1774] = {2078, 349, 0}, [1775] = {2078, 349, 0}, [1776] = {2078, 349, 0},
    [1777] = {2078, 349, 0}, [1778] = {2078, 349, 0}, [1779] = {2078, 349, 0}, [1780] = {2078, 358, 0}, [1781] = {2078, 358, 0}, [1782] = {2078, 358, 0},
    [1783] = {2078, 363, 0}, [1784] = {2078, 363, 0}, [1785] = {2078, 363, 0}, [1786] = {2078, 368, 0}, [1787] = {2078, 368, 0}, [1788] = {2078, 368, 0},
    [1789] = {2078, 368, 0}, [1790] = {2078, 403, 0}, [1791] = {2078, 403, 0}, [1792] = {2078, 403, 0}, [1793] = {2078, 404, 0}, [1794] = {2078, 404, 0},
    [1795] = {2078, 404, 0}, [1796] = {2078, 404, 0}, [1797] = {2078, 883, 0}, [1798] = {2078, 883, 0}, [1799] = {2079, 0, 0}, [1800] = {2080, 0, 0},
    [1801] = {2081, 0, 0}, [1802] = {2082, 0, 0}, [1803] = {2083, 0, 0}, [1804] = {2084, 0, 0}, [1805] = {2085, 0, 0}, [1806] = {2086, 0, 0},
    [1807] = {2087, 0, 0}, [1808] = {2088, 0, 0}, [1809] = {2089, 0, 0}, [1810] = {2090, 0, 0}, [1811] = {2091, 0, 0}, [1812] = {2092, 0, 0},
    [1813] = {2093, 0, 0}, [1814] = {2094, 0, 0}, [1815] = {2095, 0, 0}, [1816] = {2096, 0, 0}, [1817] = {2097, 0, 0}, [1818] = {2098, 0, 0},
    [1819] = {2099, 0, 0}, [1820] = {2100, 0, 0}, [1821] = {2101, 0, 0}, [1822] = {2102, 0, 0}, [1823] = {2103, 0, 0}, [1824] = {2104, 0, 0},
    [1825] = {2105, 0, 0}, [1826] = {2106, 0, 0}, [1827] = {2107, 0, 0}, [1828] = {2108, 0, 0}, [1829] = {2109, 0, 0}, [1830] = {2110, 0, 0},
    [1831] = {2111, 0, 0}, [1832] = {2112, 0, 0}, [1833] = {2113, 0, 0}, [1834] = {2114, 0, 0}, [1835] = {2115, 0, 0}, [1836] = {2116, 0, 0},
    [1837] = {2117, 0, 0}, [1838] = {2118, 0, 0}, [1839] = {2119, 0, 0}, [1840] = {2120, 0, 0}, [1841] = {2121, 0, 0}, [1842] = {2122, 0, 0},
    [1843] = {2123, 0, 0}, [1844] = {2124, 0, 0}, [1845] = {2125, 0, 0}, [1846] = {2126, 0, 0}, [1847] = {2127, 0, 0}, [1848] = {2128, 0, 0},
    [1849] = {2129, 0, 0}, [1850] = {2130, 0, 0}, [1851] = {2131, 0, 0}, [1852] = {2132, 0, 0}, [1853] = {2133, 0, 0}, [1854] = {2134, 0, 0},
    [1855] = {2135, 0, 0}, [1856] = {2136, 0, 0}, [1857] = {2137, 0, 0}, [1858] = {2138, 0, 0}, [1859] = {2139, 0, 0}, [1860] = {2140, 0, 0},
    [1861] = {2141, 0, 0}, [1862] = {2142, 0, 0}, [1863] = {2143, 0, 0}, [1864] = {2144, 0, 0}, [1865] = {2145, 0, 0}, [1866] = {2146, 0, 0},
    [1867] = {2147, 0, 0}, [1868] = {2148, 0, 0}, [1869] = {2149, 0, 0}, [1870] = {2150, 0, 0}, [1871] = {2151, 0, 0}, [1872] = {2152, 0, 0},
    [1873] = {2153, 0, 0}, [1874] = {2154, 0, 0}, [1875] = {2155, 0, 0}, [1876] = {2156, 0, 0}, [1877] = {2157, 0, 0}, [1878] = {2158, 0, 0},
    [1879] = {2159, 0, 0}, [1880] = {2160, 0, 0}, [1881] = {2161, 0, 0}, [1882] = {2162, 0, 0}, [1883] = {2163, 0, 0}, [1884] = {2164, 0, 0},
    [1885] = {2165, 0, 0}, [1886] = {2166, 0, 0}, [1887] = {2167, 0, 0}, [1888] = {2168, 0, 0}, [1889] = {2169, 0, 0}, [1890] = {2170, 0, 0},
    [1891] = {2171, 0, 0}, [1892] = {2172, 0, 0}, [1893] = {2173, 0, 0}, [1894] = {2174, 0, 0}, [1895] = {2175, 0, 0}, [1896] = {2176, 0, 0},
    [1897] = {2177, 0, 0}, [1898] = {2178, 0, 0}, [1899] = {2179, 0, 0}, [1900] = {2180, 0, 0}, [1901] = {2181, 0, 0}, [1902] = {2182, 0, 0},
    [1903] = {2183, 0, 0}, [1904] = {2184, 0, 0}, [1905] = {2185, 0, 0}, [1906] = {2186, 0, 0}, [1907] = {2187, 0, 0}, [1908] = {2188, 0, 0},
    [1909] = {2189, 0, 0}, [1910] = {2190, 0, 0}, [1911] = {2191, 0, 0}, [1912] = {2192, 0, 0}, [1913] = {2193, 0, 0}, [1914] = {2194, 0, 0},
    [1915] = {2195, 0, 0}, [1916] = {2196, 0, 0}, [1917] = {2197, 0, 0}, [1918] = {2198, 0, 0}, [1919] = {2199, 0, 0}, [1920] = {2200, 0, 0},
    [1921] = {2201, 0, 0}, [1922] = {2202, 0, 0}, [1923] = {2203, 0, 0}, [1924] = {2204, 0, 0}, [1925] = {2205, 0, 0}, [1926] = {2206, 0, 0},
    [1927] = {2207, 0, 0}, [1928] = {2208, 0, 0}, [1929] = {2209, 0, 0}, [1930] = {2210, 0, 0}, [1931] = {2211, 0, 0}, [1932] = {2212, 0, 0},
    [1933] = {2213, 0, 0}, [1934] = {2214, 0, 0}, [1935] = {2215, 0, 0}, [1936] = {2216, 0, 0}, [1937] = {2217, 0, 0}, [1938] = {2218, 0, 0},
    [1939] = {2219, 0, 0}, [1940] = {2220, 0, 0}, [1941] = {2221, 0, 0}, [1942] = {2222, 0, 0}, [1943] = {2223, 0, 0}, [1944] = {2224, 0, 0},
    [1945] = {2225, 0, 0}, [1946] = {2226, 0, 0}, [1947] = {2227, 0, 0}, [1948] = {2228, 0, 0}, [1949] = {2229, 0, 0}, [1950] = {2230, 0, 0},
    [1951] = {2231, 0, 0}, [1952] = {2232, 0, 0}, [1953] = {2233, 0, 0}, [1954] = {2234, 0, 0}, [1955] = {2235, 0, 0}, [1956] = {2236, 0, 0},
    [1957] = {2237, 0, 0}, [1958] = {2238, 0, 0}, [1959] = {2239, 0, 0}, [1960] = {2240, 0, 0}, [1961] = {2241, 0, 0}, [1962] = {2242, 0, 0},
    [1963] = {2243, 0, 0}, [1964] = {2244, 0, 0}, [1965] = {2245, 0, 0}, [1966] = {2246, 0, 0}, [1967] = {2247, 0, 0}, [1968] = {2248, 0, 0},
    [1969] = {2249, 0, 0}, [1970] = {2250, 0, 0}, [1971] = {2251, 0, 0}, [1972] = {2252, 0, 0}, [1973] = {2253, 0, 0}, [1974] = {2254, 0, 0},
    [1975] = {2255, 0, 0}, [1976] = {2256, 0, 0}, [1977] = {2257, 0, 0}, [1978] = {2258, 0, 0}, [1979] = {2259, 0, 0}, [1980] = {2260, 0, 0},
    [1981] = {2261, 0, 0}, [1982] = {2262, 0, 0}, [1983] = {2263, 0, 0}, [1984] = {2264, 0, 0}, [1985] = {2265, 0, 0}, [1986] = {2266, 0, 0},
    [1987] = {2267, 0, 0}, [1988] = {2268, 0, 0}, [1989] = {2269, 0, 0}, [1990] = {2270, 0, 0}, [1991] = {2271, 0, 0}, [1992] = {2272, 0, 0},
    [1993] = {2273, 0, 0}, [1994] = {2274, 0, 0}, [1995] = {2275, 0, 0}, [1996] = {2276, 0, 0}, [1997] = {2277, 0, 0}, [1998] = {2278, 0, 0},
    [1999] = {2279, 0, 0}, [2000] = {2280, 0, 0}, [2001] = {2281, 0, 0}, [2002] = {2282, 0, 0}, [2003] = {2283, 0, 0}, [2004] = {2284, 0, 0},
    [2005] = {2285, 0, 0}, [2006] = {2286, 0, 0}, [2007] = {2287, 0, 0}, [2008] = {2288, 0, 0}, [2009] = {2289, 0, 0}, [2010] = {2290, 0, 0},
    [2011] = {2291, 0, 0}, [2012] = {2292, 0, 0}, [2013] = {2293, 0, 0}, [2014] = {2294, 0, 0}, [2015] = {2295, 0, 0}, [2016] = {2296, 0, 0},
    [2017] = {2297, 0, 0}, [2018] = {2298, 0, 0}, [2019] = {2299, 0, 0}, [2020] = {2300, 0, 0}, [2021] = {2301, 0, 0}, [2022] = {2302, 0, 0},
    [2023] = {2303, 0, 0}, [2024] = {2304, 0, 0}, [2025] = {2305, 0, 0}, [2026] = {2306, 0, 0}, [2027] = {2307, 0, 0}, [2028] = {2308, 0, 0},
    [2029] = {2309, 0, 0}, [2030] = {2310, 0, 0}, [2031] = {2311, 0, 0}, [2032] = {2312, 0, 0}, [2033] = {2313, 0, 0}, [2034] = {2314, 0, 0},
    [2035] = {2315, 0, 0}, [2036] = {2316, 0, 0}, [2037] = {2317, 0, 0}, [2038] = {2318, 0, 0}, [2039] = {2319, 0, 0}, [2040] = {2320, 0, 0},
    [2041] = {2321, 0, 0}, [2042] = {2322, 0, 0}, [2043] = {2323, 0, 0}, [2044] = {2324, 0, 0}, [2045] = {2325, 0, 0}, [2046] = {2326, 0, 0},
    [2047] = {2327, 0, 0}, [2048] = {2328, 0, 0}, [2049] = {2329, 0, 0}, [2050] = {2330, 0, 0}, [2051] = {2331, 0, 0}, [2052] = {2332, 0, 0},
    [2053] = {2333, 0, 0}, [2054] = {2334, 0, 0}, [2055] = {2335, 0, 0}, [2056] = {2336, 0, 0}, [2057] = {2337, 0, 0}, [2058] = {2338, 0, 0},
    [2059] = {2339, 0, 0}, [2060] = {2340, 0, 0}, [2061] = {2341, 0, 0}, [2062] = {2342, 0, 0}, [2063] = {2343, 0, 0}, [2064] = {2344, 0, 0},
    [2067] = {2363, 0, 0}, [2068] = {2364, 0, 0}, [2069] = {2365, 0, 0}, [2070] = {2366, 0, 0}, [2071] = {2367, 0, 0}, [2072] = {2368, 0, 0},
    [2073] = {2369, 0, 0}, [2074] = {2370, 0, 0}, [2075] = {2371, 0, 0}, [2076] = {2372, 0, 0}, [2077] = {2373, 0, 0}, [2078] = {2374, 0, 0},
    [2079] = {2375, 0, 0}, [2080] = {2376, 0, 0}, [2081] = {2377, 0, 0}, [2082] = {2378, 0, 0}, [2083] = {2379, 0, 0}, [2084] = {2380, 0, 0},
    [2085] = {2381, 0, 0}, [2086] = {2382, 0, 0}, [2087] = {2383, 0, 0}, [2088] = {2384, 0, 0}, [2089] = {2385, 0, 0}, [2090] = {2386, 0, 0},
    [2091] = {2387, 0, 0}, [2092] = {2388, 0, 0}, [2093] = {2389, 0, 0}, [2094] = {2390, 0, 0}, [2095] = {2391, 0, 0}, [2096] = {2392, 0, 0},
    [2097] = {2393, 0, 0}, [2098] = {2394, 0, 0}, [2099] = {2395, 0, 0}, [2100] = {2396, 0, 0}, [2101] = {2397, 0, 0}, [2102] = {2398, 0, 0},
    [2103] = {2399, 0, 0}, [2104] = {2400, 0, 0}, [2105] = {2401, 0, 0}, [2106] = {2402, 0, 0}, [2107] = {2403, 0, 0}, [2108] = {2404, 0, 0},
    [2109] = {2405, 0, 0}, [2110] = {2406, 0, 0}, [2111] = {2407, 0, 0}, [2112] = {2408, 0, 0}, [2113] = {2409, 0, 0}, [2114] = {2410, 0, 0},
    [2115] = {2411, 0, 0}, [2116] = {2412, 0, 0}, [2117] = {2413, 0, 0}, [2118] = {2414, 0, 0}, [2119] = {2415, 0, 0}, [2120] = {2416, 0, 0},
    [2121] = {2417, 0, 0}, [2122] = {2418, 0, 0}, [2123] = {2419, 0, 0}, [2124] = {2420, 0, 0}, [2125] = {2421, 0, 0}, [2126] = {2422, 0, 0},
    [2127] = {2423, 0, 0}, [2128] = {2424, 0, 0}, [2129] = {2425, 0, 0}, [2130] = {2426, 0, 0}, [2131] = {2427, 0, 0}, [2132] = {2428, 0, 0},
    [2133] = {2429, 0, 0}, [2134] = {2430, 0, 0}, [2135] = {2431, 0, 0}, [2136] = {2432, 0, 0}, [2137] = {2433, 0, 0}, [2138] = {2434, 0, 0},
    [2139] = {2435, 0, 0}, [2140] = {2436, 0, 0}, [2141] = {2437, 0, 0}, [2142] = {2438, 0, 0}, [2143] = {366, 359, 2607}, [2144] = {366, 359, 2607},
    [2145] = {361, 359, 2608}, [2146] = {361, 2316, 2373}, [2147] = {366, 2316, 2372}, [2148] = {361, 2317, 2372}, [2149] = {367, 358, 361}, [2150] = {362, 363, 361},
    [2151] = {362, 358, 366}, [2152] = {366, 364, 2608}, [2153] = {366, 2317, 2373}, [2154] = {367, 363, 366}, [2155] = {1068, 1118, 2612}, [2156] = {1068, 2321, 2377},
    [2157] = {684, 883, 1068}, [2158] = {410, 403, 409}, [2159] = {409, 405, 2609}, [2160] = {409, 2319, 2375}, [2161] = {366, 364, 2610}, [2162] = {366, 2318, 2373},
    [2163] = {367, 363, 371}, [2164] = {0, 0, 0}
}

local ItemRandomProperty = {} -- For items with randomized names

-- Build filtered item_template query
local ItemTemplateQuery = [[
    SELECT entry, class, subclass, quality, BuyPrice, SellPrice, 
           InventoryType, AllowableClass, ItemLevel, RequiredLevel,
           RequiredSkill, RequiredSkillRank, stackable, startquest,
           bonding, BagFamily, flags, name, MaxDurability, ContainerSlots,
		   RandomProperty, spellcharges_1, spellcharges_2, spellcharges_3,
		   spellcharges_4, spellcharges_5, duration, AllowableRace,
		   RandomSuffix
    FROM item_template
]]

if EnableItemFilters then
	local conditions = {} -- We must use a table to store conditions to ensure we're not overwriting "where" statements, in case any of the filter conditions are empty

	if Expansion then
		if Expansion == 1 then
			table.insert(conditions, "entry NOT IN (" .. table.concat(ItemsVanilla, ',') .. ") AND entry < 24284")
		elseif Expansion == 2 then
			table.insert(conditions, "entry NOT IN (" .. table.concat(ItemsTBC, ',') .. ") AND entry < 39657")
		elseif Expansion == 3 then
			table.insert(conditions, "entry NOT IN (" .. table.concat(ItemsWotLK, ',') .. ") AND entry < 56807")
		end
	end
	
	if NeverSellIDs then
		table.insert(conditions, "NOT entry IN (" .. table.concat(NeverSellIDs, ',') .. ")")
	end
	
	if MinContainerSize then
		table.insert(conditions, "NOT (class = 1 AND ContainerSlots < "..MinContainerSize..")")
		table.insert(conditions, "NOT (class = 11 AND ContainerSlots < "..MinContainerSize..")")
	end
	
	if AllowedClassItems then
		if AllowGlyphs then
			table.insert(conditions, "(class = 16 OR AllowableClass IN (" .. table.concat(AllowedClassItems, ',') .. "))")
		else
			table.insert(conditions, "AllowableClass IN (" .. table.concat(AllowedClassItems, ',') .. ")")
		end
	end
	
	if not AllowRecipes then
		table.insert(conditions, "NOT (class = 9)")
	end
	
	if not AllowCompanions then
		table.insert(conditions, "NOT (class = 15 and subclass = 2)")
	end
	
	if not AllowMounts then
		table.insert(conditions, "NOT (class = 15 and subclass = 5)")
	end
	
	if not AllowReputationItems then
		table.insert(conditions, "RequiredReputationFaction = 0")
	end
	
	if AllowedHordeRaces then
		table.insert(conditions, "AllowableRace IN (" .. table.concat(AllowedHordeRaces, ',') .. ")")
	end
	
	if AllowedAllyRaces then
		table.insert(conditions, "AllowableRace IN (" .. table.concat(AllowedAllyRaces, ',') .. ")")
	end
	
	if not AllowKeys then
		table.insert(conditions, "(BagFamily & 256) = 0")
		table.insert(conditions, "NOT (class = 13 and subclass = 0)")
	end
	
	if not AllowConjured then
		table.insert(conditions, "(flags & 2) = 0")
	end
	
	if not AllowMisc then
		table.insert(conditions, "(BagFamily & 4) = 0")
		table.insert(conditions, "(BagFamily & 2048) = 0")
		table.insert(conditions, "NOT (class = 15 and subclass = 4)")
	end
	
	if not AllowQuestItems then
		table.insert(conditions, "(BagFamily & 16384) = 0")
		table.insert(conditions, "NOT class = 12")
	end
	
	if not AllowLockpicking then
		table.insert(conditions, "NOT (class = 13 and subclass = 1)")
	end
	
	if not AllowConsumables then
		table.insert(conditions, "NOT (class = 0)")
	end
	
	if not AllowCommonAmmo then
		table.insert(conditions, "NOT (class = 6 and quality < 2)")
	end
	
	if not AllowHolidayItems then
		table.insert(conditions, "NOT (class = 15 and subclass = 3)")
		table.insert(conditions, "HolidayId = 0")
	end 
	
	if AllowedBinds then
		table.insert(conditions, "bonding IN (" .. table.concat(AllowedBinds, ',') .. ")")
	end

	if AllowedQualities then
		table.insert(conditions, "quality IN (" .. table.concat(AllowedQualities, ',') .. ")")
	end

	if not AllowDeprecated then
		-- Obsolete/unused/unavailable items
		table.insert(conditions, "(flags & 16) = 0")
		table.insert(conditions, "NOT (NAME LIKE '%OLD%' AND NAME COLLATE utf8mb4_bin LIKE '%OLD%')")
		table.insert(conditions, "UPPER(NAME) NOT LIKE '%NPC%'")
		table.insert(conditions, "UPPER(NAME) NOT LIKE '%QA%'")
		table.insert(conditions, "UPPER(NAME) NOT LIKE '%enchant ring%'")
		table.insert(conditions, "NAME NOT LIKE '%tablet%'")
		table.insert(conditions, "NAME NOT LIKE '%throwing dagger%'")
		table.insert(conditions, "NAME NOT LIKE '%shot pouch%'")
		table.insert(conditions, "NAME NOT LIKE '%brimstone%'")
		table.insert(conditions, "NAME NOT LIKE '%small pouch%'")
		table.insert(conditions, "NAME NOT LIKE '%stormjewel%'")
		table.insert(conditions, "NAME NOT LIKE '%dye%'")
		table.insert(conditions, "NAME NOT LIKE '%feathers of azeroth%'")
		table.insert(conditions, "NAME NOT LIKE '%broken%throwing%'")
		table.insert(conditions, "NAME NOT LIKE '%northrend meat%'")
		table.insert(conditions, "NAME NOT LIKE '%ironwood seed%'")
		table.insert(conditions, "NAME NOT LIKE '%stranglethorn seed%'")
		table.insert(conditions, "NAME NOT LIKE '%simple wood%'")
		table.insert(conditions, "NAME NOT LIKE '%small sack of coins%'")
		table.insert(conditions, "NAME NOT LIKE '%slimy bag%'")
		table.insert(conditions, "NAME NOT LIKE '%bleach%'")
		table.insert(conditions, "NAME NOT LIKE '%oozing bag%'")
		table.insert(conditions, "NAME NOT LIKE '%Pale Skinner%'")
		table.insert(conditions, "NAME NOT LIKE '%Pioneer Buckler%'")
		table.insert(conditions, "NAME NOT LIKE '%locust wing%'")
		table.insert(conditions, "NAME NOT LIKE '%community token	%'")
		table.insert(conditions, "NAME NOT LIKE '%thick citrine%'")
		table.insert(conditions, "NAME NOT LIKE '%brilliant citrine%'")
		table.insert(conditions, "NAME NOT LIKE '%nightbloom lilac%'")
		table.insert(conditions, "NAME NOT LIKE '%flour%'")
		table.insert(conditions, "NAME NOT LIKE '%brew%'")
		table.insert(conditions, "NAME NOT LIKE '%[PH]%'")
		table.insert(conditions, "NAME NOT LIKE '%(PH)%'")
		table.insert(conditions, "NAME NOT LIKE '%fishing -%'")
		table.insert(conditions, "NAME NOT LIKE '%Sandy Scorpid Claw%'")
		table.insert(conditions, "NAME NOT LIKE '% caster %'")
		table.insert(conditions, "NAME NOT LIKE '%Jeweler''s Kit%'")
		table.insert(conditions, "NAME NOT LIKE '%nightmare berries%'")
		table.insert(conditions, "NAME NOT LIKE '%parchment%'")
		table.insert(conditions, "NAME NOT LIKE '%light quiver%'")
		table.insert(conditions, "NAME NOT LIKE '%honey%'")
		table.insert(conditions, "NAME NOT LIKE '%explosive shell%'")
		table.insert(conditions, "NAME NOT LIKE '%envelope%'")
		table.insert(conditions, "NAME NOT LIKE '%equipment kit%'")
		table.insert(conditions, "NAME NOT LIKE '%/%'")
		table.insert(conditions, "NAME NOT LIKE '%2.0%'")
		table.insert(conditions, "NAME NOT LIKE '%creeping anguish%'")
		table.insert(conditions, "NAME NOT LIKE '%felcloth bag%'")
		table.insert(conditions, "NAME NOT LIKE '%elementium ore%'")
		table.insert(conditions, "NAME NOT LIKE '%unused%'")
		table.insert(conditions, "NAME NOT LIKE '%lava core%'")
		table.insert(conditions, "NAME NOT LIKE '%fiery core%'")
		table.insert(conditions, "NAME NOT LIKE '%sulfuron ingot%'")
		table.insert(conditions, "NAME NOT LIKE '%sak%'")
		table.insert(conditions, "NAME NOT LIKE '%gigantique%'")
		table.insert(conditions, "NAME NOT LIKE '%portable hole%'")
		table.insert(conditions, "NAME NOT LIKE '%deptecated%'")
		table.insert(conditions, "NAME NOT LIKE '%durability%'")
		table.insert(conditions, "NAME NOT LIKE '%big sack%'")
		table.insert(conditions, "NAME NOT LIKE '%decoded%'")
		table.insert(conditions, "NAME NOT LIKE '%knowledge:%'")
		table.insert(conditions, "NAME NOT LIKE '%manual%'")
		table.insert(conditions, "NAME NOT LIKE '%gnome head%'")
		table.insert(conditions, "NAME NOT LIKE '%box of%'")
		table.insert(conditions, "NAME NOT LIKE '%Light Feather%'")
		table.insert(conditions, "NAME NOT LIKE '%Pet Stone%'")
		table.insert(conditions, "NAME NOT LIKE '%Ogrela%'")
		table.insert(conditions, "NAME NOT LIKE '%cache of%'")
		table.insert(conditions, "NAME NOT LIKE '%summoning%'")
		table.insert(conditions, "NAME NOT LIKE '%cut %'")
		table.insert(conditions, "NAME NOT LIKE '%turtle egg%'")
		table.insert(conditions, "NAME NOT LIKE '%jillian%'")
		table.insert(conditions, "NAME NOT LIKE '%heavy crate%'")
		table.insert(conditions, "NAME NOT LIKE '%plain letter%'")
		table.insert(conditions, "NOT (CLASS = 15 AND NAME LIKE '%throw%')")
		table.insert(conditions, "NAME NOT LIKE '%sack of gems%'")
		table.insert(conditions, "NAME NOT LIKE '%plans: darkspear%'")
		table.insert(conditions, "NAME NOT LIKE '%beetle husk%'")
		table.insert(conditions, "NAME NOT LIKE '%froststeel bar%'")
		table.insert(conditions, "NAME NOT LIKE '%firefly dust%'")
		table.insert(conditions, "NAME NOT LIKE '%of swords%'")
		table.insert(conditions, "NAME NOT LIKE '%gnomish alarm%'")
		table.insert(conditions, "NAME NOT LIKE '%tome%'")
		table.insert(conditions, "NOT (NAME LIKE '%broken%' AND NAME LIKE '%throwing%')")
		table.insert(conditions, "NAME NOT LIKE '%ornate spyglass%'")
		table.insert(conditions, "NAME NOT LIKE '%test%'")
		table.insert(conditions, "NAME NOT LIKE '%darkmoon prize%'")
		table.insert(conditions, "NAME NOT LIKE '%frostmourne%'")
		table.insert(conditions, "NAME NOT LIKE '%codex%'")
		table.insert(conditions, "NAME NOT LIKE '%the fall of ameth%'")
		table.insert(conditions, "NAME NOT LIKE '%frostwolf artichoke%'")
		table.insert(conditions, "NAME NOT LIKE '%symbol of kings%'")
		table.insert(conditions, "NAME NOT LIKE '%symbol of divinity%'")
		table.insert(conditions, "NAME NOT LIKE '%word of thawing%'")
		table.insert(conditions, "NAME NOT LIKE '%grimoire%'")
		table.insert(conditions, "NAME NOT LIKE '%deprecated%'")
		table.insert(conditions, "NAME NOT LIKE '%cowardly flight%'")
		table.insert(conditions, "NAME NOT LIKE '%book%'")
		table.insert(conditions, "NAME NOT LIKE '%libram%'")
		table.insert(conditions, "NAME NOT LIKE '%brazie''s%'")
		table.insert(conditions, "NAME NOT LIKE '%guide%'")
		table.insert(conditions, "NAME NOT LIKE '%glyphed breastplate%'")
		table.insert(conditions, "NAME NOT LIKE '%weak flux%'")
		table.insert(conditions, "NAME NOT LIKE '%leatherworking%'")
		table.insert(conditions, "NAME NOT LIKE '%walnut stock%'")
		table.insert(conditions, "NAME NOT LIKE '%virtuoso inking%'")
		table.insert(conditions, "NAME NOT LIKE '%dictionary%'")
		table.insert(conditions, "NAME NOT LIKE '%moonlit katana%'")
		table.insert(conditions, "NAME NOT LIKE '%Omar%'")
		table.insert(conditions, "NAME NOT LIKE '%depleted%'")
		table.insert(conditions, "NAME NOT LIKE '%bottomless inscription bag%'")
		table.insert(conditions, "NAME NOT LIKE '% Crate %' AND NAME NOT LIKE 'Crate %' AND NAME NOT LIKE '% Crate'")
		table.insert(conditions, "NAME NOT LIKE '%90 Epic%'")
		table.insert(conditions, "NAME NOT LIKE '%90 Blue%'")
		table.insert(conditions, "NAME NOT LIKE '%90 Green%'")
		-- Some quest items that show up despite the quest filters
		table.insert(conditions, "NAME NOT LIKE '%blood shard%'")
		table.insert(conditions, "NAME NOT LIKE '%dampscale basilisk eye%'")
		table.insert(conditions, "NAME NOT LIKE '%evil bat eye%'")
		table.insert(conditions, "NAME NOT LIKE '%package%'")
		table.insert(conditions, "NAME NOT LIKE '%signet of beckoning%'")
		table.insert(conditions, "NAME NOT LIKE '%silithid carapace%'")
		table.insert(conditions, "NAME NOT LIKE '%smoke beacon%'")
		table.insert(conditions, "NAME NOT LIKE '%shadoweave belt%'")
		table.insert(conditions, "NAME NOT LIKE '%snickerfang jowl%'")
		table.insert(conditions, "NAME NOT LIKE '%mojo%'")
		table.insert(conditions, "NAME NOT LIKE '%singed%'")
		-- Obsolete item class-subclass combinations
		table.insert(conditions, "NOT (class = 8 and subclass = 0)")
		table.insert(conditions, "NOT (class = 10 and subclass = 0)")
		table.insert(conditions, "NOT (class = 11 and subclass = 0)")
		table.insert(conditions, "NOT (class = 11 and subclass = 1)")
	end

	if MaxLevel then
		table.insert(conditions, "RequiredLevel <= ".. MaxLevel)
	end
	
	if not AllowBindOnAccount then
		table.insert(conditions, "(flags & 134217728) = 0")
	end

	if MinLevelConsumables then
		table.insert(conditions, "NOT (class = 0 AND RequiredLevel < " .. MinLevelConsumables .. ")")
	end

	if MinLevelGear then
		table.insert(conditions, "NOT (class = 4 AND RequiredLevel < " .. MinLevelGear .. ")")
		table.insert(conditions, "NOT (class = 2 AND RequiredLevel < " .. MinLevelGear .. ")")
	end

	if #conditions > 0 then
		ItemTemplateQuery = ItemTemplateQuery .. " WHERE " .. table.concat(conditions, " AND ")
	end
end

local function CheckAuctions(houseId, callback)
    CharDBQueryAsync(string.format("SELECT COUNT(*) FROM auctionhouse WHERE itemowner IN (%s) and houseid = %d", botList, houseId),
	function(countResult)
		if countResult then
			local count = countResult:GetUInt64(0)
			postedAuctions[houseId] = count
			callback(count)
		end
	end)
end

function bitAnd(a, b)
    local result = 0
    local shift = 0
    while a > 0 or b > 0 do
        -- Check the least significant bit of both numbers
        if a % 2 == 1 and b % 2 == 1 then
            result = result + 2^shift
        end
        -- Right shift both numbers by 1 (essentially dividing by 2)
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        shift = shift + 1
    end
    return result
end

-- Helper function to convert Quality number to string key
local function getQualityString(Quality)
    local QualityStrings = {
        [0] = "Gray/Poor",
        [1] = "White/Common",
        [2] = "Green/Uncommon",
        [3] = "Blue/Rare",
        [4] = "Purple/Epic",
        [5] = "Orange/Legendary",
        [6] = "Red/Artifact",
        [7] = "Gold/Heirloom"
    }
    return QualityStrings[Quality]
end

local function SelectRandomItems()
    local groupedItems = {
        Gear = {},
        Mats = {},
        Glyph = {},
        Projectile = {},
        Other = {},
        SpecificItems = {}
    }
    
    for _, item in pairs(itemCache) do
        if ItemWeights.SpecificItems[item.entry] then
            local weight = ItemWeights.SpecificItems[item.entry]
            for i = 1, weight do
                table.insert(groupedItems.SpecificItems, item)
            end
        elseif item.class == 2 or item.class == 4 then
            local Quality = item.Quality
            groupedItems.Gear[Quality] = groupedItems.Gear[Quality] or {}
            local weight = ItemWeights.Gear[getQualityString(Quality)]
            for i = 1, weight do
                table.insert(groupedItems.Gear[Quality], item)
            end
        elseif item.class == 7 then
            local Quality = item.Quality
            groupedItems.Mats[Quality] = groupedItems.Mats[Quality] or {}
            local weight = ItemWeights.Mats[getQualityString(Quality)]
            for i = 1, weight do
                table.insert(groupedItems.Mats[Quality], item)
            end
        elseif item.class == 6 then
            for i = 1, ItemWeights.Projectile do
                table.insert(groupedItems.Projectile, item)
            end
        elseif item.class == 16 then
            for i = 1, ItemWeights.Glyph do
                table.insert(groupedItems.Glyph, item)
            end
        else
            for i = 1, ItemWeights.Other do
                table.insert(groupedItems.Other, item)
            end
        end
    end
    
    local selectedItems = {}
    for i = 1, ActionsPerCycle do
        -- Calculate total weight each time as groups may be emptied
        local totalWeight = 0
        local weightMap = {}
        
        -- Add weights for Gear qualities that still have items
        for Quality, items in pairs(groupedItems.Gear) do
            if #items > 0 then
                local weight = ItemWeights.Gear[getQualityString(Quality)]
                if weight > 0 then
                    totalWeight = totalWeight + weight
                    table.insert(weightMap, {
                        weight = weight,
                        items = items,
                        cumWeight = totalWeight
                    })
                end
            end
        end
        
        -- Add weights for Mats qualities that still have items
        for Quality, items in pairs(groupedItems.Mats) do
            if #items > 0 then
                local weight = ItemWeights.Mats[getQualityString(Quality)]
                if weight > 0 then
                    totalWeight = totalWeight + weight
                    table.insert(weightMap, {
                        weight = weight,
                        items = items,
                        cumWeight = totalWeight
                    })
                end
            end
        end
        
        -- Add weight for Glyphs if any remain
        if #groupedItems.Glyph > 0 then
            totalWeight = totalWeight + ItemWeights.Glyph
            table.insert(weightMap, {
                weight = ItemWeights.Glyph,
                items = groupedItems.Glyph,
                cumWeight = totalWeight
            })
        end
        
        -- Add weight for Projectiles if any remain
        if #groupedItems.Projectile > 0 then
            totalWeight = totalWeight + ItemWeights.Projectile
            table.insert(weightMap, {
                weight = ItemWeights.Projectile,
                items = groupedItems.Projectile,
                cumWeight = totalWeight
            })
        end
        
        -- Add weight for Other if any remain
        if #groupedItems.Other > 0 then
            totalWeight = totalWeight + ItemWeights.Other
            table.insert(weightMap, {
                weight = ItemWeights.Other,
                items = groupedItems.Other,
                cumWeight = totalWeight
            })
        end
        
        -- Add combined weight for SpecificItems items if any remain
        if #groupedItems.SpecificItems > 0 then
            -- Use the total items count as the effective weight
            local SpecificItemsWeight = #groupedItems.SpecificItems
            totalWeight = totalWeight + SpecificItemsWeight
            table.insert(weightMap, {
                weight = SpecificItemsWeight,
                items = groupedItems.SpecificItems,
                cumWeight = totalWeight
            })
        end
        
        if totalWeight <= 0 then break end
        
        -- Select a group based on weight
        local rand = math.random() * totalWeight
        for _, entry in ipairs(weightMap) do
            if rand <= entry.cumWeight then
                -- Select random item from the chosen group
                local items = entry.items
                local itemIndex = math.random(1, #items)
                table.insert(selectedItems, items[itemIndex])
                table.remove(items, itemIndex)
                break
            end
        end
    end
    
    return selectedItems
end

---------------------------------------------------------------------------------
-- Cost Formulas
---------------------------------------------------------------------------------

function ChooseCostFormula(formulaNum, item)
    -- Set up base modifiers
    local q if item.Quality == 0 then q = 1 elseif item.Quality == 3 then q = 2.2 else q = item.Quality end
    local p if item.BuyPrice == 0 then if item.ItemLevel > 150 then p = item.ItemLevel/30 else p = 1 end elseif item.class == 2 then p = item.BuyPrice * 0.4 else p = item.BuyPrice * 0.8 end
    local s if item.SellPrice == 0 then if item.ItemLevel > 150 then s = item.ItemLevel/30 else s = 1 end elseif item.class == 2 then s = item.SellPrice * 0.4 else s = item.SellPrice * 0.8 end
    local l if item.ItemLevel == 0 then l = 1 elseif item.ItemLevel > 226 then l = item.ItemLevel * 2.5 else l = item.ItemLevel end
							
    if AHBotItemDebug then
        print("- Quality (q) type:", type(q), "Value:", q)
        print("- BuyPrice (p) type:", type(p), "Value:", p)
        print("- SellPrice (s) type:", type(s), "Value:", s)
        print("- ItemLevel (l) type:", type(l), "Value:", l)
        print("- Entry type:", type(item.entry), "Value:", item.entry)
    end
	
    -- Choose formula based on input
    if formulaNum == 1 then
        local price = (q / 3 * p / 10 * l * 1.2)
        
        -- Cap weapons at 2M ± 20%
        if item.class == 2 and price > 2000000 then
            local variance = 2000000 * 0.05
            price = 2000000 + math.random(-variance, variance)
        elseif item.entry == 50182 then -- Blood Queen's Choker should probably be more expensive than other BoEs
			price = price * 3
		end
        
        return price
    elseif formulaNum == 2 then
        return (q * p * s * l * item.entry) / 100000
    elseif formulaNum == 3 then
        return (q * q * l * item.RequiredLevel * 1.5) * 100
    elseif formulaNum == 4 then
        return ((q + l) * (item.RequiredLevel + 50) * (p + s) / 1000) * 
               (item.ItemLevel > 200 and 2 or 1)
    elseif formulaNum == 5 then
        local qualityMod = q * (item.Quality >= 3 and 1.5 or 1)
        local levelMod = (item.RequiredLevel / 10) * (item.ItemLevel / 50)
        local priceMod = ((p + s) / 1000) * (item.BuyPrice > 100000 and 1.3 or 1)
        return qualityMod * levelMod * priceMod * 10000
    else
        return math.random(1000, 1000000)
    end
end

---------------------------------------------------------------------------------
-- AH Bot Buyer Script
---------------------------------------------------------------------------------

local function AHBot_BuyAuction()
    local query
    if BotsBuyFromBots then
        query = string.format("SELECT id, itemguid, houseid, itemowner, buyoutprice, buyguid, lastbid, startbid, time FROM auctionhouse WHERE houseid IN (%s) LIMIT %d", houseList, ActionsPerCycle)
        if AHBotActionDebug then print("[Eluna AH Bot Debug]: Buyer - Starting buy cycle including bot sellers") end
    else
        query = string.format("SELECT id, itemguid, houseid, itemowner, buyoutprice, buyguid, lastbid, startbid, time FROM auctionhouse WHERE itemowner NOT IN (%s) AND houseid IN (%s) LIMIT %d", botList, houseList, ActionsPerCycle)
        if AHBotActionDebug then print("[Eluna AH Bot Debug]: Buyer - Starting buy cycle excluding bot sellers") end
    end
    
	CharDBQueryAsync(query, function(results)
		if not results then if BuyOnStartup and SellOnStartup then BuyOnStartup = false SendMessageToGMs("No eligible items to buy. Loading in new auctions...") RunCommand("reload auctions") end return end
		
		local tempResults = {}
		local auctionResults = {}
		
		-- First, store all results in temporary table to not gum up the query handling
		repeat
			table.insert(tempResults, {
				id = results:GetUInt32(0),
				itemguid = results:GetUInt32(1),
				houseid = results:GetUInt32(2),
				itemowner = results:GetUInt32(3),
				buyoutprice = results:GetUInt32(4),
				buyguid = results:GetUInt32(5),
				lastbid = results:GetUInt32(6),
				startbid = results:GetUInt32(7),
				bidtime = results:GetUInt32(8)
			})
		until not results:NextRow() or #tempResults >= ActionsPerCycle
		
		-- Then process the temporary table to remove entries we don't want to place bids/buyouts on
		if DisableBidFight then
			for _, result in ipairs(tempResults) do
				if result.buyguid == 0 then -- Don't do anything if the auction already has a bidder
					table.insert(auctionResults, result)
				end
			end
		else
			auctionResults = tempResults
		end
		
        if AHBotActionDebug then print("[Eluna AH Bot Debug]: Buyer - Found " .. #auctionResults .. " potential auctions to process") end

        if not (#auctionResults > 0) then return end -- Prevents null query in item_instance table

        local itemGuids = {}
        for _, auction in ipairs(auctionResults) do
            table.insert(itemGuids, auction.itemguid)
        end

        local itemQuery = string.format("SELECT guid, itemEntry FROM item_instance WHERE guid IN (%s)", table.concat(itemGuids, ","))

        CharDBQueryAsync(itemQuery, function(itemResults)
            if not itemResults then return end
            
            local itemEntries = {}
            repeat
                local guid = itemResults:GetUInt32(0)
                local itemEntry = itemResults:GetUInt32(1)
                itemEntries[guid] = itemEntry
            until not itemResults:NextRow()
            
            local underpricedItems = {}
            for _, item in pairs(itemCache) do
                if AHBotItemDebug then print("[Eluna AH Bot Item Debug]: Evaluating item " .. item.entry .. " for price calculation") end
                
                local validItem = false
                if ItemLevelLimit then
                    if item.ItemLevel < ItemLevelLimit then 
                        validItem = true 
                        if AHBotItemDebug then print("[Eluna AH Bot Item Debug]: Item " .. item.entry .. " meets level requirement of " .. ItemLevelLimit) end
                    end
                end

                if validItem then
                    if AHBotItemDebug then print("[Eluna AH Bot Item Debug]: Calculating price for valid item " .. item.entry) end
                    local randomBot = AHBots[math.random(1, #AHBots)]
                    local cost = ChooseCostFormula(CostFormula, item)

                    cost = cost * BotsPriceTolerance
                    if cost < 200000 then cost = math.random(50000, 250000) end
                    if AHBotItemDebug then print("[Eluna AH Bot Item Debug]: Final adjusted cost for item " .. item.entry .. ": " .. cost) end

                    for _, auction in ipairs(auctionResults) do
                        if itemEntries[auction.itemguid] == item.entry and auction.buyoutprice < cost then
                            if AHBotItemDebug then print("[Eluna AH Bot Item Debug]: Buyer - Found underpriced item " .. item.entry .. " at " .. auction.buyoutprice .. " vs calculated " .. cost) end
                            table.insert(underpricedItems, {
                                entry = item.entry,
                                currentPrice = auction.buyoutprice,
                                calculatedValue = cost,
                                auctionId = auction.id
                            })
                        end
                    end
                end
            end

            if AHBotActionDebug then print("[Eluna AH Bot Debug]: Buyer - Found " .. #underpricedItems .. " underpriced items to roll buyout/bid on.") end
			
			if #underpricedItems == 0 then
				if BuyOnStartup and SellOnStartup then
					BuyOnStartup = false
					SendMessageToGMs("No eligible items to buy. Loading in new auctions...") RunCommand("reload auctions")
				end
				return
			end

			BuyOnStartup = false
			
            local transactions = {}
            for _, item in ipairs(underpricedItems) do
                if AHBotItemDebug then print("[Eluna AH Bot Debug]: Processing transaction chances for item " .. item.entry) end
                local bidRoll = math.random(1, 100)
                local buyoutRoll = math.random(1, 100)
                local bidChance = bidRoll <= PlaceBidChance
                local buyoutChance = buyoutRoll <= PlaceBuyoutChance

                if buyoutRoll + bidRoll > 100 then
                    bidRoll = 100 - buyoutRoll
                    bidChance = bidRoll <= PlaceBidChance
                    if AHBotItemDebug then print("[Eluna AH Bot Debug]: Adjusted bid roll for item " .. item.entry .. " to " .. bidRoll) end
                end

                local matchingAuction
                for _, auction in ipairs(auctionResults) do
                    if auction.id == item.auctionId then
                        matchingAuction = auction
                        break
                    end
                end

				if matchingAuction then
					local transactionType = nil
					if buyoutRoll <= PlaceBuyoutChance then
						transactionType = "buyout"
					elseif bidRoll <= PlaceBidChance then
						transactionType = "bid"
					end

					if transactionType then
						local price
						
						if transactionType == "buyout" then
							price = matchingAuction.buyoutprice
						else  -- bid
							local minBid = math.max(matchingAuction.startbid * 1.10, matchingAuction.buyoutprice * 0.60)
							local maxBid = matchingAuction.buyoutprice * 0.95

							if minBid >= maxBid then  -- If no valid bid range exists, default to  buyout
								transactionType = "buyout"
								price = matchingAuction.buyoutprice
							else
								price = math.random(minBid, maxBid)
							end
						end
						
						table.insert(transactions, {
							transactionType = transactionType,
							entry = item.entry,
							itemGuid = matchingAuction.itemguid,
							auctionId = matchingAuction.id,
							itemOwner = matchingAuction.itemowner,
							price = price,
							houseid = matchingAuction.houseid
						})
					end
				end
            end
			if #transactions > 0 then
				local query = "UPDATE auctionhouse SET "
				local ids = {}
				local buyguidCases = {}
				local lastbidCases = {}
				local timeCases = {}

				for _, transaction in ipairs(transactions) do
					local randomBot = AHBots[math.random(1, #AHBots)]
					table.insert(buyguidCases, "WHEN " .. transaction.auctionId .. " THEN " .. randomBot)
					table.insert(lastbidCases, "WHEN " .. transaction.auctionId .. " THEN " .. transaction.price)
					table.insert(ids, transaction.auctionId)

					if transaction.transactionType == "buyout" then
						table.insert(timeCases, "WHEN " .. transaction.auctionId .. " THEN " .. os.time())
					else
						table.insert(timeCases, "WHEN " .. transaction.auctionId .. " THEN time")
					end
				end

				query = query .. "buyguid = CASE id " .. table.concat(buyguidCases, " ") .. " END, "
				query = query .. "lastbid = CASE id " .. table.concat(lastbidCases, " ") .. " END, "
				query = query .. "time = CASE id " .. table.concat(timeCases, " ") .. " END "
				query = query .. "WHERE id IN(" .. table.concat(ids, ",") .. ")"

				CharDBQueryAsync(query, function()
					SendMessageToGMs("Refreshing auctions cache to pick up new bot transactions...")
					RunCommand("reload auctions")
					if AHBotActionDebug then print("[Eluna AH Bot Debug]: Buyer - Finished placing " .. #transactions .. " buyouts/bids.") end
				end)
			end
		end)
    end)
end

---------------------------------------------------------------------------------
-- AH Bot Seller Script
---------------------------------------------------------------------------------

local currentHouse = 0
local lastAuctionId

local function AddAuctions(specificHouse)
	local houseId = 0
	
	if specificHouse then currentHouse = specificHouse end
	
	if currentHouse == 15 or currentHouse == 13 or currentHouse == 9 or currentHouse == 7 then houseId = 7
	elseif currentHouse == 8 or currentHouse == 6 then houseId = 6
	elseif currentHouse == 2 then houseId = 2 end
	
	if houseId == 0 then return end
	
	if AHBotActionDebug then print("[Eluna AH Bot Debug]: Seller - Processing auctions for house ID: " .. houseId) end
	
	CheckAuctions(houseId, function(auctionCount) -- Check how many auctions posted by the AH bot are on the AH
		if (auctionCount < MinAuctions) or (specificHouse or ((auctionCount < MaxAuctions) and (math.random(100) <= RepopulationChance))) then
			local selectedItems = SelectRandomItems()
			if AHBotActionDebug then print("[Eluna AH Bot Debug]: Seller - Item selection complete.") end
	
			CharDBQueryAsync("SELECT guid, AddedByEluna FROM item_instance ORDER BY AddedByEluna DESC", function(itemResult)
				local availableGuids = {}
				local maxGuid = 0
				local usedGuids = {}
				
				-- Get highest and second highest AddedByEluna and build used GUIDs set
				local highestAddedByEluna = 0
				local NotAddedByEluna = 0
				local maxGuidForSecondHighest = 0
				
				repeat
					local guid = itemResult:GetUInt32(0)
					local AddedByEluna = itemResult:GetUInt32(1)
					
					usedGuids[guid] = true
					maxGuid = math.max(maxGuid, guid)
					
					if AddedByEluna > highestAddedByEluna then
						NotAddedByEluna = highestAddedByEluna
						highestAddedByEluna = AddedByEluna
					elseif AddedByEluna > NotAddedByEluna and AddedByEluna < highestAddedByEluna then
						NotAddedByEluna = AddedByEluna
					end
					
					if AddedByEluna == NotAddedByEluna then
						maxGuidForSecondHighest = math.max(maxGuidForSecondHighest, guid)
					end
				until not itemResult:NextRow()
				
				-- If only one AddedByEluna found, use maxGuid as the upper bound
				local upperBound = NotAddedByEluna > 0 and maxGuidForSecondHighest or maxGuid
				
				-- Find available GUIDs below the upper bound
				for i = 1, upperBound do
					if not usedGuids[i] then
						table.insert(availableGuids, i)
						if #availableGuids >= ActionsPerCycle then
							break
						end
					end
				end
				
				-- If we need more GUIDs, check the AddedByEluna status of maxGuid
				if #availableGuids < ActionsPerCycle then
					local nextGuid
					-- If maxGuid was added by Eluna (AddedByEluna = 1), just continue from there
					if usedGuids[maxGuid] and highestAddedByEluna > 0 then
						nextGuid = maxGuid + 1
					else
						-- If not added by Eluna, start at maxGuid + 10mln
						nextGuid = maxGuid + 10000000
					end
					
					while #availableGuids < ActionsPerCycle do
						table.insert(availableGuids, nextGuid)
						nextGuid = nextGuid + 1
					end
				end
				
				if AHBotActionDebug then print("[Eluna AH Bot Debug]: Seller - Found " .. #availableGuids .. " available item GUIDs for next batch") end
				
				CharDBQueryAsync("SELECT id, AddedByEluna FROM auctionhouse ORDER BY AddedByEluna DESC", function(result)
					local availableIds = {}
					local maxId = 0
					local usedIds = {}
					local MaxIdNotAddedByEluna = 0
					local NotAddedByEluna
					local isEmpty = true
				   
					if result then repeat
						isEmpty = false  -- If we enter the loop, table is not empty
						local id = result:GetUInt32(0)
						local AddedByEluna = result:GetUInt32(1)
					   
						usedIds[id] = true
					   
						maxId = math.max(maxId, id)
					   
						if AddedByEluna == 0 then
							MaxIdNotAddedByEluna = math.max(MaxIdNotAddedByEluna, id)
							NotAddedByEluna = true
						end
						
					until not result:NextRow() end
					
					if MaxIdNotAddedByEluna == 0 then MaxIdNotAddedByEluna = maxId end
					
					if isEmpty then -- If table is empty, start from 10 000 000
						local nextId = 10000000
						while #availableIds < ActionsPerCycle do
							table.insert(availableIds, nextId)
							nextId = nextId + 1
						end
					else
						local upperBound = NotAddedByEluna and MaxIdNotAddedByEluna or maxId
						
						if NotAddedByEluna then -- If there are auctions not added by Eluna in current server session, fill in gaps
							for i = 1, upperBound do
								if not usedIds[i] then
									table.insert(availableIds, i)
									if #availableIds >= ActionsPerCycle then
										break
									end
								end
							end
						else -- If there are only auctions added by Eluna in current server session, continue from highest auction ID
							local nextId = maxId + 1
							while #availableIds < ActionsPerCycle do
								table.insert(availableIds, nextId)
								nextId = nextId + 1
							end
						end
						
						-- If we need more IDs, add them above maxId in increments
						if #availableIds < ActionsPerCycle then
							local nextId = math.max(MaxIdNotAddedByEluna + 10000000, maxId + 1)
							while #availableIds < ActionsPerCycle do
								table.insert(availableIds, nextId)
								nextId = nextId + 1
							end
						end
					end
					
					local itemQueryParts = {}
					local auctionQueryParts = {}
					local auctionCount = 0
					
					for _, item in ipairs(selectedItems) do
						if AHBotItemDebug then print("[Eluna AH Bot Item Debug]: Processing item "..item.name) end
						local isAllowed = false
						if houseId == 7 or item.race == 2147483647 or item.race == -1 then 
							isAllowed = true
						elseif houseId == 2 then -- Alliance AH, check if horde race is present in item_template
							for _, race in ipairs(AllowedAllyRaces) do
								if (bitAnd(item.race, race) ~= 0) then 
									isAllowed = true
									break
								end
							end
						elseif houseId == 6 then -- Horde AH, check if ally race is present in item_template
							for _, race in ipairs(AllowedHordeRaces) do
								if (bitAnd(item.race, race) ~= 0) then
									isAllowed = true
									break
								end
							end
						end

						if not isAllowed then
							if AHBotItemDebug then print("[Eluna AH Bot Item Debug]: Removing item " .. item.name .. " from queue due to belonging to another faction than auction house ID "..houseId) end
						else
							auctionCount = auctionCount + 1
							lastItemId = availableGuids[1]
							table.remove(availableGuids, 1)
							lastAuctionId = availableIds[1]
							table.remove(availableIds, 1)
							
							local randomBot = AHBots[math.random(1, #AHBots)]
							
							local cost = ChooseCostFormula(CostFormula, item)

							local expireTime = os.time() + math.random(6 * 3600, 48 * 3600)

							-- Item type price adjustments
							if RecipePriceAdjustment then if item.class == 9 and not item.name:find("Design:") then cost = cost * RecipePriceAdjustment end end
							if GemPriceAdjustment then if item.class == 3 then cost = cost * GemPriceAdjustment * (1 + (math.random() * 0.4 - 0.2)) end end
							if UndervaluedItemAdjust then if cost < 50000 then if ((item.class == 7 and item.entry > 40000) or (item.name:find("VIII"))) and not (item.Quality > 2 or item.entry == 41511) then cost = cost * UndervaluedItemAdjust end end end -- Adjusts certain profession mats and scrolls if very cheap
							
							-- If cost calculation aimed too low, adjust with a randomized failsafe amount
							if not cost or cost < 1000 then cost = math.random(10000, 100000) end
							
							if item.class == 4 then
								if item.ItemLevel > 200 and item.InventoryType == 9 and item.bonding == 2 then if cost < 500000 then cost = cost * 100 end end -- EOV bracers
							end 
							
							if LowPriceFloor then
								if (((item.class == 15 and item.subclass == 2) or (item.class == 16)) and cost < 200000) then cost = LowPriceFloor * (math.random() * 0.6 + 0.7) end
							else
								if UndervaluedItemAdjust then if (((item.class == 15 and item.subclass == 2) or (item.class == 16)) and cost < 200000) then cost = cost * UndervaluedItemAdjust end end
							end
							
							-- Crafted by
							if item.craftedBy == 1 then item.craftedBy = randomBot end
							
							local stack = 1
							
							if item.class == 6 then
								if AlwaysMaxStackAmmo then
									stack = item.stackable
								end
							elseif StackedItemClasses then
								for _, itemClass in ipairs(StackedItemClasses) do
									if item.class == itemClass then
										if item.stackable > 10 then
											stack = math.ceil(math.random(8, item.stackable))
										else
											stack = math.ceil(math.random(1, item.stackable))
										end
									end
								end
							end
							
							cost = cost * stack
							
							if SellPriceVariance then
								cost = cost * math.random(1 - (SellPriceVariance/100), 1 + (SellPriceVariance/100))
							end
							
							if AdjustedAmmoPrices then
								if item.class == 6 then
									if item.Quality == 1 then cost = math.random(150,5000) end
									if item.Quality == 2 then cost = math.random(10000,100000) end
									if item.Quality == 3 then cost = math.random(100000,150000) end
									if item.Quality == 4 then cost = math.random(200000,350000) end
									if item.Quality == 5 then cost = math.random(350000,1000000) end
								end
							end

							-- Random stats
							local randomStats
							if ApplyRandomProperties then
								if item.RandomProperty > 0 then randomStats = item.RandomProperty -- Random property start
								elseif item.RandomSuffix > 0 then randomStats = (item.RandomSuffix) * -1 -- Random suffix start print("Suffixed item found: "..item.entry..". Stored randomStats value: "..randomStats)
								else randomStats = 0 -- Skip random stats handling
								end
							end
							
							local enchantString = "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
							
							if randomStats > 0 then -- Handle random properties
								local properties = ItemRandomProperty[randomStats]
								if properties then
									local selectedProperty = nil
									
									for _, property in ipairs(properties) do -- First attempt to get a property based on chance
										if math.random(0, 100) <= property.chance then
											selectedProperty = property
											break
										end
									end
									
									if not selectedProperty and #properties > 0 then -- If no property was selected by chance, use the first one
										selectedProperty = properties[1]
									end
									
									if selectedProperty then -- Apply the selected property
										local e1, e2, e3 = table.unpack(ItemRandomProperties[selectedProperty.ench])
										enchantString = "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 "..e1.." 0 0 "..e2.." 0 0 "..e3.." 0 0 0 0 0 0 0 0 "
										randomStats = selectedProperty.ench
										if AHBotItemDebug then 
											print("[Eluna AH Bot Item Debug]: Item "..item.entry.." - Enchants for "..selectedProperty.ench..": "..e1..", "..e2..", "..e3) 
										end
									end
								end
							end
							
							if randomStats < 0 then -- Handle random suffixes
								local suffixOptions = {}
								local suffixOption
								
								-- Caster items, require suffix 
								if item.InventoryType == 23 or item.InventoryType == 20 -- Held in off hands, robes (cloth chest)
								or (item.class == 2 and (item.subclass == 10 or item.subclass == 19))
								or (item.class == 4 and item.subclass == 1) then -- Stamina, spirit, int, spell power, protections etc.
									suffixOptions = {36, 37, 38, 39, 9, 15, 19, 26, 81, 84, 85, 31, 32, 33, 34, 35}
									
								elseif (item.class == 4 and item.subclass == 2) -- Leather and rogue/moonkin
								or (item.class == 2 and (
									item.subclass == 2 or item.subclass == 3 or item.subclass == 6 or
									item.subclass == 13 or item.subclass == 15 or item.subclass == 16 or 
									item.subclass == 17 or item.subclass == 18)) then -- Stamina, Agility. To-do: Boomie leather gear.
									suffixOptions = {56, 63, 68, 69, 71, 74, 84, 89, 91, 31, 32, 33, 34, 35}
									
								elseif (item.class == 4 and item.subclass == 3) then -- Mail gear, hunter/shaman
									suffixOptions = {91, 89, 86, 71, 69, 63, 67, 50, 31, 32, 33, 34, 35}
									
								elseif item.class == 2 or (item.class == 4 and -- Plate gear, remaining weapons
									(item.subclass == 4 or item.subclass == 6)) then -- Plate armor and shields
									suffixOptions = {92, 89, 86, 84, 68, 71, 72, 66, 62, 63, 43, 41, 31, 32, 33, 34, 35}
								else -- Random stats failsafe
									suffixOption = math.random(49, 75)
								end
								
								-- Select a random suffix from the available options
								local selectedSuffix
								
								if suffixOption then
									selectedSuffix = suffixOption
								else
									selectedSuffix = suffixOptions[math.random(1, #suffixOptions)]
								end
								
								local e1, e2, e3, e4, e5 = table.unpack(ItemRandomSuffix[selectedSuffix].Enchantment)
								enchantString = "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 "..e1.." 0 0 "..e2.." 0 0 "..e3.." 0 0 "..e4.." 0 0 "..e5.." 0 0 "
								randomStats = selectedSuffix * -1
								if AHBotItemDebug then print("[Eluna AH Bot Item Debug]: Item "..item.entry.." - Enchants found for "..selectedSuffix..": "..e1..", "..e2..", "..e3..", "..e4..", "..e5) end
							end
							
							cost = math.floor(cost)
							
							local startBid = math.floor(cost * (math.random(51, 90) / 100))
							-- Add item_instance entry
							table.insert(itemQueryParts, "(" .. lastItemId .. ", " .. item.entry .. ", " .. randomBot .. ", " .. item.craftedBy .. ", 0, " .. stack .. ", 0, '" ..
								item.c1 .. " " .. item.c2 .. " " .. item.c3 .. " " .. item.c4 .. " " .. item.c5 .. "', 0, '"..enchantString.."', " ..
								randomStats .. ", " .. item.durability .. ", "..item.duration..", '')")

							-- Add auction entry
							table.insert(auctionQueryParts, string.format("(%d, %d, %d, %d, %d, %d, 0, 0, %d, 1, %d)",
								lastAuctionId, houseId, lastItemId, randomBot, cost, expireTime, startBid, AddedByEluna))
						end
					end
					-- We're nesting our next operations in async queries to ensure they don't overlap and are performed in rapid succession
					if #itemQueryParts > 0 and #auctionQueryParts > 0 then 
					
						local itemQuery = "INSERT INTO item_instance (guid, itemEntry, owner_guid, creatorGuid, giftCreatorGuid, count, duration, charges, flags, enchantments, randomPropertyId, durability, playedTime, text) VALUES " .. table.concat(itemQueryParts, ",")
						local auctionQuery = "INSERT INTO auctionhouse (id, houseid, itemguid, itemowner, buyoutprice, time, buyguid, lastbid, startbid, deposit, AddedByEluna) VALUES " .. table.concat(auctionQueryParts, ",")
						CharDBQueryAsync(itemQuery, function(results) -- Insert items in database first
							CharDBQueryAsync(auctionQuery, function(results) -- Once item inserts are complete, insert auctions
								if AHBotActionDebug then print("[Eluna AH Bot Debug]: Seller - " .. auctionCount .. " auctions added to auction house no. " .. houseId .. ".") end
								currentHouse = currentHouse - houseId
								
								if currentHouse == 0 then
									if BuyOnStartup then
										if AHBotActionDebug then print("[Eluna AH Bot Debug]: Seller - Done processing all included auction houses, proceeding to initiate buyers...") end
										AHBot_BuyAuction()
										SendMessageToGMs("AH bot sellers initiated. Starting buyers...")
										return
									end
									if AHBotActionDebug then print("[Eluna AH Bot Debug]: Seller - Done processing all included auction houses, instantiating auctions!") end
									SendMessageToGMs("Refreshing auctions cache to pick up new bot auctions...")
									RunCommand("reload auctions") -- Instantiates auctions
									NextAHBotSellCycle = os.time() + AHSellTimer * 60 * 60
									return
								end
								if AHBotActionDebug then print("[Eluna AH Bot Debug]: Seller - Scheduling processing of next house ID.") end
								AddAuctions() -- Schedule next auction house
							end)
						end)
					end
				end)
			end)
		else
			if AHBotActionDebug then print("[Eluna AH Bot Debug]: Seller - Action house at capacity (Min auctions: "..MinAuctions..". Current auctions: ".. tostring(auctionCount) .." / " .. MaxAuctions .. "). No action taken, awaiting next cycle on ".. os.date("%H:%M", NextAHBotSellCycle) .. " server time.") end
			if BuyOnStartup then
				AHBot_BuyAuction()
			end
		end
	end)
end

local function AHBot_SellItems(_, _, _, specificHouse)
	if not specificHouse then
		currentHouse = 0
		for _, houseId in ipairs(EnabledAuctionHouses) do
			currentHouse = currentHouse + houseId
		end
	else
		currentHouse = specificHouse
	end
	AddAuctions(specificHouse)
end

---------------------------------------------------------------------------------
-- Initialize item_template cache and initial event scheduling
---------------------------------------------------------------------------------

local ItemTemplateSize = 0

CreateLuaEvent(function()
	WorldDBQueryAsync(ItemTemplateQuery, function(results)
		if AHBotActionDebug then print("[Eluna AH Bot]: Core - Caching item_template.") end
		if results then
			repeat
				local entry = results:GetUInt32(0)
				itemCache[entry] = {
					entry = entry,
					class = results:GetUInt32(1),
					subclass = results:GetUInt32(2),
					Quality = results:GetUInt32(3),
					BuyPrice = results:GetUInt32(4),
					SellPrice = results:GetUInt32(5),
					InventoryType = results:GetUInt32(6),
					AllowableClass = results:GetInt32(7),
					ItemLevel = results:GetUInt32(8),
					RequiredLevel = results:GetUInt32(9),
					RequiredSkill = results:GetUInt32(10),
					RequiredSkillRank = results:GetUInt32(11),
					stackable = results:GetUInt32(12),
					startquest = results:GetUInt32(13),
					bonding = results:GetUInt32(14),
					BagFamily = results:GetUInt32(15),
					flags = results:GetUInt32(16),
					name = results:GetString(17),
					durability = results:GetUInt32(18),
					ContainerSlots = results:GetUInt32(19),
					RandomProperty = results:GetInt32(20),
					c1 = results:GetInt32(21),
					c2 = results:GetInt32(22),
					c3 = results:GetInt32(23),
					c4 = results:GetInt32(24),
					c5 = results:GetInt32(25),
					duration = results:GetUInt32(26),
					race = results:GetInt32(27),
					RandomSuffix = results:GetInt32(28),
					craftedBy = 0
				}
				ItemTemplateSize = ItemTemplateSize + 1
			until not results:NextRow()
			if AHBotActionDebug then print("[Eluna AH Bot]: Core - Finished caching item_template. Valid items: "..ItemTemplateSize..".") end
			
			if SetAsCraftedBy then -- Split out of the query to not delay db ops
				for entry, item in pairs(itemCache) do
					for _, craftedItem in ipairs(craftedItems) do
						if entry == craftedItem then
							item.craftedBy = 1
							break
						end
					end
				end
			end
			
			if EnableSeller then
				WorldDBQueryAsync("SELECT * FROM item_enchantment_template", function(results)
					if results then
						-- Initialize the ItemRandomProperty table if it doesn't exist
						ItemRandomProperty = ItemRandomProperty or {}
						
						repeat
							local entry = results:GetUInt32(0)
							local ench = results:GetUInt32(1)
							local chance = results:GetFloat(2)
							-- Initialize the entry table only once
							if not ItemRandomProperty[entry] then
								ItemRandomProperty[entry] = {}
							end
							
							-- Add the new enchantment data
							table.insert(ItemRandomProperty[entry], {
								ench = ench,
								chance = chance
							})
						until not results:NextRow()
						
						if AHBotActionDebug then 
							print("[Eluna AH Bot Debug]: Seller - Finished caching item_enchantment_template.") 
						end
						
						if SellOnStartup then
							AHBot_SellItems()
						end
					end
				end)
			end
		end
	end)
end, StartupDelay + 100) -- The core may crash if we get MySQL locked from other scripts querying database on load/reload Eluna. Adding slight delay in case StartupDelay is 0.

if EnableSeller then
	AHBotSellEventId = CreateLuaEvent(AHBot_SellItems, AHSellTimer * 60 * 60 * 1000, 0)
	NextAHBotSellCycle = os.time() + AHSellTimer * 60 * 60
	if AHBotActionDebug then print("[Eluna AH Bot Debug]: Seller - AH Bot seller system initialized. Actions scheduled on every " .. AHSellTimer .. " hour(s).") end
end

if EnableBuyer then
	for _, entry in ipairs(EnabledAuctionHouses) do
		AHBotBuyEventId = CreateLuaEvent(AHBot_BuyAuction, AHBuyTimer * 65 * 60 * 1000, 0) -- 5 minutes after seller bots to not cause overlapping lag
		if AHBotActionDebug then print("[Eluna AH Bot Debug]: Buyer - AH Bot buyer system initialized. Actions scheduled on every " .. AHBuyTimer .. " hour(s).") end
	end
	if BuyOnStartup and not SellOnStartup then -- The seller will initiate buyers once done, if both are enabled, so here we must check is not SellOnStartup to not start overlapping buyers
		CreateLuaEvent(AHBot_BuyAuction, StartupDelay + 1000) -- Slight artificial delay in case StartupDelay is 0.
	end
end

---------------------------------------------------------------------------------
-- Management commands
---------------------------------------------------------------------------------

local blockCommands = os.time() + 15 -- Prevents expiring auctions while initially starting AH bot

local function CheckExpiry(houseId)
	blockCommands = os.time() + 300 -- Block expirations for 5 minutes. If the core hasn't expired auctions by now, something is wrong
    CreateLuaEvent(function(eventId)
		if blockCommands < os.time() then
			print("[Eluna AH Bot]: Error expiring auctions " .. (houseId and " in house ID " .. houseId or "") .. ".")
			SendMessageToGMs("Error expiring auctions" .. (houseId and " in house ID " .. houseId or "") .. "!")
			RemoveEventById(eventId)
			blockCommands = 0
		end
		
        local query = "SELECT 1 FROM auctionhouse WHERE itemowner IN (" .. botList .. ")"
        
        if houseId then
            query = query .. " AND houseid = " .. houseId
        end
        
        CharDBQueryAsync(query, function(result)
            if not result then
                print("[Eluna AH Bot]: All bot auctions" .. (houseId and " in house ID " .. houseId or "") .. " have expired.")
                SendMessageToGMs("All bot auctions" .. (houseId and " in house ID " .. houseId or "") .. " have been expired.")
                RemoveEventById(eventId)
				blockCommands = 0
            end
        end)
    end, 5000, 0)
end

local function AHBot_Cmd(event, player, command)
	if not player then return end
	if command:find("ah") then
		if player:GetGMRank() < 1 then
			player:SendBroadcastMessage("You don't have access to this command.")
			return false
		end
	end
	
	if blockCommands > os.time() then
		if command:find("ahbot auctions expire") or command:find("ahbot auctions add") or command:find("ahbot auctions buy") or command:find("ahbot start") then
			player:SendBroadcastMessage("|cFFD8D8E6[Eluna AH Bot GM]|r: This command cannot be used while auctions are being refreshed.")
			return false
		end
	end
	
	local name = player:GetName()
	if command:lower() == "ahbot" or command == "ahbot options" or command == "ahbot help" then
		player:SendBroadcastMessage(" ")
		player:SendBroadcastMessage("|cFFD8D8E6[Eluna AH Bot GM]|r: Welcome to the Eluna AH bot menu. Possible subcommands:")
		player:SendBroadcastMessage("|- .ahbot info: Displays statistics about the auction house bot.")
		player:SendBroadcastMessage("|- .ahbot auctions expire <auction_house_ID/all>: Expires all auctions per house (2/6/7) or all houses.")
		player:SendBroadcastMessage("|- .ahbot auctions add: Force adds a batch of ".. ActionsPerCycle .." auctions to all auction houses.")
		player:SendBroadcastMessage("|- .ahbot auctions buy: Force buys a random batch of auctions from all auction houses.")
		player:SendBroadcastMessage("|- .ahbot stop: Removes the scheduled auction bot events.")
		player:SendBroadcastMessage("|- .ahbot start: Starts the auction bot, if stopped.")
		player:SendBroadcastMessage("|- .ahbot pause <hours>: Pauses the auction bot for the specified number of hours.")
		player:SendBroadcastMessage("|- .ahbot set batchsize <number>: Changes how many items the auction bots processes per cycle.")
		player:SendBroadcastMessage("|- .ahbot set buycycle <hours>: Changes how often the auction house bot checks the auction house to take action.")
		player:SendBroadcastMessage("|- .ahbot set sellcycle <hours>: Changes how often the auction house bot checks the auction house to take action.")
		return false
		
	elseif command:lower() == "ahbot info" then
		local auctionInfo = {}
		for houseId, count in pairs(postedAuctions) do
			if count and not (count == "0") then
				table.insert(auctionInfo, string.format("House ID: %d -> Auctions: %s", houseId, count))
			end
		end
		player:SendBroadcastMessage("|cFFD8D8E6[Eluna AH Bot GM]|r: ---------- INFO ----------")
		player:SendBroadcastMessage("|- Auction house IDs with active bots (2 = ally, 6 = horde, 7 = neutral): ".. houseList)
		player:SendBroadcastMessage("|- Active bot GUID lows: ".. botList)
		player:SendBroadcastMessage("|- Min bot auctions: "..MinAuctions..". Max bot auctions: "..MaxAuctions..".")
		player:SendBroadcastMessage("|- Number of possible items in auction house pool: ".. ItemTemplateSize)
		player:SendBroadcastMessage("|- Bot items on auction houses on last cycle: "..(table.concat(auctionInfo, ", ")))
		player:SendBroadcastMessage("|- Next auction house bot sell cycle (hours:minutes): ".. os.date("%H:%M", NextAHBotSellCycle))
		player:SendBroadcastMessage("|- Next auction house bot buy cycle: in " .. math.ceil((NextAHBotBuyCycle - os.time()) / 60) .. " minutes")
		local status
		if AHBotSellEventId then status = "Online" else status = "Offline" end
		player:SendBroadcastMessage("Status auction house bot seller service: "..status)
		if AHBotBuyEventId then status = "Online" else status = "Offline" end
		player:SendBroadcastMessage("Status auction house bot buyer service: "..status)
		return false
		
	elseif command:lower() == "ahbot auctions expire" or command == "ahbot auctions expire all" then
		CharDBQueryAsync("UPDATE auctionhouse SET time = 1 WHERE itemowner IN (" .. botList .. ")", function(query)
			local player = GetPlayerByName(name)
			SendMessageToGMs("GM "..name.." has set all bot auctions to expire on next auction update. Refreshing auctions cache...")
			RunCommand("reload auctions")
			print("[Eluna AH Bot]: GM "..player:GetGUIDLow().." expired all auction houses' bot auctions.")	
			CheckExpiry()
		end)
		return false
	elseif command:lower() == "ahbot auctions expire 2" then
		CharDBQueryAsync("UPDATE auctionhouse SET time = 1 WHERE itemowner IN (" .. botList .. ") AND houseid = 2", function(query)
			local player = GetPlayerByName(name)
			SendMessageToGMs("GM "..name.." has set bot auctions on house ID 2 to expire on next auction update. Refreshing auctions cache...")
			RunCommand("reload auctions")
			print("[Eluna AH Bot]: GM "..player:GetGUIDLow().." expired bot auctions on auction house 2.")	
			CheckExpiry(2)
		end)
		return false
	elseif command:lower() == "ahbot auctions expire 6" then
		CharDBQueryAsync("UPDATE auctionhouse SET time = 1 WHERE itemowner IN (" .. botList .. ") AND houseid = 6", function(query)
			local player = GetPlayerByName(name)
			SendMessageToGMs("GM "..name.." has set bot auctions on house ID 6 to expire on next auction update. Refreshing auctions cache...")
			RunCommand("reload auctions")
			print("[Eluna AH Bot]: GM "..player:GetGUIDLow().." expired bot auctions on auction house 6.")	
			CheckExpiry(6)
		end)
		return false
	elseif command:lower() == "ahbot auctions expire 7" then
		CharDBQueryAsync("UPDATE auctionhouse SET time = 1 WHERE itemowner IN (" .. botList .. ") AND houseid = 7", function(query)
			local player = GetPlayerByName(name)
			SendMessageToGMs("GM "..name.." has set bot auctions on house ID 7 to expire on next auction update. Refreshing auctions cache...")
			RunCommand("reload auctions") -- Instantiates auctions
			print("[Eluna AH Bot]: GM "..player:GetGUIDLow().." expired bot auctions on auction house 7.")
			CheckExpiry(7)
		end)
		return false
	
	elseif command:lower() == "ahbot auctions buy" then
		AHBot_BuyAuction()
		SendMessageToGMs("GM "..name.." is force buying " .. ActionsPerCycle .. " auctions from all auction houses.")
		print("[Eluna AH Bot]: GM "..player:GetGUIDLow().." force bought auctions on all auction houses.")
		return false
		
	elseif command:lower() == "ahbot auctions add" or command == "ahbot auctions add all" or command == "ahbot auction add all" or command == "auctions add all" or command == "auction add all" then
		local overrideHouse = 0
		for _, houseId in ipairs(EnabledAuctionHouses) do
			overrideHouse = overrideHouse + houseId
		end
		if overrideHouse > 1 then
			AHBot_SellItems(_, _, _, overrideHouse)
			SendMessageToGMs("GM "..name.." has force added " .. ActionsPerCycle .. " auctions to auction house(s) ".. houseList)
			print("[Eluna AH Bot]: GM "..player:GetGUIDLow().." force added auctions on all auction houses: ".. houseList)
		else
			player:SendBroadcastMessage("|cFFD8D8E6[Eluna AH Bot GM]|r: Syntax error. No auction houses enabled in AH bot config.")
		end
		return false
	elseif command:lower():find("ahbot auctions add (%d+)") then
		local _, _, houseId = command:lower():find("ahbot auctions add (%d+)")
		if houseId then
			houseId = tonumber(houseId)
			if houseId == 2 or houseId == 6 or houseId == 7 then
				local houseEnabled = false
				for _, enabledId in ipairs(EnabledAuctionHouses) do
					if enabledId == houseId then
						houseEnabled = true
						AHBot_SellItems(_, _, _, houseId)
						SendMessageToGMs("GM "..player:GetName().." has force added " .. ActionsPerCycle .. " auctions to auction house ID "..houseId..".")
						print("[Eluna AH Bot]: GM "..player:GetGUIDLow().." force added auctions on auction house "..houseId..".")
						break
					end
				end
				if not houseEnabled then
					player:SendBroadcastMessage("|cFFD8D8E6[Eluna AH Bot GM]|r: Syntax error. Auction house not found or disabled in AH bot config.")
				end
			else
				player:SendBroadcastMessage("|cFFD8D8E6[Eluna AH Bot GM]|r: Syntax error. Auction house not found or disabled in AH bot config.")
			end
		end
		return false
		
	elseif command:lower() == "ahbot stop" then
		player:SendBroadcastMessage("|cFFD8D8E6[Eluna AH Bot GM]|r: Syntax error. Please use either '.ahbot stop sell' or '.ahbot stop buy'.")
		return false
	elseif command:lower() == "ahbot stop sell" then
		RemoveEventById(AHBotSellEventId)
		AHBotSellEventId = nil
		NextAHBotSellCycle = nil
		SendMessageToGMs("GM "..name.." has force stopped the auction house seller on all auction houses.")
		print("[Eluna AH Bot]: GM "..player:GetGUIDLow().." just stopped the auction bot seller.")
		return false
	elseif command:lower() == "ahbot stop buy" then
		RemoveEventById(AHBotBuyEventId)
		AHBotBuyEventId = nil
		NextAHBotBuyCycle = nil
		SendMessageToGMs("GM "..name.." has force stopped the auction house buyer on all auction houses.")
		print("[Eluna AH Bot]: GM "..player:GetGUIDLow().." just stopped the auction bot buyer.")
		return false
		
	elseif command:lower() == "ahbot pause" then
		player:SendBroadcastMessage("|cFFD8D8E6[Eluna AH Bot GM]|r: Invalid pause time! Please specify a duration between 1 to 24 hours.")
		return false
	elseif command:find("ahbot pause ") then
		local _, _, pauseTime = command:find("ahbot pause (%d+)")
		if pauseTime and tonumber(pauseTime) >= 1 and tonumber(pauseTime) <= 24 then
			pauseTime = tonumber(pauseTime)
			RemoveEventById(AHBotSellEventId)
			RemoveEventById(AHBotBuyEventId)
			AHBotBuyEventId = CreateLuaEvent(AHBot_BuyAuction, AHBuyTimer * pauseTime * 65 * 60 * 1000, 0)
			AHBotSellEventId = CreateLuaEvent(AHBot_SellItems, AHSellTimer * pauseTime * 60 * 60 * 1000, 0)
			NextAHBotSellCycle = os.time() + pauseTime * 60 * 60
			SendMessageToGMs("GM "..name.." has paused all auction house bots for "..pauseTime.." hours.")
			print("[Eluna AH Bot]: Player "..player:GetGUIDLow().." just paused the auction bot for " .. pauseTime .. " hours.")
		else
			player:SendBroadcastMessage("|cFFD8D8E6[Eluna AH Bot GM]|r: Invalid pause time! Please specify a number between 1 and 24.")
		end
		return false
		
	elseif command:find("ahbot set batchsize ") then
		local batchsize = tonumber(command:match("ahbot%s+set%s+batchsize%s+(%d+)"))
		if batchsize and tonumber(batchsize) >= 1 and tonumber(batchsize) <= MaxAuctions then
			batchsize = tonumber(batchsize)
			ActionsPerCycle = batchsize
			SendMessageToGMs("GM "..name.." has set the auction house bots' batch size to "..batchsize..".")
			print("[Eluna AH Bot]: Player "..player:GetGUIDLow().." just changed the auction bot's batch size to "..batchsize..".")
		else
			player:SendBroadcastMessage("|cFFD8D8E6[Eluna AH Bot GM]|r: Invalid batch size! Please specify a number between 1 and "..MaxAuctions..".")
		end
		return false
		
	elseif command:find("ahbot set sellcycle ") then
		local hours = tonumber(command:match("ahbot%s+set%s+sellcycle%s+(%d+)"))
		if hours and tonumber(hours) >= 1 and tonumber(hours) <= 48 then
			hours = tonumber(hours)
			AHSellTimer = hours
			SendMessageToGMs("GM "..name.." has set the auction house bot's sell cycle time has been set to "..hours.." hours. Next cycle is in "..hours.." hour(s) from now.")
			print("[Eluna AH Bot]: GM "..player:GetGUIDLow().." just changed the auction bot's sell cycle time to "..hours.." hour(s).")
		else
			player:SendBroadcastMessage("|cFFD8D8E6[Eluna AH Bot GM]|r: Invalid sell cycle time! Please specify a number between 1 and 48.")
		end
		return false
	elseif command:find("ahbot set buycycle ") then
		local hours = tonumber(command:match("ahbot%s+set%s+buycycle%s+([%d%.]+)"))
		if hours and hours >= 0.1 and hours <= 48 then
			AHBuyTimer = hours
			SendMessageToGMs("GM "..name.." has set the auction house bot's buy cycle time has been set to %.1f minutes. Next cycle is in %.1f minutes from now.", 60 * hours, 60 * hours)
			print(string.format("[Eluna AH Bot]: GM %d just changed the auction bot's buy cycle time to %.1f minutes.", player:GetGUIDLow(), 60 * hours))
		else
			player:SendBroadcastMessage("|cFFD8D8E6[Eluna AH Bot GM]|r: Invalid buy cycle time! Please specify a number between 0.1 and 48.")
		end
		return false
			
	elseif command:lower() == "ahbot start" then
		player:SendBroadcastMessage("|cFFD8D8E6[Eluna AH Bot GM]|r: Incorrect syntax. Use either '.ahbot start sell' or '.ahbot start buy'.")
		return false
	elseif command:lower() == "ahbot start buy" then
		if not AHBotBuyEventId then
			AHBotBuyEventId = CreateLuaEvent(AHBot_BuyAuction, AHBuyTimer * 65 * 60 * 1000, 0)
			NextAHBotBuyCycle = os.time() + AHBuyTimer * 60 * 60
			SendMessageToGMs("GM "..name.." has just started the auction house buyer bot.")
			print("[Eluna AH Bot]: GM "..player:GetGUIDLow().." just started the auction bot buyer.")
		else
			player:SendBroadcastMessage("|cFFD8D8E6[Eluna AH Bot GM]|r: Auction house buyer has already been started. No action taken.")
		end
		return false
	elseif command:lower() == "ahbot start sell" then
		if not AHBotSellEventId then
			AHBotSellEventId = CreateLuaEvent(AHBot_SellItems, AHSellTimer * 60 * 60 * 1000, 0)
			NextAHBotSellCycle = os.time() + AHSellTimer * 60 * 60
			SendMessageToGMs("GM "..name.." has just started the auction house seller bot.")
			print("[Eluna AH Bot]: GM "..player:GetGUIDLow().." just started the auction bot seller.")
		else
			player:SendBroadcastMessage("|cFFD8D8E6[Eluna AH Bot GM]|r: Auction house seller has already been started. No action taken.")
		end
		return false
	
	elseif command:find("ahbot.+") then
		player:SendBroadcastMessage("|cFFD8D8E6[Eluna AH Bot GM]|r: Syntax error. Type .ahbot to see available commands.")
		return false
	end
end

RegisterPlayerEvent(42, AHBot_Cmd)

---------------------------------------------------------------------------------
-- Announce login
---------------------------------------------------------------------------------

if AnnounceOnLogin then
	local function OnPlayerLogin(event, player)
		player:SendBroadcastMessage("This server runs the |cFFD8D8E6[Eluna AH Bot]|r module by mostlynick :)")
		if player:GetGMRank() > 0 then
			player:SendBroadcastMessage("|cFFD8D8E6[Eluna AH Bot GM]|r: Type '.ahbot' to manage, set cache settings, and display statistics.")
		end
	end
	RegisterPlayerEvent(3, OnPlayerLogin)
end

---------------------------------------------------------------------------------
-- End of script
---------------------------------------------------------------------------------
