import { processPayment, PaymentResult } from './paymentSimulator.js'
import { ReservationTimer } from './reservationTimer.js'

// API endpoint'leri
const DISPATCHER_URL = 'REPLACE_WITH_DISPATCHER_URL' // örn: https://<n8n-host>/webhook/yzesks-dispatcher

// DOM elementleri
const elements = {
    groupList: document.getElementById('groupList'),
    groupTemplate: document.getElementById('groupTemplate'),
    registrationForm: document.getElementById('registrationForm'),
    registerForm: document.getElementById('registerForm'),
    paymentPanel: document.getElementById('paymentPanel'),
    notification: document.getElementById('notification'),
    selectedGroupId: document.getElementById('selectedGroupId'),
    confirmPayment: document.getElementById('confirmPayment'),
    cancelPayment: document.getElementById('cancelPayment'),
    paymentForm: document.getElementById('paymentForm'),
    reservationTimer: document.getElementById('reservationTimer')
}

// Placeholder gruplar (gerçek API bağlantısı yapılana kadar)
const placeholderGroups = [
    { 
        group_id: 'g1', 
        name: 'Ekim 2025 Grubu', 
        max_capacity: 10, 
        registered_count: 3, 
        reserved_count: 1, 
        is_active: true 
    },
    { 
        group_id: 'g2', 
        name: 'Aralık 2025 Grubu', 
        max_capacity: 10, 
        registered_count: 10, 
        reserved_count: 0, 
        is_active: true 
    }
]

// Grup listesini render et
function renderGroups(groups) {
    const template = elements.groupTemplate.innerHTML
    elements.groupList.innerHTML = groups.map(group => {
        const available = group.max_capacity - group.registered_count - group.reserved_count
        return template
            .replace(/{{name}}/g, group.name)
            .replace(/{{available}}/g, available)
            .replace(/{{capacity}}/g, group.max_capacity)
            .replace(/{{id}}/g, group.group_id)
            .replace(/{{buttonText}}/g, available > 0 ? 'Kayıt Ol' : 'Kontenjan Dolu')
            .replace(/{{disabled}}/g, available <= 0 ? 'disabled' : '')
    }).join('')

    // Kayıt butonlarına click handler ekle
    document.querySelectorAll('.register-btn').forEach(btn => {
        btn.addEventListener('click', () => handleGroupSelection(btn.dataset.groupId))
    })
}

// Grup seçildiğinde kayıt formunu göster
function handleGroupSelection(groupId) {
    const group = placeholderGroups.find(g => g.group_id === groupId)
    if (!group) return

    elements.selectedGroupId.value = groupId
    showElement(elements.registrationForm)
    elements.groupList.classList.add('opacity-50')
}

// Kayıt formunu gönder
async function handleRegistration(event) {
    event.preventDefault()
    const form = event.target
    const data = {
        action: 'reserve_spot',
        group_id: elements.selectedGroupId.value,
        name: form.name.value,
        email: form.email.value,
        phone: form.phone.value
    }

    try {
        showLoading('Rezervasyon yapılıyor...')
        const response = await postToDispatcher(data)
        
        // Zaman aşımı sayacını başlat
        const timer = new ReservationTimer(
            response.reservation_expiry,
            () => {
                showNotification('Rezervasyon süresi doldu!', 'error')
                resetView()
            }
        )
        timer.start(elements.reservationTimer)
        
        showNotification('Rezervasyon başarılı! Ödeme için 30 dakikanız var.', 'success')
        showPaymentPanel(response.registration_id)
    } catch (error) {
        showNotification(error.message, 'error')
        resetView()
    } finally {
        hideLoading()
    }
}

// Ödeme panelini göster
function showPaymentPanel(registrationId) {
    hideElement(elements.registrationForm)
    showElement(elements.paymentPanel)
    
    // Handler'ları ekle
    elements.confirmPayment.onclick = () => handlePayment('confirm', registrationId)
    elements.cancelPayment.onclick = () => handlePayment('cancel', registrationId)
    elements.paymentForm.onsubmit = (e) => {
        e.preventDefault()
        handlePayment('confirm', registrationId)
    }
}

