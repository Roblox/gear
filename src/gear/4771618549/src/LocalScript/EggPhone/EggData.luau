
local locService = game:GetService("LocalizationService")
local locTable = script.Parent.LocalizationTable
locTable.Parent = locService
local translator = locTable:GetTranslator(locService.RobloxLocaleId)

local eggFolder = game:GetService("ReplicatedStorage"):FindFirstChild("EggFolder")
if not eggFolder then
	error("[EGG PHONE] EggFolder is not in ReplicatedStorage")
end

local Eggs = {
	{
		EggName = "Eggveloper Egg of X,Y,Z",
		AssetId = 4771627322,
		EggModel = eggFolder.Egg1,
		EggMission = "Egg Hunt Developers have a special launcher that awards these. Find or Follow one into select Egg Hunt games!",
	},
	
	{
		EggName = "Star Creaeggtor Egg",
		AssetId = 4771626425,
		EggModel = eggFolder.Egg2,
		EggMission = "Star Influencers have a special launcher that awards these. Find or Follow one into select Egg Hunt games!",
	},
	
	{
		EggName = "Eleggtrifying Eggmin of 2020",
		AssetId = 4771625250,
		EggModel = eggFolder.Egg3,
		EggMission = "Roblox Admins have a special launcher that awards these. Find or Follow one into select Egg Hunt games!",
	},	
	
	{
		EggName = "Deteggctive W. Wolf",
		AssetId = 4771629993,
		EggModel = eggFolder.Egg4,
		GameName = "A Wolf Or Other",
	},
	
	{
		EggName = "Adopt Me, Chick!",
		AssetId = 4771630939,
		EggModel = eggFolder.Egg5,
		GameName = "Adopt Me",
	},
	
	{
		EggName = "Egg of Hearts",
		AssetId = 4771632285,
		EggModel = eggFolder.Egg6,
		GameName = "Astral Hearts",
	},
	
	{
		EggName = "Eggmunition",
		AssetId = 4771632715,
		EggModel = eggFolder.Egg7,
		GameName = "Bad Business",
	},
	
	{
		EggName = "Royal Egg of the Bearers",
		AssetId = 4771633331,
		EggModel = eggFolder.Egg8,
		GameName = "BEAR (Alpha)",
	},
	
	{
		EggName = "Swarming Egg of the Hive",
		AssetId = 4771636601,
		EggModel = eggFolder.Egg9,
		GameName = "Bee Swarm Simulator",
	},
	
	{
		EggName = "Egg of Hidden Treasures",
		AssetId = 4771699155,
		EggModel = eggFolder.Egg10,
		GameName = "Build A Boat For Treasure",
	},
	
	{
		EggName = "Eggsplosive Artifact of Energy",
		AssetId = 4771700073,
		EggModel = eggFolder.Egg11,
		GameName = "Deathrun",
	},
	
	{
		EggName = "Dragon Eggventure",
		AssetId = 4771701409,
		EggModel = eggFolder.Egg12,
		GameName = "Dragon Adventures",
	},
	
	{
		EggName = "Samurai Egg",
		AssetId = 4771703512,
		EggModel = eggFolder.Egg13,
		GameName = "Dungeon Quest",
	},
	
	{
		EggName = "Eg",
		AssetId = 4771704126,
		EggModel = eggFolder.Egg14,
		GameName = "Eg",
	},
	
	{
		EggName = "Chocolate Bunny Egg",
		AssetId = 4771704668,
		EggModel = eggFolder.Egg15,
		GameName = "Egg Simulator",
	},
	
	{
		EggName = "Epic Egg",
		AssetId = 4773569689,
		EggModel = eggFolder.Egg16,
		GameName = "Epic Minigames",
	},
	
	{
		EggName = "Marine Egghibit",
		AssetId = 4773570265,
		EggModel = eggFolder.Egg17,
		GameName = "Flop",
	},
	
	{
		EggName = "Ghastly Egg",
		AssetId = 4773572356,
		EggModel = eggFolder.Egg18,
		GameName = "Ghost Simulator",
	},
	
	{
		EggName = "Tenteggcle Alien",
		AssetId = 4773576325,
		EggModel = eggFolder.Egg19,
		GameName = "Gravity Oasis",
	},
	
	{
		EggName = "Heroic Egg of Owlsomeness",
		AssetId = 4773577472,
		EggModel = eggFolder.Egg20,
		GameName = "Hero Havoc",
	},	
	
	{
		EggName = "Wicked Egg of Calamity",
		AssetId = 4773578006,
		EggModel = eggFolder.Egg21,
		GameName = "Hotel Stories",
	},		
	
	{
		EggName = "Brainfreeze Egg",
		AssetId = 4773579034,
		EggModel = eggFolder.Egg22,
		GameName = "Break In",
	},			
	
	{
		EggName = "Invasion Egg",
		AssetId = 4773579839,
		EggModel = eggFolder.Egg23,
		GameName = "Mad City",
	},			
	
	{
		EggName = "Lost Egg of the Minery",
		AssetId = 4773581048,
		EggModel = eggFolder.Egg24,
		GameName = "Minery",
	},			
	
	{
		EggName = "The Eggtherian",
		AssetId = 4773581536,
		EggModel = eggFolder.Egg25,
		GameName = "Monsters of Etheria",
	},			
	
	{
		EggName = "Shady Subjeggct",
		AssetId = 4773582960,
		EggModel = eggFolder.Egg26,
		GameName = "MURDER",
	},			
	
	{
		EggName = "My Droplegg",
		AssetId = 4773586330,
		EggModel = eggFolder.Egg27,
		GameName = "My Droplets",
	},			
	
	{
		EggName = "Egg of the High Skies",
		AssetId = 4773586917,
		EggModel = eggFolder.Egg28,
		GameName = "Plane Crazy",
	},			
	
	{
		EggName = "Gourmet Egg",
		AssetId = 4773587852,
		EggModel = eggFolder.Egg29,
		GameName = "Restaurant Tycoon 2",
	},			
	
	{
		EggName = "Despacitegg",
		AssetId = 4773588762,
		EggModel = eggFolder.Egg30,
		GameName = "Robloxian Highschool",
	},			
	
	{
		EggName = "Eggobot",
		AssetId = 4773589791,
		EggModel = eggFolder.Egg31,
		GameName = "Robot Inc",
	},			
	
	{
		EggName = "Eggchanted",
		AssetId = 4773590406,
		EggModel = eggFolder.Egg32,
		GameName = "Royale High",
	},			
	
	{
		EggName = "Saber Boss Egg",
		AssetId = 4773591735,
		EggModel = eggFolder.Egg33,
		GameName = "Saber Simulator",
	},			
	
	{
		EggName = "Egg of Cthulhu",
		AssetId = 4773592634,
		EggModel = eggFolder.Egg34,
		GameName = "Scuba diving at Quill Lake",
	},			
	
	{
		EggName = "Egg of the Shard Seeker",
		AssetId = 4773593495,
		EggModel = eggFolder.Egg35,
		GameName = "Shard Seekers",
	},			
	
	{
		EggName = "Eggraging Shark of the Sea",
		AssetId = 4786869155,
		EggModel = eggFolder.Egg36,
		GameName = "SharkBite",
	},			
	
	{
		EggName = "Britannegg",
		AssetId = 4786870139,
		EggModel = eggFolder.Egg37,
		GameName = "Sinking Ship",
	},			
	
	{
		EggName = "Eggcicle",
		AssetId = 4786871232,
		EggModel = eggFolder.Egg38,
		GameName = "Ski Resort",
	},			
	
	{
		EggName = "Eggcentric Time Capsule",
		AssetId = 4786872252,
		EggModel = eggFolder.Egg39,
		GameName = "Speed Race",
	},			
	
	{
		EggName = "Roundcat Egg",
		AssetId = 4786873036,
		EggModel = eggFolder.Egg40,
		GameName = "Super Doomspire",
	},			
	
	{
		EggName = "Supercharged Striker Egg",
		AssetId = 4786873841,
		EggModel = eggFolder.Egg41,
		GameName = "Super Striker League",
	},			
	
	{
		EggName = "iEgg 12 Max Pro",
		AssetId = 4786874746,
		EggModel = eggFolder.Egg42,
		GameName = "Texting Simulator",
	},			
	
	{
		EggName = "Doc Holidegg",
		AssetId = 4786875556,
		EggModel = eggFolder.Egg43,
		GameName = "The Wild West",
	},			
	
	{
		EggName = "Time Traveler's Egg",
		AssetId = 4786876425,
		EggModel = eggFolder.Egg44,
		GameName = "Time Travel Adventures",
	},			
	
	{
		EggName = "Tiny Tank Egg",
		AssetId = 4786877411,
		EggModel = eggFolder.Egg45,
		GameName = "Tiny Tanks",
	},			
	
	{
		EggName = "Tower of Eggs",
		AssetId = 4786878003,
		EggModel = eggFolder.Egg46,
		GameName = "Tower Defense Simulator",
	},			
	
	{
		EggName = "Dreggon's Breath",
		AssetId = 4786878919,
		EggModel = eggFolder.Egg47,
		GameName = "Treasure Quest",
	},			
	
	{
		EggName = "Cheggered Flag",
		AssetId = 4786879808,
		EggModel = eggFolder.Egg48,
		GameName = "Ultimate Driving: Westover Islands",
	},			
	
	{
		EggName = "Venture Egg",
		AssetId = 4786881030,
		EggModel = eggFolder.Egg49,
		GameName = "Ventureland",
	},			
	
	{
		EggName = "Poached Egg of the Sea",
		AssetId = 4786881984,
		EggModel = eggFolder.Egg50,
		GameName = "Whatever Floats Your Boat",
	},			
	
	{
		EggName = "Fried Chicken Egg",
		AssetId = 4786883113,
		EggModel = eggFolder.Egg51,
		GameName = "Zombie Rush",
	},			
	
	{
		EggName = "Giga Zombegg",
		AssetId = 4786884452,
		EggModel = eggFolder.Egg52,
		GameName = "Zombie Strike",
	},			
	
	{
		EggName = "FabergEgg of the New Decade",
		AssetId = 4771629457,
		EggModel = eggFolder.Egg53,
	},
}

