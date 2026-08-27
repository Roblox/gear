local gui = script.Parent.TabletGui:Clone()

function Equip()
	gui.Parent = game.Players.LocalPlayer.PlayerGui
end

function Unequip()
	gui.Parent = nil
end

script.Parent.Equipped:connect(Equip)
script.Parent.Unequipped:connect(Unequip)