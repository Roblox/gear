local mPhone = script.Parent;

local vChar = nil
local vPlay = nil

function onEquip()
	vChar = mPhone.Parent
	if vChar == nil then return end

	vPlay = game.Players:GetPlayerFromCharacter(vChar)
	if vPlay == nil then return end

	megaGui = vPlay.PlayerGui:FindFirstChild("MegaphoneGui")
	if megaGui == nil then
		megaGui = mPhone.Handle.MegaphoneGui
		megaGui.Parent = vPlay.PlayerGui
		megaGui:Clone().Parent = mPhone.Handle
	end
end

function onUnequip()
	if vChar == nil then return end
	if vPlay == nil then return end

	megaGui = vPlay.PlayerGui:FindFirstChild("MegaphoneGui")
	if megaGui ~= nil then
		megaGui:Destroy()
	end
end

script.Parent.Equipped:connect(onEquip)
script.Parent.Unequipped:connect(onUnequip)
