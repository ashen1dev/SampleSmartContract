-- function definition
-- simple payment system
-- 한글 테스트
local system = require("system")

function genPoint(msg, point)
	system.print("GENPOINT====")
        system.setItem(msg, point)
end

function lookupPoint(msg)
	system.print("lookuppoint====")
        local res = system.getItem(msg)
        return res
end

