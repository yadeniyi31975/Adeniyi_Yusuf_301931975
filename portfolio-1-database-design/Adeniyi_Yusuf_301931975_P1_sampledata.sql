-- LearnNaija IPv4/IPv6 Address Management System
-- Step 10: fictional sample records. Run only when all five tables are empty.
-- University of Lagos is an illustrative example, not a claim of partnership.

BEGIN;

-- 1. Sites
INSERT INTO public.site (site_name, site_type, location, contact_email)
VALUES
 ('LearnNaija Abuja HQ', 'HQ', 'Abuja', 'network-abuja@example.com'),
 ('LearnNaija Lagos PoP', 'POP', 'Lagos', 'network-lagos@example.com'),
 ('LearnNaija Port Harcourt PoP', 'POP', 'Port Harcourt', 'network-ph@example.com'),
 ('University of Lagos Network (illustrative)', 'UNIVERSITY', 'Lagos', 'network-unilag@example.com');

-- 2. VLANs and network segments. Site IDs are looked up by site name.
INSERT INTO public.network_segment (site_id, segment_name, vlan_id, purpose)
SELECT s.site_id, v.segment_name, v.vlan_id, v.purpose
FROM (VALUES
 ('LearnNaija Abuja HQ', 'Staff', 10, 'Staff access VLAN'),
 ('LearnNaija Abuja HQ', 'Servers', 20, 'Server network VLAN'),
 ('LearnNaija Lagos PoP', 'Edge', 110, 'Lagos PoP edge services'),
 ('LearnNaija Port Harcourt PoP', 'Edge', 210, 'Port Harcourt PoP edge services'),
 ('University of Lagos Network (illustrative)', 'Partner', 310, 'Illustrative university network')
) AS v(site_name, segment_name, vlan_id, purpose)
JOIN public.site s ON s.site_name = v.site_name;

-- 3. Network devices
INSERT INTO public.network_device (site_id, segment_id, device_name, device_type, management_ip)
SELECT s.site_id, ns.segment_id, v.device_name, v.device_type, v.management_ip
FROM (VALUES
 ('LearnNaija Abuja HQ', 'Staff', 'Router-ABJ-01', 'Router', '10.10.0.2'::inet),
 ('LearnNaija Abuja HQ', 'Servers', 'Switch-ABJ-01', 'Switch', '10.10.0.130'::inet),
 ('LearnNaija Lagos PoP', 'Edge', 'Router-LAG-01', 'Router', '10.10.1.2'::inet),
 ('LearnNaija Port Harcourt PoP', 'Edge', 'Router-PHC-01', 'Router', '10.10.2.2'::inet),
 ('University of Lagos Network (illustrative)', 'Partner', 'Router-UNILAG-01', 'Router', '10.20.0.2'::inet)
) AS v(site_name, segment_name, device_name, device_type, management_ip)
JOIN public.site s ON s.site_name = v.site_name
JOIN public.network_segment ns ON ns.site_id = s.site_id AND ns.segment_name = v.segment_name;

-- 4. Separate IPv4 and IPv6 parent pools for each site.
INSERT INTO public.address_pool (site_id, address_family, parent_prefix, pool_name)
SELECT s.site_id, v.address_family, v.parent_prefix, v.pool_name
FROM (VALUES
 ('LearnNaija Abuja HQ', 'IPv4', '10.10.0.0/24'::cidr, 'Abuja IPv4 Parent'),
 ('LearnNaija Abuja HQ', 'IPv6', 'fd12:3456:789a:0100::/56'::cidr, 'Abuja IPv6 Parent'),
 ('LearnNaija Lagos PoP', 'IPv4', '10.10.1.0/24'::cidr, 'Lagos IPv4 Parent'),
 ('LearnNaija Lagos PoP', 'IPv6', 'fd12:3456:789a:0200::/56'::cidr, 'Lagos IPv6 Parent'),
 ('LearnNaija Port Harcourt PoP', 'IPv4', '10.10.2.0/26'::cidr, 'Port Harcourt IPv4 Parent'),
 ('LearnNaija Port Harcourt PoP', 'IPv6', 'fd12:3456:789a:0300::/56'::cidr, 'Port Harcourt IPv6 Parent'),
 ('University of Lagos Network (illustrative)', 'IPv4', '10.20.0.0/24'::cidr, 'UNILAG IPv4 Parent'),
 ('University of Lagos Network (illustrative)', 'IPv6', 'fd12:3456:789a:0400::/56'::cidr, 'UNILAG IPv6 Parent')
) AS v(site_name, address_family, parent_prefix, pool_name)
JOIN public.site s ON s.site_name = v.site_name;

