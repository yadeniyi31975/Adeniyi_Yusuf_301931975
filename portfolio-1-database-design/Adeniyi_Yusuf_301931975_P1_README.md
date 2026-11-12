Portfolio 1 Database Design and Modelling

Case study

LearnNaija Network Address Management System is a proposed database
system for managing the IPv4 and IPv6 address allocation of LearnNaija
Ltd., an educational technology organisation operating a headquarters in
Abuja, two Points of Presence (PoPs) in Lagos and Port Harcourt, and
connected university networks. The system maintains network address
plans using Variable Length Subnet Masking (VLSM), IPv6 prefixes and
VLAN segmentation. It provides a centralised record of address
allocations to support accurate planning, monitoring and future network
expansion.

Users

The main users are network administrators, who create and manage IP
address allocations; network engineers, who plan subnets, configure
VLANs and maintain connectivity; IT managers, who review network
resources and approve changes; and authorised university network
representatives, who view their institution's assigned network details.

Main operations

The system records network sites and connected institutions, registers
network devices and VLANs, allocates IPv4 subnets using VLSM, assigns
IPv6 prefixes for dual-stack connectivity, records subnet gateways and
address ranges, tracks available and allocated IP address blocks, and
generates address allocation and route summarisation reports.


Business rules

1. Every network site must have a unique site_id and a registered
   site name.
2. Every network segment must have a unique segment_id and belong to
   one registered site.
3. Each VLAN must have a unique VLAN ID within its site, using valid
   values from 1 to 4094.
4. Every IPv4 subnet must have a valid network address, subnet mask and
   calculated address range within its assigned parent network.
5. Every IPv6 allocation must have a valid prefix and prefix length.
   Standard user and server VLANs use /64 prefixes, while
   point-to-point links may use /127 prefixes.
6. Each address allocation must reference an existing site and network
   segment, and its address family must be identified as IPv4 or IPv6.
7. An IPv4 subnet or IPv6 prefix must not overlap another active
   allocation within the same address pool.
8. An address allocation must have a recorded allocation date and
   status; only authorised network administrators may approve changes
   or mark an allocation as released.
   
Scope

The system covers fictional network records for LearnNaija's Abuja
headquarters, Lagos and Port Harcourt PoPs, and selected connected
university networks. It includes site registration, IPv4 VLSM
allocation, IPv6 prefix management, VLAN records, address availability,
allocation status and route summarisation information. It excludes live
router configuration, automatic network monitoring, internet service
provisioning, firewall management and real-time traffic analysis.
