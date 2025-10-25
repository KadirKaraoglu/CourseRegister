// Rezervasyon süresi yöneticisi
class ReservationTimer {
    constructor(duration = 30 * 60) { // varsayılan 30 dakika
        this.duration = duration;
        this.timeLeft = duration;
        this.timer = null;
        this.callbacks = {
            onTick: null,
            onTimeout: null
        };
    }

    start(onTick, onTimeout) {
        this.callbacks.onTick = onTick;
        this.callbacks.onTimeout = onTimeout;
        this.timeLeft = this.duration;

        this.timer = setInterval(() => {
            this.timeLeft--;
            
            if (this.timeLeft <= 0) {
                this.stop();
                if (this.callbacks.onTimeout) {
                    this.callbacks.onTimeout();
                }
                return;
            }

            if (this.callbacks.onTick) {
                this.callbacks.onTick(this.timeLeft);
            }
        }, 1000);
    }

    stop() {
        if (this.timer) {
            clearInterval(this.timer);
            this.timer = null;
        }
    }

    getTimeLeftFormatted() {
        const minutes = Math.floor(this.timeLeft / 60);
        const seconds = this.timeLeft % 60;
        return `${minutes}:${seconds.toString().padStart(2, '0')}`;
    }
}

window.reservationTimer = new ReservationTimer();