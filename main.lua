-- Roblox File Scanner - Main
-- Script principal para usar o scanner

local FileScanner = require(script.Parent:WaitForChild("scanner"))
local Analyzer = require(script.Parent:WaitForChild("analyzer"))

-- Criar instância do scanner
local scanner = FileScanner.new()
local analyzer = Analyzer.new()

-- Função para iniciar o scan
local function startScan(rootInstance)
	print("[SCANNER] Iniciando scan em: " .. rootInstance.Name)
	
	local results = scanner:scan(rootInstance)
	print("[SCANNER] Scan completo! Total de itens: " .. #results)
	
	return results
end

-- Função para gerar relatório completo
local function generateFullReport(results)
	local summary = analyzer:generateSummary(results, scanner.stats)
	
	print("\n" .. string.rep("=", 50))
	print("RELATÓRIO COMPLETO DO SCANNER")
	print(string.rep("=", 50))
	print("\n📊 ESTATÍSTICAS GERAIS:")
	print("Total de itens: " .. summary.totalItems)
	print("Pastas: " .. summary.byType.folders)
	print("Scripts: " .. summary.byType.scripts)
	print("Valores: " .. summary.byType.values)
	print("Parts: " .. summary.byType.parts)
	print("Models: " .. summary.byType.models)
	print("Outros: " .. summary.byType.other)
	
	print("\n📝 ANÁLISE DE SCRIPTS:")
	print("Total: " .. summary.scripts.total)
	print("Habilitados: " .. summary.scripts.enabled)
	print("Desabilitados: " .. summary.scripts.disabled)
	print("Vazios: " .. summary.scripts.empty)
	
	if #summary.issues > 0 then
		print("\n⚠️ PROBLEMAS ENCONTRADOS (" .. #summary.issues .. "):")
		for i, issue in ipairs(summary.issues) do
			print("  " .. i .. ". [" .. issue.type .. "] " .. issue.message)
		end
	else
		print("\n✅ Nenhum problema encontrado!")
	end
	
	print("\n" .. string.rep("=", 50))
	
	return summary
end

-- Funções públicas
return {
	-- Iniciar scan de uma instância
	scan = function(instance)
		return startScan(instance)
	end,
	
	-- Gerar relatório completo
	generateReport = function(results)
		return generateFullReport(results)
	end,
	
	-- Filtrar resultados
	filter = function(filterType)
		return scanner:filter(filterType)
	end,
	
	-- Procurar por nome
	findByName = function(name)
		return scanner:findByName(name)
	end,
	
	-- Exportar como JSON
	exportJSON = function()
		return scanner:exportJSON()
	end,
	
	-- Exibir estrutura em árvore
	printTree = function()
		return scanner:printTree()
	end,
	
	-- Obter estatísticas
	getStats = function()
		return scanner.stats
	end,
	
	-- Obter resultados brutos
	getResults = function()
		return scanner.results
	end,
	
	-- Analisar estrutura
	analyzeStructure = function(results)
		return analyzer:analyzeStructure(results)
	end,
	
	-- Encontrar problemas
	findIssues = function(results)
		return analyzer:findIssues(results)
	end
}
