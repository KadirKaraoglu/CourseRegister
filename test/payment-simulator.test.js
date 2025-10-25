// Payment Simulator Tests
import { PaymentSimulator } from '../frontend/js/payment-simulator.js';

describe('PaymentSimulator', () => {
    const validPaymentData = {
        cardNumber: '4532756279624064',
        expiryDate: '12/25',
        cvv: '123'
    };

    test('should process valid payment data', async () => {
        const result = await PaymentSimulator.processPayment(validPaymentData);
        expect(result).toHaveProperty('success');
        expect(result).toHaveProperty('transactionId');
        
        if (result.success) {
            expect(result.transactionId).toMatch(/^TR\d+[a-z0-9]+$/);
            expect(result.errorMessage).toBeNull();
        } else {
            expect(result.transactionId).toBeNull();
            expect(result.errorMessage).toBe('Payment was declined');
        }
    });

    test('should reject invalid payment data', async () => {
        const invalidData = {
            cardNumber: '4532756279624064'
            // Missing required fields
        };

        await expect(PaymentSimulator.processPayment(invalidData))
            .rejects.toThrow('Invalid payment data');
    });

    test('should simulate processing time', async () => {
        const start = Date.now();
        await PaymentSimulator.processPayment(validPaymentData);
        const duration = Date.now() - start;

        expect(duration).toBeGreaterThanOrEqual(1000);
        expect(duration).toBeLessThanOrEqual(3000);
    });
});