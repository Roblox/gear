-- For the purpose of animations

local Tool = script.Parent 
local Handle = Tool.Handle 

local vCharacter
local vPlayer
local vTorso
local vHumanoid 

local DiscusThrow


local RBX_Debris = game:GetService('Debris')

local speedUp = 1

local equipped = false

local vMouse

function onEquipped(mouse)
	if equipped then return end
	equipped = true
	vCharacter = Tool.Parent 
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	vHumanoid = vCharacter:FindFirstChild("Humanoid")
	vTorso = vCharacter:FindFirstChild("Torso")
	vMouse = mouse



	if not DiscusThrow then
		DiscusThrow = vHumanoid:LoadAnimation(Tool.DiscusThrow)
	end
end 

function onUnequipped()
	equipped = false	

end



local lastActivatedTime = tick()

function onActivate()
	if tick() - lastActivatedTime > 2.6 / speedUp then
		lastActivatedTime = tick()
		local spin = Instance.new('BodyAngularVelocity', vTorso)
		RBX_Debris:AddItem(spin, 1.6)
		spin.angularvelocity = Vector3.new(0, 2.3, 0) * math.rad(360)
		spin.P = 1000
		spin.maxTorque = Vector3.new(100000000, 100000000, 100000000)
		wait(0.2)
				
		if DiscusThrow then DiscusThrow:Play() end
		wait(0.6)
		spawnDiscus()
		
	end

end

function spawnDiscus()
	local discusCopy = Handle:Clone()
	Handle.Transparency = 1.0
			RBX_Debris:AddItem(discusCopy, 8)
			discusCopy.Parent = Workspace
			if discusCopy:FindFirstChild('vCharacterLoc') and vTorso then
				discusCopy.vCharacterLoc.Value = vTorso.CFrame.p
			end
			if discusCopy:FindFirstChild('ExplosionScript') then
				discusCopy.ExplosionScript.Disabled = false
			end
			local bodyVel = Instance.new("BodyVelocity", discusCopy)
			bodyVel.maxForce = Vector3.new(4000000, 400000, 400000)
			if vTorso then
				bodyVel.velocity = (vTorso.CFrame.lookVector + Vector3.new(0, 0.5, 0)) * 50
			else
				print( 'No Torso Found' )
		end
	wait(2.1)
	Handle.Transparency = 0.0

end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Tool.Activated:connect(onActivate)