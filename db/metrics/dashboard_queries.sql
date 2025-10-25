-- Kayıt Hızı Metrikleri (conversion funnel)
WITH funnel AS (
    SELECT
        date_trunc('hour', occurred_at) AS time_bucket,
        event_type,
        COUNT(*) as event_count
    FROM registration_events
    WHERE occurred_at >= NOW() - INTERVAL '24 hours'
    GROUP BY date_trunc('hour', occurred_at), event_type
)
SELECT
    time_bucket,
    MAX(CASE WHEN event_type = 'reserved' THEN event_count ELSE 0 END) as reservations,
    MAX(CASE WHEN event_type = 'paid' THEN event_count ELSE 0 END) as payments,
    MAX(CASE WHEN event_type = 'cancelled' THEN event_count ELSE 0 END) as cancellations
FROM funnel
GROUP BY time_bucket
ORDER BY time_bucket;

-- Dönüşüm Oranı (Conversion Rate)
WITH counts AS (
    SELECT
        date_trunc('day', occurred_at) AS day,
        event_type,
        COUNT(*) as count
    FROM registration_events
    WHERE occurred_at >= NOW() - INTERVAL '30 days'
    GROUP BY date_trunc('day', occurred_at), event_type
)
SELECT
    day,
    MAX(CASE WHEN event_type = 'reserved' THEN count ELSE 0 END) as total_reservations,
    MAX(CASE WHEN event_type = 'paid' THEN count ELSE 0 END) as successful_payments,
    ROUND(
        (MAX(CASE WHEN event_type = 'paid' THEN count ELSE 0 END)::numeric /
        NULLIF(MAX(CASE WHEN event_type = 'reserved' THEN count ELSE 0 END), 0) * 100
        )::numeric, 2
    ) as conversion_rate
FROM counts
GROUP BY day
ORDER BY day;

-- İşlem Süresi Dağılımı
SELECT
    event_type,
    COUNT(*) as total_events,
    ROUND(AVG(duration_ms)::numeric, 2) as avg_duration_ms,
    ROUND(MIN(duration_ms)::numeric, 2) as min_duration_ms,
    ROUND(MAX(duration_ms)::numeric, 2) as max_duration_ms,
    ROUND(
        percentile_cont(0.95) WITHIN GROUP (ORDER BY duration_ms)::numeric,
        2
    ) as p95_duration_ms
FROM registration_events
WHERE duration_ms IS NOT NULL
GROUP BY event_type;

-- Grup Bazlı Doluluk ve Rezervasyon Durumu
SELECT
    cg.name as group_name,
    cg.max_capacity,
    cg.registered_count,
    cg.reserved_count,
    ROUND(
        (cg.registered_count::numeric / cg.max_capacity * 100)::numeric,
        2
    ) as fill_rate,
    COUNT(DISTINCT CASE WHEN re.event_type = 'cancelled' THEN re.registration_id END) as total_cancellations
FROM course_groups cg
LEFT JOIN registration_events re ON re.group_id = cg.group_id
GROUP BY cg.group_id, cg.name, cg.max_capacity, cg.registered_count, cg.reserved_count
ORDER BY cg.name;

-- Hata Analizi
SELECT
    error_type,
    COUNT(*) as error_count,
    ROUND(
        (COUNT(*)::numeric / SUM(COUNT(*)) OVER() * 100)::numeric,
        2
    ) as error_percentage
FROM registration_events
WHERE error_type IS NOT NULL
GROUP BY error_type
ORDER BY error_count DESC;