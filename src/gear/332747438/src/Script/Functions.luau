--Made by Luckymaxer

Functions = {}

function Functions.Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function Functions.GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Functions.Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
end

return Functions