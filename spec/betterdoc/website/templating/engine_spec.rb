require "spec_helper"
require "betterdoc/website/templating/engine"
require "betterdoc/website/templating/loaders/local_template_loader"
require "betterdoc/website/templating/loaders/network_template_loader"

describe Betterdoc::Website::Templating::Engine do

  describe "#resolve_content" do
    before do
      @template_loader = double
      allow(@template_loader).to receive(:load_template).and_return('aa TITLE_PLACEHOLDER bb CONTENT_PLACEHOLDER cc')
      @engine = Betterdoc::Website::Templating::Engine.new
      @engine.template_location = 'foo'
      @engine.content_placeholder = 'CONTENT_PLACEHOLDER'
      @engine.content = 'this is the content'
      @engine.title_placeholder = 'TITLE_PLACEHOLDER'
      @engine.title = 'this is the title'
      allow(@engine).to receive(:compute_template_loader).and_return(@template_loader)
    end
    describe "with valid configuration" do
      it "should resolve the content" do
        resolved_content = @engine.resolve_content
        expect(resolved_content).to eq ('aa this is the title bb this is the content cc')
      end
      it "should resolve the content and use the default title as the configured title is nil" do
        @engine.title = nil
        resolved_content = @engine.resolve_content
        expect(resolved_content).to eq ('aa BetterDoc bb this is the content cc')
      end
      describe "with additional values for head and body" do
        before do
          @template_loader = double
          allow(@template_loader).to receive(:load_template).and_return('aa <head>TITLE_PLACEHOLDER</head> bb <body>CONTENT_PLACEHOLDER cc</body>')
          allow(@engine).to receive(:compute_template_loader).and_return(@template_loader)
        end
        it "should add additional content in the head" do
          @engine.additional_head_content = "<meta>"
          resolved_content = @engine.resolve_content
          expect(resolved_content).to eq ("aa <head>this is the title\n<meta>\n</head> bb <body>this is the content cc</body>")
        end
        it "should add additional content in the body" do
          @engine.additional_body_content = "<xxx>"
          resolved_content = @engine.resolve_content
          expect(resolved_content).to eq ("aa <head>this is the title</head> bb <body>this is the content cc\n<xxx>\n</body>")
        end
        it "should add additional content in the head and the body" do
          @engine.additional_head_content = "<meta>"
          @engine.additional_body_content = "<xxx>"
          resolved_content = @engine.resolve_content
          expect(resolved_content).to eq ("aa <head>this is the title\n<meta>\n</head> bb <body>this is the content cc\n<xxx>\n</body>")
        end
        it "should not add additional content in the head or the body as the </head> element isn't there" do
          @template_loader = double
          allow(@template_loader).to receive(:load_template).and_return('aa TITLE_PLACEHOLDER bb CONTENT_PLACEHOLDER cc')
          allow(@engine).to receive(:compute_template_loader).and_return(@template_loader)
          @engine.additional_head_content = "<xxx>"
          @engine.additional_body_content = "<yyy>"
          resolved_content = @engine.resolve_content
          expect(resolved_content).to eq ("aa this is the title bb this is the content cc")
        end
      end
    end
    describe "with invalid configuration" do
      it "should raise an error if the content is nil" do
        @engine.content = nil
        expect { @engine.resolve_content }.to raise_error(Betterdoc::Website::Templating::Errors::ConfigurationError)
      end
      it "should raise an error if the template location is nil" do
        @engine.template_location = nil
        expect { @engine.resolve_content }.to raise_error(Betterdoc::Website::Templating::Errors::ConfigurationError)
      end
    end
  end

  describe "#compute_template_loader" do
    it "should return a network template loader for http values" do
      engine = Betterdoc::Website::Templating::Engine.new
      template_loader = engine.send(:compute_template_loader, "http://www.example.com")
      expect(template_loader).to be_an_instance_of(Betterdoc::Website::Templating::Loaders::NetworkTemplateLoader)
    end
    it "should return a network template loader for https values" do
      engine = Betterdoc::Website::Templating::Engine.new
      template_loader = engine.send(:compute_template_loader, "https://www.example.com")
      expect(template_loader).to be_an_instance_of(Betterdoc::Website::Templating::Loaders::NetworkTemplateLoader)
    end
    it "should return a load template loader for other values" do
      engine = Betterdoc::Website::Templating::Engine.new
      template_loader = engine.send(:compute_template_loader, "xyz")
      expect(template_loader).to be_an_instance_of(Betterdoc::Website::Templating::Loaders::LocalTemplateLoader)
    end
  end

end
