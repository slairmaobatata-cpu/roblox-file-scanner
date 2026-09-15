-- Roblox File Scanner
-- Scanner completo de arquivos e estruturas do Roblox

local FileScanner = {}
FileScanner.__index = FileScanner

-- Tipos de arquivos suportados
local FILE_TYPES = {
	"Script",
	"LocalScript",
	"ModuleScript",
	"ServerScript",
	"LocalScript",
	"CoreScript",
	"NumberValue",
	"StringValue",
	"BoolValue",
	"IntValue",
	"DoubleValue",
	"ObjectValue",
	"Configuration",
	"Folder",
	"Part",
	"Model",
	"Humanoid",
	"MeshPart",
	"UnionOperation",
	"Terrain"
}

function FileScanner.new()
	local self = setmetatable({}, FileScanner)
	self.results = {}
	self.stats = {
		totalScanned = 0,
		totalFolders = 0,
		totalScripts = 0,
		totalValues = 0,
		totalParts = 0,
		totalModels = 0,
		totalOther = 0
	}
	return self
end

-- Função para verificar se um objeto é um tipo de script
local function isScript(instance)
	local scriptTypes = {"Script", "LocalScript", "ModuleScript", "CoreScript"}
	for _, scriptType in ipairs(scriptTypes) do
		if instance:IsA(scriptType) then
			return true
		end
	end
	return false
end

-- Função para verificar se um objeto é um tipo de valor
local function isValue(instance)
	local valueTypes = {"NumberValue", "StringValue", "BoolValue", "IntValue", "DoubleValue", "ObjectValue"}
	for _, valueType in ipairs(valueTypes) do
		if instance:IsA(valueType) then
			return true
		end
	end
	return false
end

-- Função para obter informações detalhadas de um objeto
local function getInstanceInfo(instance)
	local info = {
		name = instance.Name,
		class = instance.ClassName,
		path = instance:GetFullName(),
		parent = instance.Parent and instance.Parent.Name or "nil",
		children = #instance:GetChildren(),
		properties = {}
	}

	-- Capturar propriedades específicas
	if isScript(instance) then
		pcall(function()
			info.properties.source = instance.Source and "[SCRIPT CONTENT]" or "empty"
			info.properties.enabled = instance.Enabled
		end)
	elseif isValue(instance) then
		pcall(function()
			info.properties.value = instance.Value
		end)
	end

	-- Propriedades gerais
	pcall(function()
		if instance:FindFirstChild("Humanoid") then
			info.hasHumanoid = true
		end
	end)

	return info
end

-- Função principal de scan
function FileScanner:scan(rootInstance)
	self.results = {}
	self.stats = {
		totalScanned = 0,
		totalFolders = 0,
		totalScripts = 0,
		totalValues = 0,
		totalParts = 0,
		totalModels = 0,
		totalOther = 0
	}

	local function scanRecursive(instance, depth)
		depth = depth or 0
		local info = getInstanceInfo(instance)
		info.depth = depth

		table.insert(self.results, info)
		self.stats.totalScanned = self.stats.totalScanned + 1

		-- Atualizar estatísticas
		if instance:IsA("Folder") then
			self.stats.totalFolders = self.stats.totalFolders + 1
		elseif isScript(instance) then
			self.stats.totalScripts = self.stats.totalScripts + 1
		elseif isValue(instance) then
			self.stats.totalValues = self.stats.totalValues + 1
		elseif instance:IsA("Model") then
			self.stats.totalModels = self.stats.totalModels + 1
		elseif instance:IsA("Part") or instance:IsA("MeshPart") then
			self.stats.totalParts = self.stats.totalParts + 1
		else
			self.stats.totalOther = self.stats.totalOther + 1
		end

		-- Scanear filhos
		for _, child in ipairs(instance:GetChildren()) do
			scanRecursive(child, depth + 1)
		end
	end

	scanRecursive(rootInstance)
	return self.results
end

-- Função para gerar relatório
function FileScanner:generateReport()
	local report = {}
	report.timestamp = os.date("%Y-%m-%d %H:%M:%S")
	report.stats = self.stats
	report.results = self.results
	return report
end

-- Função para filtrar resultados
function FileScanner:filter(filterType)
	local filtered = {}
	for _, result in ipairs(self.results) do
		if filterType == "scripts" and isScript(result) then
			table.insert(filtered, result)
		elseif filterType == "values" and isValue(result) then
			table.insert(filtered, result)
		elseif filterType == "folders" and result.class == "Folder" then
			table.insert(filtered, result)
		elseif filterType == "models" and result.class == "Model" then
			table.insert(filtered, result)
		elseif filterType == "parts" and (result.class == "Part" or result.class == "MeshPart") then
			table.insert(filtered, result)
		end
	end
	return filtered
end

-- Função para procurar por nome
function FileScanner:findByName(name)
	local found = {}
	for _, result in ipairs(self.results) do
		if result.name:match(name) or result.name:lower():find(name:lower()) then
			table.insert(found, result)
		end
	end
	return found
end

-- Função para exportar como JSON
function FileScanner:exportJSON()
	local jsonResult = {}
	jsonResult.timestamp = os.date("%Y-%m-%d %H:%M:%S")
	jsonResult.statistics = self.stats
	jsonResult.items = {}

	for _, result in ipairs(self.results) do
		table.insert(jsonResult.items, result)
	end

	return game:GetService("HttpService"):JSONEncode(jsonResult)
end

-- Função para exibir estrutura em forma de árvore
function FileScanner:printTree()
	local tree = {}
	for _, result in ipairs(self.results) do
		local indent = string.rep("  ", result.depth)
		local line = indent .. "📦 " .. result.name .. " (" .. result.class .. ")"
		table.insert(tree, line)
	end
	return table.concat(tree, "\n")
end

return FileScanner