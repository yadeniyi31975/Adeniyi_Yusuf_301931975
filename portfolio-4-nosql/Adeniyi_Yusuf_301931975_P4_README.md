# LearnNaija – Portfolio 4: MongoDB Setup

## Project Overview
LearnNaija is a proposed network address management system for IPv4/IPv6 address planning and VLAN segmentation.

## MongoDB Setup
MongoDB Community Edition was installed in the Ubuntu GitHub Codespace.

The MongoDB server was started manually, and the connection was verified using MongoDB Shell (`mongosh`).

## Database Created
Database: `learnnaija_network`

## Collections
- sites
- networkSegments
- networkDevices
- addressPools
- addressAllocations

## Sample Record
A sample site record for LearnNaija Abuja HQ was inserted and retrieved successfully.

## Conclusion
The exercise demonstrated MongoDB installation, server startup, database creation, collection creation and document insertion.


## Document model

The LearnNaija MongoDB database contains a `network_events` collection. Each document represents one IPv4 or IPv6 address allocation activity.

The documents contain an event ID, event type, event date and time, site information, network segment information, allocation details and event-specific details.

The site, segment, allocation and details fields are embedded documents. This groups related network information within each event.

Two event types are modelled:

- `address_allocated`
- `address_released`

### Example document

```javascript
{
  _id: "E002",
  event_type: "address_released",
  occurred_at: ISODate("2026-11-06T12:00:00Z"),
  site: {
    site_name: "LearnNaija Port Harcourt PoP",
    location: "Port Harcourt"
  },
  segment: {
    segment_name: "Edge",
    vlan_id: 210
  },
  allocation: {
    address_family: "IPv6",
    network_prefix: "fd12:3456:789a:0300::/64",
    gateway_address: "fd12:3456:789a:0300::1"
  },
  details: {
    previous_status: "ACTIVE",
    new_status: "RELEASED",
    reason: "Address block released during network review"
  }
}
```

## Implementation and results

Four illustrative network event documents are inserted into the `network_events` collection using MongoDB Shell.

The implementation demonstrates:

1. Counting all network event documents.
2. Retrieving the chronological event history of the Port Harcourt IPv6 prefix.
3. Filtering documents using the nested field `details.new_status`.

Record the actual results returned by MongoDB after executing the commands.

## Why MongoDB fits

MongoDB is suitable for this example because network allocation activities can be represented as individual documents.

Embedding site, segment and allocation details keeps related information together within an event. Different event types can also store different details without requiring every document to contain identical fields.

A separate document for each activity allows the event history to grow over time.

## Limitations

These MongoDB records are illustrative examples entered separately from PostgreSQL. They are not automatically synchronised with the relational database.

The example does not enforce PostgreSQL foreign keys, validate address-prefix overlaps or provide a complete audit history.

## Files

- [MongoDB setup](Adeniyi_Yusuf_301931975_P4_Setup.md)
- [MongoDB JavaScript implementation](Adeniyi_Yusuf_301931975_P4_MongoDB.js)
- [MongoDB connection screenshot](screenshots/Adeniyi_Yusuf_301931975_P4_MongoDBConnection.png)
- [MongoDB events and queries screenshot](screenshots/Adeniyi_Yusuf_301931975_P4_EventsAndQueries.png)

## References

- [MongoDB Data Modelling](https://www.mongodb.com/docs/manual/data-modeling/)
- [MongoDB Insert Documents](https://www.mongodb.com/docs/manual/tutorial/insert-documents/)
- [MongoDB Query Embedded Documents](https://www.mongodb.com/docs/manual/tutorial/query-embedded-documents/)
