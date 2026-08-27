local Tool = script.Parent
local charging = false

function charge()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	charging = true
	local vPlayer = game.Players:GetPlayerFromCharacter(Tool.Parent)
	if vPlayer ~= nil then
		local fuseGui = vPlayer.PlayerGui.UserGui.Background.Fuse
		local fuseTime = 100
		while charging do
			fuseTime =fuseTime - 1
			fuseGui.Size = UDim2.new(0,fuseTime,0,20)
			if fuseTime == 1 then break end
			wait(1/40)
		end
		Tool.Fuse.Value = fuseTime
		--fuseGui.Size = UDim2.new(0,0,0,20)
	end
	
end

function doneCharging()
	charging = false
	
end

function onEquipped(mouse)
	mouse.Button1Down:connect(charge)
	mouse.Button1Up:connect(doneCharging)
end

Tool.Equipped:connect(onEquipped)

