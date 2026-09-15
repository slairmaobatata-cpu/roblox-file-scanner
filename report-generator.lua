-- Roblox File Scanner - Report Generator
-- Gerador de relatórios completos e copiáveis

local ReportGenerator = {}
ReportGenerator.__index = ReportGenerator

function ReportGenerator.new()
	local self = setmetatable({}, ReportGenerator)
	return self
end

-- Gerar relatório em formato texto copiável
function ReportGenerator:generateTextReport(results, stats)
	local lines = {}
	
	table.insert(lines, "╔════════════════════════════════════════════════════════════════╗")
	table.insert(lines, "║          RELATÓRIO COMPLETO DO SCANNER ROBLOX                  ║")
	table.insert(lines, "╚════════════════════════════════════════════════════════════════╝")
	table.insert(lines, "")
	table.insert(lines, "📅 Data/Hora: " .. os.date("%d/%m/%Y %H:%M:%S"))
	table.insert(lines, "")
	
	-- Estatísticas gerais
	table.insert(lines, "┌─ 📊 ESTATÍSTICAS GERAIS ─────────────────────────────────────┐")
	table.insert(lines, "│ Total de itens scaneados: " .. stats.totalScanned)
	table.insert(lines, "│ Pastas (Folder): " .. stats.totalFolders)
	table.insert(lines, "│ Scripts: " .. stats.totalScripts)
	table.insert(lines, "│ Valores: " .. stats.totalValues)
	table.insert(lines, "│ Parts: " .. stats.totalParts)
	table.insert(lines, "│ Models: " .. stats.totalModels)
	table.insert(lines, "│ Outros: " .. stats.totalOther)
	table.insert(lines, "└──────────────────────────────────────────────────────────────┘")
	table.insert(lines, "")
	
	return lines
end

