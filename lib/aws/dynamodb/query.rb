require 'aws/dynamodb/query/version'
require 'aws/signature/v4'

module Aws
  module Dynamodb
    module Query
      class Query
        # Your code goes here...

        # Queries Dynamodb for items.
        # @see http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Query.html
        #
        # @param  [String]  table_name  The name of the table containing the requested items.
        # @param  [String]  index_name  The name of an index to query
        # @param  [String]  select  The attributes to be returned in the result: ALL_ATTRIBUTES, ALL_PROJECTED_ATTRIBUTES, COUNT, SPECIFIC_ATTRIBUTES
        # @param  [String]  key_condition_expression  The condition that specifies the key value(s) for items to be retrieved by the Query action
        # @param  [Hash]    expression_attribute_names  One or more substitution tokens for attribute names in an expression
        # @param  [Hash]    expression_attribute_values One or more values that can be substituted in an expression
        # @param  [String]  scan_index_forward  Specifies the order for index traversal: If true (default), the traversal is performed in ascending order; if false, the traversal is performed in descending order
        # @param  [String]  return_consumed_capacity  Determines the level of detail about provisioned throughput consumption that is returned in the response: INDEXES, TOTAL, NONE
        # @param  [Boolean] pagination  true by default. This will get maximum 1MB of data. To retrieve all your table data which could exceed 1MB, set pagination to false.
        # @param  [String]  last_evaluated_key  if pagination is true, this will point to the next page of data to retrieve
        # @param  [String]  aws_region  AWS region is obtained by default from ENV['AWS_REGION'], use this parameter to override with your own
        # @param  [String]  aws_access_key_id AWS access key id is obtained by default from ENV['AWS_ACCESS_KEY_ID'], use this parameter to override with your own
        # @param  [String]  aws_secret_access_key AWS secret access key is obtained by default from ENV['AWS_SECRET_ACCESS_KEY'], use this parameter to override with your own
        # @param  [String]  aws_dynamodb_endpoint AWS dynamodb endpoint is obtained by default from ENV['aws_dynamodb_endpoint'], use this parameter to override with your own
        #
        # @return [Array] array of Ruby Hash objects where each object contains all the values returned from dynamodb in dasherized format
        def self.call(table_name, index_name: nil, select: nil, key_condition_expression: nil, expression_attribute_names: nil, expression_attribute_values: nil, scan_index_forward: true, return_consumed_capacity: nil, pagination: false, last_evaluated_key: nil, aws_region: ENV['AWS_REGION'], aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'], aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], aws_dynamodb_endpoint: ENV['aws_dynamodb_endpoint'])
          result = []
          # DyanmoDB Query results are divided into "pages" of data that are 1 MB in size (or less).
          # Agents data exceeds 1MB so we need multiple pages.
          # @see http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Query.html#Query.Pagination
          last_evaluated_key = last_evaluated_key
          loop do
            payload = {
              TableName: table_name
            }
            # optional query parameters
            payload[:IndexName]                 = index_name if index_name
            payload[:select]                    = select if select
            payload[:KeyConditionExpression]    = key_condition_expression if key_condition_expression
            payload[:ExpressionAttributeNames]  = expression_attribute_names if expression_attribute_names
            payload[:ExpressionAttributeValues] = expression_attribute_values if expression_attribute_values
            payload[:scan_index_forward]        = scan_index_forward if scan_index_forward
            payload[:ReturnConsumedCapacity]    = return_consumed_capacity if return_consumed_capacity
            payload[:ExclusiveStartKey]         = last_evaluated_key if last_evaluated_key

            # generate AWS Authorization header
            aws_signature = Aws::Signature::V4::Signature.new(aws_region, aws_access_key_id, aws_secret_access_key)
            aws_signature.generate_signature('dynamodb', 'DynamoDB_20120810.Query', 'POST', payload, aws_dynamodb_endpoint, '/')
            # Create the HTTP objects
            uri = URI.parse(aws_dynamodb_endpoint)
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = aws_dynamodb_endpoint.include?('https')
            request = Net::HTTP::Post.new(uri.request_uri, aws_signature.headers)
            request.body = payload.to_json
            res = http.request(request)

            # error => return empty array
            unless res.is_a? Net::HTTPSuccess
              Rails.logger.error "Error querying DynamoDB: code=#{res.code} message=#{res.message} body=#{res.body}" if defined? Rails

              # jsonapi error format
              result = {
                errors: [
                  status: res.code,
                  title:  res.message,
                  detail: res.body
                ]
              }
              return result
            end

            # success => parse returned json
            json = Yajl::Parser.new.parse(res.body)

            # extract and construct resultset array
            json['Items'].each do |item|
              record = {}
              stored_attributes = []
              item.keys.each do |key|
                # @see: http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_AttributeValue.html
                # Sample dynamodb item: {"date_joined"=>{"S"=>"2017-09-30T16:00:00+00:00"}, "contact_country_code"=>{"NULL"=>true}, "full_name"=>{"S"=>"Breena"}, "has_bank_swift"=>{"BOOL"=>false}}
                dynamodb_data_types = %w[S BOOL BS L M N NS NULL S SS]
                # value could be found in one of these data types
                key_dasherized = key.to_s.dasherize
                dynamodb_data_types.each do |data_type|
                  record[key_dasherized] = record[key_dasherized] || item[key][data_type]
                end
                stored_attributes += [key.to_sym]
              end

              # nullify remaining model attributes to be included in returned result
              unset_attributes = Agent.attribute_keys - stored_attributes
              unset_attributes.each do |attr|
                record[attr.to_s.dasherize] = nil
              end

              result << record
            end

            # LastEvaluatedKey in the response indicates that not all of the items have been retrieved.
            # It should be used as the ExclusiveStartKey for the next Query request to retrieve the next page items.
            last_evaluated_key = json['LastEvaluatedKey']
            # Break if pagination is enabled. Else, absence of LastEvaluatedKey indicates that there are no more pages to retrieve.
            break if pagination.present? || last_evaluated_key.blank?
          end
          result
        end
      end
    end
  end
end
