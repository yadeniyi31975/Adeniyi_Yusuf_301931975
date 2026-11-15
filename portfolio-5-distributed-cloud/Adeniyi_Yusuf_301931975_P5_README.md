
# Portfolio 5 Distributed and Cloud Database Exercise

## Current setup

LearnNaija uses PostgreSQL to store structured network information, including sites, VLAN segments, network devices, IPv4 and IPv6 address pools, and address allocations. MongoDB is used to store example network events, such as address allocation and release activities.

Both database systems currently run in the same GitHub Codespace. This is a local development setup, not a distributed database deployment. No MongoDB replica set, sharding or failover test has been configured. The MongoDB event records are not automatically synchronised with PostgreSQL.

## Proposed replication

Replication keeps copies of the same database records on different database servers. LearnNaija could use a MongoDB replica set with three voting, data-holding members hosted in separate failure zones.

| Member | Starting role | Location |
|---|---|---|
| A | Primary: accepts event writes | Host 1 |
| B | Secondary: copies event changes | Host 2 |
| C | Secondary: copies event changes | Host 3 |

For example, when an `address_released` event is recorded for the LearnNaija Port Harcourt IPv6 network, the primary would accept the event and the secondary members would replicate the change asynchronously. This means a secondary could briefly contain older event information.

Reference: https://www.mongodb.com/docs/manual/replication/

## Failure and consistency

If the primary server fails, the remaining eligible members can hold an election to select a new primary, provided a majority of voting members can communicate. During the election, new writes may be temporarily interrupted.

If only one of the three voting members remains reachable, it cannot form a majority and cannot elect a writable primary.

For important network events, LearnNaija could use majority write acknowledgement. This requires at least two of the three voting members to acknowledge a write. It improves protection against losing an acknowledged event during a single-member failure, although it can increase write waiting time.

Queries sent to secondary members may return slightly older information because replication is asynchronous. PostgreSQL would remain responsible for authoritative network allocation records and their transaction rules.

References:
- https://www.mongodb.com/docs/v8.0/core/replica-set-elections/
- https://www.mongodb.com/docs/v8.0/reference/write-concern/

## Sharding and cloud deployment

Sharding divides records across multiple servers, while replication maintains copies of the same records. LearnNaija currently has only a small number of example event documents, so sharding is not necessary for this demonstration. If event volumes grow significantly, a suitable shard key would need to be selected based on actual data volume and query patterns.

A future cloud deployment could use a managed MongoDB service with authentication, encrypted connections, restricted network access and scheduled backups. Backups should also be tested through restoration exercises. Cloud hosting and managed database services have costs that would need to be assessed before implementation.

Replication does not replace backups, because accidental deletions can also be replicated. MongoDB replication would not automatically replicate PostgreSQL or synchronise the two databases. PostgreSQL would require its own availability and recovery strategy.

Reference: https://www.mongodb.com/docs/manual/sharding/

Additional reference: https://www.mongodb.com/docs/atlas/backup-restore-cluster/
