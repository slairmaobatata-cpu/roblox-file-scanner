-- Exemplos de uso do Roblox File Scanner

local Scanner = require(game.ServerScriptService:WaitForChild("main"))

-- EXEMPLO 1: Scan completo do Workspace
print("\n=== EXEMPLO 1: Scan Completo ===")
local results = Scanner.scan(workspace)
Scanner.generateReport(results)

-- EXEMPLO 2: Filtrar apenas scripts
print("\n=== EXEMPLO 2: Apenas Scripts ===")
local scripts = Scanner.filter("scripts")
for i, script in ipairs(scripts) do
	print(i .. ". " .. script.path .. " (" .. (script.properties.enabled and "Habilitado" or "Desabilitado") .. ")")
end

-- EXEMPLO 3: Procurar por nome específico
print("\n=== EXEMPLO 3: Procurar por Nome ===")
local found = Scanner.findByName("Spawn")
for i, item in ipairs(found) do
	print(i .. ". " .. item.path .. " - " .. item.class)
end

-- EXEMPLO 4: Exibir estrutura em árvore
print("\n=== EXEMPLO 4: Estrutura em Árvore ===")
print(Scanner.printTree())

-- EXEMPLO 5: Estatísticas detalhadas
print("\n=== EXEMPLO 5: Estatísticas ===")
local stats = Scanner.getStats()
print("Total Scaneado: " .. stats.totalScanned)
print("Scripts: " .. stats.totalScripts)
print("Valores: " .. stats.totalValues)
print("Pastas: " .. stats.totalFolders)

-- EXEMPLO 6: Analisar estrutura
print("\n=== EXEMPLO 6: Análise de Estrutura ===")
local structure = Scanner.analyzeStructure(results)
for depth, count in pairs(structure.depths) do
	print("Profundidade " .. depth .. ": " .. count .. " itens")
end

-- EXEMPLO 7: Encontrar problemas
print("\n=== EXEMPLO 7: Problemas ===")
local issues = Scanner.findIssues(results)
if #issues > 0 then
	for i, issue in ipairs(issues) do
		print(i .. ". [" .. issue.type .. "] " .. issue.message)
	end
else
	print("Nenhum problema encontrado!")
end

-- EXEMPLO 8: Exportar JSON
print("\n=== EXEMPLO 8: Exportar JSON ===")
local json = Scanner.exportJSON()
print("JSON gerado com sucesso! Tamanho: " .. #json .. " caracteres")
