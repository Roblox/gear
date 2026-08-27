local function Create_PrivImpl(objectType)
	if type(objectType) ~= 'string' then
		error("Argument of Create must be a string", 2)
	end
	return function(dat)
		dat = dat or {}
		local obj = Instance.new(objectType)
		local ctor = nil
		for k, v in pairs(dat) do
			if type(k) == 'string' then
				obj[k] = v
			elseif type(k) == 'number' then
				if type(v) ~= 'userdata' then
					error("Bad entry in Create body: Numeric keys must be paired with children, got a: "..type(v), 2)
				end
				v.Parent = obj
			elseif type(k) == 'table' and k.__eventname then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create.E\'"..k.__eventname.."\']` must have a function value\
					       got: "..tostring(v), 2)
				end
				obj[k.__eventname]:connect(v)
			elseif k == Create then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create]` should be paired with a constructor function, \
					       got: "..tostring(v), 2)
				elseif ctor then
					error("Bad entry in Create body: Only one constructor function is allowed", 2)
				end
				ctor = v
			else
				error("Bad entry ("..tostring(k).." => "..tostring(v)..") in Create body", 2)
			end
		end
		if ctor then
			ctor(obj)
		end
		return obj
	end
end
Create = setmetatable({}, {__call = function(tb, ...) return Create_PrivImpl(...) end})
Create.E = function(eventName)
	return {__eventname = eventName}
end

-------------------------------------------------------------------------------

local Model_Rock1 = {
	Name = 'Rock1';
	Image = 'http://www.roblox.com/asset/?id=84811980';
	{0.748,0.007},{0.902,0.050},{0.988,0.183},
	{0.980,0.335},{0.838,0.535},{0.520,0.815},
	{0.195,0.978},{0.083,0.950},{0.010,0.815},
	{0.058,0.642},{0.193,0.453},{0.512,0.117},
}

local Model_Rock2 = {
	Name = 'Rock2';
	Image = 'http://www.roblox.com/asset/?id=84811991';
	{0.065,0.328},{0.215,0.212},{0.373,0.077},
	{0.552,0.010},{0.772,0.028},{0.920,0.100},
	{0.990,0.215},{0.980,0.352},{0.950,0.482},
	{0.848,0.662},{0.767,0.833},{0.590,0.953},
	{0.415,0.968},{0.297,0.892},{0.230,0.830},
	{0.147,0.810},{0.030,0.675},{0.015,0.522},
}

local Model_Rock3 = {
	Name = 'Rock3';
	Image = 'http://www.roblox.com/asset/?id=84812013';
	{0.125,0.265},{0.330,0.087},{0.645,0.035},
	{0.873,0.128},{0.912,0.175},{0.925,0.410},
	{0.993,0.698},{0.988,0.825},{0.900,0.925},
	{0.743,0.983},{0.482,0.983},{0.203,0.917},
	{0.060,0.815},{0.003,0.680},{0.015,0.532},
	{0.060,0.383},
}

local Model_Rock4 = {
	Name = 'Rock4';
	Image = 'http://www.roblox.com/asset/?id=84812033';
	{0.185,0.250},{0.335,0.100},{0.412,0.063},
	{0.555,0.010},{0.748,0.030},{0.892,0.190},
	{0.948,0.370},{0.927,0.568},{0.770,0.823},
	{0.655,0.930},{0.487,0.973},{0.265,0.958},
	{0.108,0.838},{0.028,0.677},{0.048,0.487},
}

local Model_Rock5 = {
	Name = 'Rock5';
	Image = 'http://www.roblox.com/asset/?id=84812047';
	{0.517,0.095},{0.795,0.328},{0.990,0.637},
	{0.995,0.780},{0.950,0.927},{0.833,0.970},
	{0.635,0.950},{0.388,0.813},{0.185,0.652},
	{0.028,0.417},{0.015,0.282},{0.022,0.145},
	{0.090,0.043},{0.177,0.003},{0.375,0.013},	
}

local ModelsByName = {
	Model_Rock1 = Model_Rock1;
	Model_Rock2 = Model_Rock2;
	Model_Rock3 = Model_Rock3;
	Model_Rock4 = Model_Rock4;
	Model_Rock5 = Model_Rock5;
}

local Level1_Data = {
{{0.0029,0.1600},{0.1821,0.1233},{0.3013,0.2256},{0.3187,0.3178},
	{0.2529,0.4022},{0.0063,0.3911},};
{{0.2512,0.4033},{0.2429,0.4878},{0.2129,0.6089},{0.0429,0.4167},};
{{0.2179,0.5922},{0.2571,0.7322},{0.0921,0.7278},};
{{0.2562,0.7322},{0.4479,0.7922},{0.3121,0.8900},};
{{0.4496,0.7944},{0.5938,0.6922},{0.5938,0.9167},};
{{0.5879,0.6978},{0.6288,0.6289},{0.7021,0.6144},{0.7754,0.7222},
	{0.6754,0.9256},};
{{0.7771,0.7244},{0.8812,0.6544},{0.8854,0.8478},};
{{0.8554,0.6933},{0.8996,0.4200},{0.9654,0.6189},};
{{0.9046,0.4733},{0.7996,0.2233},{0.9429,0.2989},};
{{0.8129,0.2578},{0.7204,0.3400},{0.5904,0.4000},{0.4571,0.3422},
	{0.4688,0.2067},{0.5554,0.1378},{0.6671,0.1744},};
{{0.6679,0.1744},{0.8296,0.1311},{0.9971,0.1789},{0.8329,0.2522},};
}

local Level2_Data = {
{{0.0037,0.0811},{0.2188,0.0478},{0.3063,0.0733},{0.3362,0.2844},};
{{0.3196,0.2333},{0.4404,0.3611},{0.2746,0.4233},};
{{0.3854,0.3389},{0.5863,0.3844},{0.6821,0.5011},{0.6679,0.6611},};
{{0.6646,0.5944},{0.7154,0.7544},{0.5737,0.7200},};
{{0.6787,0.7111},{0.8271,0.7811},{0.7279,0.8444},};
{{0.7871,0.7733},{0.8388,0.7533},{0.8829,0.7567},{0.8496,0.8300},};
{{0.8529,0.7822},{0.8612,0.7467},{0.8854,0.7389},{0.8962,0.7944},};
{{0.8562,0.5856},{0.8779,0.7600},{0.9121,0.4044},};
{{0.7146,0.3378},{0.8779,0.3344},{0.6004,0.2267},};
{{0.4229,0.1478},{0.4846,0.2356},{0.6288,0.2533},{0.9979,0.1456},{0.7346,0.0822},{0.4537,0.1089},};
}

local Level3_Data = {
{{0.0013,0.1028},{0.1729,0.1483},{0.2046,0.2906},{0.1854,0.4728},{0.1354,0.6194},};
{{0.1371,0.5950},{0.1271,0.7817},{0.0254,0.6572},};
{{0.1121,0.7406},{0.2321,0.8683},{0.0996,0.9039},};
{{0.2004,0.8639},{0.3388,0.7850},{0.4612,0.8406},};
{{0.4238,0.8361},{0.5096,0.8083},{0.4813,0.8894},};
{{0.4846,0.8572},{0.5246,0.6183},{0.5837,0.5694},{0.6704,0.5683},{0.7779,0.6183},};
{{0.7638,0.6317},{0.7204,0.3839},{0.8512,0.5172},};
{{0.7488,0.4383},{0.5837,0.3083},{0.7113,0.2372},};
{{0.6496,0.3150},{0.4562,0.3506},{0.5363,0.1939},};
{{0.4113,0.1328},{0.4946,0.3417},{0.4796,0.5394},{0.4046,0.6683},{0.3196,0.6372},{0.2971,0.4839},{0.3287,0.2939},};
{{0.4113,0.1339},{0.6763,0.1794},{0.5096,0.3083},};
{{0.6454,0.1917},{0.9096,0.1306},{0.9979,0.1506},{0.8712,0.2750},};
}

local Level4_Data = {
{{0.0013,0.1028},{0.1729,0.1483},{0.2046,0.2906},{0.1854,0.4728},{0.1354,0.6194},};
{{0.1371,0.5950},{0.1271,0.7817},{0.0254,0.6572},};
{{0.1121,0.7406},{0.2321,0.8683},{0.0996,0.9039},};
{{0.2004,0.8639},{0.3388,0.7850},{0.4612,0.8406},};
{{0.4238,0.8361},{0.5096,0.8083},{0.4813,0.8894},};
{{0.4846,0.8572},{0.5246,0.6183},{0.5837,0.5694},{0.6704,0.5683},{0.7779,0.6183},};
{{0.7638,0.6317},{0.7204,0.3839},{0.8512,0.5172},};
{{0.7488,0.4383},{0.5837,0.3083},{0.7113,0.2372},};
{{0.6496,0.3150},{0.4562,0.3506},{0.5363,0.1939},};
{{0.4113,0.1328},{0.4946,0.3417},{0.4796,0.5394},{0.4046,0.6683},{0.3196,0.6372},{0.2971,0.4839},{0.3287,0.2939},};
{{0.4113,0.1339},{0.6763,0.1794},{0.5096,0.3083},};
{{0.6454,0.1917},{0.9096,0.1306},{0.9979,0.1506},{0.8712,0.2750},};
{{0.3329,0.7017},{0.4071,0.7172},{0.4046,0.7361},{0.3312,0.7183},};
}

local Level5_Data = {
{{0.0021,0.0728},{0.1279,0.1083},{0.1646,0.2228},{0.1479,0.3206},{0.0862,0.4083},};
{{0.0938,0.3839},{0.1238,0.5650},{0.0179,0.4906},};
{{0.1071,0.5472},{0.1729,0.5617},{0.2121,0.6872},{0.1479,0.8317},};
{{0.1621,0.7850},{0.1487,0.9550},{0.0887,0.8294},};
{{0.1354,0.8994},{0.1904,0.9806},{0.1088,0.9739},};
{{0.1688,0.9772},{0.2537,0.9106},{0.2479,0.9772},};
{{0.2463,0.9550},{0.2221,0.8706},{0.2788,0.6928},};
{{0.2621,0.7583},{0.2754,0.6150},{0.3479,0.5772},{0.4279,0.6594},};
{{0.3937,0.6517},{0.4663,0.5539},{0.5396,0.5617},{0.5546,0.8606},};
{{0.5337,0.8161},{0.7321,0.8383},{0.6188,0.9294},};
{{0.6763,0.8517},{0.8538,0.7728},{0.7763,0.9050},};
{{0.8046,0.8106},{0.9287,0.6350},{0.9296,0.8128},};
{{0.9196,0.7006},{0.9021,0.5339},{0.9596,0.3261},{0.9971,0.2739},};
{{0.5879,0.7550},{0.5871,0.7761},{0.7171,0.7561},};
{{0.6388,0.2128},{0.7937,0.4050},{0.8263,0.5683},{0.7846,0.6628},{0.6863,0.7183},{0.5863,0.7161},{0.5813,0.4906},};
{{0.5804,0.4872},{0.6404,0.2128},{0.4704,0.2128},{0.5537,0.3983},};
{{0.4521,0.4028},{0.5212,0.2928},{0.5537,0.3961},};
{{0.1863,0.3450},{0.1412,0.4239},{0.1554,0.5039},{0.2321,0.4806},};
{{0.1821,0.3517},{0.2304,0.4817},{0.3329,0.5083},{0.4079,0.4750},{0.4529,0.4028},{0.4713,0.2128},{0.2737,0.1050},}
}

local Level6_Data = {
{{0.0037,0.1228},{0.2871,0.1639},{0.3821,0.2539},{0.3787,0.3106},{0.3454,0.3928},{0.2479,0.4283},};
{{0.2721,0.4083},{0.1779,0.5372},{0.1821,0.4017},};
{{0.1863,0.4928},{0.2037,0.6861},{0.0838,0.5906},};
{{0.1812,0.6294},{0.2646,0.7883},{0.1412,0.7539},};
{{0.2271,0.7694},{0.4437,0.7206},{0.3563,0.8817},};
{{0.4004,0.7517},{0.4804,0.6194},{0.5496,0.7506},};
{{0.5212,0.7139},{0.6054,0.7406},{0.5396,0.8061},};
{{0.5687,0.7539},{0.6196,0.6839},{0.7221,0.6817},};
{{0.6863,0.7039},{0.7196,0.5661},{0.7504,0.6739},};
{{0.7146,0.6094},{0.7037,0.4472},{0.7763,0.5361},};
{{0.7254,0.4850},{0.5837,0.4517},{0.5521,0.2972},{0.6613,0.2161},{0.7771,0.3228},};
{{0.6146,0.4572},{0.4929,0.5039},{0.3787,0.4183},{0.3979,0.3639},};
{{0.4071,0.2594},{0.5504,0.2950},{0.3996,0.3594},};
{{0.3779,0.4206},{0.4921,0.5028},{0.4821,0.5650},};
{{0.4612,0.5228},{0.4804,0.5794},{0.4946,0.4928},};
{{0.7588,0.3228},{0.9179,0.3006},{0.8354,0.4006},};
{{0.8812,0.3228},{0.9971,0.1894},{0.9921,0.3861},};
}

local Level7_Data = {
{{0.0029,0.0761},{0.1154,0.1117},{0.2079,0.2150},{0.2496,0.3683},{0.2296,0.5283},};
{{0.2254,0.5039},{0.2371,0.7139},{0.1563,0.7794},};
{{0.1821,0.7383},{0.1513,0.8950},{0.0529,0.7783},};
{{0.1354,0.8661},{0.3371,0.9461},{0.1871,0.9661},};
{{0.3029,0.9506},{0.4854,0.8161},{0.4354,0.9628},};
{{0.4604,0.8672},{0.4629,0.6306},{0.4954,0.5450},{0.5863,0.5494},};
{{0.5671,0.5594},{0.6062,0.4872},{0.6613,0.4883},};
{{0.6563,0.4994},{0.6504,0.4461},{0.7004,0.4761},};
{{0.6671,0.4639},{0.6296,0.4639},{0.5946,0.3783},};
{{0.6254,0.3883},{0.4654,0.4306},{0.5279,0.3217},};
{{0.5079,0.4006},{0.4254,0.6506},{0.2771,0.7339},{0.2637,0.5328},};
{{0.4396,0.6083},{0.4346,0.7828},{0.3204,0.8539},{0.2321,0.8006},{0.2779,0.7306},};
{{0.2637,0.5317},{0.2938,0.3394},{0.3696,0.4750},};
{{0.2863,0.3917},{0.2938,0.2272},{0.4788,0.2661},};
{{0.4379,0.2683},{0.6721,0.2339},{0.5587,0.3294},};
{{0.6713,0.2328},{0.9962,0.2717},{0.8104,0.3961},};
}

local Level8_Data = {
{{0.0021,0.1139},{0.1971,0.1183},{0.2712,0.1739},{0.2729,0.4728},};
{{0.2671,0.4228},{0.3613,0.6217},{0.2171,0.5772},};
{{0.3379,0.6083},{0.4113,0.6106},{0.4113,0.7894},{0.3654,0.8694},};
{{0.3513,0.8628},{0.4946,0.8628},{0.4163,0.9306},};
{{0.4338,0.5161},{0.4988,0.5861},{0.4829,0.8739},{0.4329,0.7906},};
{{0.4104,0.5739},{0.3638,0.5728},{0.2954,0.4217},{0.2929,0.1717},{0.3921,0.0872},{0.4113,0.4028},};
{{0.3921,0.0861},{0.5371,0.0806},{0.4696,0.4039},{0.4104,0.4028},};
{{0.4871,0.5894},{0.5096,0.5272},{0.5421,0.5839},};
{{0.5363,0.5806},{0.5721,0.5250},{0.6138,0.5861},};
{{0.5896,0.5761},{0.6679,0.5750},{0.6671,0.8650},};
{{0.5329,0.0806},{0.6088,0.4028},{0.6887,0.3983},{0.7446,0.1128},};
{{0.4629,0.3872},{0.5104,0.4828},{0.5437,0.4183},};
{{0.5329,0.4094},{0.5704,0.4839},{0.6146,0.3894},};
{{0.7462,0.1117},{0.7454,0.7728},{0.6896,0.7694},{0.6896,0.3994},};
{{0.6554,0.8450},{0.7829,0.8461},{0.7196,0.9250},};
{{0.7671,0.8661},{0.7671,0.0828},{0.9971,0.0628},};
}

local LevelDataByName = {
	Level1 = Level1_Data;
	Level2 = Level2_Data;
	Level3 = Level3_Data;
	Level4 = Level4_Data;
	Level5 = Level5_Data;
	Level6 = Level6_Data;
	Level7 = Level7_Data;
	Level8 = Level8_Data;
}

-------------------------------------------------------------------------------

local function norm(x, y)
	local len = math.sqrt(x*x + y*y)
	return x/len, y/len
end
local function sub(ax,ay,bx,by)
	return ax-bx, ay-by
end
local function add(ax,ay,bx,by)
	return ax+bx, ay+by
end
local function len(x, y)
	return math.sqrt(x*x + y*y)
end
local function unit(x, y)
	local a = len(x, y)
	return x/a, y/a
end
local function dot(ax, ay, bx, by)
	return ax*bx + ay*by
end

local function removeValue(tb, v)
	for i = 1, #tb do
		if tb[i] == v then
			table.remove(tb, i)
			break
		end
	end
end

local function waitForAny(...)
	local events = {...}
	local cns = {}
	local sig = Instance.new('IntValue')
	local ret;
	for i, e in pairs(events) do
		cns[i] = e:connect(function(...)
			ret = {...}
			sig.Value = i
		end)
	end
	while sig.Value == 0 do
		sig.Changed:wait()
	end
	for _, cn in pairs(cns) do
		cn:disconnect()
	end
	return sig.Value, unpack(ret)
end

function InstanceModel(model, x, y, w, h, collide)
	local inst = {}
	--
	inst.Gui = Create'ImageLabel'{
		BackgroundTransparency = 1;
		Image = model.Image or '';
		Position = UDim2.new(0, x, 0, y);
		Size = UDim2.new(0, w, 0, h);
		--Visible = (not not model.Image);
	}
	inst.Name = model.Name or ''
	if collide then
		local maxx, minx, maxy, miny = -math.huge, math.huge, -math.huge, math.huge
		--generate each of the separating axis for the shape
		local axisList = {}
		local function AddAxisFromSeg(a, b)
			local ax, ay = x+a[1]*w, y+a[2]*h
			local bx, by = x+b[1]*w, y+b[2]*h
			--
			if ax > maxx then maxx = ax end
			--print(string.format("ax=%f <? minx=%f, %s", ax, minx, tostring(ax<minx)))
			if ax < minx then minx = ax end
			if ay > maxy then maxy = ay end
			if ay < miny then miny = ay end
			--[[
			Create'Frame'{
				Parent = inst.Gui;
				Position = UDim2.new(0, ax-x-2, 0, ay-y-2);
				Size = UDim2.new(0,5,0,5);
				BackgroundColor3 = Color3.new(1,0,0);
				BorderSizePixel = 0;
			}
			]]
			--
			local axis = {}
			--get the axis
			local dx, dy = norm(bx-ax, by-ay)
			dx, dy = -dy, dx 
			axis.DirX, axis.DirY = dx, dy
			
			--find the projection of self onto the axis. We can cache
			--this because there is no rotation to deal with.
			local shadowMin = math.huge
			local shadowMax = -math.huge
			for i = 1, #model do
				local p = model[i]
				local px, py = x+p[1]*w, y+p[2]*h
				local proj = px*dx + py*dy
				if proj < shadowMin then shadowMin = proj end
				if proj > shadowMax then shadowMax = proj end
			end
			axis.Min = shadowMin
			axis.Max = shadowMax
			axisList[#axisList+1] = axis
		end
		inst.Axis = axisList
		--
		for i = 1, #model-1 do
			AddAxisFromSeg(model[i], model[i+1])
		end
		AddAxisFromSeg(model[#model], model[1])
		--
		--now generate a bounding disk
		inst.CenterX = (minx+maxx)/2
		inst.CenterY = (miny+maxy)/2
		--print(string.format("minx,maxx: (%.2f, %.2f)", minx, maxx))
		inst.RadiusSq = ((maxx-minx)/2)^2 + ((maxy-miny)/2)^2
		inst.Radius = math.sqrt(inst.RadiusSq)
		--[[
		Create'Frame'{
			Parent = inst.Gui;
			Position = UDim2.new(0, inst.CenterX-x-3, 0, inst.CenterY-y-3);
			Size = UDim2.new(0,7,0,7);
			BackgroundColor3 = Color3.new(0,1,0);
			BorderSizePixel = 0;
		}
		]]
	end
	return inst
end

-------------------------------------------------------------------------------

function CreateLevel_FromGui(gui)
	local level = {}
	level.Terrain = {}
	for _, ch in pairs(gui:GetChildren()) do
		ch:Destroy()
		local model = ModelsByName[ch.Name]
		if model then
			local p = ch.Position
			local s = ch.Size
			local inst = InstanceModel(model, p.X.Offset, p.Y.Offset, 
			                                  s.X.Offset, s.Y.Offset, true)
			level.Terrain[#level.Terrain+1] = inst
			inst.Gui.Parent = gui
		end
	end
	return level
end

function CreateLevel_FromData(gui)
	local level = {}
	level.Terrain = {}
	for _, mod in pairs(LevelDataByName[gui.Parent.Name]) do
		local inst = InstanceModel(mod, 0, 0, gui.Size.X.Offset, gui.Size.Y.Offset, true)
		level.Terrain[#level.Terrain+1] = inst
		inst.Gui.Parent = gui
	end
	return level
end

-------------------------------------------------------------------------------

local ShipScale = 10
local ShipPoints = {
	{ 0,  1.5}, { 1, -0.5},
	{ 1, -1.5}, { 0, -0.5},
	{-1, -1.5}, {-1, -0.5},
}
local CratePoints = {
	{ 1,  1}, {-1,  1},
	{-1, -1}, { 1, -1},
}
function CreateBody(points, scale)
	local this = {
		X = 0, Y = 0;
		VX = 0, VY = 0;
		Radius = 0;
		Rotation = 0;
		Restitution = 1;
		NumPoints = #points;
	}
	--scale points and assign the radius
	local newPoints = {}
	for i, p in pairs(points) do
		newPoints[i] = {p[1]*scale, p[2]*scale}
		local rad = math.sqrt(newPoints[i][1]^2 + newPoints[i][2]^2)
		if rad > this.Radius then
			this.Radius = rad
		end
	end
	points = newPoints
	this.RadiusSq = this.Radius*this.Radius
	--
	function this:GetPoints()
		local pts = {}
		for i, p in pairs(points) do
			local sin, cos = math.sin(this.Rotation), math.cos(this.Rotation)
			local x = this.X + p[1]*cos - p[2]*sin
			local y = this.Y + p[2]*cos + p[1]*sin
			pts[i] = {x, y}
		end
		return pts
	end
	--
	return this
end

-------------------------------------------------------------------------------

function CreateLine(guiframe, color)
	local this = {}
	--
	local mPoints = {}
	--
	function this:Show(ax,ay,bx,by)
		local dx, dy = sub(bx,by,ax,ay)
		local ux, uy = unit(dx,dy)
		local dist = len(dx,dy)
		local i = 0
		--
		for d = 0, dist do
			i = i + 1
			local frame;
			if mPoints[i] then
				frame = mPoints[i]
			else
				frame = Create'Frame'{
					Parent = guiframe;
					BorderSizePixel = 0;
					BackgroundColor3 = color;
					Size = UDim2.new(0,3,0,3);
					BackgroundTransparency = 0.7;
					Create'Frame'{
						BorderSizePixel = 0;
						BackgroundColor3 = color;
						Size = UDim2.new(0,1,0,1);
						Position = UDim2.new(0,1,0,1);
					};
				}
				mPoints[i] = frame
			end
			--
			frame.Position = UDim2.new(0, ax+ux*d, 0, ay+uy*d)
		end
		--
		for toRem = i+1, #mPoints do
			mPoints[toRem]:Destroy()
			mPoints[toRem] = nil
		end
	end
	function this:Hide()
		for i = 1, #mPoints do
			mPoints[i]:Destroy()
			mPoints[i] = nil
		end
	end
	--
	return this
end

function CreateBodyView(body, guiframe, color)
	local this = {}
	--
	local mLines = {}
	for i = 1, body.NumPoints do
		mLines[i] = CreateLine(guiframe, color)
	end
	--
	function this:Show()
		local pts = body:GetPoints()
		for i = 1, #pts-1 do
			local p1, p2 = pts[i], pts[i+1]
			mLines[i]:Show(p1[1], p1[2], p2[1], p2[2])
		end
		local pLast, pFirst = pts[#pts], pts[1]
		mLines[#mLines]:Show(pLast[1], pLast[2], pFirst[1], pFirst[2])
	end
	function this:Hide()
		for i = 1, #mLines do
			mLines[i]:Hide()
		end
	end
	--
	return this
end

-------------------------------------------------------------------------------

function CollidePointWithLevel(level, px, py, candidates)
	local overlapAxis = {}
	local overlap = {}
	--
	for _, inst in pairs(level.Terrain) do
		if not candidates or candidates[inst] then
			local sepx = px-inst.CenterX
			local sepy = py-inst.CenterY
			if (sepx*sepx + sepy*sepy) < inst.RadiusSq then
				local leastOverlapAxis, leastOverlap = nil, math.huge
				local expelDir = 1
				--
				for _, axis in pairs(inst.Axis) do
					local proj = px*axis.DirX + py*axis.DirY
					if proj < axis.Min or proj > axis.Max then
						leastOverlapAxis = axis
						leastOverlap = 0
					else
						local over1 = axis.Max-proj
						local over2 = proj-axis.Min
						if math.min(over1,over2) < leastOverlap then
							leastOverlapAxis = axis
							if over1 < over2 then
								leastOverlap = over1
								expelDir = 1
							else
								leastOverlap = over2
								expelDir = -1
							end
						end
					end
				end
				--
				if leastOverlap > 0 then
					--add to the list of overlaps
					local i = #overlapAxis+1
					overlapAxis[i] = leastOverlapAxis
					overlap[i]     = leastOverlap*expelDir
				end
			end
		end
	end
	--now we have a list of the directions that we should expel the point from
	--various things at. If there is nothing in the list then there was no
	--collision, otherwise sum up all of the collisions:
	if #overlapAxis > 0 then
		local totalX, totalY = 0, 0
		for i = 1, #overlapAxis do
			local axis = overlapAxis[i]
			local dist = overlap[i]
			--
			totalX = totalX + axis.DirX*dist
			totalY = totalY + axis.DirY*dist
		end
		return totalX, totalY
	else
		return nil
	end
end


function CollideBodyWithLevel(level, body)
	--first do broad phase with the whole body
	local candidates = {}
	for _, inst in pairs(level.Terrain) do
		local dx, dy = inst.CenterX-body.X, inst.CenterY-body.Y
		if (dx*dx + dy*dy) < (inst.Radius+body.Radius)^2 then
			candidates[inst] = true
		end
	end
	--
	if next(candidates) then
		--we need to do a finer SAT test on the collision
		local pts = body:GetPoints()
		local collision = false
		local totaldx, totaldy = 0, 0
		for i, p in pairs(pts) do
			local dx, dy = CollidePointWithLevel(level, p[1]+totaldx, p[2]+totaldy)
			if dx then
				--there was a collision
				totaldx = totaldx + dx
				totaldy = totaldy + dy
				collision = true
			end
		end
		if collision then
			return totaldx, totaldy
		else
			return nil
		end
	else
		--we didn't get candidates, no collision
		return nil
	end
end


function PlayLevel(level, guiframe, keyStates, rocketSound, explodeSound)
	local rocketSound2 = rocketSound:Clone()
	rocketSound2.Parent = rocketSound.Parent
	--
	local ship = CreateBody(ShipPoints, 7)
	ship.X, ship.Y = guiframe.Parent.StartAt.Value.x, guiframe.Parent.StartAt.Value.y
	ship.Restitution = 0.1
	ship.Rotation = math.pi
	local shipView = CreateBodyView(ship, guiframe, Color3.new(0.0, 1.0, 0.0))
	--
	local crate = CreateBody(CratePoints, 6)
	crate.X, crate.Y = guiframe.Parent.CrateAt.Value.x, guiframe.Parent.CrateAt.Value.y
	crate.Restitution = 0.2
	local crateView = CreateBodyView(crate, guiframe, Color3.new(0.6, 0.6, 0.6))
	
	--engine state
	local allBodies = {ship, crate}
	local allViews = {shipView, crateView}
	local allJetParticles = {}
	
	local function addJetParticle(atBody)
		local p = {}
		if not atBody then
			p.X = ship.X + math.sin(ship.Rotation)*7
			p.Y = ship.Y - math.cos(ship.Rotation)*7
			local rmod = 0.6*(math.random()-0.5)^2
			local modr = ship.Rotation + rmod
			local velo = 50 + math.random()*5
			p.VX = math.sin(modr)*velo  + ship.VX
			p.VY = -math.cos(modr)*velo + ship.VY
			local ux, uy = unit(p.VX, p.VY)
			p.VX, p.VY = p.VX-ux*10*rmod, p.VY-uy*10*rmod
		else
			local theta = math.random()*math.pi*2
			p.X, p.Y = atBody.X+(math.random()-0.5)*5, atBody.Y+(math.random()-0.5)*5
			p.VX, p.VY = atBody.VX+math.cos(theta)*30, atBody.VY+math.sin(theta)*30
		end
		p.Timestamp = tick()
		p.Gui = Create'Frame'{
			Parent = guiframe;
			Position = UDim2.new(0, p.X-2, 0, p.Y-2);
			Size = UDim2.new(0, 3, 0, 3);
			BackgroundColor3 = Color3.new(1, math.random(), 0);
			BorderSizePixel = 0;
		}
		allJetParticles[#allJetParticles+1] = p
		return p
	end

	--game constants
	local shipAccel = 70
	local gravity = 20
	local link_length = 40
	local jet_particle_life = 1.2
	
	--game state
	local isLineLinked = false
	local isLinkExtended = false
	local linkLine = CreateLine(guiframe, Color3.new(1,1,1))
	local game_state = 'play'
	local lost_at = 0
	local game_message = ""
	local rocketsound_isplaying = false
	--
	ship.Touched = function(nx, ny)
		--see if we ran into the wall, or touched down
		local shipDirX = -math.sin(ship.Rotation)
		local shipDirY =  math.cos(ship.Rotation)
		local theta = math.acos(dot(nx, ny, shipDirX, shipDirY))
		local speed = len(ship.VX, ship.VY)
		if (theta > math.pi/4 and speed > 35) or speed > 60 then
			--loss
			game_state = 'loss'
			lost_at = tick()
			if speed > 60 then
				game_message = "Hey man, easy on the gas!"
			elseif theta < math.pi/4 and ny < -0.5 then
				game_message = "Bit rough on the landing there, don't you think?"
			else
				game_message = "Oops! Mind the rocks."
			end
			--
			removeValue(allBodies, ship)
			removeValue(allViews, shipView)
			shipView:Hide()
			linkLine:Hide()
			isLineLinked = false
			--draw debris and play the explode sound
			explodeSound:Play()
			for i = 1, 20 do
				addJetParticle(ship)
			end
		end
	end
	crate.Touched = function(nx, ny)
		--handle loss
		if isLineLinked and len(crate.VX, crate.VY) > 15 then
			--lost
			game_state = 'loss'
			lost_at = tick()
			game_message = "That's expensive equipment you're hauling, careful with it!"
			--
			removeValue(allBodies, crate)
			removeValue(allViews, crateView)
			crateView:Hide()
			linkLine:Hide()
			isLineLinked = false
			--draw debris and play the explode sound
			explodeSound:Play()
			for i = 1, 20 do
				addJetParticle(crate)
			end
		end
	end
	--
	local LastTime = tick()
	while game_state == 'play' or (game_state == 'loss' and (tick()-lost_at) < 1.6) do
		--do timestep
		wait()
		local t = tick()
		local dt = t-LastTime
		LastTime = t

		--------------------
		-- ship movement
		if game_state == 'play' then
			if keyStates['a'] then
				--turn
				ship.Rotation = ship.Rotation - dt*2
			end
			if keyStates['s'] then
				--
			end
			if keyStates['d'] then
				--turn
				ship.Rotation = ship.Rotation + dt*2
			end
			if keyStates['w'] then
				--fly
				local shipDirX = -math.sin(ship.Rotation)
				local shipDirY =  math.cos(ship.Rotation)
				ship.VX = ship.VX + dt*shipDirX*shipAccel
				ship.VY = ship.VY + dt*shipDirY*shipAccel
				--add some particels
				addJetParticle()
				addJetParticle()
				--play the rocket sound
				if not rocketsound_isplaying then
					rocketsound_isplaying = true
					rocketSound:Play()
					Delay(0.5, function()
						if rocketsound_isplaying then
							rocketSound2:Play()
						end
					end)
				end
			else
				--stop the rocket sound
				if rocketsound_isplaying then
					rocketsound_isplaying = false
					rocketSound:Stop()
					rocketSound2:Stop()
				end
			end
		else
			rocketSound:Stop()
			rocketSound2:Stop()
		end

		--------------------
		--  handle bodies
		for _, body in pairs(allBodies) do
			--gravity
			body.VY = body.VY + dt*gravity

			--integrate
			body.X = body.X + body.VX*dt
			body.Y = body.Y + body.VY*dt

			--collide
			local dx, dy = CollideBodyWithLevel(level, body)
			if dx then
				--collision handler
				if body.Touched then
					body.Touched(unit(dx, dy))
				end

				--move the object
				body.X = body.X + dx
				body.Y = body.Y + dy
				--
				if dot(body.VX, body.VY, dx, dy) < 0 then
					--we need to reflect the velocity through the virtual "normal"
					--that we collided on.
					local nx, ny = unit(dx, dy)
					local dotN = dot(nx, ny, body.VX, body.VY)
					body.VX = body.VX - (1+body.Restitution)*nx*dotN
					body.VY = body.VY - (1+body.Restitution)*ny*dotN
					--and apply friction
					nx, ny = -ny, nx --get the perp direction
					dotN = dot(nx, ny, body.VX, body.VY)
					if dotN > 1 then
						body.VX = body.VX - 0.5*nx*dotN
						body.VY = body.VY - 0.5*ny*dotN
					else
						body.VX = body.VX - 1*nx*dotN
						body.VY = body.VY - 1*ny*dotN
					end
				end
			end
		end

		-------------------------
		--  crate + ship linking logic
		if game_state == 'play' then
			if isLineLinked then
				if isLinkExtended then
					--pull the crate to the right distance from the ship
					local dx, dy = sub(crate.X,crate.Y,ship.X,ship.Y)
					local ux, uy = unit(dx, dy)
					local len = len(dx, dy)
					local dif = len-link_length
					--
					crate.X = ship.X + ux*link_length
					crate.Y = ship.Y + uy*link_length
					--
					ship.VX = ship.VX + dif*ux*dt*10
					ship.VY = ship.VY + dif*uy*dt*10
					--
					crate.VX = crate.VX - dif*ux*dt*22
					crate.VY = crate.VY - dif*uy*dt*22
				else
					--se if the link is extended to it's full length
					if len(sub(ship.X,ship.Y,crate.X,crate.Y)) > link_length then
						isLinkExtended = true
					end
				end
			else
				if 
					len(sub(ship.X,ship.Y,crate.X,crate.Y)) < link_length and
					len(ship.VX,ship.VY) < 5 and
					len(crate.VX,crate.VY) < 5
				then
					isLineLinked = true
				end
			end
		end

		--------------------------
		--  win condition
		if isLineLinked and ship.Y < 0 then
			game_state = 'win'
			game_message = "Well done, you saved the equipment!"
		end

		--------------------------
		--  move camera
		local psz = guiframe.Parent.Size
		local sz = guiframe.Size
		guiframe.Position = UDim2.new(0, psz.X.Offset/2-ship.X, 
		                              0, psz.Y.Offset/2-ship.Y)

		--------------------------
		--  draw views
		--draw link line
		if game_state == 'play' then
			if isLineLinked then
				linkLine:Show(ship.X, ship.Y, crate.X, crate.Y)
			else
				linkLine:Hide()
			end
		end
		--draw body veiws
		for _, view in pairs(allViews) do
			view:Show()
		end
		--draw and update particles
		local particlesToKill = {}
		for _, p in pairs(allJetParticles) do
			p.X, p.Y = p.X + p.VX*dt, p.Y + p.VY*dt
			local dx, dy = CollidePointWithLevel(level, p.X, p.Y)
			local life = tick()-p.Timestamp
			if life > jet_particle_life then
				particlesToKill[#particlesToKill+1] = p
			end
			p.Gui.Position = UDim2.new(0, p.X-1, 0, p.Y-1)
			p.Gui.BackgroundTransparency = math.min(1, life/jet_particle_life)^2
			--
			if dx then
				p.X, p.Y = p.X+dx, p.Y+dy
				if dot(p.VX, p.VY, dx, dy) < 0 then
					-- apply the 1 restitution factor
					local nx, ny = unit(dx, dy)
					local dotN = dot(nx, ny, p.VX, p.VY)
					p.VX = p.VX - 1.2*nx*dotN
					p.VY = p.VY - 1.2*ny*dotN
				end
			end
		end
		for _, p in pairs(particlesToKill) do
			removeValue(allJetParticles, p)
			p.Gui:Destroy()
		end
	end
	rocketSound:Stop()
	rocketSound2:Destroy()
	--
	return game_state, game_message
end

-------------------------------------------------------------------------------

local Tool = script.Parent
local Gui;
local Player;
local RocketSound;
local ExplodeSound;

Tool.Equipped:connect(function(mouse)
	Player = game.Players:GetPlayerFromCharacter(Tool.Parent)
	local PlayerGui = Player.PlayerGui
	local KeyState = {}
	RocketSound = Tool.RocketSound:Clone()
	RocketSound.Parent = game.Workspace.CurrentCamera
	ExplodeSound = Tool.ExplodeSound:Clone()
	ExplodeSound.Parent = game.Workspace.CurrentCamera
	--
	Player.Character.Humanoid.WalkSpeed = 0
	--
	mouse.KeyDown:connect(function(key)
		KeyState[key] = true
	end)
	mouse.KeyUp:connect(function(key)
		KeyState[key] = nil
	end)
	--
	Gui = Tool.Gui:Clone()
	Gui.Parent = PlayerGui
	Gui.MainContainer.Visible = true
	--
	local function DoLevel(lev)
		Gui.MainContainer.Visible = false
		local levelgui = lev:Clone()
		levelgui.Parent = Gui
		levelgui.Visible = true
		--
		local levelmodel = CreateLevel_FromData(levelgui.Level)
		local state, msg = PlayLevel(levelmodel, levelgui.Level, KeyState, RocketSound, ExplodeSound)
		--
		local mb = Gui.WinLossMessage:Clone()
		mb.Visible = true
		mb.Parent = levelgui
		mb.TitleLabel.Text = msg
		mb.TitleLabel.TitleLabel.Text = msg
		if state == 'win' then
			if lev.NextLevel.Value ~= '' then
				mb.Button1.Button.Text = "Next Level"
				mb.Button1.Button.Button.Text = "Next Level"
				mb.Button2.Button.Text = "Exit"
				mb.Button2.Button.Button.Text = "Exit"
				local i = waitForAny(mb.Button1.Button.MouseButton1Down,
				                     mb.Button2.Button.MouseButton1Down)
				levelgui:Destroy()
				if i == 1 then
					return DoLevel(Tool.Levels:FindFirstChild(lev.NextLevel.Value))
				elseif i == 2 then
					Gui.MainContainer.Visible = true
					return
				end
			else
				mb.TitleLabel.Text = "You beat the game!"
				mb.TitleLabel.TitleLabel.Text = "You beat the game!"
				mb.Button1.Button.Text = "Exit"
				mb.Button1.Button.Button.Text = "Exit"
				mb.Button1.Position = UDim2.new(0.5, -60, 0, 80)
				mb.Button2.Visible = false
				--
				mb.Button1.MouseButton1Down:wait()
				--
				levelgui:Destroy()
				Gui.MainContainer.Visible = true
				return
			end
		else
			mb.Button1.Button.Text = "Retry"
			mb.Button1.Button.Button.Text = "Retry"
			mb.Button2.Button.Text = "Exit"
			mb.Button2.Button.Button.Text = "Exit"
			local i = waitForAny(mb.Button1.Button.MouseButton1Down,
			                     mb.Button2.Button.MouseButton1Down)
			levelgui:Destroy()
			if i == 1 then
				return DoLevel(lev)
			elseif i == 2 then
				Gui.MainContainer.Visible = true
				return
			end
		end
	end
	--
	for _, ch in pairs(Gui.MainContainer:GetChildren()) do
		local lev = Tool.Levels:FindFirstChild(ch.Name)
		if lev then
			ch.Button.MouseButton1Down:connect(function()
				DoLevel(lev)
			end)
		end
	end
end)

Tool.Unequipped:connect(function()
	if Player then
		Player.Character.Humanoid.WalkSpeed = 16
	end
	if Gui then
		Gui:Destroy()
		Gui = nil
	end
	if RocketSound then
		ExplodeSound:Destroy()
		ExplodeSound = nil
		RocketSound:Destroy()
		RocketSound = nil
	end
end)












