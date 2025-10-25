// Ana uygulama modülü
const app = {
    state: {
        selectedGroup: null,
        formData: {},
        currentStep: 1,
        reservationTimer: null,
    },

    init() {
        this.loadGroups();
        this.attachEventListeners();
    },

    // Eğitim gruplarını yükleme
    async loadGroups() {
        const groupListElement = document.getElementById('groupListContainer');
        if (!groupListElement) return;

        // API'den grupları al
        const groups = await this.fetchGroups();
        this.groups = groups; // Store groups for later use
        
        // Grupları DOM'a ekle
        groupListElement.innerHTML = groups.map(group => this.createGroupCard(group)).join('');
    },

    // API'den grup verilerini alma (mock)
    async fetchGroups() {
        return [
            {
                id: 1,
                name: "Yapay Zeka ve Makine Öğrenmesi",
                startDate: "15 Kasım 2025",
                capacity: 10,
                registeredCount: 6,
                price: 4500
            },
            {
                id: 2,
                name: "Derin Öğrenme ve Neural Networks",
                startDate: "1 Aralık 2025",
                capacity: 10,
                registeredCount: 8,
                price: 6000
            },
            {
                id: 3,
                name: "Doğal Dil İşleme",
                startDate: "15 Aralık 2025",
                capacity: 10,
                registeredCount: 10,
                price: 5500
            }
        ];
    },

    // Grup kartı HTML'ini oluşturma
    createGroupCard(group) {
        const availableSpots = group.capacity - group.registeredCount;
        const isFullyBooked = availableSpots <= 0;

        return `
            <div class="bg-white rounded-lg shadow p-6 space-y-4">
                <h3 class="text-xl font-semibold text-gray-800">${group.name}</h3>
                <div class="space-y-2">
                    <div class="flex items-center text-gray-600">
                        <i class="fas fa-calendar-alt w-5"></i>
                        <span class="ml-2">Başlangıç: ${group.startDate}</span>
                    </div>
                    <div class="flex items-center text-gray-600">
                        <i class="fas fa-users w-5"></i>
                        <span class="ml-2">Kontenjan: ${availableSpots}/${group.capacity}</span>
                    </div>
                    <div class="flex items-center text-gray-600">
                        <i class="fas fa-turkish-lira-sign w-5"></i>
                        <span class="ml-2">${group.price.toLocaleString('tr-TR')} TL</span>
                    </div>
                </div>
                <button 
                    onclick="app.openRegistrationForm(${group.id})"
                    class="w-full py-2 px-4 rounded-md ${
                        isFullyBooked 
                            ? 'bg-gray-100 text-gray-500 cursor-not-allowed' 
                            : 'bg-primary-600 text-white hover:bg-primary-700'
                    }"
                    ${isFullyBooked ? 'disabled' : ''}
                >
                    ${isFullyBooked ? 'Kontenjan Dolu' : 'Kayıt Ol'}
                </button>
            </div>
        `;
    },

    // Event Listeners
    attachEventListeners() {
        // Modal butonları
        document.getElementById('cancelButton')?.addEventListener('click', () => this.closeModal());
        document.getElementById('nextButton')?.addEventListener('click', () => this.handleNextStep());

        // Form submit engelleme
        document.getElementById('registrationForm')?.addEventListener('submit', (e) => e.preventDefault());
        document.getElementById('paymentForm')?.addEventListener('submit', (e) => e.preventDefault());
    },

    // Modal açma/kapama
    openRegistrationForm(groupId) {
        this.state.selectedGroup = this.findGroupById(groupId);
        if (!this.state.selectedGroup) return;

        document.getElementById('selectedGroupInfo').textContent = 
            `${this.state.selectedGroup.name} - ${this.state.selectedGroup.startDate}`;
        
        document.getElementById('registrationModal').classList.remove('hidden');
        this.updateStepIndicator(1);
    },

    closeModal() {
        document.getElementById('registrationModal').classList.add('hidden');
        this.resetForm();
    },

    // Form işlemleri
    async handleNextStep() {
        const nextButton = document.getElementById('nextButton');
        const originalText = nextButton.textContent;
        
        switch (this.state.currentStep) {
            case 1:
                if (this.validateRegistrationForm()) {
                    this.saveFormData();
                    
                    // Yükleniyor göster
                    nextButton.disabled = true;
                    nextButton.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i>İşleniyor...';
                    
                    const success = await this.reserveSpot();
                    
                    // Butonu normale döndür
                    nextButton.disabled = false;
                    nextButton.textContent = originalText;
                    
                    if (success) {
                        this.showPaymentStep();
                    }
                }
                break;
            case 2:
                if (this.validatePaymentForm()) {
                    // Yükleniyor göster
                    nextButton.disabled = true;
                    nextButton.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i>Ödeme İşleniyor...';
                    
                    const success = await this.processPayment();
                    
                    // Butonu normale döndür
                    nextButton.disabled = false;
                    nextButton.textContent = originalText;
                    
                    if (success) {
                        this.showSuccess();
                    }
                }
                break;
        }
    },

    validateRegistrationForm() {
        const form = document.getElementById('registrationForm');
        const fullName = form.querySelector('[name="fullName"]');
        const email = form.querySelector('[name="email"]');
        const phone = form.querySelector('[name="phone"]');
        
        let isValid = true;
        
        // Her alanı validate et
        if (!validateFullName(fullName)) isValid = false;
        if (!validateEmail(email)) isValid = false;
        if (!validatePhone(phone)) isValid = false;
        
        // Form'un kendi validasyonunu da kontrol et
        if (!form.checkValidity()) {
            form.reportValidity();
            isValid = false;
        }
        
        return isValid;
    },

    validatePaymentForm() {
        const form = document.getElementById('paymentForm');
        const cardName = form.querySelector('[name="cardName"]');
        const cardNumber = form.querySelector('[name="cardNumber"]');
        const expiryDate = form.querySelector('[name="expiryDate"]');
        const cvv = form.querySelector('[name="cvv"]');
        
        let isValid = true;
        
        // Her alanı validate et
        if (!validateCardName(cardName)) isValid = false;
        if (!validateCardNumber(cardNumber)) isValid = false;
        if (!validateExpiryDate(expiryDate)) isValid = false;
        if (!validateCVV(cvv)) isValid = false;
        
        // Form'un kendi validasyonunu da kontrol et
        if (!form.checkValidity()) {
            form.reportValidity();
            isValid = false;
        }
        
        return isValid;
    },

    saveFormData() {
        const form = document.getElementById('registrationForm');
        const formData = new FormData(form);
        this.state.formData = {
            fullName: formData.get('fullName'),
            email: formData.get('email'),
            phone: formData.get('phone')
        };
    },

    // API çağrıları (mock)
    async reserveSpot() {
        try {
            // Mock rezervasyon - gerçek API bağlantısı olmadan çalışır
            // n8n webhook bağlandığında bu kısmı değiştirebilirsiniz
            
            // Simülasyon için 1 saniye bekle
            await new Promise(resolve => setTimeout(resolve, 1000));
            
            // Mock başarılı yanıt
            const mockSuccess = Math.random() > 0.1; // %90 başarı oranı
            
            if (!mockSuccess) {
                throw new Error('Rezervasyon başarısız');
            }
            
            this.showNotification(
                'success',
                'Rezervasyon Başarılı',
                'Lütfen 30 dakika içinde ödemenizi tamamlayın.'
            );
            return true;
        } catch (error) {
            this.showNotification(
                'error',
                'Hata!',
                'Rezervasyon yapılırken bir hata oluştu. Lütfen tekrar deneyin.'
            );
            return false;
        }
    },

    async processPayment() {
        try {
            // Mock ödeme simülasyonu
            const success = await window.paymentSimulator.process({
                amount: this.state.selectedGroup.price,
                ...this.getPaymentFormData()
            });

            if (!success) throw new Error('Ödeme başarısız');

            // Mock başarılı yanıt - n8n bağlandığında gerçek API çağrısı yapılabilir
            await new Promise(resolve => setTimeout(resolve, 1500));

            return true;
        } catch (error) {
            this.showNotification(
                'error',
                'Ödeme Başarısız',
                'Lütfen kart bilgilerinizi kontrol edip tekrar deneyin.'
            );
            return false;
        }
    },

    // UI güncelleme
    showPaymentStep() {
        document.getElementById('formStep').classList.add('hidden');
        document.getElementById('paymentStep').classList.remove('hidden');
        document.getElementById('nextButton').textContent = 'Ödemeyi Tamamla';
        
        this.updateStepIndicator(2);
        this.startReservationTimer();
    },

    updateStepIndicator(step) {
        this.state.currentStep = step;
        const circles = [1, 2, 3];
        
        circles.forEach(num => {
            const circle = document.getElementById(`step${num}Circle`);
            const line = document.getElementById(`step${num}to${num + 1}`);
            
            if (num < step) {
                circle?.classList.add('bg-primary-600', 'text-white');
                circle?.classList.remove('bg-gray-200', 'text-gray-400');
                line?.classList.add('bg-primary-600');
                line?.classList.remove('bg-gray-200');
            } else if (num === step) {
                circle?.classList.add('bg-primary-600', 'text-white');
                circle?.classList.remove('bg-gray-200', 'text-gray-400');
            } else {
                circle?.classList.add('bg-gray-200', 'text-gray-400');
                circle?.classList.remove('bg-primary-600', 'text-white');
                line?.classList.add('bg-gray-200');
                line?.classList.remove('bg-primary-600');
            }
        });
    },

    showSuccess() {
        this.showNotification(
            'success',
            'Kayıt Tamamlandı!',
            'Eğitim detayları e-posta adresinize gönderilecektir.'
        );
        this.closeModal();
        this.loadGroups(); // Kontenjanları güncelle
    },

    // Yardımcı fonksiyonlar
    findGroupById(id) {
        return this.groups?.find(g => g.id === id);
    },

    getPaymentFormData() {
        const form = document.getElementById('paymentForm');
        const formData = new FormData(form);
        return {
            cardName: formData.get('cardName'),
            cardNumber: formData.get('cardNumber'),
            expiryDate: formData.get('expiryDate'),
            cvv: formData.get('cvv')
        };
    },

    showNotification(type, title, message) {
        const toast = document.getElementById('notificationToast');
        const icon = document.getElementById('notificationIcon');
        const iconElement = icon.querySelector('i');
        const titleEl = document.getElementById('notificationTitle');
        const messageEl = document.getElementById('notificationMessage');

        // Stil ayarları
        icon.className = 'flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center';
        if (type === 'success') {
            iconElement.className = 'fas fa-check-circle text-green-500';
            icon.classList.add('bg-green-100');
        } else {
            iconElement.className = 'fas fa-exclamation-circle text-red-500';
            icon.classList.add('bg-red-100');
        }

        titleEl.textContent = title;
        messageEl.textContent = message;
        
        toast.classList.remove('hidden');
        setTimeout(() => toast.classList.add('hidden'), 5000);
    },

    resetForm() {
        document.getElementById('registrationForm')?.reset();
        document.getElementById('paymentForm')?.reset();
        document.getElementById('formStep')?.classList.remove('hidden');
        document.getElementById('paymentStep')?.classList.add('hidden');
        document.getElementById('nextButton').textContent = 'Devam Et';
        
        this.state.currentStep = 1;
        this.state.selectedGroup = null;
        this.state.formData = {};
        this.updateStepIndicator(1);
        
        if (this.state.reservationTimer) {
            clearInterval(this.state.reservationTimer);
            this.state.reservationTimer = null;
        }
    },

    startReservationTimer() {
        const timerEl = document.getElementById('reservationTimer').querySelector('span');
        let timeLeft = 30 * 60; // 30 dakika

        this.state.reservationTimer = setInterval(() => {
            timeLeft--;
            
            if (timeLeft <= 0) {
                clearInterval(this.state.reservationTimer);
                this.handleReservationTimeout();
                return;
            }

            const minutes = Math.floor(timeLeft / 60);
            const seconds = timeLeft % 60;
            timerEl.textContent = `${minutes}:${seconds.toString().padStart(2, '0')}`;
        }, 1000);
    },

    async handleReservationTimeout() {
        try {
            // Mock rezervasyon iptali - n8n bağlandığında API çağrısı yapılabilir
            await new Promise(resolve => setTimeout(resolve, 500));

            this.showNotification(
                'error',
                'Rezervasyon Süresi Doldu',
                'Rezervasyon süreniz doldu. Lütfen yeniden kayıt oluşturun.'
            );
            this.closeModal();
            this.loadGroups();
        } catch (error) {
            console.error('Rezervasyon iptali başarısız:', error);
        }
    }
};

// Sayfa yüklendiğinde uygulamayı başlat
document.addEventListener('DOMContentLoaded', () => app.init());