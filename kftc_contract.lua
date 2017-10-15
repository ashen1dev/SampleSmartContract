-- 금융결제원 기술검증 sample code
-- 1.2 타행이체 프로세스에 대한 sample code
local system = require("system");
local json = require("json");

-- 권한 체크 함수 (후에 system level api로 제고 예정)
function grantAcceess(address, funcname)
        if (system.getSender() != system.getCreator()) then
		return
	end
        local key = "ACCESS_" .. funcname .. "_" .. address
        system.setItem(key, "1")
end

function hasPermission(resource)
        local key = "ACCESS_" .. resource .. "_" .. system.getSender()
        if (system.getItem(key)) then
                return true
        end
        return false
end

-- 1.1 수취조회
-- 수취 조회는 조회 요청을 한 후 그 결과를 받는 프로세스로
-- 굳이 contract를 통하여 수행될 필요가 없다.
-- 더 최적화를 한다면 기존의 전문 형태로 진행된 후
-- 실제 타행 이체 프로세스에서 블럭체인을 사용할 수 있다.
--
-- 본 POC에서는 수취 조회를 TX로 발생시킨 후, 그 결과도 TX로 남기도록 한다
-- 단 이 TX가 state DB를 수정하지 않으며
-- 단순히 요청, 응답 만 하게 되므로 block confirm을 기다리지 않고
-- event를 발생시키는 형태로 진행한다.
-- ps. 물론 수취 조회 요청 contract function과 응답 contract function을 만들어서 할 수도 있다.
-- contract 로 한다면 다음과 같이 구현할 수 있다.
-- 1.1.1 call by 취급기관
function CheckRequest(from, to, payload)
	system.pushEvent("CHECK", payload)
end	
-- 1.1.3 call by 개설기관
function CheckConfirmed(from, to, payload)
	system.pushEvent("CHECKCONFIRM", payload)
end
-- 1.1.4 call by 개설기관
function CheckError(from, to, payload)
	system.pushEvent("CHECKERROR", payload)
end

-- 1.2 타행 이체
-- 1.2.1 타행 이체 요청
-- 타행 이체 요청 또하 TX로만 수행할 수 있으나 contract를 통해서 수행하는 sample이다.
-- call by 수취은행
function transferRequest(from, to, payload)
	if hasPermission("TRQST") == false then
		return
	end
	data = tostring({from, to, payload})
	system.pushEvent("TRQST", data)
end

-- 이벤트를 listen하도록 등록한다. (금융결제원 응용)
-- 1.2.2를 위한 선행 함수
-- 금융결제원: res, ok = call("registRequestEvent", "TRQST", url, nodeaddress)
-- 개설은행: res, ok = call("registRequestEvent", "CRQST", url, nodeaddress)
-- 취급기관: res, ok = call("registRequestEvent", "ERQST", url, nodeaddress)
-- 취급기관: res, ok = call("registRequestEvent", "ERROR", url, nodeaddress)
function registRequstEvent(url, event)
	system.registEvent(url, event)
end

-- 1.2.2 적합성 확인 & 한도 확인
-- ContractQuery로 수행
function CheckTransferKFTC(from, to, money, payload)
	if hasPermission("KFTC") == false then
		return
	end
	-- 정합성 확인 로직
	
	-- 한도 확인 로직
	fromValue = system.getItem("LIMIT" .. from)
	if fromValue < money then
		return { "limitviolation" }
	end

	return { "cantransfer" }
end


-- 1.2.4 송금 요청
-- CheckTransferKFTC에서 true가 나오면 수행
function ConfirmRequestKFTC(from, to, money, payload)
	if hasPermission("KFTC") == false then
		return
	end
	flimitkey = "LIMIT" .. from 
	tlimitkey = "LIMIT" .. to
	fromValue = system.getItem(flimitkey)
	toValue = system.getItem(tlimitkey)

	-- 양쪽 한도 조정
	system.setItem(flimitkey, fromValue - money)
	system.setItem(tlimitkey, toValue + money)

	data = tostring({from, to, money, payload})
	system.pushEvent("CRQST", data)
end

-- 1.2.5 송금 완료 TX
-- call by 개설기관 응용
function ConfirmTransfer(from, to, money, payload)
	if hasPermission("CRQST") == false then
		return
	end
	system.setItem("TRANSFER" .. from .. to, payload)
	data = tostring({from, to, money, payload})
	system.pushEvent("ERQST", data)
end


-- 1.2.7, 1.2.8, 1.2.9, 1.2.10 
function ErrorNotifyKFTC(errortype)
	system.pushEvent("ERROR", tostring(errortype))
end



