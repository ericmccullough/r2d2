require 'rails_helper'

RSpec.describe Fingerprint, type: :model do
  describe 'name' do
    context 'is invalid' do
      it 'if empty' do
        fingerprint = Fingerprint.new(name: '')
        expect(fingerprint).to be_invalid
        end
      it 'if nil' do
        fingerprint = Fingerprint.new()
        expect(fingerprint).to be_invalid
        end
      end
    context 'is valid' do
      it 'if exists' do
        fingerprint = Fingerprint.new(name: 'test')
        expect(fingerprint).to be_valid
      end
      it 'if unique' do
        Fingerprint.create(name: 'test')
        duplicate = Fingerprint.new(name: 'test')
        expect(duplicate).to be_invalid
      end
      it 'if case-insensitive unique' do
        Fingerprint.create(name: 'test')
        duplicate = Fingerprint.new(name: 'Test')
        expect(duplicate).to be_invalid
      end
    end
  end
  describe 'tcp_ports' do
    describe 'is valid if it contains' do
      it 'nothing' do
        fingerprint = Fingerprint.new(name: 'test', tcp_ports: '')
        expect(fingerprint).to be_valid
      end
      it 'a single number from 1-65535' do
        fingerprint = Fingerprint.new(name: 'test', tcp_ports: '1')
        expect(fingerprint).to be_valid
      end
      it 'a single number from 1-65535 with a plus sign' do
        fingerprint = Fingerprint.new(name: 'test', tcp_ports: '+1')
        expect(fingerprint).to be_valid
      end
      it 'a number can contain a comma' do
        fingerprint = Fingerprint.new(name: 'test', tcp_ports: '1,024')
        expect(fingerprint).to be_valid
      end
      it 'list of TCP port numbers' do
        fingerprint = Fingerprint.new(name: 'test', tcp_ports: '80 443 4445')
        expect(fingerprint).to be_valid
      end
      it 'a single number from 1-65535 preceeded by an minus sign' do
        fingerprint = Fingerprint.new(name: 'test', tcp_ports: '-1')
        expect(fingerprint).to be_valid
      end
      it 'list of TCP port numbers preceeded by minus signs' do
        fingerprint = Fingerprint.new(name: 'test', tcp_ports: '-80 -443 -4445')
        expect(fingerprint).to be_valid
      end
      it 'list of TCP port numbers preceeded, or not, by minus signs' do
        fingerprint = Fingerprint.new(name: 'test', tcp_ports: '-80 443 -4445')
        expect(fingerprint).to be_valid
      end
    end
    describe 'is invalid if it contains' do
      it 'other characters than numbers, commas, and plus or minus signs' do
        fingerprint = Fingerprint.new(name: 'test', tcp_ports: 'A80 443 4445')
        expect(fingerprint).to be_invalid
      end
      it 'a port of 0' do
        fingerprint = Fingerprint.new(name: 'test', tcp_ports: '0 443 4445')
        expect(fingerprint).to be_invalid
      end
      it 'no numbers' do
        fingerprint = Fingerprint.new(name: 'test', tcp_ports: 'web')
        expect(fingerprint).to be_invalid
      end
    end
  end
  describe 'udp_ports' do
    describe 'is valid if it contains' do
      it 'nothing' do
        fingerprint = Fingerprint.new(name: 'test', udp_ports: '')
        expect(fingerprint).to be_valid
      end
      it 'a single number from 1-65535' do
        fingerprint = Fingerprint.new(name: 'test', udp_ports: '1')
        expect(fingerprint).to be_valid
      end
      it 'list of UDP port numbers' do
        fingerprint = Fingerprint.new(name: 'test', udp_ports: '80 443 4445')
        expect(fingerprint).to be_valid
      end
      it 'a single number from 1-65535 preceeded by an minus sign' do
        fingerprint = Fingerprint.new(name: 'test', udp_ports: '-1')
        expect(fingerprint).to be_valid
      end
      it 'list of UDP port numbers preceeded by minus signs' do
        fingerprint = Fingerprint.new(name: 'test', udp_ports: '-80 -443 -4445')
        expect(fingerprint).to be_valid
      end
      it 'list of UDP port numbers preceeded, or not, by minus signs' do
        fingerprint = Fingerprint.new(name: 'test', udp_ports: '-80 443 -4445')
        expect(fingerprint).to be_valid
      end
    end
    describe 'is invalid if it contains' do
      it 'other characters than numbers, commas, and plus or minus signs' do
        fingerprint = Fingerprint.new(name: 'test', udp_ports: 'A80 443 4445')
        expect(fingerprint).to be_invalid
      end
    end
  end
  describe 'shares' do
    context 'is invalid if it contains' do
      it '< (less than)' do
        fingerprint = Fingerprint.new(name: 'test', shares: 'Share<')
        expect(fingerprint).to be_invalid
      end
      it '> (greater than)' do
        fingerprint = Fingerprint.new(name: 'test', shares: 'Share>')
        expect(fingerprint).to be_invalid
      end
      it ': (colon)' do
        fingerprint = Fingerprint.new(name: 'test', shares: 'Share:')
        expect(fingerprint).to be_invalid
      end
      it '" (double quote)' do
        fingerprint = Fingerprint.new(name: 'test', shares: 'Share"')
        expect(fingerprint).to be_invalid
      end
      it '/ (forward slash)' do
        fingerprint = Fingerprint.new(name: 'test', shares: 'Share/')
        expect(fingerprint).to be_invalid
      end
      it '\ (backslash)' do
        fingerprint = Fingerprint.new(name: 'test', shares: 'Share\\')
        expect(fingerprint).to be_invalid
      end
      it '| (vertical bar or pipe)' do
        fingerprint = Fingerprint.new(name: 'test', shares: 'Share|')
        expect(fingerprint).to be_invalid
      end
      it '? (question mark)' do
        fingerprint = Fingerprint.new(name: 'test', shares: 'Share?')
        expect(fingerprint).to be_invalid
      end
      it '* (asterisk)' do
        fingerprint = Fingerprint.new(name: 'test', shares: 'Share*')
        expect(fingerprint).to be_invalid
      end
      it 'ASCII NUL character' do
        fingerprint = Fingerprint.new(name: 'test', shares: "Share\0")
        expect(fingerprint).to be_invalid
      end
    end
    it 'is valid if all the names are valid' do
      fingerprint = Fingerprint.new(name: 'test', shares: "Share0 c$")
      expect(fingerprint).to be_valid
    end
    it 'is valid if empty' do
      fingerprint = Fingerprint.new(name: 'test', shares: '')
      expect(fingerprint).to be_valid
    end
  end
end
