# LearnNaija Network Address Management System] Normalisation

## 1. Introduction

Database normalisation is the process of organising data into related tables to reduce duplication and improve data accuracy. It helps prevent three common problems:

- **Update anomaly:** The same information has to be changed in several places.
- **Insertion anomaly:** A record cannot be added easily without unrelated information.
- **Deletion anomaly:** Deleting one record accidentally removes other important information.

The LearnNaija Network Address Management System uses five entities: Site, NetworkSegment, NetworkDevice, AddressPool and AddressAllocation. The examples below use fictional records from the Abuja headquarters and Lagos PoP.

## 2. Starting record: Unnormalised Form (UNF)

An unnormalised table can contain lists of values in one field. For example, one site record can contain several network segments, devices and address allocations.

**Table: NetworkRegister_UNF**

| site_id (PK) | site_name | site_type | location | Repeated network details |
|---|---|---|---|---|
| 1 | LearnNaija Abuja HQ | HQ | Abuja | Staff VLAN 10; devices: Router-ABJ-01 and Switch-ABJ-01; allocations: IPv4 10.10.0.0/25 and IPv6 fd12:3456:789a:0100:0010::/64 |
| 2 | LearnNaija Lagos PoP | POP | Lagos | Edge VLAN 110; device: Router-LAG-01; allocation: IPv4 10.10.1.0/27 |

**Key:** `site_id` is the primary key because each starting record represents one site.

**Problem:** The network details contain repeating lists. Devices and address allocations are not stored as separate records, making it difficult to update or manage individual network resources.

## 3. First Normal Form (1NF)

A table is in First Normal Form when each field contains only one value and there are no repeating groups.

The repeated network details are separated into individual records.

**Table 1: SiteSegment_1NF**

Primary key: Composite key (`site_id`, `vlan_id`).

| site_id (PK) | vlan_id (PK) | site_name | site_type | location | segment_name | purpose |
|---|---|---|---|---|---|---|
| 1 | 10 | LearnNaija Abuja HQ | HQ | Abuja | Staff | Staff access |
| 2 | 110 | LearnNaija Lagos PoP | POP | Lagos | Edge | PoP edge services |

**Table 2: NetworkDevice_1NF**

Primary key: `device_id`.

| device_id (PK) | site_id | vlan_id | device_name | device_type | management_ip |
|---|---|---|---|---|---|
| 101 | 1 | 10 | Router-ABJ-01 | Router | 10.10.0.2 |
| 102 | 1 | 10 | Switch-ABJ-01 | Switch | 10.10.0.3 |
| 103 | 2 | 110 | Router-LAG-01 | Router | 10.10.1.2 |

**Table 3: AddressAllocation_1NF**

Primary key: `allocation_id`.

| allocation_id (PK) | pool_id | site_id | vlan_id | pool_name | address_family | network_prefix |
|---|---|---|---|---|---|---|
| 1001 | 501 | 1 | 10 | Abuja IPv4 | IPv4 | 10.10.0.0/25 |
| 1002 | 502 | 1 | 10 | Abuja IPv6 | IPv6 | fd12:3456:789a:0100:0010::/64 |
| 1003 | 503 | 2 | 110 | Lagos IPv4 | IPv4 | 10.10.1.0/27 |

The address allocation records also contain the gateway, allocation date and allocation status. The table displays selected fields for readability.

**What changes:** Each device and address allocation now has its own record. Each field contains one value rather than a list. The records are easier to identify and manage individually.

## 4. Second Normal Form (2NF)

A table is in Second Normal Form when it is already in 1NF and every non-key field depends on the whole primary key, not just part of a combined key.

### Identifying partial dependency

In `SiteSegment_1NF`, the combined primary key is (`site_id`, `vlan_id`).

However, `site_name`, `site_type` and `location` depend only on `site_id`. They do not depend on the complete combination of `site_id` and `vlan_id`.

This is called a **partial dependency**. It means that some information depends on only one part of a combined key.