for _,egg in pairs(Eggs) do
	
	if egg.GameName then
		local mission
		local success, fail = pcall(function()
			mission = translator:FormatByKey(egg.GameName) or nil
		end)
		if mission then
			egg.EggMission = mission
		end
	end
	
end

local Games = {

	[2432005634] = { --A Wolf or Other
		Eggs = {Eggs[4], Eggs[1], Eggs[2], Eggs[3]}
	},
	
	[920587237] = { --Adopt Me
		Eggs = {Eggs[5]}
	},
	
	[1090923299] = { --Astral Hearts
		Eggs = {Eggs[6]}
	},
	
	[3233893879] = { --Bad Business
		Eggs = {Eggs[7]}
	},
	
	[3203685552] = { --BEAR
	
		Eggs = {Eggs[8]}
	},
	
	[1537690962] = { --Bee Swarm Sim
		Eggs = {Eggs[9]}
	},
	
	[537413528] = { --Build a Boat
		Eggs = {Eggs[10]}
	},
	
	[537413528] = { --Deathrun
		Eggs = {Eggs[11]}
	},
	
	[537413528] = { --Dragon Adventures
		Eggs = {Eggs[12]}
	},
	
	[4771703512] = { --Dungeon Quest
		Eggs = {Eggs[13]}
	},
	
	[2747834912] = { --Eg
		Eggs = {Eggs[14]}
	},
	
	[2753554889] = { --Egg Simulator
		Eggs = {Eggs[15]}
	},
	
	[277751860] = { --Epic Minigames
		Eggs = {Eggs[16]}
	},
	
	[4504116810] = { --Flop
		Eggs = {Eggs[17]}
	},
	
	[2685347741] = { --Ghost Simulator
		Eggs = {Eggs[18]}
	},
	
	[3652381631] = { --Gravity Oasis
		Eggs = {Eggs[19]}
	},
	
	[2765907688] = { --Hero Havoc
		Eggs = {Eggs[20]}
	},
	
	[3422530062] = { --Hotel Stories
		Eggs = {Eggs[21]}
	},
	
	[3851622790] = { --Break In
		Eggs = {Eggs[22]}
	},
	
	[1224212277] = { --Mad City
		Eggs = {Eggs[23]}
	},
	
	[1827671349] = { --Minery
		Eggs = {Eggs[24]}
	},
	
	[70523152] = { --Monsters of Etheria
		Eggs = {Eggs[25]}
	},
	
	[4572253581] = { --MURDER
		Eggs = {Eggs[26]}
	},
	
	[2773040896] = { --My Droplets
		Eggs = {Eggs[27]}
	},
	
	[3925890721] = { --Robot Inc
		Eggs = {Eggs[28]}
	},
	
	[3398014311] = { --Restaurant Tycoon 2
		Eggs = {Eggs[29]}
	},
	
	[171035019] = { --Robloxian Highschool
		Eggs = {Eggs[30]}
	},
	
	[166986752] = { --Plane Crazy
		Eggs = {Eggs[31]}
	},
	
	[735030788] = { --Royale High
		Eggs = {Eggs[32]}
	},
	
	[3823781113] = { --Saber Simulator
		Eggs = {Eggs[33]}
	},
	
	[35397735] = { --Scuba diving at Quill Lake
		Eggs = {Eggs[34]}
	},
	
	[340416369] = { --Shard Seekers
		Eggs = {Eggs[35]}
	},
	
	[734159876] = { --SharkBite
		Eggs = {Eggs[36]}
	},
	
	[939091785] = { --Sinking Ship
		Eggs = {Eggs[37]}
	},
	
	[18459893] = { --Ski Resort
		Eggs = {Eggs[38]}
	},
	
	[132414630] = { --Speed Race
		Eggs = {Eggs[39]}
	},
	
	[3725149043] = { --Super Doomspire
		Eggs = {Eggs[40]}
	},
	
	[3360853050] = { --Super Striker League
		Eggs = {Eggs[41]}
	},
	
	[2580982329] = { --Texting Simulator
		Eggs = {Eggs[42]}
	},
	
	[2317712696] = { --The Wild West
		Eggs = {Eggs[43]}
	},
	
	[4752736749] = { --Time Travel Adventures
		Eggs = {Eggs[44]}
	},
	
	[204990346] = { --Tiny Tanks
		Eggs = {Eggs[45]}
	},
	
	[3260590327] = { --Tower Defense Simulator
		Eggs = {Eggs[46]}
	},
	
	[2960777560] = { --Treasure Quest
		Eggs = {Eggs[47]}
	},
	
	[54865335] = { --Ultimate Driving: Westover Islands
		Eggs = {Eggs[48]}
	},
	
	[1526666203] = { --Ventureland
		Eggs = {Eggs[49]}
	},
	
	[156220906] = { --Whatever Floats Your Boat
		Eggs = {Eggs[50]}
	},
	
	[137885680] = { --Zombie Rush
		Eggs = {Eggs[51]}
	},
	
	[3759927663] = { --Zombie Strike
		Eggs = {Eggs[52]}
	},
}

local eggFolder = Instance.new("Folder")
eggFolder.Name = "EggFolder"
eggFolder.Parent = game:GetService("ReplicatedStorage")

for _,child in pairs(script:GetChildren()) do
	child.Parent = eggFolder
end

return function(dataValue)
	
	if dataValue == 0 then
		
		return Eggs
		
	elseif dataValue == 1 then
		
		return Games
		
	elseif dataValue == 2 then
		
		local count = 0
		
		for _,egg in pairs(Eggs) do
			
			if egg.Unlocked and egg.Unlocked == true then
				
				count = count + 1
				
			end
			
		end
		
		return count 
		
	end
	
end