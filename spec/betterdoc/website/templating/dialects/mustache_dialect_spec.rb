require "spec_helper"
require "betterdoc/website/templating/dialects/mustache_dialect"

describe Betterdoc::Website::Templating::Dialects::MustacheDialect do

  describe "#resolve_content" do
    describe "with valid configuration" do
      it "should resolve the title and content" do
        dialect = Betterdoc::Website::Templating::Dialects::MustacheDialect.new
        resolved_content = dialect.resolve_content('aa {{title}} bb {{content}} cc', content: "this is the content", title: "this is the title")
        expect(resolved_content).to eq ('aa this is the title bb this is the content cc')
      end
      it "should resolve the content and use the default title as the configured title is nil" do
        dialect = Betterdoc::Website::Templating::Dialects::MustacheDialect.new
        resolved_content = dialect.resolve_content('aa {{title}} bb {{content}} cc', content: "this is the content")
        expect(resolved_content).to eq ('aa  bb this is the content cc')
      end
    end
  end

end
