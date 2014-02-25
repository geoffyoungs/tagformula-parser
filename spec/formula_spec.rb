$: << File.dirname(__FILE__)+'/../lib'
require 'tagformula/parser'

describe Tagformula::Parser do
  describe '#parse' do

    it "parses simple formulas" do
      formula = Tagformula::Parser.parse("alpha & beta")
      expect(formula.required_tags).to include('alpha', 'beta')
      expect(formula.required_tags).not_to include('gamma')
      expect(formula.matches?(['alpha'])).to be_false
      expect(formula.matches?(['alpha', 'beta'])).to be_true
    end

    it "parses more negated tag formulas" do
      formula = Tagformula::Parser.parse("alpha & ! beta")
      expect(formula.required_tags).to include('alpha')
      expect(formula.required_tags).not_to include('beta')
      expect(formula.matches?(['alpha', 'beta'])).to be_false
      expect(formula.matches?(['alpha'])).to be_true
    end

    it "fails on invalid formulas" do
      # Unclosed bracket
      expect { Tagformula::Parser.parse("(alpha & beta")  }.to raise_error
      # Missing operator
      expect { Tagformula::Parser.parse("alpha & beta gamma")  }.to raise_error
      # Empty group
      expect { Tagformula::Parser.parse("() & alpha & beta")  }.to raise_error
    end

    it "parses tags with periods" do
      formula = Tagformula::Parser.parse("alpha.beta | gamma.delta")
      expect(formula.required_tags).to include('alpha.beta')
      expect(formula.matches?(['alpha.beta'])).to be_true
      expect(formula.matches?(['epsilon'])).to be_false
    end
  end
end
