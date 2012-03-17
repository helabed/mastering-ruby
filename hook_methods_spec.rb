describe 'ruby hook methods' do
  context "- method related hooks: " do
    context "method_missing" do
      it "should do method_missing" do
        pending("not done yet")
      end
    end
    context "method_added" do
      it "should do method_added" do
        pending("not done yet")
      end
    end
    context "singleton_method_added" do
      it "should do singleton_method_added" do
        pending("not done yet")
      end
    end
    context "method_removed" do
      it "should do method_removed" do
        pending("not done yet")
      end
    end
    context "singleton_method_removed" do
      it "should do singleton_method_removed" do
        pending("not done yet")
      end
    end
    context "method_undefined" do
      it "should do method_undefined" do
        pending("not done yet")
      end
    end
    context "singleton_method_undefined" do
      it "should do singleton_method_undefined" do
        pending("not done yet")
      end
    end

  end




  context "- for Classes and Modules: " do
    context "inherited" do
      it "should do inherited" do
        pending("not done yet")
      end
    end
    context "append_features" do
      it "should do append_features" do
        pending("not done yet")
      end
    end
    context "included" do
      it "should do included" do
        pending("not done yet")
      end
    end
    context "extend_object" do
      it "should do extend_object" do
        pending("not done yet")
      end
    end
    context "extended" do
      it "should do extended" do
        pending("not done yet")
      end
    end
    context "initialize_copy" do
      it "should do initialize_copy" do
        pending("not done yet")
      end
    end
    context "const_missing" do
      it "should do const_missing" do
        pending("not done yet")
      end
    end
  end








  context '- example of including comparable' do
    class SomeClass
      include Comparable

      def <=>(other)
        -1
      end
    end
    it "should trigger the space-ship operator (<=>) method" do
      s = SomeClass.new
      (s < 123).should == true
    end
  end
end
