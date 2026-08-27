local Tool = script.Parent

enabled = true
local origTexture = 	Tool.TextureId
game:GetService("ContentProvider"):Preload("rbxasset://icons/resize_sel.png")

local selectionBox
local selectionLasso
local handles

local previousDistance

function onHandlesDown(normal)
	print("handlesDown")
	previousDistance = 0
end
function onHandlesDrag(normal, distance)
	
	if handles.Adornee then
		local delta = distance - previousDistance 
		if math.abs(delta) >= handles.Adornee.ResizeIncrement then
			local sizeDelta = math.floor(delta / handles.Adornee.ResizeIncrement + 0.5) * handles.Adornee.ResizeIncrement
			if handles.Adornee:Resize(normal, sizeDelta) then
				previousDistance = distance
			end
		end
	end
end

function onButton1Down(mouse)
	print("3DButtonDown")
	if mouse.Target == nil or mouse.Target.Locked then
		selectionBox.Adornee = nil
		selectionLasso.Part = nil
		handles.Adornee = nil
	else
		selectionBox.Adornee = mouse.Target
		selectionLasso.Part = mouse.Target
		handles.Adornee = mouse.Target
		handles.Faces = mouse.Target.ResizeableFaces
	end
end



function onEquippedLocal(mouse)
	Tool.TextureId = "rbxasset://icons/resize_sel.png"

	mouse.Icon ="rbxasset://textures\\DragCursor.png"
	mouse.Button1Down:connect(function() onButton1Down(mouse) end)

	local character = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(character)
	
	selectionBox = Instance.new("SelectionBox")
	selectionBox.Color = BrickColor.Blue()
	selectionBox.Adornee = nil
	selectionBox.Parent = player.PlayerGui

	selectionLasso = Instance.new("SelectionPartLasso")
	selectionLasso.Name = "Model Delete Lasso"
	selectionLasso.Humanoid = character.Humanoid
	selectionLasso.Parent = game.workspace
	selectionLasso.Part = nil
	selectionLasso.Visible = true
	selectionLasso.archivable = false
	selectionLasso.Color = BrickColor.Red()

	handles = Instance.new("Handles")
	handles.Color = BrickColor.Blue()
	handles.Adornee = nil
	handles.MouseDrag:connect(onHandlesDrag)
	handles.MouseButton1Down:connect(onHandlesDown)
	handles.Parent = player.PlayerGui
end

function onUnequippedLocal()
	Tool.TextureId = origTexture
	selectionBox:Remove()
	selectionLasso:Remove()
	handles:Remove()
end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
