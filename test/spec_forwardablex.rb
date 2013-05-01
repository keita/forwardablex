require 'simplecov'
require 'coveralls'
Coveralls.wear!
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start {add_filter 'test'}

require 'forwardable'
require 'forwardablex'

class Receiver
  def method_missing(name, *args)
    name
  end
end

class Forwarder
  attr_reader :name

  def initialize(name=self.class)
    @rec = Receiver.new
    @name = name
  end
end

class XForwarder < Forwarder
  forward :@rec, :m1
  forward :@rec, :m1, :mm1
  forward! :@rec, :m2, :m3
  forward Proc.new{@rec}, :m4
  forward Proc.new{@rec}, :m4, :mm4
  forward! Proc.new{@rec}, :m5, :m6
  forward Receiver.new, :m7
  forward Receiver.new, :m7, :mm7
  forward! Receiver.new, :m8, :m9
end

class DefDelegatorForwarder < Forwarder
  def_delegator :@rec, :m1
  def_delegator :@rec, :m1, :mm1
  def_delegators :@rec, :m2, :m3
  def_delegator Proc.new{@rec}, :m4
  def_delegator Proc.new{@rec}, :m4, :mm4
  def_delegators Proc.new{@rec}, :m5, :m6
  def_delegator Receiver.new, :m7
  def_delegator Receiver.new, :m7, :mm7
  def_delegators Receiver.new, :m8, :m9
end

class DefInstanceDelegatorForwarder < Forwarder
  def_instance_delegator :@rec, :m1
  def_instance_delegator :@rec, :m1, :mm1
  def_instance_delegators :@rec, :m2, :m3
  def_instance_delegator Proc.new{@rec}, :m4
  def_instance_delegator Proc.new{@rec}, :m4, :mm4
  def_instance_delegators Proc.new{@rec}, :m5, :m6
  def_instance_delegator Receiver.new, :m7
  def_instance_delegator Receiver.new, :m7, :mm7
  def_instance_delegators Receiver.new, :m8, :m9
end

class DelegateForwarder < Forwarder
  delegate :m1 => :@rec
  delegate [:m2, :m3] => :@rec
  delegate :m4 => Proc.new{@rec}
  delegate [:m5, :m6] => Proc.new{@rec}
  delegate :m7 => Receiver.new
  delegate [:m8, :m9] => Receiver.new
end

xforwarder = Forwarder.new("xforwarder").tap do |obj|
  obj.extend ForwardableX
  obj.forward :@rec, :m1
  obj.forward :@rec, :m1, :mm1
  obj.forward! :@rec, :m2, :m3
  obj.forward Proc.new{@rec}, :m4
  obj.forward Proc.new{@rec}, :m4, :mm4
  obj.forward! Proc.new{@rec}, :m5, :m6
  obj.forward Receiver.new, :m7
  obj.forward Receiver.new, :m7, :mm7
  obj.forward! Receiver.new, :m8, :m9
end

singletonforwarder = Forwarder.new("singletonforwarder").tap do |obj|
  obj.extend ForwardableX
  obj.def_singleton_delegator :@rec, :m1
  obj.def_singleton_delegator :@rec, :m1, :mm1
  obj.def_singleton_delegators :@rec, :m2, :m3
  obj.def_singleton_delegator Proc.new{@rec}, :m4
  obj.def_singleton_delegator Proc.new{@rec}, :m4, :mm4
  obj.def_singleton_delegators Proc.new{@rec}, :m5, :m6
  obj.def_singleton_delegator Receiver.new, :m7
  obj.def_singleton_delegator Receiver.new, :m7, :mm7
  obj.def_singleton_delegators Receiver.new, :m8, :m9
end

class ClassMethodForwarder
  class << self
    def m
      "forwarded"
    end
  end

  forward :class, :m
end

class ClassMethodForwarderA < ClassMethodForwarder
  class << self
    def m
      "forwarded to A"
    end
  end
end

class KeyForwarder
  forward_as_key :@table, :a
  forward_as_key :@table, :a, :b
  forward_as_key! :@table, :c, :d, :e
  forward_as_key :class, :f
  forward_as_key Proc.new{@table}, :g
  forward_as_key Receiver.new, :h

  class << self
    def [](key)
      {f: 1}[key]
    end
  end

  def initialize(table={})
    @table = table
  end
end

describe 'ForwardableX' do
  [ XForwarder.new,
    DefDelegatorForwarder.new,
    DefInstanceDelegatorForwarder.new,
    DelegateForwarder.new,
    xforwarder,
    singletonforwarder
  ].each do |obj|
    describe obj.name do
      it 'should forward' do
        obj.m1.should == :m1
        obj.m2.should == :m2
        obj.m3.should == :m3
        obj.m4.should == :m4
        obj.m5.should == :m5
        obj.m6.should == :m6
        obj.m7.should == :m7
        obj.m8.should == :m8
        obj.m9.should == :m9
      end

      unless obj.kind_of? DelegateForwarder
        it 'should forward by alias' do
          obj.mm1.should == :m1
        end
      end
    end
  end

  it 'should forward to class' do
    ClassMethodForwarder.new.m.should == "forwarded"
    ClassMethodForwarderA.new.m.should == "forwarded to A"
  end

  it 'should forward to the table as key' do
    KeyForwarder.new(a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8).tap do |obj|
      obj.a.should == 1
      obj.b.should == 1
      obj.c.should == 3
      obj.d.should == 4
      obj.e.should == 5
      obj.f.should == 1
      obj.g.should == 7
      obj.h.should == :[]
    end
  end
end
