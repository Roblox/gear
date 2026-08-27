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
	Gear:WaitForChild("Swing")
};
local readyAnimations = {};


Controller.OnClientInvoke = (function(...)
	local tuples={...};
	if (tuples[1] == ClientAgent.REQUEST_TARGETPOINT) then
		return ((Humanoid and Humanoid.TargetPoint) or nil);
	elseif (tuples[1] == ClientAgent.REQUEST_ANIMATIONS) then
		readyAnimations[tuples[2]]:Play();
		return true;
	elseif (tuples[1] == ClientAgent.REQUEST_ANIMATIONS_END) then
		for i, v in pairs(readyAnimations) do readyAnimations[i]:Stop(); end
		return true;
	end
end);

Gear.Equipped:connect(function()
	Character = Gear.Parent;
	Player = game.Players.LocalPlayer;
	Character = Player.Character;
	Humanoid = Character:findFirstChild("Humanoid");
	if not Character or not Humanoid or Humanoid.Health == 0 then return; end
	if (#readyAnimations == 0) then
		for i=1, #preparedAnimations do
			readyAnimations[preparedAnimations[i].Name] = Humanoid:LoadAnimation(preparedAnimations[i]);
		end
		readyAnimations["Swing"].KeyframeReached:connect(function(k)
			if (k == "straight") then
				Controller:InvokeServer(ClientAgent.straight);
			elseif (k == "done") then
				Controller:InvokeServer(ClientAgent.done);
			end
		end);
	end
end);

