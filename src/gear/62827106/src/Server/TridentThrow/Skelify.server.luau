local Self = script

local Game = game

local Char = Self.Parent

local Hum = Char:FindFirstChildOfClass("Humanoid")

if not Hum then Self:Destroy() end

local FindService,GetService = Game.FindService,Game.GetService

local Services = {
	InsertService = (FindService(Game,"InsertService") or GetService(Game,"InsertService"))
}

local Pcall,Type,Pairs = pcall,type,pairs

local Accessory = 36883367

local _,Hat = Pcall(function() return Services.InsertService:LoadAsset(Accessory) end)

if Type(Hat) == "userdata" then
	local Skull = Hat:FindFirstChildOfClass("Accessory")
	if Skull then
		--[[local Mesh = Skull:FindFirstChildWhichIsA("SpecialMesh",true)
		if Mesh then
			--Mesh.Parent.Color = SkeleColor
			--Mesh.VertexColor = Vec3(170/255,0/255,170/255)
			--Mesh.TextureId = ""
		end]]
		Hum:AddAccessory(Skull)
		
		local Base = Skull:FindFirstChild("Handle")
		if Base then
			Base.CanCollide = true
		end
	end
	Hat:Destroy()
end

local Packages = {36781407,36781447,36781481,36781518,36781360}

if Hum.RigType == Enum.HumanoidRigType.R6 then
	
	
	for i=1,#Packages do
	local _,SkelePackages = Pcall(function() return Services.InsertService:LoadAsset(Packages[i]) end)
	if Type(SkelePackages) == "userdata" then
		local R6 = SkelePackages:FindFirstChild("R6",true)
		if R6 then
			for _,part in Pairs(R6:GetChildren()) do
				if part:IsA("CharacterMesh") then
					for _,v in Pairs(Char:GetChildren()) do
						if v and v:IsA("CharacterMesh") and v.BodyPart == part.BodyPart then
							v.MeshId = part.MeshId
							v.BaseTextureId = part.BaseTextureId
							v.OverlayTextureId = part.OverlayTextureId
						end
					end
				end
			end
		end
		SkelePackages:Destroy()
	end
	
end
	
elseif Hum.RigType == Enum.HumanoidRigType.R15 then


for i=1,#Packages do
	local _,SkelePackages = Pcall(function() return Services.InsertService:LoadAsset(Packages[i]) end)
	if Type(SkelePackages) == "userdata" then
		local R15 = SkelePackages:FindFirstChild("R15",true)
		if R15 then
			for _,part in Pairs(R15:GetChildren()) do
				if part:IsA("BasePart") then
					--[[if part:IsA("MeshPart") then
						--part.TextureID = ""
					end]]
					local LimbtoReplace = Hum:GetBodyPartR15(Char:FindFirstChild(part.Name))
					if LimbtoReplace then
						Hum:ReplaceBodyPartR15(LimbtoReplace,part)
					end
				end
			end
		end
		SkelePackages:Destroy()
	end
end
	
	
else --Idk what you are...
	
	Self:Destroy()
	
end

if Char:FindFirstChild("Head") then
	for _,faces in Pairs(Char:FindFirstChild("Head"):GetChildren()) do
		if faces and faces:IsA("Decal") then
			faces.Transparency = 1
		end
	end
	Char:FindFirstChild("Head").Transparency = 1
end