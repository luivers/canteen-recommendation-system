package com.school.canteen.service.payment;

import com.school.canteen.service.payment.dto.PaymentCallbackPayload;
import com.school.canteen.service.payment.dto.PaymentCreateRequest;
import com.school.canteen.service.payment.dto.PaymentCreateResponse;
import com.school.canteen.service.payment.dto.PaymentQueryResponse;
import com.school.canteen.service.payment.enums.PaymentProviderType;

import java.util.Map;

public interface PaymentProvider {

    PaymentProviderType getProviderType();

    PaymentCreateResponse createPayment(PaymentCreateRequest request);

    boolean verifyCallback(Map<String, Object> payload, String timestampHeader, String signatureHeader);

    PaymentCallbackPayload parseCallback(Map<String, Object> payload);

    PaymentQueryResponse queryPayment(String orderNumber);
}
