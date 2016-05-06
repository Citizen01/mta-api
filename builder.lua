------------------------------------------------------------------------
--- Purpose: Build api http routes with params using the annotations ---
------------------------------------------------------------------------

local EXPORT_CODE = "-- @API"
local _routes = {} -- holds all routes available

local _funcMap = {} -- create a mapping for perfs (no need to iterate over _routes for each request)
function getFuncMapping()
	return _funcMap
end

function buildAll()
	buildRoutes()
	buildFuncMapping()
end
addEventHandler("onResourceStart", resourceRoot, buildAll)

-- ex: _funcMap["POST"]["players"]["kick"] = "kick"
function buildFuncMapping()
	_funcMap = {}
	for k, r in ipairs(_routes) do
		-- method
		if not _funcMap[r.m] then
			_funcMap[r.m] = {}
		end
		-- category
		if not _funcMap[r.m][r.c] then
			_funcMap[r.m][r.c] = {}
		end
		-- func
		if not _funcMap[r.m][r.c][r.f or "default"] then
			_funcMap[r.m][r.c][r.f or "default"] = r.fn
		end
	end
	-- var_dump("-v", _funcMap)
end

function buildRoutes()
	-- outputConsole("-- buildRoutes --")

	local routes = getApiRoutesFromScripts()
	for k, route in ipairs(routes) do
		addRoute(route.path, route.method, route.funcName)
	end
	updateApiExports()
	-- var_dump("-v", _routes)
end

function getApiRoutesFromScripts()
	local apiRoutes = {path, method, funcName}

	local sScripts = getServerScripts()
	if #sScripts <= 0 then return apiRoutes end
	-- var_dump("-v", sScripts)

	for k, script in ipairs(sScripts) do
		local file = fileOpen(script, true)
		if file then
			local buffer = ""
			while not fileIsEOF(file) do
				buffer = buffer..fileRead(file, 500)
			end

			local lines = split(buffer, "\n")

			local tmp = nil
			for k, line in ipairs(lines) do
				if tmp == nil then
					local trimmed = string.trim(line)
					local exportCode = string.trim(EXPORT_CODE)
					local ecStart, ecEnd = string.find(trimmed, exportCode)
					if ecStart and ecEnd then
						local all, method, path = trimmed:match("\(\"(.*)\",\"(.*)\"\)")
						if method and path then
							tmp = {method=method, path=path}
						end
					end
				else
					local funcName = extractFuncName(line)
					table.insert(apiRoutes, {path = tmp.path, method = tmp.method, funcName = funcName})
					tmp = nil
				end
			end

			fileClose(file)
		end
	end

	return apiRoutes
end

function extractFuncName(str)
	return str:match("function (%w+)%s*\(.*\)")
end

function getServerScripts()
	local sScripts = {}
	local rootNode = xmlLoadFile("meta.xml")
	if not rootNode then return sScripts end

	local nodes = xmlNodeGetChildren(rootNode)
	if nodes then
		for k, node in ipairs(nodes) do
			if xmlNodeGetName(node) == "script" then
				local fileName = xmlNodeGetAttribute(node, "src")
				local stype = xmlNodeGetAttribute(node, "type") or "server"
				if fileName and stype == "server" then
					table.insert(sScripts, fileName)
				end
			end
		end
	end
	xmlUnloadFile(rootNode)
	return sScripts
end

-- ex: "/players/{id}"
-- ex: "/players/kick"
function addRoute( route, method, funcName )
	local parts = split(route, "/")
	local category = nil
	local func = nil

	if #parts >= 1 then
		category = parts[1]
		if #parts >= 2 then
			local isParam = string.match(parts[2], "^{%a*}$")
			if not isParam then
				func = parts[2]
			end
		end
	end

	table.insert(_routes, {m=method, c=category, f=func, fn=funcName})
	-- outputConsole("Route: m:"..tostring(method).." c:"..tostring(category).." f:"..tostring(func).. " fn:"..tostring(funcName))
end

