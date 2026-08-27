--Made by Stickmasterluke


sp=script.Parent


local cooldown=2.1
local spraysize=5
local range=10
local lastingtime=60*10

local baseid="http://www.roblox.com/asset/?id="
local sprayid=126610541


local debris=game:GetService("Debris")
local equipped=false
local check=true
local gui=sp:WaitForChild("SprayGui")
local failsafescript=sp:WaitForChild("Failsafescript")
local lastspray=sp:WaitForChild("LastSpray")

function updateid()
	if gui:FindFirstChild("Frame") and gui.Frame:FindFirstChild("ImageLabel") and gui.Frame:FindFirstChild("Frame") then
		sprayid=tonumber(tostring(gui.Frame.Frame.TextBox.Text)) or 0
		gui.Frame.ImageLabel.Image=baseid..tostring(sprayid-1)
		gui.Frame.Frame.TextBox.Text=tostring(sprayid)
	end
end

gui.Frame.Frame.TextBox.Changed:connect(updateid)
updateid()




function checktexturespace(fromedge,texturesize,tochecks)
	local tochecks=tochecks or {"x","y","z"}
	for _,v in pairs(tochecks) do
		if fromedge[v]<texturesize then
			return false
		end
	end
	return true
end

local threshhold=.05
function GetSurfaceNormal(part,pos,texturesize)
	local texturesize=texturesize or 0
	local lpos=part.CFrame:toObjectSpace(CFrame.new(pos)).p
	local abslpos=Vector3.new(math.abs(lpos.x),math.abs(lpos.y),math.abs(lpos.z))
	local fromedge=(part.Size*.5)-abslpos
	if part.ClassName=="Part" and (part.Shape==Enum.PartType.Ball or part.Shape==Enum.PartType.Cylinder) then
		return lpos-part.CFrame.p,false
	elseif math.abs(fromedge.x)<threshhold then
		return (part.CFrame*Vector3.new(lpos.x/abslpos.x,0,0)-part.CFrame.p),texturesize==0 or checktexturespace(fromedge,texturesize,{"y","z"})
	elseif math.abs(fromedge.y)<threshhold then
		return (part.CFrame*Vector3.new(0,lpos.y/abslpos.y,0)-part.CFrame.p),texturesize==0 or checktexturespace(fromedge,texturesize,{"x","z"})
	elseif math.abs(fromedge.z)<threshhold then
		return (part.CFrame*Vector3.new(0,0,lpos.z/abslpos.z)-part.CFrame.p),texturesize==0 or checktexturespace(fromedge,texturesize,{"x","y"})
	elseif part.ClassName=="WedgePart" or part.ClassName=="CornerWedgePart" then
		return part.Position-(part.CFrame*CFrame.new(0,-part.Size.Z,part.Size.Y)).p,false
	end
	return lpos-part.CFrame.p,false
end

function onEquipped(mouse)
	equipped=true
	local plr=game.Players.LocalPlayer
	if mouse~=nil and plr~=nil then
		delay(0,function()
			local plrgui=plr.PlayerGui
			if plrgui~=nil then
				gui.Parent=plrgui
			end
		end)
		mouse.Button1Down:connect(function()
			local chr=sp.Parent
			if chr and check and mouse.Target~=nil and mouse.TargetSurface~=nil and mouse.Target.Name~="Spray" and mouse.Target.Name~="Effect" and sprayid>0 then
				local surface=mouse.TargetSurface
				local t=chr:FindFirstChild("Torso")
				local h=chr:FindFirstChild("Humanoid")
				local animobject=sp:FindFirstChild("SprayPaint")
				if t and h and animobject then
					local hit=mouse.Target
					local pos=mouse.Hit.p
					if hit and pos then
						if h.Health>0 and (t.Position-pos).magnitude<range then
							local facenormal,placeable=GetSurfaceNormal(hit,pos,spraysize*.5)
							if placeable then
								check=false
								anim=h:LoadAnimation(animobject)
								if anim then
									anim:Play()
									sp.Handle.Sound:Play()
								end
								
								if lastspray.Value~=nil then
									lastspray.Value:remove()
								end
								local effect=Instance.new("Part")
								effect.Name="EffectTexture"
								effect.Anchored=false
								effect.CanCollide=false
								effect.Shape="Block"
								effect.formFactor="Custom"
								effect.Size=Vector3.new(.1,.1,.1)
								effect.Material=Enum.Material.Plastic
								effect.Locked=true
								effect.TopSurface=0
								effect.BottomSurface=0
								effect.Transparency=1
								local decal=Instance.new("Decal")
								decal.Face="Front"
								decal.Texture=baseid..tostring(sprayid-1)
								decal.Parent=effect
								local mesh=Instance.new("BlockMesh")
								mesh.Scale=Vector3.new(1/effect.Size.x,1/effect.Size.y,1/effect.Size.z)*Vector3.new(spraysize,spraysize,0)
								mesh.Offset=Vector3.new(0,0,-.21)
								mesh.Parent=effect
								local cf=CFrame.new(pos,pos+facenormal)*CFrame.new(0,0,.2)
								effect.CFrame=cf
								local w=Instance.new("Weld")
								w.Part0=hit
								w.Part1=effect
								w.C0=hit.CFrame:toObjectSpace(cf)
								w.Parent=effect
								local fss=failsafescript:clone()
								fss.Parent=effect
								fss.Disabled=false
								local smoke=Instance.new("Smoke")
								smoke.Parent=effect
								delay(1.5,function()
									if smoke then
										smoke.Enabled=false
									end
								end)
								
								debris:AddItem(p,lastingtime)
								lastspray.Value=effect
								effect.Parent=hit
								
								wait(cooldown)
								sp.Handle.Sound:Stop()
								check=true
							end
						end
					end
				end
			end
		end)
	end
end

function onUnequipped()
	equipped=false
	delay(0,function()
		gui.Parent=sp
	end)
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)

