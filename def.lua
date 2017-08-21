local system = require("system");

function lookupPoint(msg)
        local res = system.getItem(msg)
        return res
end

function genPoint(msg, point)
        system.setItem(msg, point)
end

function bulkgenPoint(msg, point)
        for token in string.gmatch(msg, "[^%s]+") do
                system.setItem(token, point)
        end
end

function sendPointCustomerTotalFast(ckey, skeylist, bkey, cspoint, bcpoint, tpoint)
        for token in string.gmatch(skeylist, "[^%s]+") do
                sendPointCustomerTotal(ckey, token, bkey, cspoint, bcpoint, tpoint)
        end
end

function sendPointCustomerTotal(ckey, skey, bkey, cspoint, bcpoint, tpoint)
        local opoint = system.getItem(ckey) + system.getItem(skey) + system.getItem(bkey)
        local epoint = 0
        local cpoint = system.getItem(ckey)
        local spoint = system.getItem(skey)
        if system.getConfirmed() == false then
                return;
        end
        if (cpoint < cspoint) then
                local bpoint = system.getItem(bkey)
                cpoint = cpoint + bcpoint
                bpoint = bpoint - bcpoint
                system.setItem(ckey, cpoint)
                system.setItem(bkey, bpoint)
        end
        if (spoint+cspoint > tpoint) then
                local bpoint = system.getItem(bkey)
                system.setItem(ckey, cpoint - cspoint)
                system.setItem(skey, 0)
                system.setItem(bkey, bpoint + spoint + cspoint)
        else
                system.setItem(ckey, cpoint - cspoint)
                system.setItem(skey, spoint + cspoint)
        end
end




