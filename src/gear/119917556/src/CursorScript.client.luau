local enabled = true
local Mouse;
local Tool = script.Parent
local Create = LoadLibrary('RbxUtility').Create
function onButton1Down(mouse)
	Mouse = mouse
	if not enabled or Tool.DrawMode.Value then
		return
	end
	enabled = false
	mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
	wait(.5)
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	enabled = true
end

function onEquippedLocal(mouse)
	Mouse = mouse
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function() onButton1Down(mouse) end)
	local player = game.Players:GetPlayerFromCharacter(Tool.Parent)
	if player then
		local gui = Create'ScreenGui'{
			Name = 'ChalkSwordUsageNotification';
			Parent = player:WaitForChild('PlayerGui');
			--
			Create'Frame'{
				Name = 'MainFrame';
				Size = UDim2.new(0, 256, 0, 128);
				Position = UDim2.new(0, -150, 1, 20);
				Style = 'RobloxRound';
				Create'ImageButton'{
					Size = UDim2.new(1,0,1,0);
					BackgroundTransparency = 1;
					Image = 'http://www.roblox.com/asset/?id=119888502';
				};
			};
		}
		local sc = Tool.Tweener:Clone()
		sc.Parent = gui.MainFrame
		sc.Disabled = false
	end
end

Tool.Equipped:connect(onEquippedLocal)

Tool:WaitForChild('DrawMode').Changed:connect(function()
	if Mouse then
		if Tool.DrawMode.Value then
			Mouse.Icon = 'http://www.roblox.com/asset/?id=119885531'
		else
			Mouse.Icon = "rbxasset://textures\\GunCursor.png"
		end
	end
end)