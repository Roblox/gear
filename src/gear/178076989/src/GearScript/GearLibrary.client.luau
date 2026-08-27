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
	Gear:WaitForChild("Throw"),
	Gear:WaitForChild("R15Throw")
};
local readyAnimations = {};

local events = {}

Controller.OnClientInvoke = (function(...)
	local tuples={...};
	if (tuples[1] == ClientAgent.REQUEST_TARGETPOINT) then
		return ((Humanoid and Humanoid.TargetPoint) or nil);
	elseif (tuples[1] == ClientAgent.REQUEST_ANIMATIONS) then
		readyAnimations[tuples[2]]:Play();
		return true;
	elseif (tuples[1] == ClientAgent.REQUEST_ANIMATIONS_END) then
		for i, v in pairs(readyAnimations) do v:Stop(); end
		return true;
	end
end);

Gear.Equipped:Connect(function()
	Character = Gear.Parent;
	Player = game.Players.LocalPlayer;
	Character = Player.Character;
	Humanoid = Character:FindFirstChildOfClass("Humanoid");
	if not Character or not Humanoid or Humanoid.Health == 0 then return; end
	if (#readyAnimations == 0) then
		for i=1, #preparedAnimations do
			readyAnimations[preparedAnimations[i].Name] = Humanoid:LoadAnimation(preparedAnimations[i]);
		end
		events[#events+1] = readyAnimations["Throw"].KeyframeReached:Connect(function(k)
			if (k == "tick") then
			--	Controller:InvokeServer(ClientAgent.SERVER_PLAY_SOUND, "pin");
			elseif (k == "throw") then
				Controller:InvokeServer(ClientAgent.SERVER_START);
			end
		end);
		
		events[#events+1] = readyAnimations["R15Throw"].KeyframeReached:Connect(function(k)
			if (k == "tick") then
			--	Controller:InvokeServer(ClientAgent.SERVER_PLAY_SOUND, "pin");
			elseif (k == "throw") then
				Controller:InvokeServer(ClientAgent.SERVER_START);
			end
		end);		
	end
end);

Gear.Unequipped:Connect(function()
	Controller:InvokeServer(ClientAgent.SERVER_START)
	for i=1, #events do
		if events[i] then events[i]:Disconnect();events[i] = nil end
	end
	events = {}
	for i, v in pairs(readyAnimations) do v:Stop(); end
end)

