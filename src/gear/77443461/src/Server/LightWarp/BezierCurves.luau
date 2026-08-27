--[[
	This is a bezierCurve module that will perform the Bezier Curve algorithm on any data type that
	supports basic arithmetic operations.
	
	Credit to Magnalite for helping me out.
	
	This documentation will describe each bezierCurve function then will explain the interpolation function.
	
	--BezierCurve.Linear--
	This is the equivalent of Linear interpolation.
	Percent = Percentage to completion. (0%-100%)
	P0 = Start Value
	P1 = End Value
	Ins = The instance you are performing the formula on.
	Property = The property of the instance you are wanting to change.
	
	--Example of Linear--
	local curve = require(workspace.BezierCurves)
	curve.Linear(50,workspace.Part.Position,Vector3.new(0,100,0),workspace.Part,"Position")
	
	--BezierCurve.Quadratic--
	This uses a control point to affect the interpolation between the start and end point.
	This is the equivalent of Linear interpolation.
	Percent = Percentage to completion. (0%-100%)
	P0 = Start Value
	P1 = Control Value
	P2 = End Value
	Ins = The instance you are performing the formula on.
	Property = The property of the instance you are wanting to change.
	
	--Example of Quadratic--
	local curve = require(workspace.BezierCurves)
	curve.Quadratic(50,workspace.Part.Position,Vector3.new(0,100,0),Vector3.new(10,10,10),workspace.Part,"Position")
	
	--BezierCurve.Cubic--
	This uses two control points to affect the interpolation between start and end point.
	Percent = Percentage to completion. (0%-100%)
	P0 = Start Value
	P1 = Control Value
	P2 = Control Value
	P3 = End Value
	Ins = The instance you are performing the formula on.
	Property = The property of the instance you are wanting to change.
	
	--Example of Cubic--
	local curve = require(workspace.BezierCurves)
	curve.Cubic(50,workspace.Part.Position,Vector3.new(0,100,0),Vector3.new(50,0,25),Vector3.new(10,10,10),workspace.Part,"Position")
	
	*Note*
	Using the BezierCurve formulas in this module will result in an instant change.
	Use BezierCurve.Interpolate for a smooth tween to the percentage or use your own interpolate function.
	Not supplying an instance and property for the regular bezier functions will result in the function returning the value,
	which allows you to interpolate yourself.
	Also call the function in a spawn function or coroutine if you don't want it to affect yield your script.
	Interpolating CFrames only interpolates the positions. Rotation matrix is untouched.
	
	--BezierCurve.Interpolate--
	This will smoothly interpolate/tween from a start percentage to the desired percentage of the formula.
	Method = Desired type of curve to perform. (Linear, Quadratic, or Cubic)
	StartPercent = Percent of the tween to start at. (0%-100%)
	EndPercent = Percent of the tween to end at. (0%-100%)
	Duration = Time it takes to complete the tween in seconds.
	Callback = function that will be called when the tween is over.
	... = Once you supply the arguments for the interpolate function, supply the arguments for the
	tween function. Ex Cubic (Percent,Ins,Property,P0,P1,P2,P3)
	
	--Example of Interpolate--
	local curve = require(workspace.BezierCurves)
	function TweenFinished()
		print("Finished")
	end
	curve.Interpolate("Cubic",0,100,5,TweenFinished,workspace.Part.Position,Vector3.new(0,100,0),Vector3.new(50,0,25),Vector3.new(10,10,10),workspace.Part,"Position")
--]]






local BezierCurve = {}

function BezierCurve.Linear(Percent,P0,P1,Ins,Property)
	local t = Percent/100
	t = t >= 1 and 1 or t
	if P0 and P1 then
		if Ins and Ins[Property] then
			if Property == "CFrame" then
				local P0 = P0.p
				local P1 = P1.p
				Ins[Property] = CFrame.new(P0 + t * (P1-P0))
			else
				Ins[Property] = P0 + t * (P1-P0)
			end
		else
			return P0 + t * (P1-P0)
		end
	end
end

function BezierCurve.Quadratic(Percent,P0,P1,P2,Ins,Property)
	local t = Percent/100
	t = t >= 1 and 1 or t
	if P0 and P1 and P2 then
		if Ins and Ins[Property] then
			if Property == "CFrame" then
				local P0 = P0.p
				local P1 = P1.p
				local P2 = P2.p
				Ins[Property] = CFrame.new((1-t)^2 * P0 + 2 * (1-t) * t * P1 + t^2 * P2)
			else
				Ins[Property] = (1-t)^2 * P0 + 2 * (1-t) * t * P1 + t^2 * P2
			end
		else
			return (1-t)^2 * P0 + 2 * (1-t) * t * P1 + t^2 * P2
		end
	end
end

function BezierCurve.Cubic(Percent,P0,P1,P2,P3,Ins,Property)
	local t = Percent/100
	t = t >= 1 and 1 or t
	if P0 and P1 and P2 and P3 then
		if Ins and Ins[Property] then
			if Property == "CFrame" then
				local P0 = P0.p
				local P1 = P1.p
				local P2 = P2.p
				local P3 = P3.p
				Ins[Property] = CFrame.new((1-t)^3 * P0 + 3 * (1-t)^2 * t * P1 + 3 * (1-t) * t^2 * P2 + t^3 * P3)
			else
				Ins[Property] = (1-t)^3 * P0 + 3 * (1-t)^2 * t * P1 + 3 * (1-t) * t^2 * P2 + t^3 * P3
			end
		else
			return (1-t)^3 * P0 + 3 * (1-t)^2 * t * P1 + 3 * (1-t) * t^2 * P2 + t^3 * P3
		end
	end
end

function BezierCurve.Interpolate(Method,StartPercent,DesiredPercent,Duration,Callback,...)
	local Start = tick()
	local EndTime = Start + Duration
	local PercentDif =  DesiredPercent - StartPercent
	while tick() < EndTime do
		wait()
		local NewPercent = StartPercent + PercentDif * ((tick()-Start)/Duration)
		if Method == "Linear" then
			BezierCurve.Linear(NewPercent,...)
		elseif Method == "Quadratic" then
			BezierCurve.Quadratic(NewPercent,...)
		elseif Method == "Cubic" then
			BezierCurve.Cubic(NewPercent,...)
		end
	end
	if Callback then
		Callback()
	end
end
return BezierCurve
