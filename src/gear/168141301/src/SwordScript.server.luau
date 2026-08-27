--[[ alexnewtron 2014 ]]--
local c = {
	gear = script.Parent,
	sword = script.Parent:WaitForChild("Handle"),
	r=game:service("RunService"),
	debris=game:GetService("Debris"),
	anims={"RightSlash","LeftSlash","OverHeadSwing"},
	taunting = script.Parent:WaitForChild("Taunting"),
	sound = script.Parent.Handle:WaitForChild("Slash1"),
	c = {
		swingrate=1.1,
		damage=0,
		slashdamage=9,
		swingdamage=14,
		basedamage=0,
	}
}
c.taunting.Value=false;
function c.tagHumanoid(humanoid,player)
	for i,v in ipairs(humanoid:GetChildren()) do
		if v.Name=="creator" then
			v:Destroy()
		end
	end
	local creator_tag=Instance.new("ObjectValue");
	creator_tag.Value=player;
	creator_tag.Name="creator";
	creator_tag.Parent=humanoid;
	c.debris:AddItem(creator_tag,1);
end
function c.blow(hit)
	if hit.Parent~=nil then
		local humanoid=hit.Parent:findFirstChild("Humanoid");
		local vCharacter=c.gear.Parent;
		if vCharacter~=nil then
			local vPlayer=game.Players:playerFromCharacter(vCharacter);
			if vPlayer~=nil then
				local hum=vCharacter:findFirstChild("Humanoid");
				if humanoid~=nil then
					if hum~=nil and humanoid~=hum and hum.Health>0 then
						c.tagHumanoid(humanoid,vPlayer);
						local t=hit.Parent:FindFirstChild("Torso");
						if t~=nil then
							humanoid:TakeDamage(c.c.damage);
						end
					end
				end
			end
		end
	end
end
c.gear.Enabled=true;
function c.onActivated()
	if c.gear.Enabled and not c.taunting.Value then
		c.gear.Enabled=false
		local character=c.gear.Parent;
		local humanoid=character.Humanoid;
		if humanoid==nil then
			print("Humanoid not found");
			return;
		end
		c.sound:Play();
		newanim=c.anims[math.random(1,#c.anims)]
		while newanim==c.gear.RunAnim.Value do
			newanim=c.anims[math.random(1,#c.anims)];
		end
		c.gear.RunAnim.Value=newanim;
		if newanim=="OverHeadSwing" then
			c.c.damage=c.c.swingdamage;
		else
			c.c.damage=c.c.slashdamage;
		end
		wait(c.c.swingrate)
		c.c.damage=c.c.basedamage;
		c.gear.Enabled=true;
	end
end
c.gear.Activated:connect(c.onActivated);
c.sword.Touched:connect(c.blow);