-- // Created by StarWars
local Players = game:GetService("Players")

local GearService = require(1075123174)

local Tool = script.Parent
local Handle = Tool.Handle
local Drum = Tool.DisplayModel.Drum

local Gear = GearService:BindGear(Tool)
Gear:SetupRemoteFunctions()
Gear:SetupLocalScript("MouseIcon")

local DisplayModel = Tool.DisplayModel

local BaseDrum = DisplayModel.Drum:Clone()
local BaseStick = Handle:Clone()
Drum:Destroy()
DisplayModel:Destroy()

local Animations = {
	DrumRoll = {Animation = Tool.Animations.R6:WaitForChild("DrumRoll"), FadeTime = nil, Weight = nil, Speed = nil, Duration = Handle.DrumRoll.TimeLength},
	Hold = {Animation = Tool.Animations.R6:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
}

local LeftStick = nil
local Drum = nil

Gear:BindEquippedFunction("drum_equip", function()
	if Gear.Humanoid and Gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animations.DrumRoll.Animation = Tool.Animations.R15:WaitForChild("DrumRoll")
		Animations.Hold.Animation = Tool.Animations.R15:WaitForChild("Hold")
	else
		Animations.DrumRoll.Animation = Tool.Animations.R6:WaitForChild("DrumRoll")
		Animations.Hold.Animation = Tool.Animations.R6:WaitForChild("Hold")
	end	
	
	local Animation = Animations.Hold
	spawn(function() Gear.ClientControls:InvokeClient(Gear.Player, "PlayAnimation", Animation) end)
	
	if LeftStick then
		LeftStick:Destroy()
	end
	if Drum then
		Drum:Destroy()
	end
	LeftStick = BaseStick:Clone()
	Drum = BaseDrum:Clone()
	local DrumAttachment = Drum:FindFirstChild("BodyFrontAttachment")
	local Attachment = LeftStick:FindFirstChild("RightGripAttachment")
	if Attachment then
		Attachment.Name = "LeftGripAttachment"
	end
	Drum.Parent = Tool
	LeftStick.Parent = Tool
	
	local LeftArm = Gear.Character:FindFirstChild("Left Arm") or Gear.Character:FindFirstChild("LeftHand")
	local Torso = Gear.Character:FindFirstChild("Torso") or Gear.Character:FindFirstChild("UpperTorso")
	if LeftArm then
		local LeftGripAttachment = LeftArm:FindFirstChild("LeftGripAttachment")
		if LeftGripAttachment then
			if LeftArm.Name == "Left Arm" then
				Attachment.Orientation = Vector3.new(0, 0, 0)
			end
			GearService:WeldToAttachment(Attachment, LeftGripAttachment)
		end
	end
	
	if Torso then
		local BodyFrontAttachment = Torso:FindFirstChild("BodyFrontAttachment")
		if BodyFrontAttachment then
			GearService:WeldToAttachment(DrumAttachment, BodyFrontAttachment)
		end
	end
end)

Gear:BindUnequippedFunction("drum_unequip", function()
	if LeftStick then
		LeftStick:Destroy()
	end
	if Drum then
		Drum:Destroy()
	end
	Drum = nil	
	LeftStick = nil
	Handle.DrumRoll:Stop()		
end)

Gear:BindActivateFunction("drum_activate", function()
	local Animation = Animations.DrumRoll
	spawn(function() 
		Gear.ClientControls:InvokeClient(Gear.Player, "PlayAnimation", Animation) 
		wait(Animation.Duration)
		Gear.ClientControls:InvokeClient(Gear.Player, "StopAnimation", Animation)
	end)
	Handle.DrumRoll:Play()
	wait(5)
end)