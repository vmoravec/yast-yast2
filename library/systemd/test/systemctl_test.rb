#!/usr/bin/env rspec

require_relative 'test_helper'
require 'yast2/systemctl'

module Yast
  describe Systemctl do
    include SystemctlStubs

    describe ".execute" do
      it "returns a struct with command results" do
        expect(SCR).to receive(:Execute).and_return(
          {'exit'=>1, 'stderr'=>'', 'stdout'=>''}
        )
        result = Systemctl.execute('enable cups.service')
        expect(result).to be_a(OpenStruct)
        expect(result.exit).to eq(1)
        expect(result.stderr).to eq('')
        expect(result.stdout).to eq('')
        expect(result.command).to match('cups.service')
      end

      it "raises exception if the execution has timed out" do
        stub_const("Yast::Systemctl::TIMEOUT", 1)
        SCR.stub(:Execute) { sleep 1.1 }
        expect(SCR).to receive(:Execute)
        expect { Systemctl.execute('disable cups.service') }.to raise_error(SystemctlError)
      end
    end

    describe ".socket_units" do
      before { stub_systemctl(:socket) }
      it "returns a list of socket unit ids registered with systemd" do
        socket_units = Systemctl.socket_units
        expect(socket_units).to be_a(Array)
        expect(socket_units).not_to be_empty
        socket_units.each {|u| expect(u).to match(/.socket$/) }
      end
    end

    describe ".service_units" do
      before { stub_systemctl(:service) }
      it "returns a list of service units" do
        service_units = Systemctl.service_units
        expect(service_units).to be_a(Array)
        expect(service_units).not_to be_empty
        service_units.each {|u| expect(u).to match(/.service$/) }
      end
    end
  end
end
