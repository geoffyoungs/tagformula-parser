# Tagformula::Parser

Match tag formulas with simple boolean operations against lists of strings.  e.g. the formula "foo & ! bar" would match ['foo'], but not ['foo', 'bar'] 

## Installation

Add this line to your application's Gemfile:

    gem 'tagformula'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tagformula

## Usage

Tagformula::Parser matches arrays of strings against formulas which require the presence or absence of strings in the array.  Conditions can be nested (in brackets), or negated (with a !) and can be 'and' ('&') or 'or' ('|') conditions.


    require 'tagformula/parser'

    formula = Tagformula::Parser.parse("alpha & beta")

    formula.matches?(%w[alpha beta])  # => true
    formula.matches?(%w[alpha gamma]) # => false

    formula = Tagformula::Parser.parse("alpha & (beta | gamma)")

    formula.matches?(%w[alpha beta])  # => true
    formula.matches?(%w[alpha gamma]) # => true

    formula = Tagformula::Parser.parse("alpha & !beta")

    formula.matches?(%w[alpha beta])  # => false
    formula.matches?(%w[alpha gamma]) # => true

Operators:

expr & expr   requires both expressions to be present
expr | expr   requires either expression to be present
expr1 & ! expr2 requires the expr1 to be present and expr2 to be absent.

Special words: 

"true" and "yes" will always match as true.   

"false" and "no" will always match as false.


## Contributing

1. Fork it ( http://github.com/geoffyoungs/tagformula/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