The site details therefore move into a separate Site table.

**Table 1: Site_2NF**

Primary key: `site_id`.

| site_id (PK) | site_name | site_type | location |
|---|---|---|---|
| 1 | LearnNaija Abuja HQ | HQ | Abuja |
| 2 | LearnNaija Lagos PoP | POP | Lagos |

**Table 2: NetworkSegment_2NF**

Primary key: Composite key (`site_id`, `vlan_id`).  
Foreign key: `site_id` references Site.

| site_id (PK, FK) | vlan_id (PK) | segment_name | purpose |
|---|---|---|---|
| 1 | 10 | Staff | Staff access |
| 2 | 110 | Edge | PoP edge services |

The site name, type and location are no longer repeated in the NetworkSegment table.

**What about NetworkDevice and AddressAllocation?**

In the displayed design, `device_id` is the single-column primary key of NetworkDevice, while `allocation_id` is the single-column primary key of AddressAllocation. They do not have composite primary keys, so there is no partial dependency to remove from those tables at this stage.

For example, the device information depends on `device_id`, while the allocation record depends on `allocation_id`.

**Table 3: AddressAllocation_2NF**

Primary key: `allocation_id`.

| allocation_id (PK) | pool_id | site_id | vlan_id | site_name | segment_name | pool_name | network_prefix |
|---|---|---|---|---|---|---|---|
| 1001 | 501 | 1 | 10 | LearnNaija Abuja HQ | Staff | Abuja IPv4 | 10.10.0.0/25 |
| 1002 | 502 | 1 | 10 | LearnNaija Abuja HQ | Staff | Abuja IPv6 | fd12:3456:789a:0100:0010::/64 |
| 1003 | 503 | 2 | 110 | LearnNaija Lagos PoP | Edge | Lagos IPv4 | 10.10.1.0/27 |

This table is in 2NF because its primary key contains only one field, `allocation_id`. However, some information still depends on other non-key fields. That problem is addressed by 3NF.

## 5. Third Normal Form (3NF)

A table is in Third Normal Form when it is already in 2NF and its non-key fields depend on the primary key directly, rather than depending on another non-key field.

This is called removing **transitive dependency**.

A transitive dependency occurs when a non-key field determines another non-key field.

For example, in `AddressAllocation_2NF`:

- `allocation_id` identifies the `pool_id`.
- `pool_id` determines the `pool_name`, `address_family` and `parent_prefix`.
- `allocation_id` also identifies the site's and segment's references, while those references determine their descriptive details.

Keeping all these descriptions in the allocation table causes repeated information.

The details therefore move into their own related tables:

- Site details move into `Site`.
- Segment details move into `NetworkSegment`.
- Device details remain in `NetworkDevice`.
- Parent address block details move into `AddressPool`.
- Individual subnet and prefix details remain in `AddressAllocation`.

### Final 3NF tables

The following five tables represent the agreed LearnNaija database design.

**Table 1: Site**

Primary key: `site_id`.

| site_id (PK) | site_name | site_type | location | contact_email (UK) |
|---|---|---|---|---|
| 1 | LearnNaija Abuja HQ | HQ | Abuja | NULL |
| 2 | LearnNaija Lagos PoP | POP | Lagos | NULL |

The `contact_email` field is optional and unique when provided.

**Table 2: NetworkSegment**

Primary key: `segment_id`.  
Foreign key: `site_id` references Site.  
Unique combination: (`site_id`, `vlan_id`).

| segment_id (PK) | site_id (FK) | segment_name | vlan_id | purpose |
|---|---|---|---|---|
| 10 | 1 | Staff | 10 | Staff access |
| 20 | 2 | Edge | 110 | PoP edge services |

**Table 3: NetworkDevice**

Primary key: `device_id`.  
Foreign keys: `site_id` references Site; `segment_id` optionally references NetworkSegment.  
Unique combination: (`site_id`, `device_name`).

