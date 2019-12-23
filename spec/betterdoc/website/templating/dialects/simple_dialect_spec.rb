require "spec_helper"
require "betterdoc/website/templating/dialects/simple_dialect"

describe Betterdoc::Website::Templating::Dialects::SimpleDialect do

  describe "#resolve_content" do
    describe "with valid configuration" do
      it "should resolve the title and content" do
        dialect = Betterdoc::Website::Templating::Dialects::SimpleDialect.new
        dialect.content_placeholder = 'CONTENT_PLACEHOLDER'
        dialect.title_placeholder = 'TITLE_PLACEHOLDER'
        resolved_content = dialect.resolve_content('aa TITLE_PLACEHOLDER bb CONTENT_PLACEHOLDER cc', content: "this is the content", title: "this is the title")
        expect(resolved_content).to eq ('aa this is the title bb this is the content cc')
      end
      it "should resolve the content and use the default title as the configured title is nil" do
        dialect = Betterdoc::Website::Templating::Dialects::SimpleDialect.new
        dialect.content_placeholder = 'CONTENT_PLACEHOLDER'
        dialect.title_placeholder = 'TITLE_PLACEHOLDER'
        resolved_content = dialect.resolve_content('aa TITLE_PLACEHOLDER bb CONTENT_PLACEHOLDER cc', content: "this is the content")
        expect(resolved_content).to eq ('aa BetterDoc bb this is the content cc')
      end
      describe "with additional values for head and body" do
        it "should add additional content in the head" do
          dialect = Betterdoc::Website::Templating::Dialects::SimpleDialect.new
          dialect.content_placeholder = 'CONTENT_PLACEHOLDER'
          dialect.title_placeholder = 'TITLE_PLACEHOLDER'
          resolved_content = dialect.resolve_content('aa <head>TITLE_PLACEHOLDER</head> bb <body>CONTENT_PLACEHOLDER cc</body>', content: "this is the content", title: "this is the title", additional_head_content: "<meta>")
          expect(resolved_content).to eq ("aa <head>this is the title\n<meta>\n</head> bb <body>this is the content cc</body>")
        end
        it "should add additional content in the body" do
          dialect = Betterdoc::Website::Templating::Dialects::SimpleDialect.new
          dialect.content_placeholder = 'CONTENT_PLACEHOLDER'
          dialect.title_placeholder = 'TITLE_PLACEHOLDER'
          resolved_content = dialect.resolve_content('aa <head>TITLE_PLACEHOLDER</head> bb <body>CONTENT_PLACEHOLDER cc</body>', content: "this is the content", title: "this is the title", additional_body_content: "<xxx>")
          expect(resolved_content).to eq ("aa <head>this is the title</head> bb <body>this is the content cc\n<xxx>\n</body>")
        end
        it "should add additional content in the head and the body" do
          dialect = Betterdoc::Website::Templating::Dialects::SimpleDialect.new
          dialect.content_placeholder = 'CONTENT_PLACEHOLDER'
          dialect.title_placeholder = 'TITLE_PLACEHOLDER'
          resolved_content = dialect.resolve_content('aa <head>TITLE_PLACEHOLDER</head> bb <body>CONTENT_PLACEHOLDER cc</body>', content: "this is the content", title: "this is the title", additional_head_content: "<meta>", additional_body_content: "<xxx>")
          expect(resolved_content).to eq ("aa <head>this is the title\n<meta>\n</head> bb <body>this is the content cc\n<xxx>\n</body>")
        end
        it "should not add additional content in the head or the body as the </head> element isn't there" do
          dialect = Betterdoc::Website::Templating::Dialects::SimpleDialect.new
          dialect.content_placeholder = 'CONTENT_PLACEHOLDER'
          dialect.title_placeholder = 'TITLE_PLACEHOLDER'
          resolved_content = dialect.resolve_content('aa TITLE_PLACEHOLDER bb CONTENT_PLACEHOLDER cc', content: "this is the content", title: "this is the title", additional_head_content: "<meta>", additional_body_content: "<xxx>")
          expect(resolved_content).to eq ("aa this is the title bb this is the content cc")
        end
      end
    end
    describe "with invalid configuration" do
      it "should raise an error if the content is nil" do
        dialect = Betterdoc::Website::Templating::Dialects::SimpleDialect.new
        expect { dialect.resolve_content('aa TITLE_PLACEHOLDER bb CONTENT_PLACEHOLDER cc', {}) }.to raise_error(Betterdoc::Website::Templating::Errors::ConfigurationError)
      end
    end
  end

end
