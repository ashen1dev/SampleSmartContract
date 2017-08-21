local system = require("system");

system.nextBlock()

ret, ok = call("genPoint", "Bank0", 1200000)
assert(ok, ret)

ret, ok = call("bulkgenPoint", "Bank1 Bank2", 1200000000)
assert(ok, ret)

ret, ok = call("bulkgenPoint", "Store1 Store2", 0)
assert(ok, ret)

ret, ok = call("bulkgenPoint", "Customer1 Customer2", 0)
assert(ok, ret)

system.print("here")
a = 0
cs = 90000
bc = 1200000
t = 5000000
while a < 1000 do
	ret, ok = call("sendPointCustomerTotal", "Customer1", "Store1", "Bank1", cs, bc, t)
	system.print(a .. " :     " .. call("lookupPoint", "Customer1") .. " : " .. call("lookupPoint", "Store1") .. " : " ..  call("lookupPoint", "Bank1"))
	a = a+1
end