| device_id (PK) | site_id (FK) | segment_id (FK) | device_name | device_type | management_ip |
|---|---|---|---|---|---|
| 101 | 1 | 10 | Router-ABJ-01 | Router | 10.10.0.2 |
| 102 | 1 | 10 | Switch-ABJ-01 | Switch | 10.10.0.3 |
| 103 | 2 | 20 | Router-LAG-01 | Router | 10.10.1.2 |

**Table 4: AddressPool**

Primary key: `pool_id`.  
Foreign key: `site_id` references Site.

| pool_id (PK) | site_id (FK) | address_family | parent_prefix | pool_name |
|---|---|---|---|---|
| 501 | 1 | IPv4 | 10.10.0.0/16 | Abuja IPv4 |
| 502 | 1 | IPv6 | fd12:3456:789a:0100::/56 | Abuja IPv6 |
| 503 | 2 | IPv4 | 10.10.1.0/24 | Lagos IPv4 |

**Table 5: AddressAllocation**

Primary key: `allocation_id`.  
Foreign key: `pool_id` references AddressPool.  
Composite foreign key: (`site_id`, `segment_id`) references NetworkSegment.

| allocation_id (PK) | pool_id (FK) | site_id | segment_id | network_prefix | gateway_address | allocation_date | allocation_status |
|---|---|---|---|---|---|---|---|
| 1001 | 501 | 1 | 10 | 10.10.0.0/25 | 10.10.0.1 | 2026-11-01 | ACTIVE |
| 1002 | 502 | 1 | 10 | fd12:3456:789a:0100:0010::/64 | fd12:3456:789a:0100:0010::1 | 2026-11-01 | ACTIVE |
| 1003 | 503 | 2 | 20 | 10.10.1.0/27 | 10.10.1.1 | 2026-11-02 | ACTIVE |

The optional `contact_email` values are shown as `NULL` because they are not supplied in the examples. The other displayed fields have example values.

### How the IDs keep the tables connected

The IDs allow the database to connect related records without repeating all their descriptions.

For example:

- `site_id = 1` connects the Abuja headquarters to its network segments, devices and address pools.
- `segment_id = 10` identifies the Abuja Staff VLAN.
- `pool_id = 501` identifies the Abuja IPv4 parent address block.
- `allocation_id = 1001` identifies the IPv4 subnet assigned to the Staff VLAN.

The foreign keys ensure that these references point to existing records. The composite foreign key also ensures that the recorded site and segment belong together.

## 6. Note on replacing a combined key with an ID

In the earlier NetworkSegment example, the combined key is (`site_id`, `vlan_id`) because a VLAN ID is unique within a particular site.

The final agreed design uses an automatically generated `segment_id` as the primary key instead. It retains the unique combination (`site_id`, `vlan_id`) to prevent duplicate VLAN IDs within the same site.

Using an automatically generated ID makes it easier for other tables to reference a network segment. However, **an automatically generated ID alone does not prove that a table is in 3NF**. The separation of site details from segment details is what removes the partial dependency.

The same principle applies to `allocation_id` and the other generated IDs: they identify records, while the separation of independent information removes duplication.

**Design consideration:** The agreed `AddressAllocation` table retains both `site_id` and `segment_id` so the composite foreign key can check that the segment belongs to the stated site. Since the segment also identifies its site, this retains a controlled duplicate reference. Under a strict textbook 3NF test, the site could instead be obtained through the segment. The field remains in the final tables above to match the agreed database design.

## 7. Conclusion

Normalisation organises the LearnNaija Network Address Management System into five related tables. 1NF removes repeating lists and ensures that fields contain individual values. 2NF removes partial dependencies, such as site details depending only on part of the combined site-and-VLAN key. 3NF separates information that depends on other non-key fields, such as parent address pool details and site descriptions.

The resulting design reduces repeated records, makes updates easier and supports accurate management of LearnNaija's sites, network devices, VLANs, IPv4 subnets and IPv6 prefixes.
