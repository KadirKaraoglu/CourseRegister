/**
 * Rezervasyon zaman aşımı yöneticisi
 * Kullanıcıya kalan süreyi gösterir ve süre dolduğunda uyarı verir
 */

const RESERVATION_TIMEOUT = 30 * 60 * 1000; // 30 dakika (ms)
let activeTimer = null;

export class ReservationTimer {
    constructor(expiryTime, onExpire) {
        this.expiryTime = new Date(expiryTime).getTime();
        this.onExpire = onExpire;
        this.timer = null;
        this.countdownElement = null;
    }

    /**
     * Zamanlayıcıyı başlat ve süreyi göster
     * @param {HTMLElement} element - Sürenin gösterileceği DOM elementi
     */
    start(element) {
        if (activeTimer) {
            activeTimer.stop();
        }
        
        this.countdownElement = element;
        activeTimer = this;

        const updateDisplay = () => {
            const now = Date.now();
            const timeLeft = this.expiryTime - now;

            if (timeLeft <= 0) {
                this.stop();
                this.onExpire();
                return;
            }

            // Kalan süreyi formatla ve göster
            const minutes = Math.floor(timeLeft / 60000);
            const seconds = Math.floor((timeLeft % 60000) / 1000);
            
            this.countdownElement.textContent = 
                `Rezervasyon süresi: ${minutes}:${seconds.toString().padStart(2, '0')}`;
            
            // Son 5 dakikada uyarı rengi
            if (timeLeft < 5 * 60 * 1000) {
                this.countdownElement.classList.add('text-red-600');
            }
        };

        // Her saniye güncelle
        updateDisplay();
        this.timer = setInterval(updateDisplay, 1000);
    }

    /**
     * Zamanlayıcıyı durdur
     */
    stop() {
        if (this.timer) {
            clearInterval(this.timer);
            this.timer = null;
        }
        
        if (this.countdownElement) {
            this.countdownElement.textContent = '';
            this.countdownElement.classList.remove('text-red-600');
        }

        if (activeTimer === this) {
            activeTimer = null;
        }
    }

    /**
     * Şu anki aktif zamanlayıcıyı durdur
     */
    static stopActive() {
        if (activeTimer) {
            activeTimer.stop();
        }
    }
}