# treasure_hunt_tracker

```bash
bundle install
foreman start
```

To reset the DB:

```bash
rails db:drop
rails db:prepare
rails solid_queue:install
rails db:migrate
```

### UI

http://localhost:5000/progress

### Job Admin

http://localhost:5000/jobs
