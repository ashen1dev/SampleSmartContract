local system = require("system");

system.nextBlock()

ret, ok = call("registBCpoint", 1200000)
assert(ok, ret)

ret, ok = call("registTHpoint", 5000000)
assert(ok, ret)

ret, ok = call("genPoint", "Bank0", 1200000)
assert(ok, ret)

ret, ok = call("bulkgenPoint", "Bank1 Bank2", 1200000000)
assert(ok, ret)

ret, ok = call("bulkgenPoint", "Store1 Store2", 0)
assert(ok, ret)

ret, ok = call("bulkgenPoint", "Customer1 Customer2", 0)
assert(ok, ret)

ret, ok = call("registStore", "Store1", "Bank1")
assert(ok, ret)

system.print("here")
a = 0
cs = 90000
while a < 200 do
	ret, ok = call("sendPointCustomerTotal", "Customer1", "Store1", cs)
        system.print("  " .. a .. " :     " .. call("lookupPoint", "Customer1") .. " : " .. call("lookupPoint", "Store1") .. " : " ..  call("lookupPoint", "Bank1"))
	a = a+1
end

ret, ok = call("recall", "Customer1", "Store1")
assert(ok, ret)

system.print(call("lookupPoint", "Customer1"))
system.print(call("lookupPoint", "Store1"))
system.print(call("lookupPoint", "Bank1"))
