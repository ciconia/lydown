require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')

RSpec.describe Lydown do
  it "correctly translates continuo with full bar rests" do
    verify_example('use_cases/recitativo-continuo')
  end

  it "correctly translates continuo from BWV247/16" do
    verify_example('use_cases/recitativo-continuo-BWV247-16')
  end
end

RSpec.describe Lydown do
  it "correctly handles multiple parts with multiple keys" do
    verify_example('use_cases/multi-part-multi-key')
  end

  it "correctly handles duration macros with rests" do
    verify_example('use_cases/macros-with-rests')
  end

  it "correctly handles duration macros with commands" do
    verify_example('use_cases/macros-with-commands')
  end
  
  it "correctly handles duration macros with figures" do
    verify_example('use_cases/macros-with-figures')
  end

  it "correctly translates first note octave" do
    ld = Lydown::Translation.process(ripple: load_example('use_cases/gamba-translation.rpl'))
    expect(ld).to eq(load_example('use_cases/gamba-translation.ld'))
  end
end
