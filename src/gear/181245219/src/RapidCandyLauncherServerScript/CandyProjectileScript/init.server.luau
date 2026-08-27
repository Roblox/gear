local LOW_DAMAGE = 15
local HIGH_DAMAGE = 25


local Candy = script.Parent

local PlayersService = game:GetService("Players")
local RS = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local MonsterData = require(RS:WaitForChild('MonsterData'))
local Utility = require(RS:WaitForChild('Utility'))

local MonsterManager = require(ServerScriptService.MonsterManager)

local MonsterContainer = workspace:WaitForChild("MonsterContainer")


local OwnerTag = script:WaitForChild('Owner')

local MyPlayer = OwnerTag.Value
local MyCharacter = MyPlayer and MyPlayer.Character


local HitHumanoidsList = {}

local function OnTouch(hitObj)
	
	local candyDamage = math.random(LOW_DAMAGE, HIGH_DAMAGE)
	-- Quick check to see if we hit a monster 
	if hitObj:IsDescendantOf(MonsterContainer) then
		local hitMonster, monsterHumanoid = Utility.FindCharacterAncestor(hitObj)
		if hitMonster and hitMonster:IsDescendantOf(MonsterContainer) and not HitHumanoidsList[monsterHumanoid] then
			--if MonsterData.Dawnzilla and MonsterData.Dawnzilla.DisplayName and hitMonster.Name == MonsterData.Dawnzilla then
			--	return
			--end
			monsterHumanoid:TakeDamage(candyDamage)
			HitHumanoidsList[monsterHumanoid] = true
			MonsterManager:TagPlayerCollection(OwnerTag.Value, monsterHumanoid)
		end
	end
end

Candy.Touched:connect(OnTouch)
