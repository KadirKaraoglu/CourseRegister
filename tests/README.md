Testler dizini

Bu klasörde stored procedure'lar için basit SQL testleri bulunmaktadır.

Çalıştırmak için psql veya Supabase SQL editor kullanabilirsiniz.

Örnek psql komutu (PowerShell):

psql -h <host> -U <user> -d <db> -f tests/001_procedure_tests.sql

Not: Test script'leri veritabanında değişiklik yapar (ör: test group oluşturur ve siler). Production veritabanında çalıştırmayın.

Concurrency test (Node.js):

1) Install dependencies (PowerShell):

```ps1
cd tests
npm install
```

2) Run the concurrency test against a dev DB (set env vars):

```ps1
$env:PGHOST='localhost'; $env:PGUSER='postgres'; $env:PGPASSWORD='secret'; $env:PGDATABASE='postgres'; npm run concurrency-test
```

The test will attempt multiple parallel `reserve_spot` calls and print results along with final counters.
