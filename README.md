# [Turtle](https://github.com/petlove/turtle)
[![Build Status](https://travis-ci.org/petlove/turtle.svg?branch=master)](https://travis-ci.org/petlove/turtle)
[![Maintainability](https://api.codeclimate.com/v1/badges/66a7166187c323835430/maintainability)](https://codeclimate.com/github/petlove/turtle/maintainability)
[![Maintainability](https://api.codeclimate.com/v1/badges/66a7166187c323835430/maintainability)](https://codeclimate.com/github/petlove/turtle/maintainability)

A helper to use workers and topics with Ruby on Rails

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'turtle', github: 'petlove/turtle'
```

## Usage

### Queues with priority for shoryuken
```ruby
Turtle.shoryuken_queues_priorities
# => [["macaw_linquetab_enqueue_triggered_send_credit_earned", 2],
#  ["macaw_linquetab_enqueue_triggered_send_question_answer", 2],
#  ["macaw_linquetab_enqueue_triggered_send_product_back_in_stock", 2],
#  ["macaw_linquetab_perform_order_events", 3],
#  ["macaw_linquetab_perform_order_payment_pending_events", 3],
#  ["macaw_linquetab_perform_shipment_events", 3],
#  ["macaw_linquetab_update_data_extension_reviews", 1],
#  ["macaw_linquetab_update_data_extension_products", 1],
#  ["macaw_linquetab_update_data_extension_animal_pets", 1],
#  ["macaw_linquetab_update_data_extension_orders_carts", 1],
#  ["macaw_linquetab_update_data_extension_customers", 1],
#  ["macaw_linquetab_update_data_extension_customer_coupons", 1],
#  ["macaw_linquetab_update_list_subscribers", 1],
#  ["macaw_linquetab_perform_subscription_events", 3],
#  ["macaw_linquetab_update_data_extension_subscriptions", 1]]

# Filter by queue metadata fields
Turtle.shoryuken_queues_priorities(priority: 3)
# => [["macaw_linquetab_perform_order_events", 3],
#  ["macaw_linquetab_perform_order_payment_pending_events", 3],
#  ["macaw_linquetab_perform_shipment_events", 3],
#  ["macaw_linquetab_perform_subscription_events", 3]]
```

### Setting DelayedJob
You should follow this steps:
1. Add `gem 'delayed_job_active_record'` in your Gemfile
2. Run `rails generate delayed_job:active_record`
3. Run `rails db:migrate`
4. Set in the file _config/application.rb_ this code:
```ruby
config.active_job.queue_adapter = :delayed_job
```
5. Set the file _config/initializers/delayed_job.rb_ with this code:
```ruby
Delayed::Worker.queue_attributes = Turtle.delayed_job_queue_attributes
```
6. Set the supervisor to run DelayedJob with this code:
```bash
[program:delayed_job]
command=bundle exec rake jobs:work
user = root
autostart=true
autorestart=true
redirect_stderr=false
```

See more about DelayedJob [here](https://github.com/collectiveidea/delayed_job).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).