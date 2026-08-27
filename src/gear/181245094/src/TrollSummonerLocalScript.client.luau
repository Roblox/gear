-- Made by SolarCrane



local COOLDOWN = 60.0 * 5

local EXIT_CODES =
{
	SUCCESS = "SUCCESS";
	BAD_LOC = "Invalid Spawn Location";
	COOLDOWN = "On Cooldown";
	INVALID_ARG = "Invalid Arguements";
	ERROR = "Error";
}

local COLORFUL_TROLL_FACE = "http://www.roblox.com/asset/?id=180506286"
local COLORLESS_TROLL_FACE = "http://www.roblox.com/asset/?id=180506414"
local TROLL_FACE_SIZE = UDim2.new(0,228,0,229)

local RS = game:GetService('ReplicatedStorage')
local PlayersService = game:GetService("Players")

local Utility = require(RS:WaitForChild('Utility'))
local Signal = require(RS:WaitForChild('Signal'))
local CreateLocalWelder = require(RS:WaitForChild('LocalEquipWeld'))


local LocalPlayer = PlayersService.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local RequestShootServer = Tool:WaitForChild('RequestShootServer')
local TimeLeftUntilSummon = Tool:WaitForChild('TimeLeftUntilSummon')
local LastActivation = 0 --tick()

CreateLocalWelder(Tool)

local TrollSummoningGui = nil


local function CreateGui()
	local this = {}
	
	function this:Show()
		this.Container.Visible = true
	end
	
	function this:Hide()
		this.Container.Visible = false
	end

	function this:Update()
		local now = tick()
		local elapsedTime = now - LastActivation
		local remainingTime = COOLDOWN - elapsedTime
		local alpha = Utility.Clamp(0, 1, elapsedTime / COOLDOWN)
		if this.ColorfulOccluder then
			this.ColorfulOccluder.Size = UDim2.new(1,0,-alpha,0);
		end
		if this.CountdownTime then
			if remainingTime >= 1 then
				local seconds = math.floor(remainingTime % 60)
				local minutes = math.floor(remainingTime / 60)
				if minutes > 0 then
					this.CountdownTime.Text = tostring(minutes) .. "m"
				else
					this.CountdownTime.Text = tostring(seconds) .. "s"
				end
				if this.Title then
					this.Title.Visible = true
				end
			else
				this.CountdownTime.Text = "READY"
				if this.Title then
					this.Title.Visible = false
				end
			end
		end
	end

	local function Init()
		
		this.ScreenGui = Utility.Create'ScreenGui'
		{
			Name = "TrollSummonerGui";
			Parent = PlayerGui;
		}
			this.Container = Utility.Create'Frame'
			{
				Name = "Container";
				Size = UDim2.new(0.3,0,1,-225);
				Position = UDim2.new(0.35, 0, 0, 100);
				BackgroundTransparency = 1;
				Parent = this.ScreenGui;
			};
				this.Title = Utility.Create'TextLabel'
				{
					Name = "Title";
					ZIndex = 2;
					Text = "The Troll Is Feeding";
					BackgroundTransparency = 1;
					Position = UDim2.new(0,30,0,60);
					Size = UDim2.new(1,-60,0,50);
					--TextColor3 = Color3.new(177/255,70/255,35/255);
					TextColor3 = Color3.new(246/255,146/255,29/255);
					Font = Enum.Font.SourceSansBold;
					FontSize = Enum.FontSize.Size36;
					TextYAlignment = Enum.TextYAlignment.Center;
					Parent = this.Container;
				}
				this.CountdownTime = Utility.Create'TextLabel'
				{
					Name = "CountdownTime";
					ZIndex = 2;
					Text = "";
					BackgroundTransparency = 1;
					Position = UDim2.new(0,30,0.5,-25);
					Size = UDim2.new(1,-60,0,50);
					TextColor3 = Color3.new(177/255,70/255,35/255);
					--TextColor3 = Color3.new(246/255,146/255,29/255);
					Font = Enum.Font.SourceSansBold;
					FontSize = Enum.FontSize.Size48;
					TextYAlignment = Enum.TextYAlignment.Center;
					Parent = this.Container;
				}
				this.ErrorMsg = Utility.Create'TextLabel'
				{
					Name = "ErrorMsg";
					ZIndex = 2;
					Text = "";
					BackgroundTransparency = 1;
					Position = UDim2.new(0,30,0,90);
					Size = UDim2.new(1,-60,0,50);
					--TextColor3 = Color3.new(177/255,70/255,35/255);
					TextColor3 = Color3.new(246/255,146/255,29/255);
					Font = Enum.Font.SourceSansBold;
					FontSize = Enum.FontSize.Size48;
					TextYAlignment = Enum.TextYAlignment.Center;
					Visible = false;
					Parent = this.Container;
				}
				--[[
				this.CloseButton = Utility.Create'TextButton'
				{
					Name = "CloseButton";
					ZIndex = 2;
					Text = "X";
					BackgroundTransparency = 1;
					TextColor3 = Color3.new(246/255,146/255,29/255);
					Position = UDim2.new(1,-50,0,3);
					Size = UDim2.new(0,45,0,45);
					Font = Enum.Font.Arial;
					FontSize = Enum.FontSize.Size36;
					Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
					Parent = this.Container;
				}
				--]]
				this.ColorLessImage = Utility.Create'ImageLabel'
				{
					Name = "Colorless";
					Size = TROLL_FACE_SIZE;
					Image = COLORLESS_TROLL_FACE;
					Position = UDim2.new(0.5, -TROLL_FACE_SIZE.X.Offset/2, 0.5, -TROLL_FACE_SIZE.Y.Offset/2);
					ImageTransparency = 0.5;
					BackgroundTransparency = 1;
					Parent = this.Container;
				};
					this.ColorfulOccluder = Utility.Create'Frame'
					{
						Name = "ColorfulOccluder";
						Size = UDim2.new(1,0,-0.5,0);
						Position = UDim2.new(0, 0, 1, 0);
						BackgroundTransparency = 1;
						ClipsDescendants = true;
						Parent = this.ColorLessImage;
					}
						this.ColorfulImage = Utility.Create'ImageLabel'
						{
							Name = "Colorful";
							Size = TROLL_FACE_SIZE;
							Image = COLORFUL_TROLL_FACE;
							Position = UDim2.new(0, 0, 1, -TROLL_FACE_SIZE.Y.Offset);
							BackgroundTransparency = 1;
							Parent = this.ColorfulOccluder;
						};
					--[[
				this.CloseButton.MouseButton1Click:connect(function()
					this:Hide()
				end)
				--]]
	end
	
	Init()
	
	return this
