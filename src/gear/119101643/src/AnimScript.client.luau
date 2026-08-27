local Tool = script.Parent
local AC = Tool.Handle 

local Humanoid 
local Character
local Player 

local PlayAnim 

local function OnEquipped()
	Character = Tool.Parent 
	Humanoid = Character:WaitForChild('Humanoid') 
	Player = Game.Players:GetPlayerFromCharacter(Character) 
end 

Tool.Equipped:connect(OnEquipped)

PlayAnim = Tool:WaitForChild('PlayAnim')

PlayAnim.Changed:connect(function()
	if PlayAnim and PlayAnim.Value == true then 
--		local lAnim = Humanoid:LoadAnimation(Tool:WaitForChild('LaunchAnim'))
		--if lAnim then lAnim:Play() end 		
		local torso = Character:WaitForChild('Torso')
		local rShoulder = torso:WaitForChild('Right Shoulder') 
		rShoulder.MaxVelocity = 0.04 
		rShoulder.CurrentAngle = math.pi 
		wait(1.5)
		PlayAnim.Value = false 
		rShoulder.MaxVelocity = 0.75
	end 
end) 
