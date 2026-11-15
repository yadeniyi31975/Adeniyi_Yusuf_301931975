
-- LEARNNAIJA PORTFOLIO 3
-- SESSION A: Administrator A

-- Start a transaction
BEGIN;

-- Register a new network device at Abuja HQ
INSERT INTO public.network_device
    (site_id, segment_id, device_name, device_type)
SELECT
    s.site_id,
    ns.segment_id,
    'Router-ABJ-CONCURRENCY-TEST',
    'Router'
FROM public.site s
JOIN public.network_segment ns
    ON ns.site_id = s.site_id
WHERE s.site_name = 'LearnNaija Abuja HQ'
  AND ns.segment_name = 'Staff';

-- IMPORTANT:
-- Do not run COMMIT immediately.
-- Keep this transaction open while Session B runs.
