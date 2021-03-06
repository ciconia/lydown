require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')
require 'fileutils'
require File.expand_path('../lib/lydown/cli', File.dirname(__FILE__))

RSpec.describe Lydown::Translation do
  it "translates simple ripple code to lydown" do
    ld = Lydown::Translation.process(ripple: load_example('translation_simple.rpl'))
    expect(ld.strip_whitespace).to eq(load_example('translation_simple.ld').strip_whitespace)
  end

  it "translates named macros" do
    ld = Lydown::Translation.process(
      ripple: load_example('translation_macros.rpl'),
      macros: {
        'm1' => '#6. #3', 
        'm5' => '#4 ~ @6. #3 #6. #3',
        'm6' => 'r6 # #6. #3 #8 r'
      }
    )
    expect(ld).to eq(load_example('translation_macros.ld'))
  end

  after(:example) do
    FileUtils.rm Dir.glob('spec/examples/translate/mvmt1/*.ld') rescue nil
  end

  it "translates a complete directory of ripple files" do
    ld = Lydown::CLI::Translation.process(
      path: File.join('spec/examples/translate')
    )
    
    basso = IO.read('spec/examples/translate/mvmt1/basso.ld')
    violino1 = IO.read('spec/examples/translate/mvmt1/violino1.ld')
    expect(basso.strip).to eq(load_example('translation_simple.ld').strip)
    expect(violino1.strip).to eq(load_example('translation_macros.ld').strip)
  end
end