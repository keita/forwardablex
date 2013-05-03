# ForwardableX

ForwardableX is a Ruby library to extend forwardable.rb.

[![Gem Version](https://badge.fury.io/rb/forwardablex.png)](http://badge.fury.io/rb/forwardablex) [![Build Status](https://travis-ci.org/keita/forwardablex.png?branch=master)](https://travis-ci.org/keita/forwardablex) [![Coverage Status](https://coveralls.io/repos/keita/forwardablex/badge.png?branch=master)](https://coveralls.io/r/keita/forwardablex) [![Code Climate](https://codeclimate.com/github/keita/forwardablex.png)](https://codeclimate.com/github/keita/forwardablex)

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

### Table Accessor

```ruby
class Forwarder
  forward_as_key :@table, :key

  def initialize
    @table = {:key => "forwarded"}
  end
end
Forwarder.new.key #=> "forwarded"
```

### Identity

```ruby
class Forwarder
  foward :identity, :self
end
Forwarder.new {|x| x == x.self} #=> true
```

## Documentation

- [API Documentation](http://rubydoc.info/gems/forwardablex)

## Licence

ForwardableX is free software distributed under MIT licence.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
