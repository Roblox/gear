--By QuantumSama

local TargetRef = script.Parent.CharRef

local Gui = script.Parent

local OutfitButtons = {Gui.Outfit1, Gui.Outfit2, Gui.Outfit3, Gui.Outfit4}
local CloseButton = Gui.Close

function KillGui()
	Gui.Parent:Destroy()
end


CloseButton.MouseButton1Click:connect(KillGui)

local debounce = false
for i, button in pairs(OutfitButtons) do
	button.MouseButton1Click:connect(function()
		if debounce then return end
		debounce = true
		local outfitScript = Gui.OutfitScript:Clone()
		outfitScript.OutfitNumber.Value = i
		outfitScript.Parent = TargetRef.Value
		outfitScript.Disabled = false
		KillGui()
	end)
end
while true do
	if TargetRef.Value == nil or TargetRef.Value.Parent == nil then KillGui() end
	wait(2)
end




