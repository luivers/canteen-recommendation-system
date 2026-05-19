package com.school.canteen.service.payment;

import com.school.canteen.exception.BusinessException;
import com.school.canteen.service.payment.config.PaymentProperties;
import com.school.canteen.service.payment.provider.MockPaymentProvider;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PaymentProviderFactoryTest {

    @Test
    void returnsMockProviderWhenModeIsMock() {
        PaymentProperties properties = new PaymentProperties();
        MockPaymentProvider mockProvider = new MockPaymentProvider(properties);
        PaymentProviderFactory factory = new PaymentProviderFactory(properties, List.of(mockProvider));

        assertSame(mockProvider, factory.getProvider("WECHAT"));
    }

    @Test
    void rejectsDisabledMockProvider() {
        PaymentProperties properties = new PaymentProperties();
        properties.getMock().setEnabled(false);
        PaymentProviderFactory factory = new PaymentProviderFactory(properties, List.of(new MockPaymentProvider(properties)));

        BusinessException exception = assertThrows(BusinessException.class, factory::getMockProvider);
        assertTrue(exception.getMessage().contains("Mock payment provider is disabled"));
    }

    @Test
    void sandboxModeFailsClearlyWhenProviderIsNotImplemented() {
        PaymentProperties properties = new PaymentProperties();
        properties.setMode("sandbox");
        PaymentProviderFactory factory = new PaymentProviderFactory(properties, List.of(new MockPaymentProvider(properties)));

        BusinessException exception = assertThrows(BusinessException.class, () -> factory.getProvider("WECHAT"));
        assertTrue(exception.getMessage().contains("WECHAT_SANDBOX"));
    }
}
