Mock payment servis

Bu küçük Express servisi, frontend ve n8n testleri için üç senaryo sunar: `success`, `fail`, `timeout`.

Çalıştırma:

1) Node.js kurulu olmalı.
2) Klasöre girip paketleri yükleyin:

   npm install

3) Servisi başlatın:

   npm start

Endpoint:
- POST /pay
  body: { scenario: 'success'|'fail'|'timeout', registration_id: '<uuid>' }

Dönen sonuçlar:
- success -> 200 { status: 'success', registration_id }
- fail -> 402 { status: 'failed', registration_id }
- timeout -> 202 { status: 'processing', registration_id } (uzun işlem simülasyonu)