end


local function TrySummonTheTrolls()
	local now = tick()
	if now - LastActivation < COOLDOWN then
		-- Still on cooldown
		return
	end
	local humanoid = Utility.GetHumanoid(LocalPlayer)
	local targetPoint = humanoid and humanoid.TargetPoint
	spawn(function()
		local exitCode = RequestShootServer:InvokeServer(targetPoint, tick() + (_G.ClientTimeDiff or 0))
		local timeRemaining = TimeLeftUntilSummon:InvokeServer()
		LastActivation = tick() - (COOLDOWN - timeRemaining)
		if exitCode and exitCode ~= EXIT_CODES.SUCCESS then
			if TrollSummoningGui and TrollSummoningGui.ErrorMsg then
				TrollSummoningGui.ErrorMsg.Text = "The Troll Requires a Valid Spawn Location"
	
				TrollSummoningGui.ErrorMsg.Visible = true
				delay(3, function()
					TrollSummoningGui.ErrorMsg.Visible = false
				end)
			end
		end
	end)
end


local Equipped = false
local function OnEquip()
	Equipped = true
	Handle.Transparency = 0
	local humanoid = Utility.GetHumanoid(LocalPlayer)
	if humanoid then
		--local FireReloadAnim = Tool:FindFirstChild('FireAndReload')
		--FireReloadAnimTrack = FireReloadAnim and humanoid:LoadAnimation(FireReloadAnim)
	end
	if not TrollSummoningGui then
		TrollSummoningGui = CreateGui()
	end
	local timeRemaining = TimeLeftUntilSummon:InvokeServer()
	LastActivation = tick() - (COOLDOWN - timeRemaining)
	TrollSummoningGui:Show()
	spawn(function()
		while Equipped do
			if TrollSummoningGui then
				TrollSummoningGui:Update()
			end
			wait()
		end
	end)
end

local function OnUnequip()
	Equipped = false
	if TrollSummoningGui then
		TrollSummoningGui:Hide()
	end
end

local function OnActivated()
	if Equipped then
		TrySummonTheTrolls()
	end
end

CreateLocalWelder(Tool)

Tool.Equipped:connect(OnEquip)
Tool.Unequipped:connect(OnUnequip)
Tool.Activated:connect(OnActivated)

