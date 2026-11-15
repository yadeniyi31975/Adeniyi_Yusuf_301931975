
# LearnNaija MongoDB Setup

MongoDB 8.0.34 runs in the existing Ubuntu GitHub Codespace alongside PostgreSQL.

The MongoDB server uses `/workspaces/mongodb-data` as its data directory. This folder is located outside the LearnNaija GitHub repository to keep database files separate from project files.

MongoDB is configured to accept local connections through `127.0.0.1` on port `27017`. The server is started manually because the Codespace environment does not use systemd as its main service manager.

## Start and Connect

The following commands are used to start the MongoDB server and connect to it using MongoDB Shell (`mongosh`).

```bash
mkdir -p /workspaces/mongodb-data

mongod --dbpath /workspaces/mongodb-data --logpath /workspaces/mongodb-data/mongod.log --logappend --bind_ip 127.0.0.1 --fork

mongosh "mongodb://127.0.0.1:27017"
```

## Connection Verification

The MongoDB connection is checked using the following commands inside MongoDB Shell:

```javascript
db.version()

db.runCommand({ ping: 1 })
```

The `db.version()` command returns MongoDB version `8.0.34`.

The `db.runCommand({ ping: 1 })` command returns `{ ok: 1 }`, confirming that the MongoDB server is responding successfully.

## Evidence

The screenshot below provides evidence of the MongoDB connection and verification.

![LearnNaija MongoDB Connection](screenshots/Adeniyi_Yusuf_301931975_P4_MongoDBConnection.png)

## Reference

[MongoDB Ubuntu Installation Guide](https://www.mongodb.com/docs/v8.0/tutorial/install-mongodb-on-ubuntu/)
