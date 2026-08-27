local Tool = script.Parent

enabled = true
local origTexture = 	Tool.TextureId
game:GetService("ContentProvider"):Preload("rbxasset://icons/surface_sel.png")

local selectionSurface
local selectionLasso

local value = nil

local selectedButton = nil

function setSelectionSurface(part, surface) 
	unsetSelectionSurface()
	selectionSurface.Adornee = part
	selectionSurface.TargetSurface = surface
	selectionLasso.Part = part
end
function unsetSelectionSurface() 
	selectionSurface.Adornee = nil
	selectionLasso.Part = nil
end

local SurfaceEnum = {}
SurfaceEnum["Smooth"] = Enum.SurfaceType.Smooth
SurfaceEnum["Studs"] = Enum.SurfaceType.Studs
SurfaceEnum["Inlets"] = Enum.SurfaceType.Inlet
SurfaceEnum["Universal"] = Enum.SurfaceType.Universal
SurfaceEnum["Glue"] = Enum.SurfaceType.Glue
SurfaceEnum["Weld"] = Enum.SurfaceType.Weld
SurfaceEnum["Hinge"] = Enum.SurfaceType.Hinge
SurfaceEnum["Motor"] = Enum.SurfaceType.Motor


function canSelectObject(part, surface)
	return part and not (part.Locked) and part:IsA("BasePart") and (part.Position - Tool.Parent.Head.Position).Magnitude < 60 and 
		(not(part:IsA("WedgePart")) or surface ~= Enum.NormalId.Front)
end


function on3dMouseMove(mouse)
	local part = mouse.Target
	local surface = mouse.TargetSurface
	if canSelectObject(part, surface) then
		setSelectionSurface(part, surface)
	else
		unsetSelectionSurface()
	end

end
function on3dButton1Down(mouse) 
	local part = selectionSurface.Adornee
	if part then
		local normalId = selectionSurface.TargetSurface
		if selectedButton == nil or SurfaceEnum[selectedButton.Name] == nil then return end
		local surface = SurfaceEnum[selectedButton.Name]
		if surface == nil then return end
		--Apply the selected surface to the current parts
		if normalId == Enum.NormalId.Top then
			part.TopSurface = surface
		elseif normalId == Enum.NormalId.Bottom then  
			part.BottomSurface = surface
		elseif normalId == Enum.NormalId.Front then  
			part.FrontSurface = surface
		elseif normalId == Enum.NormalId.Back then  
			part.BackSurface = surface
		elseif normalId == Enum.NormalId.Left then  
			part.LeftSurface = surface
		elseif normalId == Enum.NormalId.Right then  
			part.RightSurface = surface
		end
	end
end

function onEquippedLocal(mouse)
	Tool.TextureId = "rbxasset://icons/surface_sel.png"
	local character = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(character)

	mouse.Move:connect(function() on3dMouseMove(mouse) end)
	mouse.Button1Down:connect(function() on3dButton1Down(mouse) end)

	selectionSurface = Instance.new("SurfaceSelection")
	selectionSurface.Color = BrickColor.Red()
	selectionSurface.Adornee = nil
	selectionSurface.Parent = player.PlayerGui

	selectionLasso = Instance.new("SelectionPartLasso")
	selectionLasso.Name = "Model Delete Lasso"
	selectionLasso.Humanoid = character.Humanoid
	selectionLasso.Parent = game.workspace
	selectionLasso.Part = nil
	selectionLasso.Visible = true
	selectionLasso.archivable = false
	selectionLasso.Color = BrickColor.Red()

	Tool.SelectedButton.Changed:connect(function(property)

		if value == Tool.SelectedButton.Value then return end
		value = Tool.SelectedButton.Value

		selectedButton = Tool.SelectedButton.Value

	end)
end

function onUnequippedLocal()
	Tool.TextureId = origTexture
	if selectionBox then selectionBox:Remove() end
	if selectionLasso then selectionLasso:Remove() end
end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