function updateApiExports()
	local rootNode = xmlLoadFile("meta.xml")
	if rootNode then
		-- Cleaning
		local nodes = xmlNodeGetChildren(rootNode)
		if nodes then
			for k, node in ipairs(nodes) do
				if xmlNodeGetName(node) == "export" then
					if xmlNodeGetAttribute(node, "api") == "true" then
						xmlDestroyNode(node)
					end
				end
			end
		end

		-- Adding
		for k, r in ipairs(_routes) do
			local node = xmlCreateChild(rootNode, "export")
			xmlNodeSetAttribute(node, "api", "true")
			xmlNodeSetAttribute(node, "function", r.fn)
			xmlNodeSetAttribute(node, "http", "true")
		end
		return xmlSaveFile(rootNode) and xmlUnloadFile(rootNode)
	end
end

--------------------------------------------------------

function string.trim(str)
	return string.gsub(str, "%s+", "")
end

function var_dump(...)
	-- default options
	local verbose = false
	local firstLevel = true
	local outputDirectly = true
	local noNames = false
	local indentation = "\t\t\t\t\t\t"
	local depth = nil

	local name = nil
	local output = {}
	for k,v in ipairs(arg) do
		-- check for modifiers
		if type(v) == "string" and k < #arg and v:sub(1,1) == "-" then
			local modifiers = v:sub(2)
			if modifiers:find("v") ~= nil then
				verbose = true
			end
			if modifiers:find("s") ~= nil then
				outputDirectly = false
			end
			if modifiers:find("n") ~= nil then
				verbose = false
			end
			if modifiers:find("u") ~= nil then
				noNames = true
			end
			local s,e = modifiers:find("d%d+")
			if s ~= nil then
				depth = tonumber(string.sub(modifiers,s+1,e))
			end
		-- set name if appropriate
		elseif type(v) == "string" and k < #arg and name == nil and not noNames then
			name = v
		else
			if name ~= nil then
				name = ""..name..": "
			else
				name = ""
			end

			local o = ""
			if type(v) == "string" then
				table.insert(output,name..type(v).."("..v:len()..") \""..v.."\"")
			elseif type(v) == "userdata" then
				local elementType = "no valid MTA element"
				if isElement(v) then
					elementType = getElementType(v)
				end
				table.insert(output,name..type(v).."("..elementType..") \""..tostring(v).."\"")
			elseif type(v) == "table" then
				local count = 0
				for key,value in pairs(v) do
					count = count + 1
				end
				table.insert(output,name..type(v).."("..count..") \""..tostring(v).."\"")
				if verbose and count > 0 and (depth == nil or depth > 0) then
					table.insert(output,"\t{")
					for key,value in pairs(v) do
						-- calls itself, so be careful when you change anything
						local newModifiers = "-s"
						if depth == nil then
							newModifiers = "-sv"
						elseif  depth > 1 then
							local newDepth = depth - 1
							newModifiers = "-svd"..newDepth
						end
						local keyString, keyTable = var_dump(newModifiers,key)
						local valueString, valueTable = var_dump(newModifiers,value)

						if #keyTable == 1 and #valueTable == 1 then
							table.insert(output,indentation.."["..keyString.."]\t=>\t"..valueString)
						elseif #keyTable == 1 then
							table.insert(output,indentation.."["..keyString.."]\t=>")
							for k,v in ipairs(valueTable) do
								table.insert(output,indentation..v)
							end
						elseif #valueTable == 1 then
							for k,v in ipairs(keyTable) do
								if k == 1 then
									table.insert(output,indentation.."["..v)
								elseif k == #keyTable then
									table.insert(output,indentation..v.."]")
								else
									table.insert(output,indentation..v)
								end
							end
							table.insert(output,indentation.."\t=>\t"..valueString)
						else
							for k,v in ipairs(keyTable) do
								if k == 1 then
									table.insert(output,indentation.."["..v)
								elseif k == #keyTable then
									table.insert(output,indentation..v.."]")
								else
									table.insert(output,indentation..v)
								end
							end
							for k,v in ipairs(valueTable) do
								if k == 1 then
									table.insert(output,indentation.." => "..v)
								else
									table.insert(output,indentation..v)
								end
							end
						end
					end
					table.insert(output,"\t}")
				end
			else
				table.insert(output,name..type(v).." \""..tostring(v).."\"")
			end
			name = nil
		end
	end
	local string = ""
	for k,v in ipairs(output) do
		if outputDirectly then
			outputConsole(v)
		end
		string = string..v
	end
	return string, output
end