-- Gerar lista de todos os itens
function ReportGenerator:generateItemsList(results)
	local lines = {}
	
	table.insert(lines, "┌─ 📋 LISTA COMPLETA DE ITENS ─────────────────────────────────┐")
	table.insert(lines, "")
	
	local itemsByClass = {}
	
	-- Agrupar por classe
	for _, result in ipairs(results) do
		if not itemsByClass[result.class] then
			itemsByClass[result.class] = {}
		end
		table.insert(itemsByClass[result.class], result)
	end
	
	-- Ordenar alfabeticamente
	local sortedClasses = {}
	for class, _ in pairs(itemsByClass) do
		table.insert(sortedClasses, class)
	end
	table.sort(sortedClasses)
	
	-- Exibir por classe
	for _, class in ipairs(sortedClasses) do
		local items = itemsByClass[class]
		table.insert(lines, "🔹 " .. class .. " (" .. #items .. " item(ns))")
		
		for _, item in ipairs(items) do
			local icon = ""
			if class:match("Script") then icon = "📜"
			elseif class:match("Value") then icon = "📦"
			elseif class == "Folder" then icon = "📁"
			elseif class == "Model" then icon = "🎁"
			elseif class:match("Part") then icon = "⬜"
			else icon = "•"
			end
			
			local indent = string.rep("  ", math.min(item.depth, 3))
			local status = ""
			if item.properties.enabled ~= nil then
				status = " [" .. (item.properties.enabled and "✓ ON" or "✗ OFF") .. "]"
			end
			
			table.insert(lines, indent .. icon .. " " .. item.name .. status)
			table.insert(lines, indent .. "   └─ Caminho: " .. item.path)
			table.insert(lines, indent .. "   └─ Profundidade: " .. item.depth)
			
			if item.children > 0 then
				table.insert(lines, indent .. "   └─ Filhos: " .. item.children)
			end
			
			table.insert(lines, "")
		end
	end
	
	table.insert(lines, "└──────────────────────────────────────────────────────────────┘")
	table.insert(lines, "")
	
	return lines
end

-- Gerar análise de scripts
function ReportGenerator:generateScriptsAnalysis(results)
	local lines = {}
	local scripts = {}
	
	for _, result in ipairs(results) do
		if result.class:match("Script") then
			table.insert(scripts, result)
		end
	end
	
	if #scripts == 0 then
		return lines
	end
	
	table.insert(lines, "┌─ 📜 ANÁLISE DE SCRIPTS ──────────────────────────────────────┐")
	table.insert(lines, "")
	table.insert(lines, "Total de Scripts: " .. #scripts)
	
	local enabled = 0
	local disabled = 0
	local empty = 0
	
	for _, script in ipairs(scripts) do
		if script.properties.enabled then
			enabled = enabled + 1
		else
			disabled = disabled + 1
		end
		if script.properties.source == "empty" then
			empty = empty + 1
		end
	end
	
	table.insert(lines, "Scripts Habilitados: " .. enabled)
	table.insert(lines, "Scripts Desabilitados: " .. disabled)
	table.insert(lines, "Scripts Vazios: " .. empty)
	table.insert(lines, "")
	
	-- Listar scripts
	table.insert(lines, "📍 Scripts Detectados:")
	table.insert(lines, "")
	
	for i, script in ipairs(scripts) do
		local status = script.properties.enabled and "✓ ATIVO" or "✗ INATIVO"
		local empty_status = script.properties.source == "empty" and " [VAZIO]" or ""
		
		table.insert(lines, i .. ". " .. script.name .. " - " .. status .. empty_status)
		table.insert(lines, "   Tipo: " .. script.class)
		table.insert(lines, "   Caminho: " .. script.path)
		table.insert(lines, "")
	end
	
	table.insert(lines, "└──────────────────────────────────────────────────────────────┘")
	table.insert(lines, "")
	
	return lines
end

-- Gerar análise de valores
function ReportGenerator:generateValuesAnalysis(results)
	local lines = {}
	local values = {}
	
	for _, result in ipairs(results) do
		if result.class:match("Value") then
			table.insert(values, result)
		end
	end
	
	if #values == 0 then
		return lines
	end
	
	table.insert(lines, "┌─ 📦 ANÁLISE DE VALORES ──────────────────────────────────────┐")
	table.insert(lines, "")
	table.insert(lines, "Total de Valores: " .. #values)
	table.insert(lines, "")
	
	-- Agrupar por tipo
	local valuesByType = {}
	for _, value in ipairs(values) do
		if not valuesByType[value.class] then
			valuesByType[value.class] = {}
		end
		table.insert(valuesByType[value.class], value)
	end
	
	for valueType, items in pairs(valuesByType) do
		table.insert(lines, "🔹 " .. valueType .. " (" .. #items .. ")")
		for _, item in ipairs(items) do
			table.insert(lines, "   • " .. item.name .. " = " .. tostring(item.properties.value))
			table.insert(lines, "     Caminho: " .. item.path)
		end
		table.insert(lines, "")
	end
	
	table.insert(lines, "└──────────────────────────────────────────────────────────────┘")
	table.insert(lines, "")
	
	return lines
end

-- Gerar análise de estrutura
function ReportGenerator:generateStructureAnalysis(results)
	local lines = {}
	
	table.insert(lines, "┌─ 🏗️ ANÁLISE DE ESTRUTURA ────────────────────────────────────┐")
	table.insert(lines, "")
	
	-- Análise por profundidade
	local depthAnalysis = {}
	for _, result in ipairs(results) do
		if not depthAnalysis[result.depth] then
			depthAnalysis[result.depth] = 0
		end
		depthAnalysis[result.depth] = depthAnalysis[result.depth] + 1
	end
	
	table.insert(lines, "📊 Distribuição por Profundidade:")
	for depth = 0, 20 do
		if depthAnalysis[depth] then
			local bar = string.rep("█", math.min(depthAnalysis[depth], 50))
			table.insert(lines, "Nível " .. string.format("%2d", depth) .. ": " .. bar .. " (" .. depthAnalysis[depth] .. ")")
		end
	end
	
	table.insert(lines, "")
	
	-- Análise por classe
	local classAnalysis = {}
	for _, result in ipairs(results) do
		if not classAnalysis[result.class] then
			classAnalysis[result.class] = 0
		end
		classAnalysis[result.class] = classAnalysis[result.class] + 1
	end
	
	table.insert(lines, "📋 Distribuição por Classe:")
	local sortedClasses = {}
	for class, count in pairs(classAnalysis) do
		table.insert(sortedClasses, {class = class, count = count})
	end
	table.sort(sortedClasses, function(a, b) return a.count > b.count end)
	
	for _, item in ipairs(sortedClasses) do
		local bar = string.rep("█", math.min(item.count, 50))
		table.insert(lines, item.class .. ": " .. bar .. " (" .. item.count .. ")")
	end
	
	table.insert(lines, "")
	table.insert(lines, "└──────────────────────────────────────────────────────────────┘")
	table.insert(lines, "")
	
	return lines
end

-- Gerar lista de problemas/alertas
function ReportGenerator:generateIssuesReport(results)
	local lines = {}
	local issues = {}
	
	-- Encontrar problemas
	for _, result in ipairs(results) do
		-- Scripts vazios
		if result.class:match("Script") and result.properties.source == "empty" then
			table.insert(issues, {
				severity = "⚠️ AVISO",
				type = "Script Vazio",
				path = result.path,
				message = "Script sem conteúdo detectado"
			})
		end
		
		-- Scripts desabilitados
		if result.class:match("Script") and result.properties.enabled == false then
			table.insert(issues, {
				severity = "ℹ️ INFO",
				type = "Script Desabilitado",
				path = result.path,
				message = "Script está desabilitado"
			})
		end
		
		-- Nesting profundo
		if result.depth > 10 then
			table.insert(issues, {
				severity = "⚠️ AVISO",
				type = "Estrutura Profunda",
				path = result.path,
				message = "Nível " .. result.depth .. " (pode afetar performance)"
			})
		end
	end
	
	if #issues == 0 then
		table.insert(lines, "┌─ ✅ VERIFICAÇÃO DE PROBLEMAS ────────────────────────────────┐")
		table.insert(lines, "│")
		table.insert(lines, "│  Nenhum problema detectado! ✓")
		table.insert(lines, "│")
		table.insert(lines, "└──────────────────────────────────────────────────────────────┘")
		table.insert(lines, "")
		return lines
	end
	
	table.insert(lines, "┌─ 🔍 VERIFICAÇÃO DE PROBLEMAS ────────────────────────────────┐")
	table.insert(lines, "")
	table.insert(lines, "Total de Problemas: " .. #issues)
	table.insert(lines, "")
	
	for i, issue in ipairs(issues) do
		table.insert(lines, i .. ". " .. issue.severity .. " [" .. issue.type .. "]")
		table.insert(lines, "   Caminho: " .. issue.path)
		table.insert(lines, "   Detalhes: " .. issue.message)
		table.insert(lines, "")
	end
	
	table.insert(lines, "└──────────────────────────────────────────────────────────────┘")
	table.insert(lines, "")
	
	return lines
end

-- Gerar árvore visual
function ReportGenerator:generateTreeView(results)
	local lines = {}
	
	table.insert(lines, "┌─ 🌳 ESTRUTURA EM ÁRVORE ──────────────────────────────────────┐")
	table.insert(lines, "")
	
	for _, result in ipairs(results) do
		if result.depth <= 5 then -- Limitar profundidade para readabilidade
			local indent = string.rep("│   ", result.depth)
			local icon = ""
			if result.class:match("Script") then icon = "📜"
			elseif result.class:match("Value") then icon = "📦"
			elseif result.class == "Folder" then icon = "📁"
			elseif result.class == "Model" then icon = "🎁"
			elseif result.class:match("Part") then icon = "⬜"
			else icon = "▪"
			end
			
			local status = ""
			if result.properties.enabled == false then
				status = " ✗"
			elseif result.properties.enabled == true then
				status = " ✓"
			end
			
			table.insert(lines, indent .. "├─ " .. icon .. " " .. result.name .. status)
		end
	end
	
	table.insert(lines, "")
	table.insert(lines, "└──────────────────────────────────────────────────────────────┘")
	table.insert(lines, "")
	
	return lines
end

-- Gerar relatório completo
function ReportGenerator:generateCompleteReport(results, stats)
	local lines = {}
	
	-- Cabeçalho
	local headerLines = self:generateTextReport(results, stats)
	for _, line in ipairs(headerLines) do
		table.insert(lines, line)
	end
	
	-- Árvore
	local treeLines = self:generateTreeView(results)
	for _, line in ipairs(treeLines) do
		table.insert(lines, line)
	end
	
	-- Lista completa
	local itemsLines = self:generateItemsList(results)
	for _, line in ipairs(itemsLines) do
		table.insert(lines, line)
	end
	
	-- Análise de scripts
	local scriptsLines = self:generateScriptsAnalysis(results)
	for _, line in ipairs(scriptsLines) do
		table.insert(lines, line)
	end
	
	-- Análise de valores
	local valuesLines = self:generateValuesAnalysis(results)
	for _, line in ipairs(valuesLines) do
		table.insert(lines, line)
	end
	
	-- Análise de estrutura
	local structureLines = self:generateStructureAnalysis(results)
	for _, line in ipairs(structureLines) do
		table.insert(lines, line)
	end
	
	-- Problemas
	local issuesLines = self:generateIssuesReport(results)
	for _, line in ipairs(issuesLines) do
		table.insert(lines, line)
	end
	
	-- Rodapé
	table.insert(lines, "╔════════════════════════════════════════════════════════════════╗")
	table.insert(lines, "║                   FIM DO RELATÓRIO                            ║")
	table.insert(lines, "╚════════════════════════════════════════════════════════════════╝")
	
	return table.concat(lines, "\n")
end

-- Exibir relatório no Output (copiável)
function ReportGenerator:displayReport(reportText)
	print("\n" .. reportText)
end

-- Salvar relatório em StringValue para fácil cópia
function ReportGenerator:saveToStringValue(reportText, name)
	name = name or "ScanReport"
	
	local stringValue = Instance.new("StringValue")
	stringValue.Name = name
	stringValue.Value = reportText
	stringValue.Parent = game.ServerStorage
	
	print("\n✅ Relatório salvo em: game.ServerStorage." .. name)
	print("📋 Conteúdo copiável disponível!")
	
	return stringValue
end

return ReportGenerator
