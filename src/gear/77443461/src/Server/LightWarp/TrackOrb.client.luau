local Tracked_Orb = script:FindFirstChild("TrackedOrb")

if not Tracked_Orb or not Tracked_Orb.Value then return end

Tracked_Orb = Tracked_Orb.Value

local Camera = workspace.CurrentCamera

local OldSubject,OldType = Camera.CameraSubject,Camera.CameraType

Camera.CameraSubject = Tracked_Orb
Camera.CameraType = Enum.CameraType.Watch

local Run = (game:FindService("RunService") or game:GetService("RunService"))

repeat
	Run.RenderStepped:Wait()
until not Tracked_Orb:IsDescendantOf(workspace) or Tracked_Orb.Transparency > 0

Camera.CameraSubject = OldSubject or game.Players.LocalPlayer.Character
Camera.CameraType = OldType
