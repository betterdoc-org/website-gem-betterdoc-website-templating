require "spec_helper"
require "betterdoc/website/templating/engine"
require "betterdoc/website/templating/loaders/local_template_loader"
require "betterdoc/website/templating/loaders/network_template_loader"

describe Betterdoc::Website::Templating::Engine do

  describe "#resolve_content" do
    describe "with valid configuration" do
      describe "with explicit dialect" do
        it "should resolve the content" do
          dummy_dialect = double
          expect(dummy_dialect).to receive(:resolve_content).with(eq('aa TITLE_PLACEHOLDER bb CONTENT_PLACEHOLDER cc'), hash_including(:foo)).and_return('resolved content')

          engine = Betterdoc::Website::Templating::Engine.new
          engine.template_location = 'foo_template_location'
          engine.template_dialect = dummy_dialect
          expect(engine).to receive(:resolve_template).with(eq('foo_template_location')).and_return('aa TITLE_PLACEHOLDER bb CONTENT_PLACEHOLDER cc')

          engine_result = engine.resolve_content(foo: 'bar')
          expect(engine_result).to eq('resolved content')
        end
      end
      describe "without explicit dialect" do
        it "should resolve the content using MustacheDialect by analyzing the template location" do
          engine = Betterdoc::Website::Templating::Engine.new
          engine.template_location = "foo/bar.mustache.html"
          expect(engine).to receive(:resolve_template).and_return('aa {{title}} bb {{content}} cc')
          expect(engine.resolve_content(title: 'x_title', content: 'x_content')).to eq ('aa x_title bb x_content cc')
        end
        it "should resolve the content using SimpleDialect by analyzing the template location" do
          engine = Betterdoc::Website::Templating::Engine.new
          engine.template_location = "foo/bar"
          expect(engine).to receive(:resolve_template).and_return('aa INCLUDE_TITLE_HERE bb INCLUDE_CONTENT_HERE cc')
          expect(engine.resolve_content(title: 'x_title', content: 'x_content')).to eq ('aa x_title bb x_content cc')
        end
      end
    end
    describe "with invalid configuration" do
      it "should raise an error if the template location is nil" do
        engine = Betterdoc::Website::Templating::Engine.new
        expect { engine.resolve_content(foo: 'bar') }.to raise_error(Betterdoc::Website::Templating::Errors::ConfigurationError)
      end
    end
  end

  describe "#compute_template_loader" do
    it "should return a network template loader for http values" do
      engine = Betterdoc::Website::Templating::Engine.new
      template_loader = engine.send(:resolve_template_loader, "http://www.example.com")
      expect(template_loader).to be_an_instance_of(Betterdoc::Website::Templating::Loaders::NetworkTemplateLoader)
    end
    it "should return a network template loader for https values" do
      engine = Betterdoc::Website::Templating::Engine.new
      template_loader = engine.send(:resolve_template_loader, "https://www.example.com")
      expect(template_loader).to be_an_instance_of(Betterdoc::Website::Templating::Loaders::NetworkTemplateLoader)
    end
    it "should return a load template loader for other values" do
      engine = Betterdoc::Website::Templating::Engine.new
      template_loader = engine.send(:resolve_template_loader, "xyz")
      expect(template_loader).to be_an_instance_of(Betterdoc::Website::Templating::Loaders::LocalTemplateLoader)
    end
  end

end
