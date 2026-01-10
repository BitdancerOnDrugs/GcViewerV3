return setmetatable({}, {
    __index = function(_, key)
        if key == "__version" then
            return "0.2"
        elseif key == "__log" then
            return {
                "[+] Added proper actor system",
                "[+] Re-factor entire script",
                "[+] Actor frame is alot more stable now",
                "[+] Rewrote filtering, rewrote start ups, rewrote script decompile"
            }
        end
        return nil 
    end
})
