BaseUrl = "rbxassetid://"

BaseVehicle = script.Snowped:Clone()
if BaseVehicle:FindFirstChild("Motor6D") then
	BaseVehicle.Motor6D:Destroy()
end
BaseVehicle.Transparency = 0
script.Snowped:Destroy()

function CreateVehicle()

	local ExhaustSmoke = {}
	local Lights = {}
	local Sparkles = {}
	local HoverParts = {}
	
	local Body = BaseVehicle:Clone()

	local Tables = {
		ExhaustSmoke = ExhaustSmoke,
		Lights = Lights,
		Sparkles = Sparkles,
		HoverParts = HoverParts,
	}
	
	return {
		Vehicle = Body,
		Tables = Tables
	}
	
end

return {
	BaseUrl = BaseUrl,
	CreateVehicle = CreateVehicle
}