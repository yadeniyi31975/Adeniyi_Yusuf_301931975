\(IPV4/IPV6 ADDRESS PLAN (VLSM TABLE)\) Database Design

1. Entities --- what the database keeps records of
The database contains five main entities:
1. Site: Stores information about LearnNaija's Abuja headquarters,
   Lagos and Port Harcourt PoPs, and connected university networks.
2. NetworkSegment: Stores network segments and their VLAN
   information at each site.
3. NetworkDevice: Stores details of network devices, such as
   routers and switches, and their assigned network segments.
4. AddressPool: Stores the parent IPv4 or IPv6 address blocks from
   which smaller network allocations are made.
5. AddressAllocation: Stores individual IPv4 subnets and IPv6
   prefixes assigned to network segments.

Five entities are sufficient because university networks can be recorded
as sites with a university site type, while VLAN information belongs to
NetworkSegment.

2. Attributes and keys --- fields, PostgreSQL types, PKs, FKs, unique fields, and required or optional values
Site
- site_id -- BIGINT, primary key (PK), required.
- site_name -- VARCHAR(100), required.
- site_type -- VARCHAR(20), required; HQ, POP or UNIVERSITY.
- location -- VARCHAR(150), required.
- contact_email -- VARCHAR(150), optional, unique when provided.

NetworkSegment
- segment_id -- BIGINT, PK, required.
- site_id -- BIGINT, foreign key (FK) referencing Site, required.
- segment_name -- VARCHAR(100), required.
- vlan_id -- INTEGER, required; between 1 and 4094.
- purpose -- VARCHAR(100), required.
- Unique combination: site_id and vlan_id.

NetworkDevice

- device_id -- BIGINT, PK, required.
- site_id -- BIGINT, FK referencing Site, required.
- segment_id -- BIGINT, optional FK referencing NetworkSegment.
- device_name -- VARCHAR(100), required.
- device_type -- VARCHAR(30), required.
- management_ip -- INET, optional; stores an individual IPv4 or IPv6
  address.
- Unique combination: site_id and device_name.

AddressPool

- pool_id -- BIGINT, PK, required.
- site_id -- BIGINT, FK referencing Site, required.
- address_family -- VARCHAR(4), required; IPv4 or IPv6.
- parent_prefix -- CIDR, required; stores the parent network block.
- pool_name -- VARCHAR(100), required.

AddressAllocation

- allocation_id -- BIGINT, PK, required.
- pool_id -- BIGINT, FK referencing AddressPool, required.
- site_id -- BIGINT, required.
- segment_id -- BIGINT, required.
- network_prefix -- CIDR, required.
- gateway_address -- INET, optional.
- allocation_date -- DATE, required.
- allocation_status -- VARCHAR(20), required; RESERVED, ACTIVE or
  RELEASED.

The allocation's site and segment use a composite foreign key to ensure
that the segment belongs to the stated site.

3. Relationships --- how the tables connect

- Site and NetworkSegment: One site can have zero or many network
  segments. Each network segment belongs to exactly one site.
- Site and NetworkDevice: One site can have zero or many devices.
  Each device belongs to exactly one site.
- NetworkSegment and NetworkDevice: One segment can contain zero
  or many devices. A device may have no assigned segment or belong to
  one segment.
- Site and AddressPool: One site can have zero or many address
  pools. Each address pool belongs to one site.
- AddressPool and AddressAllocation: One pool can have zero or
  many allocations. Each allocation belongs to exactly one pool.
- NetworkSegment and AddressAllocation: One segment can have zero
  or many address allocations. Each allocation belongs to exactly one
  segment.

For example, the Abuja headquarters can have several VLAN segments, such
as staff and server networks, with separate IPv4 and IPv6 allocations.

4. Business rules and constraints --- match every numbered rule to a database check or operation

1. Unique site: The primary key on site_id and a NOT NULL
   constraint on site_name ensure each site has a unique identifier
   and registered name.
2. Unique network segment: The primary key on segment_id and its
   required foreign key to Site ensure every segment is uniquely
   identified and belongs to an existing site.
3. Valid VLAN: A CHECK constraint restricts VLAN IDs to 1--4094. A
   UNIQUE constraint on (site_id, vlan_id) prevents duplicate VLAN
   IDs within a site.
4. Valid IPv4 subnet: The CIDR data type validates network prefix
   notation. An allocation operation checks that the IPv4 subnet
   belongs within its assigned parent pool.
5. Valid IPv6 prefix: The CIDR type stores IPv6 prefixes. A CHECK
   or allocation operation enforces /64 for standard user and server
   VLANs and /127 for point-to-point links.
6. Valid allocation references: Foreign keys ensure allocations
   reference existing pools and segments. A composite foreign key
   ensures the recorded site matches the segment's site, while a CHECK
   constraint validates the address family.
7. No overlapping allocations: A database trigger or controlled
   allocation operation checks that a proposed prefix does not overlap
   another active allocation in the same pool. A primary key alone
   cannot enforce this rule.
8. Allocation approval: NOT NULL and CHECK constraints enforce the
   allocation date and valid status. Database permissions or authorised
   application operations restrict approval and release actions to
   network administrators.
5. Design assumptions
1. University connections are represented as sites with the type
   UNIVERSITY; UNILAG and UNIPORT are fictional examples for this
   design.
2. IPv4 and IPv6 parent prefixes are maintained separately in
   AddressPool. Address ranges and route summaries are calculated from
   stored prefixes rather than duplicated.
3. Network administrator authentication and permissions are managed
   through database roles or an authorised application layer rather
   than a separate user table.

