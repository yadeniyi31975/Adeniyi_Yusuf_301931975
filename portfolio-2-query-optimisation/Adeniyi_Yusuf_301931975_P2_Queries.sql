-- MIT 8103 Portfolio 2: SQL Queries
-- Case study: LearnNaija Network Address Management System
-- Database: learnnaija_addr_portfolio
-- Database system: PostgreSQL 16

-- These three queries use the agreed Portfolio 1 tables and sample records.
-- Run this file from the PostgreSQL prompt while connected to learnnaija_addr_portfolio.

-- Query 1: List active IPv4 and IPv6 allocations
-- JOIN connects each allocation to its pool, site and network segment.

SELECT
    s.site_name,
    ns.segment_name,
    ap.address_family,
    aa.network_prefix,
    aa.gateway_address,
    aa.allocation_status
FROM public.address_allocation AS aa
JOIN public.site AS s
    ON s.site_id = aa.site_id
JOIN public.network_segment AS ns
    ON ns.site_id = aa.site_id
   AND ns.segment_id = aa.segment_id
JOIN public.address_pool AS ap
    ON ap.pool_id = aa.pool_id
WHERE aa.allocation_status = 'ACTIVE'
ORDER BY
    s.site_name,
    ns.segment_name,
    ap.address_family,
    aa.network_prefix;

-- Query 2: Find network segments without an active IPv6 allocation
-- NOT EXISTS identifies segments without a matching active IPv6 allocation.

SELECT
    s.site_name,
    ns.segment_name,
    'IPv6' AS address_family
FROM public.network_segment AS ns
JOIN public.site AS s
    ON s.site_id = ns.site_id
WHERE NOT EXISTS (
    SELECT 1
    FROM public.address_allocation AS aa
    JOIN public.address_pool AS ap
        ON ap.pool_id = aa.pool_id
    WHERE aa.site_id = ns.site_id
      AND aa.segment_id = ns.segment_id
      AND ap.address_family = 'IPv6'
      AND aa.allocation_status = 'ACTIVE'
)
ORDER BY
    s.site_name,
    ns.segment_name;

-- Query 3: Count all address allocations for each network segment
-- LEFT JOIN retains a segment even when it has no allocation.
-- COUNT(aa.allocation_id) returns zero for a segment with no matching allocation.

SELECT
    s.site_name,
    ns.segment_name,
    COUNT(aa.allocation_id) AS total_allocations
FROM public.site AS s
JOIN public.network_segment AS ns
    ON ns.site_id = s.site_id
LEFT JOIN public.address_allocation AS aa
    ON aa.site_id = ns.site_id
   AND aa.segment_id = ns.segment_id
GROUP BY
    s.site_id,
    s.site_name,
    ns.segment_id,
    ns.segment_name
ORDER BY
    s.site_name,
    ns.segment_name;
