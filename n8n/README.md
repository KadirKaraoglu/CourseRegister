YZESKS - n8n Dispatcher

Bu klasörde, n8n'ye import edilebilecek bir dispatcher workflow şablonu bulunur (`dispatcher_workflow.json`).

Nasıl import edilir:
1) n8n ara yüzüne giriş yapın.
2) Workflows -> Import -> `dispatcher_workflow.json` dosyasını yükleyin.
3) Ortam değişkenleri olarak `SUPABASE_URL` ve `SUPABASE_KEY` ekleyin (HTTP Request node'ları Supabase RPC endpoint'lerine istek atacak şekilde ayarlanmıştır).

Dispatcher beklenen payload örnekleri (POST `/webhook/yzesks-dispatcher`):

1) Rezervasyon (reserve_spot)
{
  "action": "reserve_spot",
  "group_id": "<group-uuid>",
  "email": "kullanici@example.com",
  "name": "Ad Soyad",
  "phone": "0555xxxxxxx"
}

2) Ödeme onayı (confirm_payment)
{
  "action": "confirm_payment",
  "registration_id": "<registration-uuid>"
}

3) Rezervasyon iptali (cancel_reservation)
{
  "action": "cancel_reservation",
  "registration_id": "<registration-uuid>"
}

Notlar:
- Gerçek projede HTTP Request node'ları yerine n8n içindeki veritabanı/pg node'larını veya Supabase node'larını kullanmak daha güvenli olacaktır.
- `SUPABASE_URL` değeri Supabase REST endpoint base URL'si olmalıdır, örn: `https://xyzcompany.supabase.co`.

Scheduler kullanımı:
- `scheduler_workflow.json` import edilerek günlük veya daha kısa aralıklarla `cleanup_expired_reservations` RPC çağrılabilir.
- Cron node zamanlamasını test ortamı için kısa aralıklara (her 1-5 dakika) çekebilirsiniz.
