--[[Super Util]]--
function WaitForChild(parent,child)
	while not parent:FindFirstChild(child) do  wait(1/30) end
	return parent[child]
end

function MakeValue(class,name,value,parent)
	local temp = Instance.new(class)
	temp.Name = name
	temp.Value = value
	temp.Parent = parent
	return temp
end	

--[[Constants]]--

local Tool = script.Parent
local MyGui = WaitForChild(script,'Gui')
--[[Workspace Variables]]--

--[[Script Variables]]--

--[[Script Functions]]--
function OnEquip()
	Spawn(function()
		char = Tool.Parent
		local player = game.Players:GetPlayerFromCharacter(char)
		if player then
			local tgui = MyGui:Clone()
			tgui.Parent = player.PlayerGui
		end
	end)
end

function OnUnequip()
	local player = game.Players:GetPlayerFromCharacter(char)
	if player and player.PlayerGui and player.PlayerGui:FindFirstChild('Gui') then
		player.PlayerGui:FindFirstChild('Gui'):Destroy()
	end
	
end

--[[Running Logic]]--

Tool.Equipped:connect(OnEquip)

Tool.Unequipped:connect(OnUnequip)
