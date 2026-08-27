-- Created by StarWars
local GearService = require(1075123174)

local GearData = GearService:BindGear(script.Parent, "Glider")

local Tool = script.Parent
local DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end