# Aws::Dynamodb::Query

Executes low level API DynamoDB Query (http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Query.html#DDB-Query-request-KeyConditionExpression) with less memory footprint.

The following query options are currently supported:
1. index_name
2. select
3. key_condition_expression
4. expression_attribute_names
5. expression_attribute_values
6. scan_index_forward
7. return_consumed_capacity
8. aws_access_key_id
9. aws_secret_access_key
10. aws_region
11. aws_dynamodb_endpoint

Support for more Query options will be added in future releases. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aws-dynamodb-query'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aws-dynamodb-query

## Usage

```ruby
include Aws::Dynamodb::Query

aws_access_key_id = 'AKIAJVB3LAMUASP5JTUQ'
aws_secret_access_key = 'cD4kSv9XDZgFhb2Bps/63h4+oMPudnpRt4GDS9Rr'
aws_region = 'ap-southeast-1'
aws_dynamodb_endpoint = 'http://dynamodb.ap-southeast-1.amazonaws.com'

res = Query.call('my_table',
                 index_name: 'role-created_at-index',
                 select: 'ALL_ATTRIBUTES',
                 key_condition_expression: '#profile_role = :profile_role',
                 expression_attribute_names: { '#profile_role' => 'role' },
                 expression_attribute_values: { ':profile_role' => { 'S' => 'ADMIN' } },
                 scan_index_forward: true,
                 return_consumed_capacity: 'TOTAL',
                 aws_access_key_id: aws_access_key_id,
                 aws_secret_access_key: aws_secret_access_key,
                 aws_region: aws_region,
                 aws_dynamodb_endpoint: aws_dynamodb_endpoint)
```    

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/khaled83/aws-dynamodb-query. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

