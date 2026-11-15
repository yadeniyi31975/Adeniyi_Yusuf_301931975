### Two Database Sessions and Concurrency Testing

This exercise tested how PostgreSQL handles two administrators attempting to register the same network device at the same site at the same time.

The test used the `network_device` table and the unique constraint on `(site_id, device_name)`.

- Session A started a transaction and inserted `Router-ABJ-CONCURRENCY-TEST` at LearnNaija Abuja HQ.
- Session B attempted to insert the same device while Session A's transaction was still open.
- Session B waited because PostgreSQL was checking the conflicting uncommitted insertion.
- Session A committed its transaction.
- Session B then received a duplicate-key error because the device had already been registered.
- Session B rolled back its failed transaction.

**Conclusion:** The exercise demonstrated how PostgreSQL transactions and unique constraints help maintain data integrity when multiple administrators attempt conflicting database operations concurrently.