// Ödeme simülatörü
window.paymentSimulator = {
    process: async function(paymentData) {
        // Basit mock validasyonlar
        if (!this.validateCard(paymentData)) {
            return false;
        }

        // Rastgele başarı/başarısızlık (80% başarı oranı)
        return Math.random() < 0.8;
    },

    validateCard: function(paymentData) {
        const { cardNumber, expiryDate, cvv } = paymentData;

        // Kart numarası kontrolü (mock)
        const cleanCardNumber = cardNumber.replace(/\s/g, '');
        if (cleanCardNumber.length !== 16 || !/^\d+$/.test(cleanCardNumber)) {
            return false;
        }

        // Son kullanma tarihi kontrolü (AA/YY formatı)
        if (!/^\d{2}\/\d{2}$/.test(expiryDate)) {
            return false;
        }

        // CVV kontrolü
        if (!/^\d{3}$/.test(cvv)) {
            return false;
        }

        return true;
    }
};