--Fixed by Luckymaxer
--[[ alexnewtron 2014 ]]--


local Gear = script.Parent.Parent;
local Player = nil;
local Character = nil;
local Humanoid = nil;
local Controller = script.Parent:WaitForChild("Controller");



local d = {
	Debris = game:GetService("Debris")
};

local ClientAgent = require(script.Parent:WaitForChild("ClientAgent"));
local preparedAnimations = {
	Gear:WaitForChild("EquipAnim"),
	Gear:WaitForChild("Kick"),
	Gear:WaitForChild("QuickSlash"),
	Gear:WaitForChild("ShieldWalk"),
};
ShieldBlock = Gear:WaitForChild("ShieldBlock")
local readyAnimations = {};

Blocking = Gear:WaitForChild("Blocking")

Controller.OnClientInvoke = (function(...)
	local tuples={...};
	if (tuples[1] == ClientAgent.REQUEST_TARGETPOINT) then
		return ((Humanoid and Humanoid.TargetPoint) or nil);
	elseif (tuples[1] == ClientAgent.REQUEST_ANIMATIONS) then
		repeat wait() until readyAnimations[tuples[2]] ~= nil
		readyAnimations[tuples[2]]:Play(.1,1,4);
		return true;
	elseif (tuples[1] == ClientAgent.REQUEST_ANIMATIONS_END) then
		for i, v in pairs(readyAnimations) do readyAnimations[i]:Stop(); end
		return true;
	end
end);

function KeyPress(Key, Down)
	if Key == "q" then
		if Down then
			if ShieldBlockAnim then
				ShieldBlockAnim:Stop()
			end
			ShieldBlockAnim = Humanoid:LoadAnimation(ShieldBlock)
			if ShieldBlockAnim then
				ShieldBlockAnim:Play()
			end
			Blocking:FireServer(true)
		else
			if ShieldBlockAnim then
				ShieldBlockAnim:Stop()
			end	
			Blocking:FireServer(false)
		end
	end
end

local UIS, CAS = game:GetService'UserInputService', game:GetService'ContextActionService'

Gear.Equipped:connect(function(Mouse)
	Character = Gear.Parent;
	Player = game.Players.LocalPlayer;
	Character = Player.Character;
	Humanoid = Character:findFirstChild("Humanoid");
	if not Character or not Humanoid or Humanoid.Health == 0 then return; end
	if (#readyAnimations == 0) then
		for i=1, #preparedAnimations do
			readyAnimations[preparedAnimations[i].Name] = Humanoid:LoadAnimation(preparedAnimations[i]);
		end
	end
	Mouse.KeyDown:connect(function(Key)
		KeyPress(Key, true)
	end)
	Mouse.KeyUp:connect(function(Key)
		KeyPress(Key, false)
	end)
	
	local shieldUp = false
	if UIS.TouchEnabled then
		CAS:BindActionToInputTypes(
			'DragonSwordAndShield_Shield',
			function(action, state, input)
				if state == Enum.UserInputState.Begin then
					if shieldUp then
						CAS:SetTitle('DragonSwordAndShield_Shield', 'Shield In')
						KeyPress('q', false)
						shieldUp = false
					else
						CAS:SetTitle('DragonSwordAndShield_Shield', 'Shield Out')
						KeyPress('q', true)
						shieldUp = true
					end
				end
			end,
			true,
			''
		)
		CAS:SetTitle('DragonSwordAndShield_Shield', 'Shield Out')
	end
	UIS.InputBegan:connect(function(input)
		pcall(function()
			if input.UserInputType == Enum.UserInputType.Gamepad1 then
				if input.KeyCode == Enum.KeyCode.ButtonX then
					if shieldUp then
						KeyPress('q', true)
						shieldUp = false
					else
						KeyPress('q', false)
						shieldUp = true
					end
				end
			end
		end)
	end)
end);

Gear.Unequipped:connect(function()
	if ShieldBlockAnim then
		ShieldBlockAnim:Stop()
	end
	Blocking:FireServer(false)
	
	if UIS.TouchEnabled then
		CAS:UnbindAction'DragonSwordAndShield_Shield'
	end
end)

