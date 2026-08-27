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
	Gear:WaitForChild("holdAni"),
};
local readyAnimations = {};

local Mouse = nil;
local Mouse_down_connection = nil;
local Mouse_up_connection = nil;


Controller.OnClientInvoke = (function(...)
	local tuples={...};
	if (tuples[1] == ClientAgent.REQUEST_TARGETPOINT) then
		return ((Humanoid and Humanoid.TargetPoint) or nil);
	elseif (tuples[1] == ClientAgent.REQUEST_ANIMATIONS) then
		repeat wait() until readyAnimations[tuples[2]] ~= nil
		readyAnimations[tuples[2]]:Play();
		return true;
	elseif (tuples[1] == ClientAgent.REQUEST_ANIMATIONS_END) then
		for i, v in pairs(readyAnimations) do readyAnimations[i]:Stop(); end
		return true;
	end
end);

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
	
	Mouse_down_connection = Mouse.KeyDown:connect(function(Key)
		Key = Key:lower()
		pcall(function() Controller:InvokeServer(ClientAgent.KEY_DOWN, Key); end);
	end)
	
	Mouse_up_connection = Mouse.KeyUp:connect(function(Key)
		Key = Key:lower()
		pcall(function() Controller:InvokeServer(ClientAgent.KEY_UP, Key); end);
	end)
	
end);

Gear.Unequipped:connect(function()
	if (Mouse_down_connection ~= nil) then
		Mouse_down_connection:disconnect();
		Mouse_down_connection = nil;
	end
	
	if (Mouse_up_connection ~= nil) then
		Mouse_up_connection:disconnect();
		Mouse_up_connection = nil;
	end
end);