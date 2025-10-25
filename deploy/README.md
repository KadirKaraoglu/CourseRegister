Dağıtım (Hostinger Coolify) - Notlar

1) Coolify, Docker imajınızı deploy ederek statik frontend veya containerized servisleri çalıştırır.
2) Bu repo basit bir Nginx image ile frontend servis edilmesi için Dockerfile içerir.

Önerilen ortam değişkenleri (Coolify'de tanımlanmalı):
- SUPABASE_URL
- SUPABASE_KEY
- N8N_WEBHOOK_URL

CI/CD (GitHub Actions):
- Workflow `/.github/workflows/deploy.yml` imajı build edip kayıt deposuna push eder. Secrets: `REGISTRY_HOST`, `REGISTRY_USER`, `REGISTRY_PASSWORD`, `REGISTRY_REPO`.

Not: Backend (n8n, Supabase) ayrı servisler olarak Coolify üzerinde ya da ilgili sağlayıcıda yönetilmeli.
