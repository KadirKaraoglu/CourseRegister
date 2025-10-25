/**
 * Mock Payment Simulator Service
 * Simulates payment scenarios: success, failure, timeout, and network errors
 */

// Simulated delay ranges (ms)
const DELAYS = {
    MIN: 800,    // Minimum processing time
    MAX: 2000,   // Maximum processing time
    TIMEOUT: 5000 // Timeout threshold
}

// Payment result types
const RESULT = {
    SUCCESS: 'success',
    FAILURE: 'failure',
    TIMEOUT: 'timeout',
    NETWORK_ERROR: 'network_error'
}

// Simulated error messages
const ERROR_MESSAGES = {
    CARD_DECLINED: 'Kart reddedildi.',
    INSUFFICIENT_FUNDS: 'Yetersiz bakiye.',
    INVALID_CARD: 'Geçersiz kart bilgileri.',
    SYSTEM_ERROR: 'Sistem hatası.',
    TIMEOUT: 'İşlem zaman aşımına uğradı.',
    NETWORK: 'Ağ bağlantısı hatası.'
}

// Track payment attempts to prevent double submission
const paymentAttempts = new Map()

/**
 * Simulates a payment process with various scenarios
 * @param {string} registrationId - The registration ID for the payment
 * @param {string} [forceResult] - Optional: Force a specific result for testing
 * @returns {Promise} Resolves with success result or rejects with error
 */
export async function processPayment(registrationId, forceResult = null) {
    // Check for duplicate payment attempt
    if (paymentAttempts.has(registrationId)) {
        const lastAttempt = paymentAttempts.get(registrationId)
        const timeSinceLastAttempt = Date.now() - lastAttempt
        
        if (timeSinceLastAttempt < 10000) { // 10 seconds cooldown
            throw new Error('Lütfen tekrar denemeden önce biraz bekleyin.')
        }
    }
    
    // Record this attempt
    paymentAttempts.set(registrationId, Date.now())

    // Determine result (random if not forced)
    const result = forceResult || getRandomResult()
    
    // Simulate processing delay
    const delay = getRandomDelay()
    
    return new Promise((resolve, reject) => {
        const timeoutId = setTimeout(() => {
            reject(new Error(ERROR_MESSAGES.TIMEOUT))
        }, DELAYS.TIMEOUT)

        setTimeout(() => {
            clearTimeout(timeoutId)
            
            switch (result) {
                case RESULT.SUCCESS:
                    resolve({
                        success: true,
                        message: 'Ödeme başarıyla tamamlandı.',
                        transactionId: generateTransactionId()
                    })
                    break
                    
                case RESULT.FAILURE:
                    reject(new Error(getRandomError()))
                    break
                    
                case RESULT.NETWORK_ERROR:
                    reject(new Error(ERROR_MESSAGES.NETWORK))
                    break
                    
                default:
                    reject(new Error(ERROR_MESSAGES.SYSTEM_ERROR))
            }
        }, delay)
    })
}

// Helper function to generate random delay
function getRandomDelay() {
    return Math.floor(Math.random() * (DELAYS.MAX - DELAYS.MIN + 1)) + DELAYS.MIN
}

// Helper function to get random result
function getRandomResult() {
    const results = [RESULT.SUCCESS, RESULT.FAILURE, RESULT.NETWORK_ERROR]
    const weights = [0.7, 0.2, 0.1] // 70% success, 20% failure, 10% network error
    
    const random = Math.random()
    let sum = 0
    
    for (let i = 0; i < weights.length; i++) {
        sum += weights[i]
        if (random <= sum) return results[i]
    }
    
    return RESULT.SUCCESS
}

// Helper function to get random error message
function getRandomError() {
    const errors = [
        ERROR_MESSAGES.CARD_DECLINED,
        ERROR_MESSAGES.INSUFFICIENT_FUNDS,
        ERROR_MESSAGES.INVALID_CARD
    ]
    return errors[Math.floor(Math.random() * errors.length)]
}

// Helper function to generate transaction ID
function generateTransactionId() {
    return 'TR' + Date.now().toString(36).toUpperCase() + 
           Math.random().toString(36).substring(2, 7).toUpperCase()
}

// For testing: expose result types
export const PaymentResult = RESULT