-- LearnNaija IPv4/IPv6 Address Management System
-- Step 10: Run each invalid INSERT separately in psql, without BEGIN.
-- Each stated error is expected. These statements should not add rows.

-- 1. Required site_name: expected NOT NULL error.
INSERT INTO public.site (site_name, site_type, location)
VALUES (NULL, 'HQ', 'Abuja');

-- 2. Invalid site_type: expected site_type_check error.
INSERT INTO public.site (site_name, site_type, location)
VALUES ('TEST Invalid Site Type', 'BRANCH', 'Abuja');

-- 3. Duplicate optional email: expected site_contact_email_uq error.
INSERT INTO public.site (site_name, site_type, location, contact_email)
VALUES ('TEST Duplicate Email', 'HQ', 'Abuja', 'network-abuja@example.com');

-- 4. Required segment_name: expected NOT NULL error.
INSERT INTO public.network_segment (site_id, segment_name, vlan_id, purpose)
VALUES ((SELECT site_id FROM public.site WHERE site_name = 'LearnNaija Abuja HQ'), NULL, 4000, 'Test required field');

-- 5. Missing site reference: expected network_segment_site_fk error.
INSERT INTO public.network_segment (site_id, segment_name, vlan_id, purpose)
VALUES (-1, 'TEST Missing Site', 4001, 'Test foreign key');

-- 6. VLAN outside 1-4094: expected network_segment_vlan_check error.
INSERT INTO public.network_segment (site_id, segment_name, vlan_id, purpose)
VALUES ((SELECT site_id FROM public.site WHERE site_name = 'LearnNaija Abuja HQ'), 'TEST Invalid VLAN', 4095, 'Test VLAN range');

-- 7. Duplicate VLAN within Abuja: expected network_segment_site_vlan_uq error.
INSERT INTO public.network_segment (site_id, segment_name, vlan_id, purpose)
VALUES ((SELECT site_id FROM public.site WHERE site_name = 'LearnNaija Abuja HQ'), 'TEST Duplicate VLAN', 10, 'Test VLAN uniqueness');

-- 8. Required device_name: expected NOT NULL error.
INSERT INTO public.network_device (site_id, segment_id, device_name, device_type)
VALUES ((SELECT site_id FROM public.site WHERE site_name = 'LearnNaija Abuja HQ'), NULL, NULL, 'Router');

-- 9. Missing device site: expected network_device_site_fk error.
INSERT INTO public.network_device (site_id, segment_id, device_name, device_type)
VALUES (-1, NULL, 'TEST Missing Site Device', 'Router');

-- 10. Missing device segment: expected network_device_segment_fk error.
INSERT INTO public.network_device (site_id, segment_id, device_name, device_type)
VALUES ((SELECT site_id FROM public.site WHERE site_name = 'LearnNaija Abuja HQ'), -1, 'TEST Missing Segment Device', 'Switch');

-- 11. Duplicate device name at same site: expected network_device_site_name_uq error.
INSERT INTO public.network_device (site_id, segment_id, device_name, device_type)
VALUES (
 (SELECT site_id FROM public.site WHERE site_name = 'LearnNaija Abuja HQ'),
 (SELECT segment_id FROM public.network_segment
  WHERE site_id = (SELECT site_id FROM public.site WHERE site_name = 'LearnNaija Abuja HQ')
    AND segment_name = 'Staff'),
 'Router-ABJ-01', 'Router'
);

-- 12. Required pool_name: expected NOT NULL error.
INSERT INTO public.address_pool (site_id, address_family, parent_prefix, pool_name)
VALUES ((SELECT site_id FROM public.site WHERE site_name = 'LearnNaija Abuja HQ'), 'IPv4', '10.99.0.0/24'::cidr, NULL);

-- 13. Missing pool site: expected address_pool_site_fk error.
INSERT INTO public.address_pool (site_id, address_family, parent_prefix, pool_name)
VALUES (-1, 'IPv4', '10.99.0.0/24'::cidr, 'TEST Missing Site Pool');

