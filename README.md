# TourkrubToolkit

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tourkrub-toolkit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tourkrub-toolkit

## Usage

### ServiceObject

```
class AddOneService
    include TourkrubToolkit::ServiceObject
    
    declare_input do
        attribute :value, Types::Strict::Integer
    end

    declare_output do
        attribute :data, Types::Strict::Integer
    end
        
    # attribut types https://dry-rb.org/gems/dry-struct/
    
    def process
        new_value = input.value + 1
        assign_output(data: new_value)
    end
end

service = AddOneService.process(value: 1)

service.input #=> <AddOneService::Input value=1>
service.output #=> <AddOneService::Output data=2>
service.success? => true
```

