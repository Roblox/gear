local Tool = script.Parent
local spraying = false
local torso = nil
local offset = 5
local debris = game:GetService("Debris")

local bubble = Instance.new("Part")
bubble.Shape = 0
bubble.formFactor = 0
bubble.Size = Vector3.new(1,1,1)
bubble.Transparency = 0.2
bubble.BottomSurface = "Smooth"
bubble.TopSurface = "Smooth"
bubble.CanCollide = true

function onEquipped(mouse)

	torso = Tool.Parent:FindFirstChild("Torso", false) or Tool.Parent:FindFirstChild("UpperTorso", false)
	mouse.Button1Down:connect(onButton1Down)
	mouse.Button1Up:connect(onButton1Up)

end

function onUnequipped()

	spraying = false
	Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=27787143"
	Tool.Handle.FoamSound:Stop()


end

function onButton1Down(mouse)

	spraying = true
	Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=27787226"
	Tool.Handle.FoamSound:Play()
	sprayBubbles()

end

function onButton1Up(mouse)

	spraying = false
	Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=27787143"
	Tool.Handle.FoamSound:Stop()

end

function sprayBubbles()

	while spraying do
		
		local sprayDir = torso.CFrame.lookVector.unit

		local bubbleClone = bubble:clone()
		local torsoNormal = torso.CFrame.lookVector
		local denom = math.abs(torsoNormal.x) + math.abs(torsoNormal.z)
		local posX = 5 * (torsoNormal.x/denom)
		local posZ = 5 * (torsoNormal.z/denom)
		bubbleClone.Position = Vector3.new(Tool.Handle.Position.x + posX,Tool.Handle.Position.y,Tool.Handle.Position.z + posZ)
		bubbleClone.Velocity = Vector3.new(sprayDir.x,sprayDir.y + 0.5, sprayDir.z) * 50
		bubbleClone.Size = Vector3.new(math.random(1,2),math.random(1,2),math.random(1,2))
		bubbleClone.Parent = game.Workspace

		local script = Tool.ExtinguishScript:clone()
		script.Parent = bubbleClone
		script.Disabled = false

		debris:AddItem(bubbleClone, 2)
		
		wait(0.05)
	end

end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
