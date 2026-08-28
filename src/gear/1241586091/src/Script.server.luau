-- // Created by StarWars
local Debris = game:GetService("Debris")

local Tool = script.Parent

local GearService = require(1075123174)

local Gear = GearService:BindGear(Tool)
Gear:SetupRemoteFunctions()
Gear:SetupLocalScript("MouseIcon")

local AnimationsFolder = Tool.Animations
local R6Folder = AnimationsFolder:WaitForChild("R6")
local R15Folder = AnimationsFolder:WaitForChild("R15")

local Animations =
{
	Cast = {Animation = R6Folder:WaitForChild("Cast")}
}

local ClientControls = Tool:WaitForChild("Remotes"):WaitForChild("ClientControls")

local RELOAD_TIME = 5
local HAIL_DAMAGE = 20

local BaseHailPart = Instance.new("Part")
BaseHailPart.Shape = Enum.PartType.Ball
BaseHailPart.Size = Vector3.new(1, 1, 1)
BaseHailPart.TopSurface = Enum.SurfaceType.Smooth
BaseHailPart.BottomSurface = Enum.SurfaceType.Smooth
BaseHailPart.Color = Color3.new(1, 1, 1)
BaseHailPart.Material = Enum.Material.Ice

Gear:BindEquippedFunction("ice_spell_equipped", function()
	if Gear.Humanoid and Gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animations =
		{
			Cast = {Animation = R15Folder:WaitForChild("Cast")}
		}		
	else
		Animations =
		{
			Cast = {Animation = R6Folder:WaitForChild("Cast")}
		}
	end
end)

Gear:BindActivateFunction("ice_spell_activate", function()
	pcall(function() ClientControls:InvokeClient(Gear.Player, "PlayAnimation", Animations.Cast) end)
	
	spawn(function()
		local StartTime = tick()
		while tick() - StartTime < RELOAD_TIME do
			local NumOfHail = math.random(1, 3)
			
			for i = 1, NumOfHail do
				local t = 2*math.pi*math.random()
				local TouchDebounce = false
				local NewHail = BaseHailPart:Clone()
				NewHail.CFrame = CFrame.new(Gear.Humanoid.RootPart.CFrame.p + Vector3.new(math.random(50)*math.cos(t), 50, math.random(50)*math.sin(t)))
				NewHail.Touched:Connect(function(hit)
					if TouchDebounce then return end 
					TouchDebounce = true
					if hit and hit.Parent and not hit:IsDescendantOf(Gear.Character) then
						local HitHumanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
						if hit.Parent:IsA("Accessory") then
							HitHumanoid = hit.Parent.Parent:FindFirstChildOfClass("Humanoid")
						end
						
						if HitHumanoid then
							HitHumanoid:TakeDamage(HAIL_DAMAGE)
						end
						wait()
						NewHail:Destroy()
					end
					
					TouchDebounce = false
				end)
				Debris:AddItem(NewHail, 5)
				NewHail.Parent = workspace
			end			
			
			wait()
		end
	end)	
	
	wait(RELOAD_TIME)
end)
