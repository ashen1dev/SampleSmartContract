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

a = 0
cs = 90000
while a < 100 do
	ret, ok = call("sendPointCustomerTotal", "Customer1", "Store1", cs)
	assert(ok, ret)
	a = a+1
end

