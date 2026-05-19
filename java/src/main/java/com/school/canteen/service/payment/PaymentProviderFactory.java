package com.school.canteen.service.payment;

import com.school.canteen.exception.BusinessException;
import com.school.canteen.service.payment.config.PaymentProperties;
import com.school.canteen.service.payment.enums.PaymentMode;
import com.school.canteen.service.payment.enums.PaymentProviderType;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import java.util.EnumMap;
import java.util.List;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class PaymentProviderFactory {

    private final PaymentProperties properties;
    private final List<PaymentProvider> providers;

    public PaymentProvider getProvider(String paymentMethod) {
        PaymentMode mode;
        try {
            mode = properties.resolvedMode();
        } catch (IllegalArgumentException e) {
            throw new BusinessException("PAYMENT_MODE_UNSUPPORTED", HttpStatus.BAD_REQUEST, e.getMessage());
        }
        if (mode == PaymentMode.MOCK) {
            return getMockProvider();
        }
        PaymentProviderType sandboxType = PaymentProviderType.fromPaymentMethod(paymentMethod);
        return findProvider(sandboxType);
    }

    public PaymentProvider getMockProvider() {
        if (!properties.getMock().isEnabled()) {
            throw new BusinessException("PAYMENT_MOCK_DISABLED", HttpStatus.BAD_REQUEST, "Mock payment provider is disabled");
        }
        return findProvider(PaymentProviderType.MOCK);
    }

    private PaymentProvider findProvider(PaymentProviderType type) {
        Map<PaymentProviderType, PaymentProvider> providerMap = new EnumMap<>(PaymentProviderType.class);
        for (PaymentProvider provider : providers) {
            providerMap.put(provider.getProviderType(), provider);
        }
        PaymentProvider provider = providerMap.get(type);
        if (provider == null) {
            throw new BusinessException(
                "PAYMENT_PROVIDER_NOT_IMPLEMENTED",
                HttpStatus.BAD_REQUEST,
                "Payment provider is not implemented: " + type
            );
        }
        return provider;
    }
}
