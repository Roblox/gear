--Made by Luckymaxer

NPCModule = require(191816425)

function Zombify(Creator, Enemy, Omega)
	if not Enemy then
		return
	end
	local ZombieData = NPCModule.GetTable({Key = "ZombieHunterCrossbow", Player = Creator})
	if not ZombieData then
		return
	end
	local ZombieFunctions = ZombieData.GetData({Player = Creator})
	if not ZombieFunctions then
		return
	end
	local Zombie = ZombieFunctions.ConfigureZombie({Creator = Creator, Enemy = Enemy, Omega = Omega})
	return Zombie
end

return {
	Zombify = Zombify
}