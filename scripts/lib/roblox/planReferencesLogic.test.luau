local test = require("@std/test")

local planReferences = require("@scripts/lib/roblox/planReferencesLogic")

local function node(name: string)
	return { name = name }
end

test.suite("planReferencesLogic", function(suite)
	suite:case("leaves unreferenced instances without metadata", function(asserts)
		local root = node("Root")
		local child = node("Child")
		local plan = planReferences({ root, child }, {}, "gear")

		asserts.eq(0, plan.referenceCount)
		asserts.eq(nil, plan.getMetadata(root).id)
		asserts.eq({}, plan.getMetadata(child).attributes)
	end)

	suite:case("assigns one stable id to a shared target", function(asserts)
		local root = node("Root")
		local firstWeld = node("FirstWeld")
		local secondWeld = node("SecondWeld")
		local plan = planReferences({
			root,
			firstWeld,
			secondWeld,
		}, {
			{ source = firstWeld, propertyName = "Part0", target = root },
			{ source = firstWeld, propertyName = "Part1", target = root },
			{ source = secondWeld, propertyName = "Part0", target = root },
		}, "g10472779")

		asserts.eq(3, plan.referenceCount)
		asserts.eq("g10472779_1", plan.getMetadata(root).id)
		asserts.eq({
			Rojo_Target_Part0 = "g10472779_1",
			Rojo_Target_Part1 = "g10472779_1",
		}, plan.getMetadata(firstWeld).attributes)
		asserts.eq({
			Rojo_Target_Part0 = "g10472779_1",
		}, plan.getMetadata(secondWeld).attributes)
	end)

	suite:case("supports self references", function(asserts)
		local objectValue = node("ObjectValue")
		local plan = planReferences({ objectValue }, {
			{ source = objectValue, propertyName = "Value", target = objectValue },
		}, "gear")

		asserts.eq("gear_1", plan.getMetadata(objectValue).id)
		asserts.eq({
			Rojo_Target_Value = "gear_1",
		}, plan.getMetadata(objectValue).attributes)
	end)

	suite:case("ids follow model order rather than reference order", function(asserts)
		local root = node("Root")
		local earlyTarget = node("Early")
		local lateTarget = node("Late")
		local source = node("Source")
		local plan = planReferences({ root, earlyTarget, lateTarget, source }, {
			{ source = source, propertyName = "Late", target = lateTarget },
			{ source = source, propertyName = "Early", target = earlyTarget },
		}, "gear")

		asserts.eq("gear_2", plan.getMetadata(earlyTarget).id)
		asserts.eq("gear_3", plan.getMetadata(lateTarget).id)
	end)

	suite:case("errors instead of dropping an out-of-model target", function(asserts)
		local source = node("Source")
		local external = node("External")
		local ok, message = pcall(function()
			planReferences(
				{ source },
				{
					{ source = source, propertyName = "Value", target = external },
				},
				"gear",
				function(instance)
					return instance.name
				end
			)
		end)

		asserts.eq(false, ok)
		asserts.eq(true, string.find(message, "Source.Value points outside the dumped model", 1, true) ~= nil)
	end)

	suite:case("rejects a source outside the model", function(asserts)
		local root = node("Root")
		local externalSource = node("External")
		local ok, message = pcall(function()
			planReferences({ root }, {
				{ source = externalSource, propertyName = "Value", target = root },
			}, "gear")
		end)

		asserts.eq(false, ok)
		asserts.eq(true, string.find(message, "reference source is not part of the model", 1, true) ~= nil)
	end)

	suite:case("rejects metadata lookups outside the model", function(asserts)
		local root = node("Root")
		local plan = planReferences({ root }, {}, "gear")
		local ok, message = pcall(function()
			plan.getMetadata(node("External"))
		end)

		asserts.eq(false, ok)
		asserts.eq(true, string.find(message, "instance is not part of the reference plan", 1, true) ~= nil)
	end)
end)
