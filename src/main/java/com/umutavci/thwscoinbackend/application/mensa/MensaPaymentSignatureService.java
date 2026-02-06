package com.umutavci.thwscoinbackend.application.mensa;

import com.umutavci.thwscoinbackend.infrastructure.blockchain.PaymentManager;
import com.umutavci.thwscoinbackend.web.mensa.dto.PaymentSignatureRequest;
import com.umutavci.thwscoinbackend.web.mensa.dto.PaymentSignatureResponse;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.web3j.crypto.Credentials;
import org.web3j.crypto.Sign;
import org.web3j.crypto.StructuredDataEncoder;
import org.web3j.protocol.Web3j;
import org.web3j.utils.Numeric;

import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@ConditionalOnProperty(name = "blockchain.enabled", havingValue = "true")
public class MensaPaymentSignatureService {

    private final Web3j web3j;
    private final PaymentManager paymentManager;

    @Value("${blockchain.payment-manager-address}")
    private String paymentManagerAddress;

    @Value("${blockchain.chain-id:0}")
    private long chainIdOverride;

    @Value("${blockchain.signer-private-key:${blockchain.private-key:}}")
    private String signerPrivateKey;

    private Credentials signerCredentials;

    @PostConstruct
    public void init() {
        if (signerPrivateKey == null || signerPrivateKey.isBlank()) {
            throw new IllegalStateException("blockchain.signer-private-key (or blockchain.private-key) is required");
        }
        signerCredentials = Credentials.create(signerPrivateKey);
    }

    public PaymentSignatureResponse signMensaPayment(PaymentSignatureRequest req) throws Exception {
        String payer = req.payer();
        BigInteger amount = BigInteger.valueOf(req.amount());
        BigInteger nonce = paymentManager.nonces(payer).send();

        long expirySeconds = req.expirySeconds() != null ? req.expirySeconds() : 300;
        long expiry = Instant.now().getEpochSecond() + expirySeconds;

        long chainId = chainIdOverride > 0 ? chainIdOverride :
                web3j.ethChainId().send().getChainId().longValue();

        String serviceBytes32 = bytes32Hex("MENSA");

        String typedDataJson = buildTypedData(
                chainId,
                paymentManagerAddress,
                serviceBytes32,
                amount,
                payer,
                nonce,
                BigInteger.valueOf(expiry)
        );

        StructuredDataEncoder encoder = new StructuredDataEncoder(typedDataJson);
        byte[] digest = encoder.hashStructuredData();
        Sign.SignatureData sig = Sign.signMessage(digest, signerCredentials.getEcKeyPair(), false);

        int v = sig.getV()[0];
        if (v < 27) v += 27;

        String r = Numeric.toHexString(sig.getR());
        String s = Numeric.toHexString(sig.getS());

        return new PaymentSignatureResponse(
                req.amount(),
                req.orderId(),
                expiry,
                v,
                r,
                s,
                nonce.longValue()
        );
    }

    private String bytes32Hex(String value) {
        byte[] bytes = value.getBytes(StandardCharsets.UTF_8);
        byte[] padded = new byte[32];
        System.arraycopy(bytes, 0, padded, 0, Math.min(bytes.length, 32));
        return "0x" + Numeric.toHexStringNoPrefix(padded);
    }

    private String buildTypedData(
            long chainId,
            String verifyingContract,
            String service,
            BigInteger amount,
            String payer,
            BigInteger nonce,
            BigInteger expiry
    ) {
        Map<String, Object> domain = new HashMap<>();
        domain.put("name", "PaymentManager");
        domain.put("version", "1");
        domain.put("chainId", BigInteger.valueOf(chainId));
        domain.put("verifyingContract", verifyingContract);

        Map<String, Object> message = new HashMap<>();
        message.put("service", service);
        message.put("amount", amount);
        message.put("payer", payer);
        message.put("nonce", nonce);
        message.put("expiry", expiry);

        return "{" +
                "\"types\":{" +
                "\"EIP712Domain\":[{" +
                "\"name\":\"name\",\"type\":\"string\"},{" +
                "\"name\":\"version\",\"type\":\"string\"},{" +
                "\"name\":\"chainId\",\"type\":\"uint256\"},{" +
                "\"name\":\"verifyingContract\",\"type\":\"address\"}]," +
                "\"Payment\":[{" +
                "\"name\":\"service\",\"type\":\"bytes32\"},{" +
                "\"name\":\"amount\",\"type\":\"uint256\"},{" +
                "\"name\":\"payer\",\"type\":\"address\"},{" +
                "\"name\":\"nonce\",\"type\":\"uint256\"},{" +
                "\"name\":\"expiry\",\"type\":\"uint256\"}]}," +
                "\"primaryType\":\"Payment\"," +
                "\"domain\":{" +
                "\"name\":\"" + domain.get("name") + "\"," +
                "\"version\":\"" + domain.get("version") + "\"," +
                "\"chainId\":" + domain.get("chainId") + "," +
                "\"verifyingContract\":\"" + domain.get("verifyingContract") + "\"}," +
                "\"message\":{" +
                "\"service\":\"" + message.get("service") + "\"," +
                "\"amount\":" + message.get("amount") + "," +
                "\"payer\":\"" + message.get("payer") + "\"," +
                "\"nonce\":" + message.get("nonce") + "," +
                "\"expiry\":" + message.get("expiry") + "}}" +
                "}";
    }
}
