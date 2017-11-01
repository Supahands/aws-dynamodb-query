require 'test_helper'
require 'aws/dynamodb/query'

class Aws::Dynamodb::QueryTest < Minitest::Test
  include Aws::Dynamodb::Query

  def test_that_it_has_a_version_number
    refute_nil ::Aws::Dynamodb::Query::VERSION
  end

  def test_it_gets_dynamodb_token_invalid_response
    aws_access_key_id = 'AKIAJVB3LAMUASP5JTUQ'
    aws_secret_access_key = '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'
    aws_region = 'ap-southeast-1'
    aws_dynamodb_endpoint = 'http://dynamodb.ap-southeast-1.amazonaws.com'

    res = Query.call('my_table',
                     index_name: 'role-created_at-index',
                     select: 'ALL_ATTRIBUTES',
                     key_condition_expression: '#user_role = :user_role',
                     expression_attribute_names: { '#user_role' => 'role' },
                     expression_attribute_values: { ':user_role' => {'S' => 'ADMIN'} },
                     scan_index_forward: true,
                     return_consumed_capacity: 'TOTAL',
                     aws_access_key_id: aws_access_key_id,
                     aws_secret_access_key: aws_secret_access_key,
                     aws_region: aws_region,
                     aws_dynamodb_endpoint: aws_dynamodb_endpoint)
    refute_empty res[:errors]
    error = res[:errors][0]
    assert_equal  '400', error[:status]
    assert_equal  'Bad Request', error[:title]
    assert_match 'The security token included in the request is invalid.', error[:detail]
  end
end