// Ödeme işlemlerini yönet
async function handlePayment(action, registrationId) {
    const isConfirm = action === 'confirm'
    
    if (isConfirm) {
        try {
            showLoading('Ödeme işleniyor...')
            
            // Önce ödeme simülasyonunu çalıştır
            const paymentResult = await processPayment(registrationId)
            
            // Başarılı ödemeden sonra dispatcher'a bildir
            const data = {
                action: 'confirm_payment',
                registration_id: registrationId,
                transaction_id: paymentResult.transactionId
            }
            
            await postToDispatcher(data)
            showNotification('Ödeme başarılı! Kaydınız tamamlandı.', 'success')
            resetView()
            await fetchAndRenderGroups()
            
        } catch (error) {
            if (error.message.includes('tekrar denemeden önce')) {
                showNotification('Çok hızlı tekrar denediniz. Lütfen biraz bekleyin.', 'error')
            } else {
                showNotification('Ödeme Hatası: ' + error.message, 'error')
                // Başarısız ödemede rezervasyonu iptal et
                try {
                    const data = {
                        action: 'cancel_reservation',
                        registration_id: registrationId,
                        reason: 'payment_failed'
                    }
                    await postToDispatcher(data)
                } catch (cancelError) {
                    console.error('Rezervasyon iptal hatası:', cancelError)
                }
            }
        } finally {
            hideLoading()
        }
    } else {
        // İptal işlemi
        try {
            showLoading('İşlem iptal ediliyor...')
            const data = {
                action: 'cancel_reservation',
                registration_id: registrationId,
                reason: 'user_cancelled'
            }
            await postToDispatcher(data)
            showNotification('Rezervasyon iptal edildi.', 'info')
            resetView()
            await fetchAndRenderGroups()
        } catch (error) {
            showNotification('İptal Hatası: ' + error.message, 'error')
        } finally {
            hideLoading()
        }
    }
}

// API çağrıları için yardımcı fonksiyon
async function postToDispatcher(data) {
    const response = await fetch(DISPATCHER_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    })
    
    if (!response.ok) {
        const error = await response.json()
        throw new Error(error.message || 'İşlem başarısız')
    }
    
    return response.json()
}

// UI yardımcı fonksiyonları
function showElement(element) {
    element.classList.remove('hidden')
}

function hideElement(element) {
    element.classList.add('hidden')
}

function resetView() {
    elements.groupList.classList.remove('opacity-50')
    hideElement(elements.registrationForm)
    hideElement(elements.paymentPanel)
    elements.registerForm.reset()
    ReservationTimer.stopActive() // Aktif zamanlayıcıyı durdur
}

function showLoading(message) {
    elements.groupList.classList.add('opacity-50')
    showNotification(message, 'info')
}

function hideLoading() {
    elements.groupList.classList.remove('opacity-50')
    elements.notification.classList.add('hidden')
}

function showNotification(message, type = 'info') {
    const classes = {
        success: 'notification-success',
        error: 'notification-error',
        info: 'bg-blue-600'
    }
    elements.notification.className = `fixed bottom-4 right-4 p-4 rounded-lg text-white ${classes[type]}`
    elements.notification.textContent = message
    showElement(elements.notification)
    
    // 3 saniye sonra gizle
    setTimeout(() => {
        hideElement(elements.notification)
    }, 3000)
}

// Event listener'ları ekle
elements.registerForm.addEventListener('submit', handleRegistration)

// Sayfa yüklendiğinde grupları göster
async function fetchAndRenderGroups() {
    // TODO: Gerçek API'den grupları çek
    renderGroups(placeholderGroups)
}

// Başlangıç
fetchAndRenderGroups()
