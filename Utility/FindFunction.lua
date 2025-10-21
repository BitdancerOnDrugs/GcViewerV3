local FindFunc = {}
function FindFunc:CheckConstants(func, totalConstants, expected)
    assert(typeof(func) == "function", "First argument must be a function")
    assert(typeof(totalConstants) == "number", "Second argument must be a number")
    assert(typeof(expected) == "table", "Third argument must be a table")

    local constants = debug.getconstants(func)
    if not constants then
        return false
    end

    if #constants ~= totalConstants then
        return false
    end

    for index, expectedValue in next, expected do
        local actualValue = constants[index]
        if type(expectedValue) == "string" and expectedValue:match("^typeof:") then
            local expectedType = expectedValue:sub(8)
            if typeof(actualValue) ~= expectedType then
                return false
            end
        else
            if actualValue ~= expectedValue then
                return false
            end
        end
    end

    return true
end
function FindFunc:CheckUpvalues(func, totalUpvalues, expected)
    assert(typeof(func) == "function", "First argument must be a function")
    assert(typeof(totalUpvalues) == "number", "Second argument must be a number")
    assert(typeof(expected) == "table", "Third argument must be a table")

    local count = debug.getupvalues(func)
    if not count then
        return false
    end

    if #count ~= totalUpvalues then
        return false
    end

    for index, expectedValue in next, expected do
        local actualValue = count[index]
        if type(expectedValue) == "string" and expectedValue:match("^typeof:") then
            local expectedType = expectedValue:sub(8)
            if typeof(actualValue) ~= expectedType then
                return false
            end
        else
            if actualValue ~= expectedValue then
                return false
            end
        end
    end

    return true
end
function FindFunc:CheckProtos(func, expectedProtoCount)
    assert(typeof(func) == "function", "First argument must be a function")
    assert(typeof(expectedProtoCount) == "number", "Second argument must be a number")

    local protos = debug.getprotos(func)
    if not protos then
        return false
    end

    return #protos == expectedProtoCount
end
function FindFunc:CheckReturns(func, expected)
    assert(typeof(func) == "function", "Argument must be a function")
    local ok, result = pcall(func)
    if not ok then
        return false
    end

    if typeof(expected) == "table" then
        for i, v in ipairs(expected) do
            if result[i] ~= v then
                return false
            end
        end
        return true
    else
        return result == expected
    end
end
function FindFunc:GcLookUp(val, callback, filter)
    for i, v in next, getgc(val and true or nil) do
        if typeof(v) == "function" and islclosure(v) and not isexecutorclosure(v) then
            if filter then
                if filter(v) then
                    if callback then
                        callback(i, v)
                    else
                        return v
                    end
                end
            else
                if callback then
                    callback(i, v)
                else
                    return v
                end
            end
        end
    end
end
function FindFunc:FindFunctionsByConstants(expectedCount, expectedConstants)
    local found = {}
    self:GcLookUp(true, function(_, func)
        if self:CheckConstants(func, expectedCount, expectedConstants) then
            table.insert(found, func)
        end
    end)
    return found
end
function FindFunc:FindFunctionsByUpvalues(expectedCount, expectedUpvalues)
    local found = {}
    self:GcLookUp(true, function(_, func)
        if self:CheckUpvalues(func, expectedCount, expectedUpvalues) then
            table.insert(found, func)
        end
    end)
    return found
end
function FindFunc:FindFunctionsByProtoCount(count)
    local found = {}
    self:GcLookUp(true, function(_, func)
        if self:CheckProtos(func, count) then
            table.insert(found, func)
        end
    end)
    return found
end
function FindFunc:FindFunctionsByScript(script)
    if not getscriptfromfunction then
        return {}
    end
    local found = {}
    self:GcLookUp(true, function(_, func)
        if getscriptfromfunction(func) == script then
            table.insert(found, func)
        end
    end)
    return found
end
function FindFunc:FindFunctionsByReturn(expected)
    local found = {}
    self:GcLookUp(true, function(_, func)
        if self:CheckReturns(func, expected) then
            table.insert(found, func)
        end
    end)
    return found
end
function FindFunc:FindFunctionsByNameChunkLine(nameOrChunk)
    local found = {}
    self:GcLookUp(true, function(_, func)
        local info = debug.info(func, "nS")
        if info and (info.name == nameOrChunk or info.short_src == nameOrChunk or info.source == nameOrChunk) then
            table.insert(found, func)
        end
    end)
    return found
end
function FindFunc:GetAllMatching(filterFunc)
    local found = {}
    self:GcLookUp(true, function(_, func)
        if filterFunc(func) then
            table.insert(found, func)
        end
    end)
    return found
end
function FindFunc:GetClosureInfo(func)
    if typeof(func) ~= "function" then
        return {}
    end

    local info = {
        constants = debug.getconstants(func),
        upvalues = debug.getupvalues(func),
        protos = debug.getprotos(func),
        script = getscriptfromfunction and getscriptfromfunction(func) or nil,
        debug = debug.info(func, "nSluf")
    }

    return info
end
function FindFunc:DumpFunctionInfo(func)
    local data = self:GetClosureInfo(func)
    print("Function:", tostring(func))
    print("Script:", tostring(data.script))
    print("Constants:", typeof(data.constants) == "table" and #data.constants or "n/a")
    print("Upvalues:", typeof(data.upvalues) == "table" and #data.upvalues or "n/a")
    print("Protos:", typeof(data.protos) == "table" and #data.protos or "n/a")
    if data.debug then
        print("Name:", data.debug.name)
        print("Source:", data.debug.source)
        print("Line:", data.debug.linedefined)
    end
end
function FindFunc.getscriptfromthread(script)
    if not getscriptfromthread then
        return "Executor doesnt support getscriptfromthread"
    end
    for i,v in next, getreg() do 
        if typeof(v) == "thread" and getscriptfromthread(v) == script then
            return getscriptfromthread(v)
        end
    end
end
function FindFunc.getscriptfromfunction(f)
    if not getscriptfromfunction then
        return "Executor doesnt support getscriptfromfunction"
    end
    return getscriptfromfunction(f)
end

return FindFunc
