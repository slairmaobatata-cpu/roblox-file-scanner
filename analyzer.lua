-- Roblox File Analyzer
-- Analisador avançado com estatísticas detalhadas

local Analyzer = {}
Analyzer.__index = Analyzer

function Analyzer.new()
	local self = setmetatable({}, Analyzer)
	self.analysis = {}
	return self
end

-- Analisar estrutura de pasta
function Analyzer:analyzeStructure(results)
	local structure = {
		depths = {},
		byClass = {},
		byParent = {}
	}

	for _, result in ipairs(results) do
		-- Por profundidade
		if not structure.depths[result.depth] then
			structure.depths[result.depth] = 0
		end
		structure.depths[result.depth] = structure.depths[result.depth] + 1

		-- Por classe
		if not structure.byClass[result.class] then
			structure.byClass[result.class] = 0
		end
		structure.byClass[result.class] = structure.byClass[result.class] + 1

		-- Por parent
		if not structure.byParent[result.parent] then
			structure.byParent[result.parent] = 0
		end
		structure.byParent[result.parent] = structure.byParent[result.parent] + 1
	end

	return structure
end

-- Analisar scripts
function Analyzer:analyzeScripts(results)
	local scriptAnalysis = {
		total = 0,
		byType = {},
		enabled = 0,
		disabled = 0,
		empty = 0
	}

	for _, result in ipairs(results) do
		if result.class:match("Script") then
			scriptAnalysis.total = scriptAnalysis.total + 1

			if not scriptAnalysis.byType[result.class] then
				scriptAnalysis.byType[result.class] = 0
			end
			scriptAnalysis.byType[result.class] = scriptAnalysis.byType[result.class] + 1

			if result.properties.enabled then
				scriptAnalysis.enabled = scriptAnalysis.enabled + 1
			else
				scriptAnalysis.disabled = scriptAnalysis.disabled + 1
			end

			if result.properties.source == "empty" then
				scriptAnalysis.empty = scriptAnalysis.empty + 1
			end
		end
	end

	return scriptAnalysis
end

-- Encontrar problemas potenciais
function Analyzer:findIssues(results)
	local issues = {}

	for _, result in ipairs(results) do
		-- Scripts vazios
		if result.class:match("Script") and result.properties.source == "empty" then
			table.insert(issues, {
				type = "empty_script",
				path = result.path,
				message = "Script vazio detectado: " .. result.path
			})
		end

		-- Scripts desabilitados
		if result.class:match("Script") and result.properties.enabled == false then
			table.insert(issues, {
				type = "disabled_script",
				path = result.path,
				message = "Script desabilitado: " .. result.path
			})
		end

		-- Estrutura profunda (possível problema de performance)
		if result.depth > 10 then
			table.insert(issues, {
				type = "deep_nesting",
				path = result.path,
				depth = result.depth,
				message = "Estrutura muito profunda " .. result.depth .. " níveis: " .. result.path
			})
		end
	end

	return issues
end

-- Gerar resumo
function Analyzer:generateSummary(results, stats)
	local summary = {}
	summary.totalItems = stats.totalScanned
	summary.byType = {
		folders = stats.totalFolders,
		scripts = stats.totalScripts,
		values = stats.totalValues,
		parts = stats.totalParts,
		models = stats.totalModels,
		other = stats.totalOther
	}
	summary.structure = self:analyzeStructure(results)
	summary.scripts = self:analyzeScripts(results)
	summary.issues = self:findIssues(results)

	return summary
end

return Analyzer