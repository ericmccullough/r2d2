require 'netaddr'

FactoryGirl.define do
  
  sequence :name do |n|
    "list#{n}"
  end
  
  factory :glyph do
    name
  end

  factory :list do
    name
    glyph
  end

  factory :device do
    mac  { 6.times.map{ rand(256) }.map{ |d| '%02x' % d }.join(':').to_s }
    list { List.find_by_name('Unassigned') }
    notes Faker::Lorem.sentence(3)
  end

  factory :node do
    mac  { 6.times.map{ rand(256) }.map{ |d| '%02x' % d }.join(':').to_s }
    ip Faker::Internet.ip_v4_address
  end

  factory :sweep do
    cidr = (16..29).to_a
    ip = Faker::Internet.ip_v4_address
    cidr4 = NetAddr::CIDR.create("#{ip}/#{cidr.sample}")
    description cidr4.to_s
    transient do
      node_count 1
    end
    ip_array = cidr4.enumerate
    after(:create) do |sweep, evaluator|
#      create_list(:result, evaluator.device_count, sweep: sweep)
      evaluator.node_count.times  { sweep.nodes << create(:node, ip: ip_array.sample) }
    end
  end

  factory :lease do
    ip Faker::Internet.ip_v4_address
    name 'com.example.' + Faker::Internet.user_name
    expiration Faker::Time.between(2.days.ago, Faker::Time.forward(23, :morning))
    kind ['D','B','U','R','N'].sample
    device
  end

  factory :sweeper do
    description '1.1.1.0/24'
    ip '1.1.1.1'
    mac { 6.times.map{ rand(256) }.map{ |d| '%02x' % d }.join(':').to_s }
  end

  factory :scope do
    ip   Faker::Internet.ip_v4_address
    mask '255.255.255.0'
    description Faker::Address.street_address
    comment Faker::Lorem.sentence(3)
    cidr4 = NetAddr::CIDR.create(Faker::Internet.ip_v4_address+'/24')
    ip_array = cidr4.enumerate
    transient do
      lease_count 1
    end
    after(:create) do |scope, evaluator|
      evaluator.lease_count.times  { scope.leases << create(:lease, ip: ip_array.sample) }
      sweeper.create(ip: ip_array.sample, description: evaluator.description)
    end
  end

  factory :server do
    ip   Faker::Internet.ip_v4_address
    name Faker::Internet.domain_word + ".example.com"
    transient do
      scope_count 1
    end
    after(:create) do |server, evaluator|
      evaluator.scope_count.times do
        mask = (23..29).to_a.sample.to_s
        cidr4 = NetAddr::CIDR.create(Faker::Internet.ip_v4_address+'/'+mask)
        server.scopes << create(:scope, ip: cidr4.to_s, mask: cidr4.wildcard_mask)
      end
    end
  end
end