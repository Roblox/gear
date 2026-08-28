-- Made by StarWars

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local Camera = workspace.CurrentCamera

local Drone = {}
Drone.__index = Drone

local function SetupControls(self)
	ContextActionService:BindAction("Forward", function(actionName, userInputState, inputObject)
		if userInputState == Enum.UserInputState.Begin then
			self.Direction = self.Direction + Vector3.new(0, 0, -1)
		elseif userInputState == Enum.UserInputState.End then
			self.Direction = self.Direction - Vector3.new(0, 0, -1)
		end
	end, false, Enum.PlayerActions.CharacterForward)
	
	ContextActionService:BindAction("Backward", function(actionName, userInputState, inputObject)
		if userInputState == Enum.UserInputState.Begin then
			self.Direction = self.Direction + Vector3.new(0, 0, 1)
		elseif userInputState == Enum.UserInputState.End then
			self.Direction = self.Direction - Vector3.new(0, 0, 1)
		end
	end, false, Enum.PlayerActions.CharacterBackward)
	
	ContextActionService:BindAction("Left", function(actionName, userInputState, inputObject)
		if userInputState == Enum.UserInputState.Begin then
			self.Direction = self.Direction + Vector3.new(-1, 0, 0)
		elseif userInputState == Enum.UserInputState.End then
			self.Direction = self.Direction - Vector3.new(-1, 0, 0)
		end
	end, false, Enum.PlayerActions.CharacterLeft)
	
	ContextActionService:BindAction("Right", function(actionName, userInputState, inputObject)
		if userInputState == Enum.UserInputState.Begin then
			self.Direction = self.Direction + Vector3.new(1, 0, 0)
		elseif userInputState == Enum.UserInputState.End then
			self.Direction = self.Direction - Vector3.new(1, 0, 0)
		end
	end, false, Enum.PlayerActions.CharacterRight)	
	
	ContextActionService:BindAction("Up", function(actionName, userInputState, inputObject)
		if userInputState == Enum.UserInputState.Begin then
			self.Direction = self.Direction + Vector3.new(0, 1, 0)
		elseif userInputState == Enum.UserInputState.End then
			self.Direction = self.Direction - Vector3.new(0, 1, 0)
		end
	end, false, Enum.KeyCode.E)	
	
	ContextActionService:BindAction("Down", function(actionName, userInputState, inputObject)
		if userInputState == Enum.UserInputState.Begin then
			self.Direction = self.Direction + Vector3.new(0, -1, 0)
		elseif userInputState == Enum.UserInputState.End then
			self.Direction = self.Direction - Vector3.new(0, -1, 0)
		end
	end, false, Enum.KeyCode.Q)			
	
	ContextActionService:BindAction("Rotation", function(actionName, userInputState, inputObject)
		local ViewportSize = Camera.ViewportSize
		
		local DistanceFromCenter = math.abs(inputObject.Position.X - (ViewportSize.X * 0.5))
		if DistanceFromCenter > ViewportSize.X * 0.1 then
			if inputObject.Position.X > ViewportSize.X * 0.5 then
				self.Yaw = -1
			else
				self.Yaw = 1
			end	
		else
			self.Yaw = 0
		end
	end, false, Enum.UserInputType.MouseMovement)				
end

function Drone.new(model)
	local self = {}
	self.Model = model
	self.Speed = 32
	self.Direction = Vector3.new(0, 0, 0)
	self.Yaw = 0
	self.TurnSpeed = 90

	SetupControls(self)
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CameraSubject = nil	
	Camera.FieldOfView = 95	
	
	return setmetatable(self, Drone)
end

function Drone:Update(delta)
	if not self.Model then return end 
	
	local NewPosition = CFrame.new(self.Model.PrimaryPart.BodyPosition.Position) * CFrame.Angles(self.Model.PrimaryPart.BodyGyro.CFrame:toEulerAnglesXYZ()) * CFrame.new(self.Direction * delta * self.Speed)
	self.Model.PrimaryPart.BodyPosition.Position = NewPosition.p
	self.Model.PrimaryPart.BodyGyro.CFrame = self.Model.PrimaryPart.BodyGyro.CFrame * CFrame.Angles(0, math.rad(self.Yaw) * self.TurnSpeed * delta, 0)
	local WorldOrientation = self.Model.PrimaryPart.CameraAttachment.WorldOrientation
	Camera.CFrame = CFrame.new(self.Model.PrimaryPart.CameraAttachment.WorldPosition) * CFrame.fromOrientation(math.rad(WorldOrientation.X), math.rad(WorldOrientation.Y), math.rad(WorldOrientation.Z))

	for _, part in ipairs(self.Model:GetChildren()) do
		if part.Name == "Propeller" then
			local Motor6D = part:FindFirstChildWhichIsA("Motor6D")
			if Motor6D then
				Motor6D.Transform = Motor6D.Transform * CFrame.Angles(0, math.rad(delta * 1000), 0)
			end
		end
	end
end

function Drone:Destroy()
	Camera.FieldOfView = 70
	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
	
	ContextActionService:UnbindAction("Forward")
	ContextActionService:UnbindAction("Backward")
	ContextActionService:UnbindAction("Left")
	ContextActionService:UnbindAction("Right")
	ContextActionService:UnbindAction("Up")
	ContextActionService:UnbindAction("Down")		
	ContextActionService:UnbindAction("Rotation")
end

return Drone