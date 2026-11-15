
-- LEARNNAIJA PORTFOLIO 3
-- SESSION B: Administrator B

-- Start a second transaction
BEGIN;

-- Attempt to register the SAME device at Abuja HQ
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

-- This insert should wait while Session A is uncommitted.
-- After Session A commits, this insert should fail
-- because the device name already exists at that site.
