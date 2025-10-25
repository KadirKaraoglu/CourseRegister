import { test, expect } from '@playwright/test';

// Ana akış testi
test('3-click registration flow', async ({ page }) => {
    // Ana sayfaya git
    await page.goto('http://localhost:3000');
    
    // 1. Tıklama: Grup seçimi
    const groupButton = await page.getByRole('button', { name: 'Kayıt Ol' }).first();
    await expect(groupButton).toBeVisible();
    await groupButton.click();
    
    // Kayıt formunun görünür olduğunu kontrol et
    const registrationForm = await page.getByTestId('registration-form');
    await expect(registrationForm).toBeVisible();
    
    // Form bilgilerini doldur
    await page.getByLabel('Ad Soyad').fill('Test User');
    await page.getByLabel('E-posta').fill('test@example.com');
    await page.getByLabel('Telefon').fill('5551234567');
    
    // 2. Tıklama: Kayıt formunu gönder
    await page.getByRole('button', { name: 'Kaydı Tamamla & Ödemeye Geç' }).click();
    
    // Ödeme formunun görünür olduğunu kontrol et
    const paymentForm = await page.getByTestId('payment-form');
    await expect(paymentForm).toBeVisible();
    
    // Ödeme bilgilerini doldur
    await page.getByLabel('Kart Numarası').fill('4532756279624064');
    await page.getByLabel('Son Kullanma Tarihi').fill('12/25');
    await page.getByLabel('CVV').fill('123');
    
    // 3. Tıklama: Ödemeyi onayla
    await page.getByRole('button', { name: 'Ödemeyi Onayla' }).click();
    
    // Başarılı bildirimini bekle
    const notification = await page.getByTestId('notification');
    await expect(notification).toContainText('Ödemeniz başarıyla tamamlandı');
});

// Edge case'ler
test('kontenjan dolu grup testi', async ({ page }) => {
    await page.goto('http://localhost:3000');
    
    // Kontenjanı dolu olan bir grup bul
    const fullGroupButton = await page.getByRole('button', { name: 'Kontenjan Dolu' }).first();
    await expect(fullGroupButton).toBeDisabled();
});

test('rezervasyon zaman aşımı testi', async ({ page }) => {
    test.setTimeout(120000); // 2 dakika timeout
    
    await page.goto('http://localhost:3000');
    
    // Grubu seç ve kayıt formunu doldur
    await page.getByRole('button', { name: 'Kayıt Ol' }).first().click();
    await page.getByLabel('Ad Soyad').fill('Timeout Test');
    await page.getByLabel('E-posta').fill('timeout@example.com');
    await page.getByLabel('Telefon').fill('5559876543');
    await page.getByRole('button', { name: 'Kaydı Tamamla & Ödemeye Geç' }).click();
    
    // 31 dakika bekle (rezervasyon süresi + 1 dakika)
    await page.waitForTimeout(31 * 60 * 1000);
    
    // Rezervasyonun iptal edildiğini kontrol et
    const notification = await page.getByTestId('notification');
    await expect(notification).toContainText('Rezervasyon süresi doldu');
});

test('ödeme başarısız senaryosu', async ({ page }) => {
    await page.goto('http://localhost:3000');
    
    // Normal kayıt akışını başlat
    await page.getByRole('button', { name: 'Kayıt Ol' }).first().click();
    await page.getByLabel('Ad Soyad').fill('Failed Payment Test');
    await page.getByLabel('E-posta').fill('failed@example.com');
    await page.getByLabel('Telefon').fill('5553334444');
    await page.getByRole('button', { name: 'Kaydı Tamamla & Ödemeye Geç' }).click();
    
    // Geçersiz kart bilgileri gir
    await page.getByLabel('Kart Numarası').fill('4532756279624999');
    await page.getByLabel('Son Kullanma Tarihi').fill('12/25');
    await page.getByLabel('CVV').fill('999');
    await page.getByRole('button', { name: 'Ödemeyi Onayla' }).click();
    
    // Hata mesajını kontrol et
    const notification = await page.getByTestId('notification');
    await expect(notification).toContainText('Ödeme reddedildi');
});