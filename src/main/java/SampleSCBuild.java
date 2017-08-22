import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.security.PublicKey;
import static java.nio.charset.StandardCharsets.*;

import io.blocko.coinstack.*;
import io.blocko.coinstack.Math;
import io.blocko.coinstack.exception.*;
import io.blocko.coinstack.util.*;
import io.blocko.coinstack.model.*;

public class SampleSCBuild {
	
	public static String ContractPk = null;
	public static String ContractAddress = null;
	
        public static String SAMPLE_PRIVKEY = "KwjFub6oV3xmjz9PNwXVPhD5WxKEbuX5YajPXwn4FRzZAbyEjUbh";
        //public static String SAMPLE_PRIVKEY = "L49dVtBG7emznSTgezCrKdRxj6kX8EGMGx5ACSg3NNBrit7r2Bi4";

        public static CoinStackClient createNewClient() {
                CredentialsProvider credentials = null;
                AbstractEndpoint endpoint = new AbstractEndpoint() {
                        @Override
                        public String endpoint() {
                                //return "http://testchain.blocko.io";
                                return "http://localhost:3000";
                        }
                        @Override
                        public boolean mainnet() {
                                return true;
                        }
                        @Override
                        public PublicKey getPublicKey() {
                                return null;
                        }
                };
                CoinStackClient client = new CoinStackClient(credentials, endpoint);
                return client;
        }

	public static void main(String[] args) throws IOException, CoinStackException {
		System.out.println("## SampleTxBuild");
		
		CoinStackClient client = createNewClient();
		ContractPk = SAMPLE_PRIVKEY;
		
                try {
                        ContractAddress = ECKey.deriveAddress(ContractPk);
                        //ContractAddress = "1Ge4nk2hoevspGUbLUUQEWQ25L45voMfR7";
                } catch (Exception e) {
                        System.err.println("Fail to dereive Address" +ContractPk);

                        return;
                }

		System.out.println("### define simple contract");
		sampleDefineContract(client);
		
		System.out.println("### execute simple contract");
		sampleExecContract(client);

		System.out.println("### Query simple data");
		sampleQueryContract(client);
		return;
	}
		    
	private static void sleep(int time) {
		try {
			Thread.sleep(time);
		} catch (InterruptedException e) {}
	}

	public static String readContentFrom(String textFileName) throws IOException {
		BufferedReader bufferedTextFileReader = new BufferedReader(new FileReader(textFileName));
		StringBuilder contentReceiver = new StringBuilder();
		String ss;
		while ((ss = bufferedTextFileReader.readLine()) != null) {
		    contentReceiver.append(ss+"\n");
		} 
	 
		return contentReceiver.toString();
	} 


	public static void sampleDefineContract(CoinStackClient client)
			throws IOException, CoinStackException {

/*
        String POINT_FUNC = "";
        {
                POINT_FUNC += "local system = require(\"system\")\n";
                POINT_FUNC += "function lookupPoint(msg)\n";
                POINT_FUNC += "\tsystem.print(\"LOOKUPPOINT: \" .. msg)\n";
                POINT_FUNC += "\tlocal res = system.getItem(msg)\n";
                POINT_FUNC += "\treturn res\n";
                POINT_FUNC += "end\n\n";
                POINT_FUNC += "function genPoint(msg, point)\n";
                POINT_FUNC += "\tsystem.print(\"GENPOINT: \" .. msg .. \" sends \" .. point)\n";
                POINT_FUNC += "\tsystem.setItem(msg, point)\n";
                POINT_FUNC += "end\n\n";
	}
*/
		String Code = readContentFrom("./def.lua");
		LuaContractBuilder lcBuilder = new LuaContractBuilder();
		lcBuilder.setContractId(ContractAddress);
		lcBuilder.setDefinition(Code.getBytes("UTF-8"));

                String rawTx = lcBuilder.buildTransaction(client, ContractPk);
                String txHash = TransactionUtil.getTransactionHash(rawTx);

                System.out.println("- Func Def tx: "+txHash);
                System.out.println("-          code:"+Code);
                client.sendTransaction(rawTx);
                sleep(1000 * 10);
                System.out.println("- Func Def finised -");
	}
	
	
	public static void sampleExecContract(CoinStackClient client)
			throws IOException, CoinStackException {

		String Code = readContentFrom("./test2.lua");
                LuaContractBuilder lcBuilder = new LuaContractBuilder();
                lcBuilder.setContractId(ContractAddress);
                //String code = "res, ok = call(\"genPoint\", \"ABC\", 12000000000); assert(ok, res)";
                lcBuilder.setFee(1000000);
                lcBuilder.setExecution(Code.getBytes());

                String rawTx = lcBuilder.buildTransaction(client, ContractPk);
                String txHash = TransactionUtil.getTransactionHash(rawTx);
                client.sendTransaction(rawTx);
                sleep(1000 * 20);
                System.out.println("- Func Exec finised -");
        }

	public static void sampleQueryContract(CoinStackClient client)
			throws IOException, CoinStackException {
                String code = String.format("res, ok = call(\"lookupPoint\", \"Customer1\"); return res");
                String pointstr = null;

                ContractResult res = client.queryContract(
                                ContractAddress, ContractBody.TYPE_LSC, code.getBytes());
                if (res == null) {
                        System.out.println("  res: is null");
                        return;
                }

		System.out.println("Customer1: " +res.asJson());

		code = String.format("res, ok = call(\"lookupPoint\", \"Store1\"); return res");

                res = client.queryContract(
                                ContractAddress, ContractBody.TYPE_LSC, code.getBytes());
                if (res == null) {
                        System.out.println("  res: is null");
                        return;
                }

		System.out.println("Store1: " +res.asJson());

 		code = String.format("res, ok = call(\"lookupPoint\", \"Bank1\"); return res");

                res = client.queryContract(
                                ContractAddress, ContractBody.TYPE_LSC, code.getBytes());
                if (res == null) {
                        System.out.println("  res: is null");
                        return;
                }

		System.out.println("Bank1: " +res.asJson());
	}
}
