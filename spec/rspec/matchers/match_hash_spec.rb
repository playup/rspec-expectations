require 'spec_helper'

module RSpec
  module Matchers

    def a_test(m, left, right)
      case m
        when "a matcher"         ; left.should =~                         right
        when "another matcher"   ; left.should be_hash_matching           right
        when "a partial matcher" ; left.should be_hash_partially_matching right
      end
    end

    ["a matcher", "another matcher", "a partial matcher"].each { |matcher_name|
      ["", " in ruby 1.8"].each { |context|
        shared_examples_for "#{matcher_name}#{context}" do
          desc = context == "a partial matcher" ? "partially " : ""
          it "passes if #{desc}matches" do
            a_test(matcher_name, actual, expected)
          end

          it "fails if doesn't #{desc}match" do
            lambda { a_test(matcher_name, failing, expected) }.should(
              if context == " in ruby 1.8"
                # Don't have ordered hashes in ruby 1.8 so can't guarantee what the failure message will look like..
                fail
              else
                fail_with(
                  if RSpec.configuration.color_enabled?
                    failure_message
                  else
                    # Have to modify the failure message if color is not enabled, and if its a regex
                    failure_message.is_a?(Regexp)? /.*/ : failure_message.gsub(/\e\[\d+m/, "")
                  end
                )

              end
            )
          end
        end
      }
    }


    describe "actual.should =~ expected, when expected hash" do

      context "has values of unmatching classes" do
        let(:expected        ) { { "a" => { "b" => 1 } } }
        let(:actual          ) { { "a" => { "b" => 1 } } }
        let(:failing         ) { { "a" => [ "b", 1   ] } }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"a\" => \e[31m- \e[1m{\"b\"=>1}\e[0m\e[32m+ \e[1m[\"b\", 1]\e[0m\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[32m+ \e[1m1 additional\e[0m"
        }

        it_should_behave_like "a matcher"
      end

      context "has a value that matches a Class" do
        let(:expected        ) { { "a" => { "b" => Fixnum  } } }
        let(:actual          ) { { "a" => { "b" => 3       } } }
        let(:failing         ) { { "a" => { "b" => '3'     } } }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"a\" => {\n\e[0m    \"b\" => \e[31m- \e[1mFixnum\e[0m\e[32m+ \e[1m\"3\"\e[0m\n\e[0m  }\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[32m+ \e[1m1 additional\e[0m"
        }

        it_should_behave_like "a matcher"
      end

      context "has two values that match a Class" do
        let(:expected        ) { { "a" => { "b" => Fixnum , "c" => Fixnum  } } }
        let(:actual          ) { { "a" => { "b" => 3      , "c" => 4       } } }
        let(:failing         ) { { "a" => { "b" => 3      , "c" => '4'     } } }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"a\" => {\n\e[0m    \"b\" => \e[34m: \e[1m3\e[0m,\n\e[0m    \"c\" => \e[31m- \e[1mFixnum\e[0m\e[32m+ \e[1m\"4\"\e[0m\n\e[0m  }\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[32m+ \e[1m1 additional\e[0m, \e[34m: \e[1m1 match_class\e[0m"
        }

        it_should_behave_like "a matcher"
      end

      context "has an array of items that match a Class" do
        let(:expected        ) { { "a" => { "b" => [ Fixnum , Fixnum ] } } }
        let(:actual          ) { { "a" => { "b" => [ 3      , 4      ] } } }
        let(:failing         ) { { "a" => { "b" => [ 3      , '4'    ] } } }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"a\" => {\n\e[0m    \"b\" => [\e[34m: \e[1m3\e[0m, \e[31m- \e[1mFixnum\e[0m\e[32m+ \e[1m\"4\"\e[0m]\n\e[0m  }\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[32m+ \e[1m1 additional\e[0m, \e[34m: \e[1m1 match_class\e[0m"
        }

        it_should_behave_like "a matcher"
      end

      context "has a value that is validated by a proc" do
        let(:expected        ) { { "a" => { "b" => lambda { |x| [FalseClass, TrueClass].include? x.class  } } } }
        let(:actual          ) { { "a" => { "b" => true                                                     } } }
        let(:failing         ) { { "a" => { "b" => 'true'                                                   } } }
        let(:failure_message ) {
          /#{Regexp.escape("\e[0m{\n\e[0m  \"a\" => {\n\e[0m    \"b\" => \e[31m- \e[1m#<Proc")}.*?#{Regexp.escape("\e[0m\e[32m+ \e[1m\"true\"\e[0m\n\e[0m  }\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[32m+ \e[1m1 additional\e[0m")}/
        }

        it_should_behave_like "a matcher"
      end

      context "has twos value that are validated by a class and a proc" do
        let(:expected        ) { { "a" => { "b" => Fixnum , "c" => lambda { |x| [FalseClass, TrueClass].include? x.class  } } } }
        let(:actual          ) { { "a" => { "b" => 3      , "c" => true                                                     } } }
        let(:failing         ) { { "a" => { "b" => '3'    , "c" => true                                                   } } }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"a\" => {\n\e[0m    \"c\" => \e[36m{ \e[1mtrue\e[0m,\n\e[0m    \"b\" => \e[31m- \e[1mFixnum\e[0m\e[32m+ \e[1m\"3\"\e[0m\n\e[0m  }\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[32m+ \e[1m1 additional\e[0m, \e[36m{ \e[1m1 match_proc\e[0m"
        }

        it_should_behave_like "a matcher"
      end

      context "has an array with missing items" do
        let(:expected        ) { { "a" => [1,2,3  ] } }
        let(:actual          ) { { "a" => [1,2, 3 ] } }
        let(:failing         ) { { "a" => [1,2    ] } }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"a\" => [1, 2, \e[31m- \e[1m3\e[0m]\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m"
        }

        it_should_behave_like "a matcher"
      end

      context "has an array with incorrect items" do
        let(:expected        ) { { "a" => [1,2,3] } }
        let(:actual          ) { { "a" => [1,2,3] } }
        let(:failing         ) { { "a" => [1,2,4] } }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"a\" => [1, 2, \e[31m- \e[1m3\e[0m\e[32m+ \e[1m4\e[0m]\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[32m+ \e[1m1 additional\e[0m"
        }

        it_should_behave_like "a matcher"
      end

      context "has an array with extra items" do
        let(:expected        ) { { "a" => [1,2,3  ] } }
        let(:actual          ) { { "a" => [1,2, 3 ] } }
        let(:failing         ) { { "a" => [1,2,3,4] } }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"a\" => [1, 2, 3, \e[32m+ \e[1m4\e[0m]\n\e[0m}\nWhere, \e[32m+ \e[1m1 additional\e[0m"
        }

        it_should_behave_like "a matcher"
      end

      context "has an array with a regex" do
        let(:expected        ) { { "a" => [1,2,/\d/ ] } }
        let(:actual          ) { { "a" => [1,2, 3   ] } }
        let(:failing         ) { { "a" => [1,2      ] } }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"a\" => [1, 2, \e[31m- \e[1m/\\d/\e[0m]\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m"
        }

        it_should_behave_like "a matcher"
      end

      context "is a hash with unexpected values" do
        let(:expected        ) { { "a" => "expected1", "b" => "expected2"} }
        let(:actual          ) { { "b" => "expected2", "a" => "expected1"} }
        let(:failing         ) { { "a" => "unexpected1", "b" => "expected2"} }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"b\" => \"expected2\",\n\e[0m  \"a\" => \e[31m- \e[1m\"expected1\"\e[0m\e[32m+ \e[1m\"unexpected1\"\e[0m\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[32m+ \e[1m1 additional\e[0m"
        }

        it_should_behave_like "a matcher"
      end

      context "is a hash with unexpected keys" do
        let(:expected        ) { { "expected1"   => "expected1"  , "expected2" => "expected2"} }
        let(:actual          ) { { "expected2"   => "expected2"  , "expected1" => "expected1"} }
        let(:failing         ) { { "unexpected1" => "unexpected1", "expected2" => "expected2"} }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"expected2\" => \"expected2\",\n\e[0m\e[31m- \e[1m\"expected1\" => \"expected1\"\e[0m,\n\e[0m\e[32m+ \e[1m\"unexpected1\" => \"unexpected1\"\e[0m\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[32m+ \e[1m1 additional\e[0m"
        }

        it_should_behave_like "a matcher"
      end

      context "has a hash" do
        let(:expected        ) { { "x" => {"a" => "ABC", "b" => "BBC"}} }
        let(:actual          ) { { "x" => {"b" => "BBC", "a" => "ABC"}} }
        let(:failing         ) { { "x" => {"a" => "DEF", "b" => "BBC"}} }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"x\" => {\n\e[0m    \"b\" => \"BBC\",\n\e[0m    \"a\" => \e[31m- \e[1m\"ABC\"\e[0m\e[32m+ \e[1m\"DEF\"\e[0m\n\e[0m  }\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[32m+ \e[1m1 additional\e[0m"  
        }

        it_should_behave_like "a matcher"
      end

      context "has a regex" do
        let(:expected        ) { {"a" => /[A-Z]{3}/ } }
        let(:actual          ) { {"a" => "ABC"      } }
        let(:failing         ) { {"a" => "abc"      } }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"a\" => \e[31m- \e[1m/[A-Z]{3}/\e[0m\e[32m+ \e[1m\"abc\"\e[0m\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[32m+ \e[1m1 additional\e[0m"
        }

        it_should_behave_like "a matcher"
      end

      context "has a hash with a regex" do
        let(:expected        ) { { "x" => { "a" => /[A-Z]{3}/ } } }
        let(:actual          ) { { "x" => {"a" => "ABC"       } } }
        let(:failing         ) { { "x" => {"a" => "abc"       } } }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"x\" => {\n\e[0m    \"a\" => \e[31m- \e[1m/[A-Z]{3}/\e[0m\e[32m+ \e[1m\"abc\"\e[0m\n\e[0m  }\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[32m+ \e[1m1 additional\e[0m"
        }

        it_should_behave_like "a matcher"
      end

      context "has multiple regexes" do
        let(:expected        ) { { "x" => {"a" => /[B-Z]/ , 'b' => /[A-Z]{3}/, 'c' => /^[A-Z]{3}$/ }} }
        let(:actual          ) { { "x" => {"a" => "ABC"   , "b" => "BBC"     , "c" => "CBC"        }} }
        let(:failing         ) { { "x" => {"a" => "ABC"   , "b" => "bbc"     , "c" => "CBC"        }} }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"x\" => {\n\e[0m    \"a\" => \e[33m~ \e[0mA\e[33m(\e[1mB\e[0m\e[33m)\e[0mC\e[0m,\n\e[0m    \"c\" => \e[33m~ \e[0m\e[33m(\e[1mCBC\e[0m\e[33m)\e[0m\e[0m,\n\e[0m    \"b\" => \e[31m- \e[1m/[A-Z]{3}/\e[0m\e[32m+ \e[1m\"bbc\"\e[0m\n\e[0m  }\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[32m+ \e[1m1 additional\e[0m, \e[33m~ \e[1m2 match_regex\e[0m"
        }

        it_should_behave_like "a matcher"
      end

      context "has lots of stuff" do
        let(:expected) {
          pat_datetime = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/
          {
            "href" => Regexp.compile("#{Regexp.quote '/api/goals/games/'}[0-9]+#{Regexp.quote '/matches/'}[0-9]+$"),
            "scheduled_start" => pat_datetime,
            "networks" => %w(abc nbc cnn),
            "expected_key" => "expected_value",
            "end_date" => pat_datetime,
            "home_team" => {
              "name" => String,
              "short_name" => lambda { |x| x.is_a?(String) and x.size == 3 },
              "link" => [{"href" => "http://puge.example.org/api/goals/teams/FLA/players", "rel" => "players"}],
              "href" => "http://puge.example.org/api/goals/teams/FLA"
            },
            "away_team" => {
              "name" => "sharks",
              "short_name" => "SHA",
              "link" => [{"href" => "http://puge.example.org/api/goals/teams/SHA/players", "rel" => "players"}],
              "href" => "http://puge.example.org/api/goals/teams/SHA"
            }
          }
        }
        let(:actual) {
          {
            "href" => "http://puge.example.org/api/goals/games/635/matches/832",
            "scheduled_start" => "2010-01-01T00:00:00Z",
            "networks" => %w(abc nbc cnn),
            "expected_key" => "expected_value",
            "end_date" => "2010-01-02T01:00:00Z",
            "home_team" => {
              "name" => "flames",
              "short_name" => "FLA",
              "link" => [{"href"=>"http://puge.example.org/api/goals/teams/FLA/players", "rel"=>"players"}],
              "href" => "http://puge.example.org/api/goals/teams/FLA",
            },
            "away_team" => {
              "name" => "sharks",
              "short_name" => "SHA",
              "href" => "http://puge.example.org/api/goals/teams/SHA",
              "link" => [{"href"=>"http://puge.example.org/api/goals/teams/SHA/players", "rel"=>"players"}]
            }
          }
        }
        let(:failing) {
          {
            "href" => "http://puge.example.org/api/goals/games/635/matches/832",
            "scheduled_start" => "2010-01-01T00:00:00Z",
            "networks" => ["abc", "cnn", "yyy", "zzz"],
            "unexpected_key" => "unexpected_value",
            "end_date" => "2010-01-01T01:00:00Z",
            "home_team" => {
              "name" => "flames",
              "short_name" => "FLA",
              "link" => [{"href" => "http://puge.example.org/api/goals/teams/FLA/players", "rel" => "players"}],
              "href" => "http://puge.example.org/api/goals/teams/FLA"
            },
            "away_team" => {
              "name" => "sharks",
              "short_name" => "unexpected2",
              "link" => [{"href" => "http://puge.example.org/api/goals/teams/SHA/players", "rel" => "players"}],
              "href" => "http://puge.example.org/api/goals/teams/SHA"
            }
          }
        }

        let(:failure_message) {
          "\e[0m{\n\e[0m  \"href\" => \e[33m~ \e[0mhttp://puge.example.org\e[33m(\e[1m/api/goals/games/635/matches/832\e[0m\e[33m)\e[0m\e[0m,\n\e[0m  \"scheduled_start\" => \e[33m~ \e[0m\e[33m(\e[1m2010-01-01T00:00:00Z\e[0m\e[33m)\e[0m\e[0m,\n\e[0m  \"end_date\" => \e[33m~ \e[0m\e[33m(\e[1m2010-01-01T01:00:00Z\e[0m\e[33m)\e[0m\e[0m,\n\e[0m  \"home_team\" => {\n\e[0m    \"name\" => \e[34m: \e[1m\"flames\"\e[0m,\n\e[0m    \"short_name\" => \e[36m{ \e[1m\"FLA\"\e[0m,\n\e[0m    \"link\" => [{\n\e[0m      \"href\" => \"http://puge.example.org/api/goals/teams/FLA/players\",\n\e[0m      \"rel\" => \"players\"\n\e[0m    }\n\e[0m    ],\n\e[0m    \"href\" => \"http://puge.example.org/api/goals/teams/FLA\"\n\e[0m  },\n\e[0m  \"networks\" => [\"abc\", \e[31m- \e[1m\"nbc\"\e[0m\e[32m+ \e[1m\"cnn\"\e[0m, \e[31m- \e[1m\"cnn\"\e[0m\e[32m+ \e[1m\"yyy\"\e[0m, \e[32m+ \e[1m\"zzz\"\e[0m],\n\e[0m  \"away_team\" => {\n\e[0m    \"name\" => \"sharks\",\n\e[0m    \"link\" => [{\n\e[0m      \"href\" => \"http://puge.example.org/api/goals/teams/SHA/players\",\n\e[0m      \"rel\" => \"players\"\n\e[0m    }\n\e[0m    ],\n\e[0m    \"href\" => \"http://puge.example.org/api/goals/teams/SHA\",\n\e[0m    \"short_name\" => \e[31m- \e[1m\"SHA\"\e[0m\e[32m+ \e[1m\"unexpected2\"\e[0m\n\e[0m  },\n\e[0m\e[31m- \e[1m\"expected_key\" => \"expected_value\"\e[0m,\n\e[0m\e[32m+ \e[1m\"unexpected_key\" => \"unexpected_value\"\e[0m\n\e[0m}\nWhere, \e[31m- \e[1m4 missing\e[0m, \e[32m+ \e[1m5 additional\e[0m, \e[33m~ \e[1m3 match_regex\e[0m, \e[34m: \e[1m1 match_class\e[0m, \e[36m{ \e[1m1 match_proc\e[0m"
        }

        it_should_behave_like "a matcher#{' in ruby 1.8' if RUBY_VERSION.to_f == 1.8}"
      end
    end


    describe "actual.should be_hash_matching(expected)" do

      context "has an array with missing items" do
        let(:expected        ) { { "a" => [1,2,3  ] } }
        let(:actual          ) { { "a" => [1,2, 3 ] } }
        let(:failing         ) { { "a" => [1,2    ] } }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"a\" => [1, 2, \e[31m- \e[1m3\e[0m]\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m" 
        }

        it_should_behave_like "another matcher"
      end
    end

    describe "actual.should be_hash_partially_matching(expected)" do

      context "contains a hash with missing items" do
        let(:expected        ) { { "x" => { "a" => [1,2,3]                       } } }
        let(:actual          ) { { "x" => { "a" => [1,2,3] , "b" => "unexpected" } } }
        let(:failing         ) { { "x" => { "a" => [1,2  ] , "b" => "unexpected" } } }
        let(:failure_message) { 
          "\e[0m{\n\e[0m  \"x\" => {\n\e[0m    \"a\" => [1, 2, \e[31m- \e[1m3\e[0m],\n\e[0m  \e[32m+ \e[1m\"b\" => \"unexpected\"\e[0m\n\e[0m  }\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[32m+ \e[1m1 additional\e[0m"
        }

        it_should_behave_like "a partial matcher"
      end

      context "is a hash inside the expected" do
        let(:expected        ) { { "a" => { "b" => { "c" => 1 } } } }
        let(:actual          ) { { "a" => { "b" => { "c" => 1 } } } }
        let(:failing         ) {          { "b" => { "c" => 1 } }   }
        let(:failure_message) { 
          "\e[0m{\n\e[0m\e[31m- \e[1m\"a\" => {\"b\"=>{\"c\"=>1}}\e[0m,\n\e[0m\e[32m+ \e[1m\"b\" => {\"c\"=>1}\e[0m\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[32m+ \e[1m1 additional\e[0m"
        }

        it_should_behave_like "a partial matcher"
      end

      context "has lots of stuff" do
        let(:expected) {
          {
            "home_team" => {
              "name" => "flames",
              "short_name" => /^[A-Z]{3}$/
            }
          }
        }
        let(:actual) {
          {
            "href" => "http://puge.example.org/api/goals/games/635/matches/832",
            "scheduled_start" => "2010-01-01T00:00:00Z",
            "end_date" => "2010-01-02T01:00:00Z",
            "home_team" => {
              "name" => "flames",
              "short_name" => "FLA",
              "href" => "http://puge.example.org/api/goals/teams/FLA"
            },
            "away_team" => {
              "name" => "sharks",
              "short_name" => "SHA",
              "href" => "http://puge.example.org/api/goals/teams/SHA"
            }
          }
        }
        let(:failing) {
          {
            "href" => "http://puge.example.org/api/goals/games/635/matches/832",
            "scheduled_start" => "2010-01-01T00:00:00Z",
            "end_date" => "2010-01-01T01:00:00Z",
            "home_team" => {
              "name" => "unexpected1",
              "short_name" => "FLA",
              "href" => "http://puge.example.org/api/goals/teams/FLA"
            },
            "away_team" => {
              "name" => "sharks",
              "short_name" => "unexpected2",
              "href" => "http://puge.example.org/api/goals/teams/SHA"
            }
          }
        }
        let(:failure_message) {
          "\e[0m{\n\e[0m  \"home_team\" => {\n\e[0m    \"short_name\" => \e[33m~ \e[0m\e[33m(\e[1mFLA\e[0m\e[33m)\e[0m\e[0m,\n\e[0m    \"name\" => \e[31m- \e[1m\"flames\"\e[0m\e[32m+ \e[1m\"unexpected1\"\e[0m,\n\e[0m  \e[32m+ \e[1m\"href\" => \"http://puge.example.org/api/goals/teams/FLA\"\e[0m\n\e[0m  },\n\e[0m\e[32m+ \e[1m\"href\" => \"http://puge.example.org/api/goals/games/635/matches/832\"\e[0m,\n\e[0m\e[32m+ \e[1m\"scheduled_start\" => \"2010-01-01T00:00:00Z\"\e[0m,\n\e[0m\e[32m+ \e[1m\"end_date\" => \"2010-01-01T01:00:00Z\"\e[0m,\n\e[0m\e[32m+ \e[1m\"away_team\" => {\"name\"=>\"sharks\", \"short_name\"=>\"unexpected2\", \"href\"=>\"http://puge.example.org/api/goals/teams/SHA\"}\e[0m\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[32m+ \e[1m6 additional\e[0m, \e[33m~ \e[1m1 match_regex\e[0m"
        }

        it_should_behave_like "a partial matcher#{' in ruby 1.8' if RUBY_VERSION.to_f == 1.8}"
      end

      context "has a hash with a nil" do
        let(:expected        ) { { "a" => /[A-Z]/, "b" => /\d+/} }
        let(:actual          ) { { "a" => "ABC"  , "b" => 1    } }
        let(:failing         ) { { "a" => "ABC"  , "b" => nil  } }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"a\" => \e[33m~ \e[0m\e[33m(\e[1mA\e[0m\e[33m)\e[0mBC\e[0m,\n\e[0m  \"b\" => \e[31m- \e[1m/\\d+/\e[0m\e[32m+ \e[1mnil\e[0m\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[32m+ \e[1m1 additional\e[0m, \e[33m~ \e[1m1 match_regex\e[0m"
        }

        it_should_behave_like "a partial matcher"
      end

      context "has a hash with a missing regexed key" do
        let(:expected        ) { { "a" => /[A-Z]/, "b" => /\d+/} }
        let(:actual          ) { { "a" => "ABC"  , "b" => 1    } }
        let(:failing         ) { { "a" => "ABC"                } }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"a\" => \e[33m~ \e[0m\e[33m(\e[1mA\e[0m\e[33m)\e[0mBC\e[0m,\n\e[0m\e[31m- \e[1m\"b\" => /\\d+/\e[0m\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[33m~ \e[1m1 match_regex\e[0m"
        }

        it_should_behave_like "a partial matcher"
      end

      context "has an array of hashes, where the hash in the array has extra values" do
        let(:expected        ) { { "a" => [ { "b" => 1           }, { "d" => 3 } ] } }
        let(:actual          ) { { "a" => [ { "b" => 1, "c" => 2 }, { "d" => 3 } ] } }
        let(:failing         ) { { "a" => [ { "b" => 2, "c" => 2 }, { "d" => 3 } ] } }
        let(:failure_message ) {
          "\e[0m{\n\e[0m  \"a\" => [{\n\e[0m    \"b\" => \e[31m- \e[1m1\e[0m\e[32m+ \e[1m2\e[0m,\n\e[0m  \e[32m+ \e[1m\"c\" => 2\e[0m\n\e[0m  }\n\e[0m  , {\n\e[0m    \"d\" => 3\n\e[0m  }\n\e[0m  ]\n\e[0m}\nWhere, \e[31m- \e[1m1 missing\e[0m, \e[32m+ \e[1m2 additional\e[0m"
        }

        it_should_behave_like "a partial matcher"
      end
    end

  end
end
