require "fetcher"

describe "Mixpanel Methods " do
  describe "all" do
    it "should raise exception if credential is invalid" do
      lambda { Fetcher::Mixpanel::All.new([]) }.should raise_error(ArgumentError)
      lambda { Fetcher::Mixpanel::All.new({}) }.should raise_error(ArgumentError)
    end
  end
end
