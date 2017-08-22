-- function definition
-- simple payment system
local system = require("system");
function genPoint(key, value) --called by smart oracle
    system.setItem(key, value)
end

function lookupPoint(msg)
	system.print("lookuppoint====")
        local res = system.getItem(msg)
        return res
end

function bulkgenPoint(msg, point)
        for token in string.gmatch(msg, "[^%s]+") do
                system.setItem(token, point)
        end
end

function registStore(skey, bkey)
	local ss = "bankof_" .. skey
	system.setItem(ss, bkey)
end

function getBank(skey)
	local ss = "bankof_" .. skey
	local res = system.getItem(ss)
	return res
end

function registBCpoint(bcpoint)
	local bc = "BC_POINT"
	system.setItem(bc, bcpoint)
end

function getBCpoint()
	return system.getItem("BC_POINT")
end

function registTHpoint(thpoint)
	local th = "TH_POINT"
	system.setItem(th, thpoint)
end

function getTHpoint()
	return system.getItem("TH_POINT")
end

function sendPointCustomerTotalFast(ckey, skeylist, cspoint)
        for token in string.gmatch(skeylist, "[^%s]+") do
                sendPointCustomerTotal(ckey, token, cspoint)
        end
end


-- payment function
-- customer -> store
-- if customer has fewer money then cspoint, gets money from a bank
-- if store has enough money then sends money to a bank
function sendPointCustomerTotal(ckey, skey, cspoint)
        local cpoint = system.getItem(ckey)
        local spoint = system.getItem(skey)
	local bcpoint = getBCpoint()
	local tpoint = getTHpoint()

        if system.getConfirmed() == false then
                return;
        end
        if (cpoint < cspoint) then
		local bkey = getBank(skey)
                local bpoint = system.getItem(bkey)
                cpoint = cpoint + bcpoint
                bpoint = bpoint - bcpoint
                system.setItem(ckey, cpoint)
                system.setItem(bkey, bpoint)
		system.print("B to C : " .. bkey .. " to " .. ckey)
        end
        if (spoint+cspoint > tpoint) then
		local bkey = getBank(skey)
                local bpoint = system.getItem(bkey)
                system.setItem(ckey, cpoint - cspoint)
                system.setItem(skey, 0)
                system.setItem(bkey, bpoint + spoint + cspoint)
		system.print("S to B : " .. skey .. " to " .. bkey)
        else
                system.setItem(ckey, cpoint - cspoint)
                system.setItem(skey, spoint + cspoint)
        end
end

