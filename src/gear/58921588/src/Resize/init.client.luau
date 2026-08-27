-- basic functions
function waitForChild(instance, name)
	while not instance:findFirstChild(name) do
		instance.ChildAdded:wait()
	end
end

local Tool = script.Parent
waitForChild(Tool.Resize,"Active")

enabled = true
local origTexture = 	Tool.TextureId
game:GetService("ContentProvider"):Preload("rbxasset://icons/resize_sel.png")

local selectionBox
local selectionLasso
local handles

local previousDistance
local needsCursor = true

-- Wether a handle is being dragged, true if it is and false if not.
local isDragging = false

-- Hold the anchor state a piece was in when dragging started.
local anchorState = false

local currMouseTarget
local connections = {}

function onHandlesDown(normal)
	previousDistance = 0
end
function onHandlesDrag(normal, distance)
	
	if handles.Adornee then
		local delta = distance - previousDistance 
		if math.abs(delta) >= handles.Adornee.ResizeIncrement then
			local sizeDelta = math.floor(delta / handles.Adornee.ResizeIncrement + 0.5) * handles.Adornee.ResizeIncrement
			
			-- Keep the piece from falling while resizing.
			-- Auto join the piece to other pieces.
			if not isDragging then
				isDragging = true
				anchorState = handles.Adornee.Anchored
				handles.Adornee.Anchored = true
				
			end

			game.JointsService:SetJoinAfterMoveInstance(handles.Adornee)

			if handles.Adornee:Resize(normal, sizeDelta) then
				previousDistance = distance
			end

			game.JointsService:CreateJoinAfterMoveJoints()
			game.JointsService:SetJoinAfterMoveInstance(nil)

		end
	end
end

function onButton1Down(mouse)
	local success = pcall(function() theMouse = mouse.Target end)

	if success then
		if canSelect(mouse.Target) then
			selectionBox.Adornee = mouse.Target
			selectionLasso.Part = mouse.Target
			handles.Adornee = mouse.Target
			handles.Faces = mouse.Target.ResizeableFaces
		else
			selectionBox.Adornee = nil
			selectionLasso.Part = nil
			handles.Adornee = nil
		end
	end
end

function mouseTargetChanged(mouse)

	if canSelect(mouse.Target) then
		if needsCursor then
			mouse.Icon ="rbxasset://textures\\DragCursor.png"
			needsCursor = false
		end
	else
		needsCursor = true
		mouse.Icon = ""
	end

end

local function isPartOfModel(object)
	if object and object ~= game.Workspace and object:IsA("Model") then
		return true
	elseif not object or object == game.Workspace then
		return false
	else
		return isPartOfModel(object.Parent)
	end
end

function canSelect(object)
	local isModel = isPartOfModel(object)
	return object and object:IsA("BasePart") and not object.Locked and not isPartOfModel(object)
end


function onEquippedLocal(mouse)

	currMouseTarget = nil

	table.insert(connections,mouse.Button1Down:connect(function() onButton1Down(mouse) end) )

	-- Track mouse up since up won't happen for the handle unless the mouse is over the handle.
	table.insert(connections,mouse.Button1Up:connect(function()
																			if isDragging then
																				handles.Adornee.Anchored = anchorState
																				isDragging = false
																			end
	 																 end) )
	table.insert(connections, mouse.Move:connect(function()
			if currMouseTarget ~= mouse.Target then
				mouseTargetChanged(mouse)
				currMouseTarget = mouse.Target
			end
		end)
	)

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

	for i = 1, #connections do
		if connections[i] then connections[i]:disconnect() end
	end

	connections = {}
end

script.Active.Changed:connect(function(prop)
	if script.Active.Value == true then
		onEquippedLocal(Tool.Mouse.Value)
	else
		onUnequippedLocal()
	end
end)
