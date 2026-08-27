--[[
	Rewritten by ArceusInator
	
	This script will run the sword code on the client if filtering is disabled
--]]
local Tool = script.Parent
local Sword = require(Tool:WaitForChild'Sword')
local GLib = require(Tool:WaitForChild'GLib')
GLib.Script.Name = 'GLib'
GLib.Script.Parent = Tool
local Handle = Tool:WaitForChild'Handle'
local LeftSword
local Tracks = {}
local DisconnectOnUnquipped = {}
local UIS, CAS = game:GetService'UserInputService', game:GetService'ContextActionService'

if not workspace.FilteringEnabled then
	-- Run the sword code on the client
	
	Sword:Initialize()
end

function onInput(input, type, state, key)
	local type, state, key = type, state, key
	if input then
		type, state, key = input.UserInputType.Name, input.UserInputState.Name, input.KeyCode.Name
	end
	
	if workspace.FilteringEnabled then
		Tool.RemoteInput:FireServer(type, state, key)
	else
		Sword:InterpretInput(type, state, key)
	end
end

function MotorAnimate(name, action)
	local animation = Tool:FindFirstChild(name)
	local track = Tracks[animation] or GLib.GetHumanoid(GLib.GetCharacterFromPart(Tool)):LoadAnimation(animation)
	Tracks[animation] = track
	
	if action == 'Play' or action == nil then
		track:Play()
	elseif action == 'Stop' then
		track:Stop()
	end
end

local eqdone = true
Tool.Equipped:connect(function(mouse)
	if not eqdone then return end
	eqdone = false
	
	if not Tool:FindFirstChild'LocalLeftSword' then
		mouse.Button1Down:connect(function()
			if workspace.FilteringEnabled then
				-- Send input info to the server
				Tool.RemoteClick:FireServer()
			else
				-- Interpret it on the client
				Sword:Attack()
			end
		end)
		
		if not Tool:FindFirstChild'LeftSword' and not Tool:FindFirstChild'LocalLeftSword' then
			LeftSword = Tool.Handle:Clone()
			LeftSword.Name = 'LocalLeftSword'
			LeftSword.Parent = Tool
			local weld = Instance.new("ManualWeld")
			weld.Part1 = LeftSword
			weld.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
			weld.C1 = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)
			weld.Part0 = Tool.Parent:FindFirstChild'Left Arm'
			weld.Parent = LeftSword
		end
		LeftSword = Tool:FindFirstChild'LocalLeftSword'
	end
		
	MotorAnimate('DualEquip', 'Play')
	
	table.insert(DisconnectOnUnquipped, UIS.InputBegan:connect(onInput))
	if UIS.TouchEnabled then
		local spinDisabled = false
		CAS:BindActionToInputTypes(
			'DualDarkhearts_Spin',
			function(action, state)
				GLib.FastSpawn(function()
					if state == Enum.UserInputState.Begin then
						if not spinDisabled then
							if not Tool.Data.WhirlwindAvailable.Value then
								spinDisabled = true
								if workspace.FilteringEnabled then Tool.RemoteAction:FireServer'Spin' else Sword:ForceSpin() end
								GLib.SetButtonCooldown('DualDarkhearts_Spin', 0.5)
								wait(0.5)
								GLib.SetButtonCooldown('DualDarkhearts_Spin', 0)
								spinDisabled = false
							else
								Tool.Data.WhirlwindAvailable.Value = false
								spinDisabled = true
								if workspace.FilteringEnabled then Tool.RemoteAction:FireServer'Whirlwind' else Sword:Whirlwind() end
								GLib.SetButtonCooldown('DualDarkhearts_Spin', 12)
								wait(12)
								GLib.SetButtonCooldown('DualDarkhearts_Spin', 0)
								spinDisabled = false
							end
						end
					end
				end)
			end,
			true,
			''
		)
		CAS:SetTitle('DualDarkhearts_Spin', 'Spin')
		
		table.insert(DisconnectOnUnquipped, Tool.Data.WhirlwindAvailable.Changed:connect(function(available)
			if available then
				CAS:SetTitle('DualDarkhearts_Spin', 'Whirlwind!')
			else
				CAS:SetTitle('DualDarkhearts_Spin', 'Spin')
			end
		end))
	end
	
	eqdone = true
end)
local ueqdone = true
Tool.Unequipped:connect(function()
	if not ueqdone then return end
	ueqdone = false
	
	if LeftSword then LeftSword:Destroy() end
	
	for name, track in next, Tracks do
		track:Stop()
	end
	Tracks = {}
	
	for i, con in next, DisconnectOnUnquipped do con:disconnect() end
	
	if UIS.TouchEnabled then
		CAS:UnbindAction'DualDarkhearts_Spin'
	end
	
	ueqdone = true
end)
Tool.ChildAdded:connect(function(child)
	if child.Name == 'LeftSword' then
		if LeftSword then spawn(function() LeftSword:Destroy() LeftSword = nil end) end
	end
end)