--Made by Stickmasterluke
--Rescripted by TakeoHonorable


local sp=script.Parent

local Remote = sp:WaitForChild("ClientInput")

function onActivated()
	Remote:FireServer(game.Players.LocalPlayer:GetMouse().Hit.p)
end

sp.Activated:Connect(onActivated)







