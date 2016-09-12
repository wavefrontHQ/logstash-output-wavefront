# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/wavefront"
require "logstash/codecs/plain"
require "logstash/event"
require "socket"

def event(hash = {})
  event = LogStash::Event.new
  hash.each do |k, v|
    event[k] = v
  end
  event
end

def maketags(**kwargs)
  return { :point_tags => Hash[kwargs.map { |k, v| [k.id2name, v]}] }
end

describe LogStash::Outputs::Wavefront do
  subject(:mywriter) { double("mywriter") }

  subject do
    wavefront = LogStash::Outputs::Wavefront.new({
      "host" => host,
      "port" => port,
      "source" => source,
      "metrics" => metrics,
      "prefix" => prefix,
      "tag_separator" => tag_separator
    })
    expect(Wavefront::Writer).to receive(:new) { mywriter }
    wavefront.register
    wavefront
  end

  let(:host) { "localhost" }
  let(:port) { 2878 }
  let(:source) { "mynode" }
  let(:metrics) { ["count"] }
  let(:prefix) { "myprefix" }
  let(:tag_separator) { "tagz" }

  describe "#register" do
    context "without a given source" do
      let(:source) { "" }
      it "infers source name from socket" do
        subject.receive(event())
        expect(subject.source).to eq(Socket.gethostname)
      end
    end
  end

  describe "#receive" do
    it "forwards event with matching metrics" do
      expect(mywriter).to receive(:write).with(2, "myprefix.a.count", maketags({}))
      subject.receive(event({"a" => {"count" => 2}}))
    end

    it "forwards multiple metrics when needed" do
      expect(mywriter).to receive(:write).with(2, "myprefix.a.count", maketags({}))
      expect(mywriter).to receive(:write).with(3, "myprefix.b.count", maketags({}))
      subject.receive(event({"a" => {"count" => 2}, "b" => {"count" => 3}}))
    end

    context "without a metrics prefix" do
      let(:prefix) { "" }
      it "does not include a metrics prefix in the output" do
        expect(mywriter).to receive(:write).with(2, "a.count", maketags({}))
        subject.receive(event({"a" => {"count" => 2}}))
      end
    end

    it "drops event without matching metrics" do
      subject.receive(event({"a" => {"foo" => 2}}))
    end

    it "skips non-hash fields in the event" do
      subject.receive(event({"a" => "b"}))
    end

    it "parses tags when they are present in the metric name" do
      expect(mywriter).to receive(:write).with(2, "myprefix.a.count",
        maketags(foo: "bar", boo: "baz=qux"))
      subject.receive(event(
        {"a.tagz.foo=bar.boo=baz=qux.tagwrongformat" => {"count" => 2}}))
    end

    it "starts zombie mode when WF cxn drops" do
      expect(mywriter).to receive(:write).with(any_args).and_raise(Errno::EPIPE)
      subject.receive(event({"a" => {"count" => 2}}))
      # Pipe is broken, we should try to connect again.
      expect(Wavefront::Writer).to receive(:new) { mywriter }.once
      expect(mywriter).to receive(:write).with(any_args)
      subject.receive(event({"a" => {"count" => 2}}))
    end

    it "does not try to reconnect when cxn is still healthy" do
      expect(mywriter).to receive(:write).with(any_args).twice
      subject.receive(event({"a" => {"count" => 2}}))
      subject.receive(event({"a" => {"count" => 2}}))
    end

    context "without a tags separator" do
      let(:tag_separator) { "" }
      it "does not parse out tags from the metric name" do
        expect(mywriter).to receive(:write).with(
          2, "myprefix.a.tagz.foo=bar.boo=baz.count", maketags({}))
        subject.receive(event({"a.tagz.foo=bar.boo=baz" => {"count" => 2}}))
      end
    end
  end

end
