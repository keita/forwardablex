# ForwardableX

ForwardableX is a Ruby library to extend forwardable.rb.

## Installation

    gem install forwardablex

## Usage

### Forward to Instance Variable

```ruby
Receiver = Struct(:m)
class Forwarder
  forward :@receiver, :m
  def initialize
    @recevier = Receiver.new("forwarded")
  end
end
Forwarder.new.m #=> "forwarded"
```

### Forward to Proc Receiver

```ruby
class Forwarder
  forward lambda{Struct(:m).new("forwarded")}, :m
end
Forwarder.new.m #=> "forwarded"
```

### Forward to Instance

```ruby
Receiver = Struct(:m)
class Forwarder
  forward Receiver.new("forwarded"), :m
end
Forwarder.new.m #=> "forwarded"
```

### Class Method Accessor

```ruby
Receiver = Struct(:name)
class Forwarder
  class << self
    def m
      "forwarded"
    end
  end
  forward :class, :m
end
Forwarder.new.m #=> "forwarded"
```

## Licence

ForwardableX is free software distributed under MIT licence.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
