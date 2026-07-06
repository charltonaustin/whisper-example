# Pub/Sub Example

A small Rails 8 app demonstrating the [wisper](https://github.com/krisleech/wisper)
publish/subscribe gem: a publisher broadcasting domain events, subscribers
reacting synchronously and asynchronously (via ActiveJob), and a DB-backed
registry that lets you add/remove subscribers **without restarting the app**.

## Setup

Requires Ruby 3.4.8 (see `.ruby-version`).

```
bundle install
bin/rails db:setup   # creates the DB, runs migrations, loads db/seeds.rb
```

`db/seeds.rb` registers the initial subscribers (see below) — re-run
`bin/rails db:seed` any time, it's idempotent.

## Running the app

```
bin/rails server
```

Visit `http://localhost:3000` (redirects to `/orders/new`).

## How the pub/sub example works

- `OrderCreator` (`app/models/order_creator.rb`) is the **publisher**. It
  includes `Wisper::Publisher` and broadcasts `:order_created` or
  `:order_creation_failed` after trying to save an `Order`.
- `OrderNotifier` and `OrderBilling` (`app/listeners/`) are **subscribers** —
  plain Ruby objects with methods matching the event names.
- `OrdersController#create` (`app/controllers/orders_controller.rb`) just
  calls `OrderCreator.new.create(order_params)` — the publisher subscribes
  its own listeners from the DB registry (see below).

### Try it

1. Go to `/orders/new` and submit the form.
2. Watch the server log (or `log/development.log`) — you'll see lines like:

   ```
   [OrderBilling] Charging Ada Lovelace 5000 cents for order #1
   [ActiveJob] Enqueued WisperEventJob ... "OrderNotifier", "order_created", ...
   [OrderNotifier] Order #1 placed by Ada Lovelace for 5000 cents
   ```

   `OrderBilling` runs synchronously, inline with the request.
   `OrderNotifier` is subscribed with `async: true`, so it's enqueued as an
   `ActiveJob` (`app/jobs/wisper_event_job.rb`) and runs on a background
   thread via the default `:async` queue adapter — no extra setup needed in
   development.
3. Submit the form with a blank customer name or a total of `0` to see the
   `:order_creation_failed` event broadcast instead.

## Adding/removing subscribers live, without restarting the server

Subscribers aren't hardcoded — `OrderCreator#initialize` reads active rows
from the `subscriptions` table (see `app/models/subscription.rb`) and
subscribes each listener fresh on every request. That means you can toggle
who's listening while the server keeps running, with no redeploy.

Go to `http://localhost:3000/subscriptions` to see the current subscriptions
and:

- **Add a new one** — the app ships a third listener, `OrderAuditLog`
  (`app/listeners/order_audit_log.rb`), that isn't seeded and stays dormant
  until you register it. Fill in the form with:
    - Publisher class name: `OrderCreator`
    - Listener class name: `OrderAuditLog`
    - Async: unchecked
    - Active: checked

  Submit, then place another order at `/orders/new` — you'll immediately see
  `[OrderAuditLog] AUDIT: ...` in the log, with no restart.
- **Deactivate one** — click "Deactivate" next to `OrderBilling` (or any
  row), then place another order — that listener stops firing on the very
  next request.

## Key files

| File                                          | Role                                                              |
|-----------------------------------------------|-------------------------------------------------------------------|
| `app/models/order_creator.rb`                 | Publisher; auto-subscribes from the `Subscription` registry       |
| `app/models/subscription.rb`                  | DB-backed record of which listeners are active per publisher      |
| `app/listeners/order_notifier.rb`             | Async subscriber (logs a confirmation message)                    |
| `app/listeners/order_billing.rb`              | Sync subscriber (logs a "charge" message)                         |
| `app/listeners/order_audit_log.rb`            | Dormant subscriber, enable it via `/subscriptions`                |
| `app/broadcasters/active_job_broadcaster.rb`  | Custom Wisper broadcaster that hands events to ActiveJob          |
| `app/jobs/wisper_event_job.rb`                | Job that resolves the listener class and invokes the event method |
| `config/initializers/wisper.rb`               | Registers the async broadcaster                                   |
| `app/controllers/orders_controller.rb`        | Publishes `order_created`/`order_creation_failed`                 |
| `app/controllers/subscriptions_controller.rb` | Minimal (no-auth) UI to add/toggle subscriptions live             |
