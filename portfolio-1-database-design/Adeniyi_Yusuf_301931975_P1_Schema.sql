-- LearnNaija Network Address Management System
-- PostgreSQL 16 database schema

BEGIN;

-- 1. Stores LearnNaija network sites.
CREATE TABLE public.site (
    site_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    site_name VARCHAR(100) NOT NULL,
    site_type VARCHAR(20) NOT NULL,
    location VARCHAR(150) NOT NULL,
    contact_email VARCHAR(150),

    CONSTRAINT site_type_check
        CHECK (site_type IN ('HQ', 'POP', 'UNIVERSITY'))
);

-- Email addresses must be unique when provided.
CREATE UNIQUE INDEX site_contact_email_uq
    ON public.site (contact_email)
    WHERE contact_email IS NOT NULL;


-- 2. Stores network segments and their VLAN details.
CREATE TABLE public.network_segment (
    segment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    site_id BIGINT NOT NULL,
    segment_name VARCHAR(100) NOT NULL,
    vlan_id INTEGER NOT NULL,
    purpose VARCHAR(100) NOT NULL,

    CONSTRAINT network_segment_site_fk
        FOREIGN KEY (site_id)
        REFERENCES public.site (site_id),

    CONSTRAINT network_segment_vlan_check
        CHECK (vlan_id BETWEEN 1 AND 4094),

    CONSTRAINT network_segment_site_vlan_uq
        UNIQUE (site_id, vlan_id),

    -- Supports the composite foreign key in AddressAllocation.
    CONSTRAINT network_segment_site_segment_uq
        UNIQUE (site_id, segment_id)
);


-- 3. Stores routers, switches and other network devices.
CREATE TABLE public.network_device (
    device_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    site_id BIGINT NOT NULL,
    segment_id BIGINT,
    device_name VARCHAR(100) NOT NULL,
    device_type VARCHAR(30) NOT NULL,
    management_ip INET,

    CONSTRAINT network_device_site_fk
        FOREIGN KEY (site_id)
        REFERENCES public.site (site_id),

    CONSTRAINT network_device_segment_fk
        FOREIGN KEY (segment_id)
        REFERENCES public.network_segment (segment_id),

    CONSTRAINT network_device_site_name_uq
        UNIQUE (site_id, device_name),

    -- Management IPs are individual addresses, not subnet prefixes.
    CONSTRAINT network_device_management_ip_check
        CHECK (
            management_ip IS NULL
            OR masklen(management_ip) IN (32, 128)
        )
);


-- 4. Stores parent IPv4 and IPv6 address blocks.
CREATE TABLE public.address_pool (
    pool_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    site_id BIGINT NOT NULL,
    address_family VARCHAR(4) NOT NULL,
    parent_prefix CIDR NOT NULL,
    pool_name VARCHAR(100) NOT NULL,

    CONSTRAINT address_pool_site_fk
        FOREIGN KEY (site_id)
        REFERENCES public.site (site_id),

    CONSTRAINT address_pool_family_check
        CHECK (
            (address_family = 'IPv4' AND family(parent_prefix::inet) = 4)
            OR
            (address_family = 'IPv6' AND family(parent_prefix::inet) = 6)
        )
);


-- 5. Stores individual IPv4 subnet and IPv6 prefix allocations.
CREATE TABLE public.address_allocation (
    allocation_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pool_id BIGINT NOT NULL,
    site_id BIGINT NOT NULL,
    segment_id BIGINT NOT NULL,
    network_prefix CIDR NOT NULL,
    gateway_address INET,
    allocation_date DATE NOT NULL,
    allocation_status VARCHAR(20) NOT NULL,

    CONSTRAINT address_allocation_pool_fk
        FOREIGN KEY (pool_id)
        REFERENCES public.address_pool (pool_id),

    -- Ensures that the selected segment belongs to the recorded site.
    CONSTRAINT address_allocation_site_segment_fk
        FOREIGN KEY (site_id, segment_id)
        REFERENCES public.network_segment (site_id, segment_id),

    CONSTRAINT address_allocation_status_check
        CHECK (
            allocation_status IN ('RESERVED', 'ACTIVE', 'RELEASED')
        )
);


-- Additional business rules require transaction logic or permissions.
-- Allocation operations must check that each subnet or prefix falls
-- within its parent pool and matches the pool's address family.
-- They must also enforce /64 and /127 IPv6 prefix lengths according
-- to the segment purpose.
-- A transaction-safe trigger or controlled allocation operation must
-- prevent overlapping active allocations within the same pool.
-- Database roles or an authorised application must restrict approval
-- and release actions to network administrators.
-- These rules are not enforced by the table definitions above.

COMMIT;