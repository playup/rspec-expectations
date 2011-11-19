Feature: be_json_matching matcher

  Scenario: basic usage
    Given a file named "be_json_matching_matcher_spec.rb" with:
      """
      describe '{ "x": { "a": "ABC" } }' do
        it { should be_json_matching({ 'x'=>{'a'=>/[A-Z]{3}/ } }) }
      end

      describe '{ "x": { "a": "123" } }' do
        it { should be_json_matching({ 'x'=>{'a'=>/[A-Z]{3}/ } }) }

        # deliberate failures
        it { should_not be_json_matching({ 'x'=>{'a'=>/[A-Z]{3}/ } }) }
      end
      """
    When I run `rspec be_json_matching_matcher_spec.rb`
    Then the output should contain:
    """
    Failures:

      1) { "x": { "a": "123" } } 
         Failure/Error: it { should be_json_matching({ 'x'=>{'a'=>/[A-Z]{3}/ } }) }
           {
             "x"=>{
               "a"=>- /[A-Z]{3}/+ "123"
             }
           }
           Where, - 1 missing, + 1 additional
    """
    And the output should contain "3 examples, 1 failure"