-- 14. Address family does not match parent prefix: expected address_pool_family_check error.
INSERT INTO public.address_pool (site_id, address_family, parent_prefix, pool_name)
VALUES ((SELECT site_id FROM public.site WHERE site_name = 'LearnNaija Abuja HQ'), 'IPv4', 'fd12:3456:789a:0900::/56'::cidr, 'TEST Wrong Address Family');

-- 15. Required allocation_date: expected NOT NULL error.
INSERT INTO public.address_allocation
 (pool_id, site_id, segment_id, network_prefix, gateway_address, allocation_date, allocation_status)
VALUES (
 (SELECT pool_id FROM public.address_pool WHERE pool_name = 'Abuja IPv4 Parent'),
 (SELECT site_id FROM public.site WHERE site_name = 'LearnNaija Abuja HQ'),
 (SELECT segment_id FROM public.network_segment
  WHERE site_id = (SELECT site_id FROM public.site WHERE site_name = 'LearnNaija Abuja HQ') AND segment_name = 'Staff'),
 '10.10.0.160/27'::cidr, '10.10.0.161'::inet, NULL, 'ACTIVE'
);

-- 16. Missing pool reference: expected address_allocation_pool_fk error.
INSERT INTO public.address_allocation
 (pool_id, site_id, segment_id, network_prefix, gateway_address, allocation_date, allocation_status)
VALUES (
 -1,
 (SELECT site_id FROM public.site WHERE site_name = 'LearnNaija Abuja HQ'),
 (SELECT segment_id FROM public.network_segment
  WHERE site_id = (SELECT site_id FROM public.site WHERE site_name = 'LearnNaija Abuja HQ') AND segment_name = 'Staff'),
 '10.10.0.160/27'::cidr, '10.10.0.161'::inet, DATE '2026-11-10', 'ACTIVE'
);

-- 17. Site does not match segment: expected address_allocation_site_segment_fk error.
INSERT INTO public.address_allocation
 (pool_id, site_id, segment_id, network_prefix, gateway_address, allocation_date, allocation_status)
VALUES (
 (SELECT pool_id FROM public.address_pool WHERE pool_name = 'Lagos IPv4 Parent'),
 (SELECT site_id FROM public.site WHERE site_name = 'LearnNaija Lagos PoP'),
 (SELECT segment_id FROM public.network_segment
  WHERE site_id = (SELECT site_id FROM public.site WHERE site_name = 'LearnNaija Abuja HQ') AND segment_name = 'Staff'),
 '10.10.1.32/27'::cidr, '10.10.1.33'::inet, DATE '2026-11-10', 'ACTIVE'
);

-- 18. Invalid allocation status: expected address_allocation_status_check error.
INSERT INTO public.address_allocation
 (pool_id, site_id, segment_id, network_prefix, gateway_address, allocation_date, allocation_status)
VALUES (
 (SELECT pool_id FROM public.address_pool WHERE pool_name = 'Abuja IPv4 Parent'),
 (SELECT site_id FROM public.site WHERE site_name = 'LearnNaija Abuja HQ'),
 (SELECT segment_id FROM public.network_segment
  WHERE site_id = (SELECT site_id FROM public.site WHERE site_name = 'LearnNaija Abuja HQ') AND segment_name = 'Staff'),
 '10.10.0.192/27'::cidr, '10.10.0.193'::inet, DATE '2026-11-10', 'PENDING'
);

-- Final count check after all invalid inserts have failed.
-- Expected: site 4; network_segment 5; network_device 5;
-- address_pool 8; address_allocation 10.
SELECT 'site' AS table_name, COUNT(*) AS row_count FROM public.site
UNION ALL SELECT 'network_segment', COUNT(*) FROM public.network_segment
UNION ALL SELECT 'network_device', COUNT(*) FROM public.network_device
UNION ALL SELECT 'address_pool', COUNT(*) FROM public.address_pool
UNION ALL SELECT 'address_allocation', COUNT(*) FROM public.address_allocation;

-- These current table definitions do not yet enforce subnet containment,
-- IPv6 /64 and /127 prefix lengths, or active-prefix overlap prevention.
-- Those require additional transaction-safe validation or triggers.
-- Network administrator approval/release permissions require roles or
-- authorised application logic. Do not treat those rules as tested here.
