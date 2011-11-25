Feature: be_matching matcher

  Scenario: basic usage
    Given a file named "be_matching_matcher_spec.rb" with:
      """
      describe "hash matcher" do
        subject { { :a=>1, :b=>2, :c=>'3', :d=>4, :e=>"additional stuff" } }
        let(:expected) { { :a=>1, :b=>Fixnum, :c=>/[0-9]/, :d=>lambda { |x| (3..5).include?(x) } } }

        it { should be_matching(expected, :ignore_additional=>true) }
        it { should be_matching(expected) }

        # deliberate failures
        it { should_not be_matching(expected) }
      end
      """
    When I run `rspec be_matching_matcher_spec.rb`
    Then the output should contain:
      """
      Failures:

        1) hash matcher 
           Failure/Error: it { should be_matching(expected) }
             {
               :a=>1,
               :b=>: 2,
               :c=>~ (3),
               :d=>{ 4,
             + :e=>"additional stuff"
             }
             Where, + 1 additional, ~ 1 match_regexp, : 1 match_class, { 1 match_proc
      """
    Then the output should contain "3 examples, 1 failure"
