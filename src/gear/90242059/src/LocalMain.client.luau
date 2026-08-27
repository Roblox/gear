local RbxUtility = LoadLibrary('RbxUtility')
local Create = RbxUtility.Create
local CreateSignal = RbxUtility.CreateSignal


--general gear globals
local Tool = script.Parent
local Player = nil
local PlayerGui = nil
local Character = nil
local Equipped = false
local Gui = nil


--key management
local KeyState = {}
local KeyDown = CreateSignal()
local KeyUp = CreateSignal()
local function ResetKeyState()
	KeyState = {}
end
local function doKeyDown(key)
	KeyState[key] = true
	KeyDown:fire(key)
end
local function doKeyUp(key)
	KeyState[key] = false
	KeyUp:fire(key)
end


--sign function utility
local function sign(a)
	if a > 0 then
		return 1
	elseif a < 0 then
		return -1
	else
		return 0
	end
end

--table manipulation
local function append(list, value)
	list[#list+1] = value
end
local function remove(list, value)
	for i, v in pairs(list) do
		if v == value then
			table.remove(list, i)
			return
		end
	end
end

local AllArt = {
	'http://www.roblox.com/asset/?id=90029341';
	'http://www.roblox.com/asset/?id=90029349';
	'http://www.roblox.com/asset/?id=90029354';
	'http://www.roblox.com/asset/?id=90029349';
	'http://www.roblox.com/asset/?id=90032025';
	'http://www.roblox.com/asset/?id=90032039';
	'http://www.roblox.com/asset/?id=90032055';
	'http://www.roblox.com/asset/?id=90032039';	
	'http://www.roblox.com/asset/?id=90029349';
	'http://www.roblox.com/asset/?id=90032039';
	'http://www.roblox.com/asset/?id=90029364';
	'http://www.roblox.com/asset/?id=90032067';
	'http://www.roblox.com/asset/?id=90029377';
	'http://www.roblox.com/asset/?id=90029383';
	'http://www.roblox.com/asset/?id=90029391';
	'http://www.roblox.com/asset/?id=89281913';
	'http://www.roblox.com/asset/?id=90035988';
	'http://www.roblox.com/asset/?id=90029349';
	'http://www.roblox.com/asset/?id=90035993';
	'http://www.roblox.com/asset/?id=90032039';
	'http://www.roblox.com/asset/?id=90222009';
	'http://www.roblox.com/asset/?id=90222022';
	'http://www.roblox.com/asset/?id=90218280';
	'http://www.roblox.com/asset/?id=90218293';
	'http://www.roblox.com/asset/?id=90218404';
	'http://www.roblox.com/asset/?id=90220976'; --dead wasp
	'http://www.roblox.com/asset/?id=90220995'; --dead snake
	'http://www.roblox.com/asset/?id=34065729'; --cracked egg
	'http://www.roblox.com/asset/?id=90032819'; --skateboard
	'http://www.roblox.com/asset/?id=89946259'; --cracked egg
	'http://www.roblox.com/asset/?id=90174099';
	'http://www.roblox.com/asset/?id=90174110';
	'http://www.roblox.com/asset/?id=90174112';
	'http://www.roblox.com/asset/?id=9939963' ;
	'http://www.roblox.com/asset/?id=9879704' ;
	'http://www.roblox.com/asset/?id=90032547';
	'http://www.roblox.com/asset/?id=90033843';
	'http://www.roblox.com/asset/?id=90029669';
	'http://www.roblox.com/asset/?id=90030251';
	'http://www.roblox.com/asset/?id=90031006';
	'http://www.roblox.com/asset/?id=90030991';
	'http://www.roblox.com/asset/?id=90220985';
}
local InvulnAngelAnim = {
	FrameLength = 0.4; Looped = true;
	'http://www.roblox.com/asset/?id=81097186';
}

game:GetService("ContentProvider"):PreloadAsync(AllArt)

--some animations for the character
local CharacterAnim_Walk = {
	FrameLength = 0.06; Looped = true;
	'http://www.roblox.com/asset/?id=90029341';
	'http://www.roblox.com/asset/?id=90029349';
	'http://www.roblox.com/asset/?id=90029354';
	'http://www.roblox.com/asset/?id=90029349';
	Reversed = {
		'http://www.roblox.com/asset/?id=90032025';
		'http://www.roblox.com/asset/?id=90032039';
		'http://www.roblox.com/asset/?id=90032055';
		'http://www.roblox.com/asset/?id=90032039';
	};
}
local CharacterAnim_Idle = {
	FrameLength = 0; Looped = true;
	'http://www.roblox.com/asset/?id=90029349';
	Reversed = { 'http://www.roblox.com/asset/?id=90032039'; };
}
local CharacterAnim_Jump = {
	FrameLength = 0;   Looped = false;
	'http://www.roblox.com/asset/?id=90029364';
	Reversed = { 'http://www.roblox.com/asset/?id=90032067'; };
}
local CharacterAnim_RideSkateboard = {
	FrameLength = 0.5; Looped = true;
	'http://www.roblox.com/asset/?id=90029377';
	'http://www.roblox.com/asset/?id=90029383';
}
local CharacterAnim_JumpSkateboard = {
	FrameLength = 0;   Looped = false;
	'http://www.roblox.com/asset/?id=90029391';
}
local CharacterAnim_Throw = {
	FrameLength = 0;   Looped = false;
	'http://www.roblox.com/asset/?id=89281913'; --TODO: add
}
local CharacterAnim_Damaged = {
	FrameLength = 0.1; Looped = true;
	'http://www.roblox.com/asset/?id=90035988';
	'http://www.roblox.com/asset/?id=90029349';
	Reversed = {
		'http://www.roblox.com/asset/?id=90035993';
		'http://www.roblox.com/asset/?id=90032039';
	};
}


--other animations
local HatchetAnim = {
	FrameLength = 0.1; Looped = true;
	'http://www.roblox.com/asset/?id=90222009';
	'http://www.roblox.com/asset/?id=90222022';
}
local SnailAnim = {
	FrameLength = 0.4; Looped = true;
	'http://www.roblox.com/asset/?id=90218280';
	'http://www.roblox.com/asset/?id=90218293';
	DeadFrame = 'http://www.roblox.com/asset/?id=90218404';
}
local InvulnAngelAnim = {
	FrameLength = 0.4; Looped = true;
	'http://www.roblox.com/asset/?id=81097186';
}


--rect:
-- x, y, w, h, vx, vy
local function CollideRect(a, b, arespond)
	local dx = ((b.x+b.w/2) - (a.x+a.w/2))
	local dy;
	if b.slope then
		local ofs = (a.x + a.w/2) - b.x
		local hoffs = b.slope*ofs
		dy = ((b.y-hoffs+b.h/2) - (a.y+a.h/2))
	else
		dy = ((b.y+b.h/2) - (a.y+a.h/2))
	end
	local overlapx = (a.w/2 + b.w/2) - math.abs(dx)
	local overlapy = (a.h/2 + b.h/2) - math.abs(dy)
	--
	if arespond then
		--decide which axis to separate on
		if overlapx > 0 and overlapy > 0 then
			if overlapx < overlapy and overlapy > 5 then
				local sepx = dx - sign(dx)*(a.w/2 + b.w/2)
				a.x = a.x + sepx
				a.vx = 0
				return 'x', overlapx
			else
				local sepy = dy - sign(dy)*(a.h/2 + b.h/2)
				a.y = a.y + sepy
				a.vy = 0
				return 'y', overlapx
			end
		else
			return false
		end
	else
		--just see if they collided
		return overlapx > 0 and overlapy > 0
	end
end

local STAGE_WIDTH = 584
local STAGE_HEIGHT = 414
--
local WALK_SPEED = 200
local WALK_ACCEL = 700
--
local SKATE_SPEED = 250
local SKATE_MOD = 50
--
local GRAVITY = 1000
local DAMAGE_SAFE_PERIOD = 1.2
local TIME_BETWEEN_HEALTH_LOSS = 2
--
local HATCHET_WIDTH = 36
local HATCHET_HEIGHT = 32
local HATCHET_SPEED = 100

local function PlayLevel(leveldat, gameData)
	--globals
	local level;
	local CamCurrentHeight = 0;

	--======================================= game logic ==================================================--

	-- all of the terrain objects
	local TerrainObjectList = {}
	local TerrainEntityList = {}
	local EntityList = {}
	local HatchetList = {}
	local GarbageList = {}

	-- generic animation routine
	local function Animate(animator, t)
		local anim = animator.CurrentAnim
		local elapsed = t-animator.CurrentFrameStartedAt
		if elapsed > anim.FrameLength then
			local frames = #anim
			if animator.CurrentFrame == frames then
				if anim.Looped then
					animator.CurrentFrame = 1
				end
			else
				animator.CurrentFrame = animator.CurrentFrame + 1
			end
			animator.CurrentFrameStartedAt = t
			animator.CurrentImage = anim[animator.CurrentFrame]
			if anim.Reversed then
				animator.CurrentImageR = anim.Reversed[animator.CurrentFrame]
			end
		end
	end
	local function StartAnimation(animator, anim, t)
		if animator.CurrentAnim ~= anim then
			animator.CurrentAnim = anim
			animator.CurrentFrame = 1
			animator.CurrentFrameStartedAt = t
			animator.CurrentImage = anim[1]
			if anim.Reversed then
				animator.CurrentImageR = anim.Reversed[1]
			else
				animator.CurrentImageR = nil
			end
		end
	end


	-- the character object. Short name since we will be using it a lot
	local ch = {
		x = 0; y = 0; w = 32; h = 64;
		vx = 0; vy = 0;
		--
		Won = false;
		Dead = false;
		DiedAt = 0;
		--
		Health = 32;
		NextLoseHealthAt = tick()+1; --lose health periodically
		LastDamagedAt = 0;
		LastOnGroundHeight = 0;
		LastJumpAt = 0;
		LastOnGroundTime = tick();
		--
		IsOnGround = false;
		--
		IsSkating = false; --riding on skateboard
		--
		IsJumping = false; -- jumping stats
		--
		IsInvuln = false;  --invulnerable
		IsInvulnUntil = 0;
		--
		CurrentAnim = CharacterAnim_Walk;
		CurrentFrame = 1;
		CurrentFrameStartedAt = tick();
		CurrentImage = CharacterAnim_Walk[1];
	}

	--======================================= hud updating ================================================--
	local function UpdateHud_Score()
		local scoreStr = tostring(gameData.Score)
		Gui.MainFrame.Hud.ScoreContainer.Score.Text = "Score: "..string.rep('0', 6-#scoreStr)..scoreStr
	end

	local function UpdateHud_Life()
		for i = 5, gameData.Lives+1, -1 do
			Gui.MainFrame.Hud.LifeContainer['Life'..i].Visible = false
		end
	end

	local function UpdateHud_Health()
		for i = 32, ch.Health+1, -1 do
			Gui.MainFrame.Hud.HealthContainer['Health'..i].BackgroundColor3 = 
				(i > 8) and Color3.new(0.5, 0.5, 0.5) or Color3.new(0.5, 0.5, 0.5);
		end
		for i = 1, ch.Health do
			Gui.MainFrame.Hud.HealthContainer['Health'..i].BackgroundColor3 = 
				(i > 8) and Color3.new(0.8, 0.8, 0) or Color3.new(0.8, 0, 0);
		end
	end

	UpdateHud_Score()
	UpdateHud_Life()
	UpdateHud_Health()

	--=====================================================================================================--

	--update animation function
	local function UpdateCharacterAnimation()
		local currentAnim = ch.CurrentAnim
		local desiredAnim;
		if tick()-ch.LastDamagedAt < DAMAGE_SAFE_PERIOD then
			desiredAnim = CharacterAnim_Damaged
		else
			if ch.IsSkating then
				if ch.IsJumping then
					desiredAnim = CharacterAnim_JumpSkateboard
				else
					desiredAnim = CharacterAnim_RideSkateboard
				end
			else
				if ch.IsJumping then
					desiredAnim = CharacterAnim_Jump
				else
					if math.abs(ch.vx) > 0 then
						desiredAnim = CharacterAnim_Walk
					else
						desiredAnim = CharacterAnim_Idle
					end
				end
			end
		end
		if desiredAnim ~= currentAnim then
			StartAnimation(ch, desiredAnim, tick())
		end
	end


	-- "garbage" function, to animate a gui falling off the stage
	local function AddGarbage(ent)
		if not ent.vx then ent.vx = 0 end
		if not ent.vy then ent.vy = -400 end
		ent.gui.ZIndex = 5
		append(GarbageList, ent)
	end 


	-- create a gui for an entity
	local function CreateGui(ent)
		ent.gui = Create'ImageLabel'{
			Name = 'EntityView';
			Position = UDim2.new(0, ent.x, 0, ent.y);
			Size = UDim2.new(0, ent.w, 0, ent.h);
			Image = ent.CurrentImage or '';
			BackgroundTransparency = 1;
			Parent = level
		}
	end


	local function ShowScoreDisplay(ent, score)
		local gui = Tool.ScoreDisplay:Clone()
		gui.Position = UDim2.new(0, ent.x + ent.w/2, 0, ent.y + ent.h/2)
		gui.Text = tostring(score)
		gui.Parent = level
		gui:TweenPosition(UDim2.new(0, ent.x + ent.w/2, 0, ent.y + ent.h/2 - 50), 'Out', 'Quad', 1)
		Delay(1, function()
			gui:Destroy()
		end)
	end


	-- load in level
	level = leveldat:Clone()
	for _, v in pairs(level:GetChildren()) do
		if v.Name:find('TERRAIN_') then
			local terrain = {}
			terrain.x, terrain.y = v.Position.X.Offset, v.Position.Y.Offset
			terrain.w, terrain.h = v.Size.X.Offset, v.Size.Y.Offset
			terrain.gui = v
			--enlarge x a bit so we don't fall through cracks
			terrain.x = terrain.x - 1
			terrain.w = terrain.w + 2
			--
			local amt = v.Name:match("_SLOPE(-?%d*%.?%d+)")
			if amt then
				amt = tonumber(amt)
				terrain.slope = amt/terrain.w
				if amt > 0 then
					terrain.y = terrain.y + amt
				else
					terrain.h = terrain.h - amt
				end
			end
			--
			append(TerrainObjectList, terrain)

		elseif v.Name == 'TERRAINENTITY_PLATFORM' then
			local ent = {}
			--
			ent.x, ent.y = v.Position.X.Offset, v.Position.Y.Offset
			ent.w, ent.h = v.Size.X.Offset, v.Size.Y.Offset
			ent.gui = v
			ent.Platform = true
			--
			if v:FindFirstChild('DIRECTION') then
				local originX, originY = ent.x, ent.y
				local dispX, dispY = v.DIRECTION.Value.x, v.DIRECTION.Value.y
				local lastX, lastY = ent.x, ent.y
				local f = v.FREQUENCY.Value
				local startT = tick()
				function ent:onTick(dt, time)
					local elapsed = time-startT
					local frac = 0.5+0.5*math.sin(elapsed*f)
					ent.x, ent.y = originX + dispX*frac, originY + dispY*frac
					ent.gui.Position = UDim2.new(0, ent.x, 0, ent.y)
					--if the character is on this platform then make them move with it.
					if ch.OnPlatform == ent then
						local dx, dy = ent.x-lastX, ent.y-lastY
						ch.x = ch.x + dx
						if dy < 0 then
							ch.y = ch.y + dy
						end
					end
					lastX, lastY = ent.x, ent.y
				end
			end
			--
			append(TerrainEntityList, ent)
			append(TerrainObjectList, ent)	

		elseif v.Name == 'TERRAINENTITY_WIN' then
			local ent = {}
			--
			ent.x, ent.y = v.Position.X.Offset, v.Position.Y.Offset
			ent.w, ent.h = v.Size.X.Offset, v.Size.Y.Offset
			ent.gui = v
			--
			ent.BlockShot = false
			ent.DamagePlayer = false
			ent.Killable = false
			ent.InvincibleKillable = false
			--
			function ent:onCollide()
				ch.Won = true
				return true --remove
			end
			--
			append(EntityList, ent)		

		elseif v.Name:find('ENTITY_FOOD') then
			local ent = {}
			--
			ent.x, ent.y = v.Position.X.Offset, v.Position.Y.Offset
			ent.w, ent.h = v.Size.X.Offset, v.Size.Y.Offset
			ent.gui = v
			--
			ent.BlockShot = false
			ent.DamagePlayer = false
			ent.Killable = false
			ent.InvincibleKillable = false
			--
			local score = v:FindFirstChild('SCORE').Value
			function ent:onCollide()
				gameData.Score = gameData.Score + score
				ShowScoreDisplay(ent, score)
				ch.Health = math.min(32, ch.Health + 2)
				UpdateHud_Health()
				UpdateHud_Score()
				ent.gui:Destroy()
				return true --remove
			end
			--
			append(EntityList, ent)		

		elseif v.Name == 'ENTITY_ROCK' then
			local ent = {}
			--
			ent.x, ent.y = v.Position.X.Offset, v.Position.Y.Offset
			ent.w, ent.h = v.Size.X.Offset, v.Size.Y.Offset
			ent.gui = v
			--
			ent.BlockShot = true
			ent.DamagePlayer = true
			ent.Killable = false
			ent.InvincibleKillable = true
			--
			append(EntityList, ent)

		elseif v.Name == 'ENTITY_SNAIL' then
			local ent = {}
			--
			ent.x, ent.y = v.Position.X.Offset, v.Position.Y.Offset
			ent.w, ent.h = v.Size.X.Offset, v.Size.Y.Offset
			ent.gui = v
			--
			ent.BlockShot = false
			ent.DamagePlayer = true
			ent.Killable = true
			ent.InvincibleKillable = true
			--
			function ent:onDied()
				ent.CurrentImage = SnailAnim.DeadFrame
				ent.gui.Image = ent.CurrentImage
				AddGarbage(ent)
			end
			--
			StartAnimation(ent, SnailAnim, tick())
			--
			append(EntityList, ent)

		elseif v.Name == 'ENTITY_WASP' then
			local ent = {}
			--
			ent.x, ent.y = v.Position.X.Offset, v.Position.Y.Offset
			ent.w, ent.h = v.Size.X.Offset, v.Size.Y.Offset
			ent.gui = v
			--
			ent.BlockShot = false
			ent.DamagePlayer = true
			ent.Killable = true
			ent.InvincibleKillable = true
			--
			local initalY = ent.y
			local randOffs = math.random()*100
			function ent:onDied()
				ent.gui.Image = 'http://www.roblox.com/asset/?id=90220976' --dead wasp
				AddGarbage(ent)
			end
			function ent:onTick(dt, t)
				ent.y = initalY + 20*math.sin(t*2 + randOffs)
				ent.gui.Position = UDim2.new(0, ent.x, 0, ent.y)
			end
			--
			append(EntityList, ent)

		elseif v.Name == 'ENTITY_SNAKE' then
			local ent = {}
			--
			ent.x, ent.y = v.Position.X.Offset, v.Position.Y.Offset
			ent.w, ent.h = v.Size.X.Offset, v.Size.Y.Offset
			ent.gui = v
			--
			ent.BlockShot = false
			ent.DamagePlayer = true
			ent.Killable = true
			ent.InvincibleKillable = true
			--
			function ent:onDied()
				ent.gui.Image = 'http://www.roblox.com/asset/?id=90220995' --dead snake
				AddGarbage(ent)
			end
			--
			append(EntityList, ent)

		elseif v.Name == 'ENTITY_SKATEBOARD_EGG' then
			local ent = {}
			--
			ent.x, ent.y = v.Position.X.Offset, v.Position.Y.Offset
			ent.w, ent.h = v.Size.X.Offset, v.Size.Y.Offset
			ent.gui = v
			--
			ent.BlockShot = false
			ent.DamagePlayer = false
			ent.Killable = true
			ent.InvincibleKillable = true
			--
			function ent:onDied()
				ent.CurrentImage = 'http://www.roblox.com/asset/?id=34065729' --cracked egg
				ent.gui.Image = ent.CurrentImage
				AddGarbage(ent)

				--create the skateboard object
				--67x20
				local skateEnt = {}
				skateEnt.x = ent.x + ent.w/2 - 67/2
				skateEnt.y = ent.y + ent.h - 40
				skateEnt.w = 67
				skateEnt.h = 20
				skateEnt.CurrentImage = 'http://www.roblox.com/asset/?id=90032819' --skateboard
				CreateGui(skateEnt)
				--
				skateEnt.BlockShot = false
				skateEnt.DamagePlayer = false
				skateEnt.Killable = false
				skateEnt.InvincibleKillable = false
				--
				function skateEnt:onCollide()
					skateEnt.gui:Destroy()
					ch.IsSkating = true
					UpdateCharacterAnimation()
					return true --remove me
				end
				--
				append(EntityList, skateEnt)
			end
			function ent:onCollide()
				ent:onDied()
				return true --remove
			end
			--
			append(EntityList, ent)

		elseif v.Name == 'ENTITY_INVINCIBLE_EGG' then
			local ent = {}
			--
			ent.x, ent.y = v.Position.X.Offset, v.Position.Y.Offset
			ent.w, ent.h = v.Size.X.Offset, v.Size.Y.Offset
			ent.gui = v
			--
			ent.BlockShot = false
			ent.DamagePlayer = false
			ent.Killable = true
			ent.InvincibleKillable = true
			--
			function ent:onDied()
				ent.CurrentImage = 'http://www.roblox.com/asset/?id=89946259' --cracked egg
				ent.gui.Image = ent.CurrentImage
				AddGarbage(ent)

				--give player invincibility
				ch.IsInvuln = true
				ch.IsInvulnUntil = tick()+8
				if ch.InvulnAngel then ch.InvulnAngel.gui:Destroy() end
				ch.InvulnAngel = {
					Mode = 'In';
					Started = tick();
					gui = Create'ImageLabel'{
						Name = 'InvulnAngel';
						Parent = level;
						BackgroundTransparency = 1;
						Size = UDim2.new(0, 52, 0, 47);
						Position = UDim2.new();
					};
				}
				StartAnimation(ch.InvulnAngel, InvulnAngelAnim, tick())
			end
			function ent:onCollide()
				ent:onDied()
				return true --remove
			end
			--
			append(EntityList, ent)

		elseif v.Name == 'PLAYER_START' then
			local x, y = v.Position.X.Offset, v.Position.Y.Offset
			local w, h = v.Size.X.Offset, v.Size.Y.Offset
			--
			ch.x = x + w/2 - ch.w/2
			ch.y = y + h/2 - ch.h/2
			ch.gui = v
			ch.guioffsetx = w/2 - ch.w/2
			ch.guioffsety = h/2 - ch.h/2
		end
	end
	level.Parent = Gui.MainFrame.GameContainer
	--show a start level thing
	local startMsg = Tool.MessageFrame:Clone()
	startMsg.Parent = level.Parent
	startMsg.Message.Text = level.LEVELNAME.Value
	startMsg.Button.Visible = false
	Spawn(function()
		wait(0.5)
		startMsg:TweenPosition(UDim2.new(startMsg.Position.X.Scale, startMsg.Position.X.Offset, 
		                                 startMsg.Position.Y.Scale, startMsg.Position.Y.Offset - 400),
		                       'Out', 'Quad', 1)
		Delay(1, function()
			startMsg:Destroy()
		end)
	end)

	--========================== set up events =======================--
	--key connections
	local LastJumpKeyTime = 0;
	local KeyDownCn = KeyDown:connect(function(key)
		if ch.Dead then return end
		if key == 'w' and not ch.IsJumping and 
			(tick()-ch.LastOnGroundTime) < 0.1 and 
			(tick()-LastJumpKeyTime) > 0.1
		then
			LastJumpKeyTime = tick()
			ch.IsJumping = true
			ch.LastJumpAt = tick()
			ch.LastJumpVY = ch.vy
			ch.LastJumpY = ch.y
			if KeyState[string.char(13)] then --high jump
				ch.vy = ch.vy - 600
			else
				if IsSkating then
					ch.vy = ch.vy - 500
				else
					ch.vy = ch.vy - 400
				end
			end
		elseif key:byte() == 13 then --enter
			local jumpT = (tick()-ch.LastJumpAt)
			if jumpT < 0.1 then
				--do delayed super-jump
				ch.vy = ch.LastJumpVY - 600
				ch.y = ch.LastJumpY + ch.vy*jumpT + 0.5*GRAVITY*jumpT*jumpT
			else
				--fire
				local hatchet = {}
				hatchet.x = ch.x + ((ch.vx >= 0) and ch.w or -HATCHET_WIDTH)
				hatchet.y = ch.y
				hatchet.vx = ((ch.vx >= 0) and 1 or -1)*HATCHET_SPEED + ch.vx
				hatchet.vy = -200
				hatchet.w, hatchet.h = HATCHET_WIDTH, HATCHET_HEIGHT
				StartAnimation(hatchet, HatchetAnim, tick())
				hatchet.gui = Create'ImageLabel'{
					Parent = level;
					Name = "Hatchet";
					BackgroundTransparency = 1;
					Size = UDim2.new(0, HATCHET_WIDTH, 0, HATCHET_HEIGHT);
					Position = UDim2.new(0, hatchet.x, 0, hatchet.y);
					Image = hatchet.CurrentImage;
				}
				--
				append(HatchetList, hatchet)
			end
		end
		UpdateCharacterAnimation()
	end)
	local KeyUpCn = KeyUp:connect(function(key)
		UpdateCharacterAnimation()
	end)


	--=========================== game loop ==========================--
	local StartTime = tick()
	local LastTime = StartTime
	while Equipped and (not ch.Dead or (tick()-ch.DiedAt) < 2) and not ch.Won do
		---- timestep ----
		wait()
		if not Equipped then return end
		local Now = tick()
		local dt = Now-LastTime
		LastTime = Now
		------------------

		-- check for fallen
		if ch.y > 400 then
			ch.Dead = true
			break
		end

		-- apply movement controls
		local walkDir = (KeyState['a'] and -1 or 0) + (KeyState['d'] and 1 or 0)
		if ch.IsSkating then
			ch.vx = SKATE_SPEED + SKATE_MOD*walkDir
		else
			ch.vx = ch.vx + WALK_ACCEL*walkDir*dt
			--clamp velocity
			if ch.vx >  WALK_SPEED then ch.vx =  WALK_SPEED end
			if ch.vx < -WALK_SPEED then ch.vx = -WALK_SPEED end
		end

		-- move the character
		ch.vy = ch.vy + GRAVITY*dt
		ch.x, ch.y = ch.x + ch.vx*dt, ch.y + ch.vy*dt
		UpdateCharacterAnimation()

		--character stuff if not dead
		if not ch.Dead then
			-- disable invincibility if it is over the timeout, and animate the invulnerability angel
			if ch.IsInvuln then
				if Now > ch.IsInvulnUntil then
					--end invulnerability
					ch.IsInvuln = false
					ch.InvulnAngel.gui:Destroy()
					ch.InvulnAngel = nil

				else
					--move the angel (52x47)
					local elapsed = (Now - ch.InvulnAngel.Started)/8
					local x, y;
					if elapsed < 0.1 then
						elapsed = elapsed/0.1
						x = ch.x - 52 - 200*(1-elapsed)
						y = ch.y - 47 - 600*(1-elapsed)
					elseif elapsed < 0.9 then
						elapsed = (elapsed-0.1)/0.8
						x = ch.x - 52
						y = ch.y - 47
					else
						elapsed = (elapsed-0.9)/0.1
						x = ch.x - 52 - 200*(elapsed)
						y = ch.y - 47 - 600*(elapsed)
					end

					--draw the angel
					Animate(ch.InvulnAngel, Now)
					ch.InvulnAngel.gui.Position = UDim2.new(0, x, 0, y)
					ch.InvulnAngel.gui.Image = ch.InvulnAngel.CurrentImage
				end
			end

			-- take away health gradually
			if Now > ch.NextLoseHealthAt and not ch.Dead then
				ch.NextLoseHealthAt = ch.NextLoseHealthAt + TIME_BETWEEN_HEALTH_LOSS
				ch.Health = ch.Health - 1
				if ch.Health == 0 then
					ch.Dead = true
					ch.DiedAt = Now;
					AddGarbage(ch)
				end
				UpdateHud_Health()
			end

			-- collide the character with the terrain
			local didCollide = false
			local applyFriction = false
			ch.OnPlatform = nil
			for _, terrain in pairs(TerrainObjectList) do
				local axis = CollideRect(ch, terrain, true)
				if axis then
					didCollide = true
					if axis == 'y' then
						applyFriction = true
					end
					ch.LastOnGroundHeight = ch.y
					if terrain.Platform then
						ch.OnPlatform = terrain
					end
				end
			end

			--collide the character with entites if they have not recently got damage
			if Now-ch.LastDamagedAt > DAMAGE_SAFE_PERIOD then
				for i, ent in pairs(EntityList) do
					if CollideRect(ch, ent, false) then
						--if we are invincible, blast everything killable out of the way
						if ch.IsInvuln and ent.InvincibleKillable then
							table.remove(EntityList, i)
							i = i - 1
							if i == 0 then i = nil end
							if ent.onDied then
								ent:onDied()
							else
								AddGarbage(ent)
							end
						else
							--normal hit behavior
							--pollibly damage us
							if ent.DamagePlayer then
								--inflict damage
								if ch.IsSkating then
									--if we're on a skateboard, put us off of it
									ch.IsSkating = false
									UpdateCharacterAnimation()
								else
									--otherwise, we lose a bunch of health
									ch.Health = math.max(0, ch.Health - 8)
									if ch.Health == 0 then 
										AddGarbage(ch) 
										ch.Dead = true
										ch.DiedAt = Now;
									end
									UpdateHud_Health()
								end

								--push us up into the air a bit. Play damaged anim
								--todo: play a damaged sound
								ch.vy = ch.vy - 40
								ch.LastDamagedAt = Now
								UpdateCharacterAnimation()
								Delay(DAMAGE_SAFE_PERIOD+0.1, UpdateCharacterAnimation)
							elseif ent.onCollide then
								--otherwise run specific oncollide behavoir
								if ent:onCollide() then
									table.remove(EntityList, i)
									i = i - 1
									if i == 0 then i = nil end
								end
							end
						end
					end
				end
			end

			-- record isonground
			ch.IsOnGround = didCollide and applyFriction
			if ch.IsOnGround then
				ch.LastOnGroundTime = Now
				ch.LastOnGroundHeight = ch.y
			end

			-- if we collided, and are jumping, then end the jump
			if didCollide and ch.IsJumping then
				ch.IsJumping = false
				UpdateCharacterAnimation()
			end

			-- if we collided on the y axis, and aren't walking, then apply friction 
			if applyFriction and walkDir == 0 then
				local old = ch.vx
				ch.vx = sign(ch.vx)*math.max(0, math.abs(ch.vx) - 600*dt)
				if ch.vx == 0 and old ~= 0 then
					--switch walk -> idle
					UpdateCharacterAnimation()
				end
			end

		end --(if not not ch.Dead)

		-- draw the character
		if not ch.Dead then
			Animate(ch, Now)
			ch.gui.Position = UDim2.new(0, ch.x - ch.guioffsetx, 0, ch.y - ch.guioffsety)
			if ch.vx >= 0 or not ch.CurrentImageR then
				ch.gui.Image = ch.CurrentImage
			else
				ch.gui.Image = ch.CurrentImageR
			end
		else
			ch.gui.Image = CharacterAnim_Jump[1]
		end

		-- move and effect hatchets
		local stageBottom = level.Parent.AbsolutePosition.y + STAGE_HEIGHT
		for i = 1, #HatchetList do
			local h = HatchetList[i]
			if h then
				h.vy = h.vy + GRAVITY*dt
				h.x = h.x + h.vx*dt
				h.y = h.y + h.vy*dt
				Animate(h, Now)
				h.gui.Image = h.CurrentImage
				h.gui.Position = UDim2.new(0, h.x, 0, h.y)

				--see if the hatchet is out of bounds
				if h.gui.AbsolutePosition.y > stageBottom then
					table.remove(HatchetList, i)
					h.gui:Destroy()
					i = i - 1
				else
					--collide with stuff
					for entityNum, ent in pairs(EntityList) do
						if CollideRect(h, ent, ent.BlockShot) then
							if ent.Killable then
								table.remove(EntityList, entityNum)
								if ent.onDied then
									ent:onDied()
								else
									AddGarbage(ent)
								end
								break
							end
						end
					end
				end
			end
		end

		-- move and effect garbage
		for i = 1, #GarbageList do
			local garbage = GarbageList[i]
			if garbage then
				garbage.vy = garbage.vy + GRAVITY*dt
				garbage.x = garbage.x + garbage.vx*dt
				garbage.y = garbage.y + garbage.vy*dt
				garbage.gui.Position = UDim2.new(0, garbage.x, 0, garbage.y)
				--
				if garbage.gui.AbsolutePosition.y > stageBottom then
					table.remove(GarbageList, i)
					garbage.gui:Destroy()
					i = i - 1
				end
			end
		end

		-- move and effect entities
		for _, ent in pairs(EntityList) do
			--play anims
			if ent.CurrentAnim then
				Animate(ent, Now)
				ent.gui.Image = ent.CurrentImage
			end
			if ent.onTick then
				ent:onTick(dt, Now)
			end
		end

		--move and effect terrain entities
		for _, ent in pairs(TerrainEntityList) do
			if ent.onTick then
				ent:onTick(dt, Now)
			end
		end

		--move screen to track character
		if not ch.Dead then
			local stageLeft = level.Parent.AbsolutePosition.x
			local characterAt = ch.gui.AbsolutePosition.x + ch.gui.Size.X.Offset/2
			local characterOffset = characterAt - stageLeft
			local toMove;
			--if we're falling adjust lastongroundat
			if ch.gui.AbsolutePosition.y > stageBottom - 150 then
				CamCurrentHeight = ch.y
				ch.LastOnGroundHeight = ch.y
			end

			--track character y
			local desiredMove = (ch.LastOnGroundHeight - CamCurrentHeight)
			local camSpeed = 100 + 200*math.min(1, math.abs(desiredMove)/100)
			CamCurrentHeight = CamCurrentHeight + sign(desiredMove)*math.min(math.abs(desiredMove), 100*dt)

			--track character x
			if characterOffset > STAGE_WIDTH*0.6 then
				toMove = -(characterOffset - STAGE_WIDTH*0.6)
			elseif characterOffset < STAGE_WIDTH*0.4 then
				toMove =  (STAGE_WIDTH*0.4 - characterOffset)
			end
			level.Position = UDim2.new(0, level.Position.X.Offset + (toMove or 0), 
			                           0, -CamCurrentHeight + 240)
		end

	end --end MainLoop

	KeyDownCn:disconnect()
	KeyUpCn:disconnect()

	--if we're still running
	if Equipped then
		--show dead or next level screen
		local msg = Tool.MessageFrame:Clone()
		msg.Parent = level.Parent
		msg.Button.Visible = false
		msg.Message.Text = ''

		if ch.Dead then
			if gameData.Lives > 0 then
				ch.Health = 0
				UpdateHud_Health()
				gameData.Lives = gameData.Lives - 1
				msg.Message.Text = 'You Died'
				wait(0.5)
				UpdateHud_Life()
				wait(0.5)
				msg.Button.Text = 'Try '..level.LEVELNAME.Value..' Again'
				msg.Button.Visible = true
				msg.Button.MouseButton1Down:wait()
				--
				msg:Destroy()
				level:Destroy()
				return 'TryAgain'
			else
				msg.Message.Text = 'You Lose =('
				msg.Button.Text = 'Restart Game'
				msg.Button.Visible = true
				msg.Button.MouseButton1Down:wait()
				--
				msg:Destroy()
				level:Destroy()
				return 'RestartGame'
			end
		else
			msg.Message.Text = level.LEVELNAME.Value..' Completed'
			for i = ch.Health, 1, -1 do
				ch.Health = ch.Health - 1
				gameData.Score = gameData.Score + 100
				UpdateHud_Health()
				UpdateHud_Score()
				wait(0.06)
			end
			if Tool:FindFirstChild(level.NEXTLEVEL.Value) then
				msg.Button.Text = 'Start Next Level'
				msg.Button.Visible = true
				msg.Button.MouseButton1Down:wait()
			end
			msg:Destroy()
			level:Destroy()
			return 'NextLevel'
		end
	end
end


local function PlayGame()
	gameData = {}
	gameData.Score = 0
	gameData.Lives = 5
	--
	local curLevel = Tool.GameLevelTutorial
	while Equipped do
		local status = PlayLevel(curLevel, gameData)
		if status == 'TryAgain' then
			--do nothing, loop
		elseif status == 'RestartGame' then
			return PlayGame()
		elseif status == 'NextLevel' then
			curLevel = Tool:FindFirstChild(curLevel.NEXTLEVEL.Value)
			if not curLevel then
				local msg = Tool.MessageFrame:Clone()
				msg.Parent = Gui.MainFrame.GameContainer
				msg.Message.Text = 'You Win! Score: '..gameData.Score
				msg.Button.Text = 'Play Again?'
				msg.Button.MouseButton1Down:wait()
				return PlayGame()
			end
		end
	end
end


Tool.Equipped:connect(function(mouse)
	Equipped = true
	Character = Tool.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	PlayerGui = Player.PlayerGui
	--
	--PlayerGui:ClearAllChildren()
	Character.Humanoid.WalkSpeed = 0
	--
	mouse.KeyDown:connect(function(key) doKeyDown(key) end)
	mouse.KeyUp:connect(function(key) doKeyUp(key) end)
	--
	Gui = Create'ScreenGui'{
		Parent = PlayerGui;
		Name = 'WonderboyGui';
		--
		Create'Frame'{
			Name = 'MainFrame';
			Parent = PlayerGui;
			Style = 'RobloxRound';
			Size = UDim2.new(0, 600, 0, 430);
			Position = UDim2.new(0.5, -300, 0.5, -250);
			--
			Create'Frame'{
				Name = 'GameContainer';
				Size = UDim2.new(1,0,1,0);
				ClipsDescendants = true;
				BackgroundTransparency = 1;
			};
		};
	}
	Tool.TitleScreen:Clone().Parent = Gui.MainFrame
	local ClickedStart = false
	Spawn(function()
		while Equipped and not ClickedStart do
			Gui.MainFrame.TitleScreen.StartButton.StartButton.TextTransparency = 0.7*(0.5+0.5*math.sin(tick()*2))
			wait()
		end
	end)
	Gui.MainFrame.TitleScreen.StartButton.StartButton.MouseButton1Down:wait()
	ClickedStart = true
	Gui.MainFrame.TitleScreen.Visible = false
	Tool.Hud:Clone().Parent = Gui.MainFrame
	for i = 1, 32 do
		local frame = Create'Frame'{
			Name = 'Health'..i;
			Parent = Gui.MainFrame.Hud.HealthContainer;
			BackgroundColor3 = (i > 8) and Color3.new(0.9, 0.9, 0) or Color3.new(0.9, 0, 0);
			BorderSizePixel = 0;
			Position = UDim2.new(0, 5*(i-1)-3, 0, -3);
			Size = UDim2.new(0, 3, 0, 14);
		}
	end
	--
	PlayGame()
end)

Tool.Unequipped:connect(function()
	if Character then
		Character.Humanoid.WalkSpeed = 16
	end
	Equipped = false
	if Gui then
		Gui:Destroy()
		Gui = nil
	end
end)
