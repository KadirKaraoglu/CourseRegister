# Hostinger Coolify Deployment Kılavuzu

Bu doküman, YZESKS (Yapay Zeka Eğitim Kayıt Sistemi) uygulamasının Hostinger Coolify platformuna dağıtımı için gerekli adımları içerir.

## 1. Ön Gereksinimler

- Hostinger hesabı
- Coolify erişimi
- Domain (SSL için)
- Supabase projesi
- GitHub repository

## 2. Ortam Değişkenleri

Aşağıdaki ortam değişkenlerini Coolify dashboard'unda ayarlayın:

```env
# Domain ayarları
DOMAIN=egitim.example.com
SSL_EMAIL=admin@example.com

# n8n yapılandırması
N8N_HOST=n8n.example.com
N8N_USER=admin
N8N_PASSWORD=<güvenli-şifre>

# Supabase bağlantı bilgileri
SUPABASE_HOST=db.example.supabase.co
SUPABASE_DB=postgres
SUPABASE_USER=postgres
SUPABASE_PASSWORD=<supabase-şifresi>
```

## 3. GitHub Actions Secrets

GitHub repository ayarlarında şu secrets'ları tanımlayın:

- `COOLIFY_SSH_KEY`: Coolify sunucusuna SSH erişimi için private key
- `COOLIFY_HOST`: Coolify sunucu IP adresi
- `COOLIFY_USER`: SSH kullanıcı adı
- `COOLIFY_TOKEN`: Coolify API token
- `COOLIFY_URL`: Coolify instance URL
- `DOMAIN`: Uygulama domain adresi

## 4. İlk Deployment Adımları

1. Coolify dashboard'da yeni bir proje oluşturun
2. Repository'yi bağlayın
3. Build ve deployment ayarlarını yapılandırın:
   - Build command: `npm run build`
   - Output directory: `dist`
   - Node.js version: 18

4. SSL sertifikası oluşturun:
```bash
docker-compose run --rm certbot
```

5. Servisleri başlatın:
```bash
docker-compose up -d
```

## 5. Güvenlik Kontrolleri

- [ ] n8n admin şifresi güvenli
- [ ] Supabase credentials güvenli
- [ ] SSL sertifikası aktif
- [ ] Nginx rate limiting aktif
- [ ] Docker container security scanning yapıldı

## 6. Monitoring

- Coolify dashboard üzerinden container durumlarını izleyin
- n8n workflow loglarını kontrol edin
- Nginx access/error loglarını takip edin

## 7. Bakım ve Güncelleme

### Uygulama Güncelleme
```bash
git push origin main  # GitHub Actions otomatik deploy edecek
```

### Manuel Güncelleme
```bash
ssh coolify
cd /var/www/yzesks
git pull
docker-compose pull
docker-compose up -d
```

### SSL Sertifika Yenileme
```bash
docker-compose run --rm certbot renew
```

## 8. Rollback Prosedürü

1. Önceki versiyona dön:
```bash
git checkout <previous-commit>
git push -f origin main
```

2. Manuel rollback:
```bash
cd /var/www/yzesks
git checkout <previous-commit>
docker-compose up -d
```

## 9. Troubleshooting

### Sık Karşılaşılan Sorunlar

1. SSL Sertifika Hataları
```bash
docker-compose logs certbot
docker-compose run --rm certbot --force-renewal
```

2. n8n Bağlantı Sorunları
```bash
docker-compose logs n8n
docker-compose restart n8n
```

3. Nginx Hataları
```bash
docker-compose logs frontend
nginx -t
```