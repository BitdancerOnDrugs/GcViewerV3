return setmetatable({}, {
    __index = function(_, key)
        if key == "__version" then
            return "0.0.1"
        elseif key == "__log" then
            return {
                    "[/] Detection patching",
                    "[/] MetaMethod invoking patched",
            }
        end
        return nil 
    end
})
