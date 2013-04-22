# Copyright (C) 2013 Keita Yamaguchi <keita.yamaguchi@gmail.com>

require "forwardablex/version"

# ForwardableX is a module for providing extra Forwardable functions. Benefits
# to use this library are the following:
#
# - you can use easy keyword "forward", instead of "def_instance_delegator" or "def_delegator"
# - you can specify message receiver as instance variable name, Proc object or plain object
# - no need to declare "extend Forwardable"
# - forwardable.rb compatible API
#
# @example Forward to Instance Variable
#   Receiver = Struct(:m)
#   class Forwarder
#     forward :@receiver, :m
#     def initialize
#       @recevier = Receiver.new("forwarded")
#     end
#   end
#   Forwarder.new.m #=> "forwarded"
# @example Forward to Proc Receiver
#   class Forwarder
#     forward lambda{Struct(:m).new("forwarded")}, :m
#   end
#   Forwarder.new.m #=> "forwarded"
# @example Forward to Instance
#   Receiver = Struct(:m)
#   class Forwarder
#     forward Receiver.new("forwarded"), :m
#   end
#   Forwarder.new.m #=> "forwarded"
# @example Class Method Accessor
#   Receiver = Struct(:name)
#   class Forwarder
#     class << self
#       def m
#         "forwarded"
#       end
#     end
#     forward :class, :m
#   end
#   Forwarder.new.m #=> "forwarded"
module ForwardableX
  # Define a method that forwards the message to the receiver. You can specify
  # receiver as instance variable name, Proc object, and plain object.
  #
  # @param receiver [Symbol, String, Proc, or Object]
  #   message receiver
  # @param method [Symbol]
  #   method name that we forward to
  # @param name [Symbol]
  #   method name that we forward from
  # @return [void]
  def forward(receiver, method, name=method)
    context = self.kind_of?(Module) ? self : self.singleton_class
    context.instance_eval do
      case receiver
      when :class
        define_method(name) do |*args, &b|
          self.class.__send__(method, *args, &b)
        end
      when Symbol, String
        define_method(name) do |*args, &b|
          instance_variable_get(receiver).__send__(method, *args, &b)
        end
      when Proc
        define_method(name) do |*args, &b|
          instance_eval(&receiver).__send__(method, *args, &b)
        end
      else
        define_method(name) do |*args, &b|
          receiver.__send__(method, *args, &b)
        end
      end
    end
  end
  alias :def_instance_delegator :forward
  alias :def_singleton_delegator :forward
  alias :def_delegator :forward

  # Define each method that calls the receiver's method.
  #
  # @param receiver [Symbol, String, Proc, or Object]
  #   message receiver
  # @param methods [Array<Symbol>]
  #   method names that we forward to
  # @return [void]
  def forward!(receiver, *methods)
    methods.delete("__send__")
    methods.delete("__id__")
    methods.each {|method| forward(receiver, method)}
  end
  alias :def_instance_delegators :forward!
  alias :def_singleton_delegators :forward!
  alias :def_delegators :forward!

  # Same as Forwardable#delegate, but you can specify receivers as instance
  # variable name, Proc object, and plain object.
  #
  # @param hash [Hash]
  #   the hash table contains keys as methods and values as recevier
  # @return [void]
  def delegate(hash)
    hash.each do |methods, receiver|
      forward!(receiver, *methods)
    end
  end

  # Define a method that forwards the key to the receiver. You can specify
  # receiver as instance variable name, Proc object, and plain object.
  #
  # @param receiver [Symbol, String, Proc, or Object]
  #   message receiver that have method #[]
  # @param key [Symbol]
  #   key that we forward to the receiver
  # @param name [Symbol]
  #   method name that we forward from
  # @return [void]
  def forward_as_key(receiver, key, name=key)
    context = self.kind_of?(Module) ? self : self.singleton_class
    context.instance_eval do
      case receiver
      when :class
        define_method(name) do |*args, &b|
          self.class.__send__(:[], key, *args, &b)
        end
      when Symbol, String
        define_method(name) do |*args, &b|
          instance_variable_get(receiver).__send__(:[], key, *args, &b)
        end
      when Proc
        define_method(name) do |*args, &b|
          instance_eval(&receiver).__send__(:[], key, *args, &b)
        end
      else
        define_method(name) do |*args, &b|
          receiver.__send__(:[], key, *args, &b)
        end
      end
    end
  end

  # Define each method that forwards to the receiver as key.
  #
  # @param receiver [Symbol, String, Proc, or Object]
  #   message receiver that have method #[]
  # @param key [Array<Symbol>]
  #   key that we forward to the receiver
  # @return [void]
  def forward_as_key!(receiver, *keys)
    keys.each {|key| forward_as_key(receiver, key)}
  end
end

# @api private
class Object
  extend ForwardableX
end
