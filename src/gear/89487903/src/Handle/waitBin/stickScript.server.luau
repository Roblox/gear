function waitForChild(obj,name)
	while not obj:FindFirstChild(name) do
		wait()
		print("1waiting for " .. name)
	end
	return obj:FindFirstChild(name)
end

local TimePlaced = time()
local MyPart = script.Parent

local RipOutDamage = 15

while not MyPart:FindFirstChild("HorrorAxe") do 
 -- print("waiting for horror axe")
	wait() 
end
local DamagePerTick = 2
local MyTool = MyPart:FindFirstChild("HorrorAxe")
local MyHost = MyPart.Parent
local MyCharacter = MyHost.Parent
local MyHumanoid = waitForChild(MyCharacter,"Humanoid")
 -- WE HAVE TO GO DEEPER
local TakingAxe = false

script.Parent:FindFirstChild("screaming"):Play()

function ReAttachStickbox()
	local tweld = Instance.new("Weld")
	tweld.Part0 = MyPart -- > part0 has to be the parent 
	tweld.Part1 = MyPart:FindFirstChild("stickbox")
	tweld.C0 = CFrame.new()
	tweld.C1 = MyPart:FindFirstChild("stickbox").CFrame:inverse() * MyPart.CFrame
	tweld.Parent = MyPart
end

function OnTouch(hit)
	if (hit.Parent == nil) then return end -- happens when bullet hits sword
	local vhumanoid = hit.Parent:findFirstChild("Humanoid")
	local vPlayer = game.Players:playerFromCharacter(hit.Parent)
	--print("retreveing axe "..vhumanoid.." "..MyHumanoid)
	if vhumanoid ~= nil and vhumanoid ~= MyHumanoid and MyHumanoid ~= nil and time() - TimePlaced>2 and not TakingAxe then
		TakingAxe = true
		print("it's a humanoid")
 -- temptool.Parent = game.Workspace
		MyHumanoid:TakeDamage(RipOutDamage)
		MyTool.Parent = nil
		MyPart.Parent = MyTool
		MyTool.Parent = game.Workspace
		ReAttachStickbox()
		script.Parent:FindFirstChild("screaming"):Stop()
 -- vhumanoid:EquipTool(MyTool)

		script:Destroy()
	end
end
script.Parent.Touched:connect(OnTouch)

while script.Parent do
	MyHumanoid:TakeDamage(DamagePerTick)
	wait(.5)
	
end