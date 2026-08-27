-- // Created by StarWars
local InsertService = game:GetService("InsertService")

local GearService = require(1075123174)

local Tool = script.Parent
if Tool:FindFirstChild("Handle") then
	Tool.Handle:Destroy()
end
local JetpackPart = Tool.Jetpack
JetpackPart.Transparency = 1

local JetpackModel = InsertService:LoadAsset(1177015292)
JetpackModel = JetpackModel:GetChildren()[1]

local Gear = GearService:BindGear(Tool)
Gear:SetupRemoteFunctions()

local Remotes = Tool:WaitForChild("Remotes")
local ServerControls = Remotes:WaitForChild("ServerControls")
local ClientControls = Remotes:WaitForChild("ClientControls")

local CurrentJetpack = nil

function EngineToggle(value)
	if CurrentJetpack and CurrentJetpack:FindFirstChild("Body") then
		for _, attachment in next, CurrentJetpack.Body:GetChildren() do
			if attachment.Name == "EngineAttachment" then
				for _, obj in next, attachment:GetChildren() do
					if obj then
						obj.Enabled = value
					end
				end
			end
		end
	end
end

Gear:BindEquippedFunction("jetpack_equip", function()
	local BodyBackAttachment = Gear.Character:FindFirstChild("BodyBackAttachment", true)
	GearService:WeldToAttachment(JetpackPart:FindFirstChild("BodyBackAttachment"), BodyBackAttachment)	
	
	CurrentJetpack = JetpackModel:Clone()
	CurrentJetpack:SetPrimaryPartCFrame(Gear.Character:GetPrimaryPartCFrame())
	local JetpackAttachment = CurrentJetpack:FindFirstChild("BodyBackAttachment", true)
	
	GearService:WeldToAttachment(JetpackAttachment, BodyBackAttachment)
	CurrentJetpack.Parent = Gear.Character
	
	local AnimateScript = CurrentJetpack:FindFirstChild("Animate")
	if AnimateScript then
		AnimateScript.Disabled = false
	end	
end)

Gear:BindUnequippedFunction("jetpack_unequip", function()
	local MotorGrip = JetpackPart:FindFirstChildOfClass("Motor6D") 
	if MotorGrip then
		MotorGrip:Destroy()
	end
	if CurrentJetpack then
		CurrentJetpack:Destroy()
	end
	
	CurrentJetpack = nil
end)

ServerControls.OnServerInvoke = (function(player, mode, value)
	if player == Gear.Player then
		if mode == "MouseDown" then
			EngineToggle(true)
			JetpackPart.Wind:Play()
		elseif mode == "MouseUp" then
			EngineToggle(false)
			JetpackPart.Wind:Stop()
		end
	end
end)