-- 5. IPv4 subnet and IPv6 prefix allocations.
-- Pool, site and segment IDs are looked up, not guessed.
INSERT INTO public.address_allocation
 (pool_id, site_id, segment_id, network_prefix, gateway_address, allocation_date, allocation_status)
SELECT ap.pool_id, s.site_id, ns.segment_id, v.network_prefix, v.gateway_address,
       v.allocation_date, v.allocation_status
FROM (VALUES
 ('LearnNaija Abuja HQ', 'Abuja IPv4 Parent', 'Staff', '10.10.0.0/25'::cidr, '10.10.0.1'::inet, DATE '2026-11-01', 'ACTIVE'),
 ('LearnNaija Abuja HQ', 'Abuja IPv6 Parent', 'Staff', 'fd12:3456:789a:0100::/64'::cidr, 'fd12:3456:789a:0100::1'::inet, DATE '2026-11-01', 'ACTIVE'),
 ('LearnNaija Abuja HQ', 'Abuja IPv4 Parent', 'Servers', '10.10.0.128/27'::cidr, '10.10.0.129'::inet, DATE '2026-11-02', 'RESERVED'),
 ('LearnNaija Abuja HQ', 'Abuja IPv6 Parent', 'Servers', 'fd12:3456:789a:0101::/64'::cidr, 'fd12:3456:789a:0101::1'::inet, DATE '2026-11-02', 'ACTIVE'),
 ('LearnNaija Lagos PoP', 'Lagos IPv4 Parent', 'Edge', '10.10.1.0/27'::cidr, '10.10.1.1'::inet, DATE '2026-11-03', 'ACTIVE'),
 ('LearnNaija Lagos PoP', 'Lagos IPv6 Parent', 'Edge', 'fd12:3456:789a:0200::/64'::cidr, 'fd12:3456:789a:0200::1'::inet, DATE '2026-11-03', 'ACTIVE'),
 ('LearnNaija Port Harcourt PoP', 'Port Harcourt IPv4 Parent', 'Edge', '10.10.2.0/27'::cidr, '10.10.2.1'::inet, DATE '2026-11-04', 'ACTIVE'),
 ('LearnNaija Port Harcourt PoP', 'Port Harcourt IPv6 Parent', 'Edge', 'fd12:3456:789a:0300::/64'::cidr, 'fd12:3456:789a:0300::1'::inet, DATE '2026-11-04', 'RELEASED'),
 ('University of Lagos Network (illustrative)', 'UNILAG IPv4 Parent', 'Partner', '10.20.0.0/27'::cidr, '10.20.0.1'::inet, DATE '2026-11-05', 'ACTIVE'),
 ('University of Lagos Network (illustrative)', 'UNILAG IPv6 Parent', 'Partner', 'fd12:3456:789a:0400::/64'::cidr, 'fd12:3456:789a:0400::1'::inet, DATE '2026-11-05', 'ACTIVE')
) AS v(site_name, pool_name, segment_name, network_prefix, gateway_address, allocation_date, allocation_status)
JOIN public.site s ON s.site_name = v.site_name
JOIN public.network_segment ns ON ns.site_id = s.site_id AND ns.segment_name = v.segment_name
JOIN public.address_pool ap ON ap.site_id = s.site_id AND ap.pool_name = v.pool_name;

COMMIT;
