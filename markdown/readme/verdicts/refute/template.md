### Refute Verdicts

#### verdict_refute?

```ruby
verdict_refute?(id, test, msg = nil)
vr?(id, test, msg = nil)
```

Fails if ```test``` is a true value.

@[ruby](verdict_refute.rb)

@[xml](verdict_refute.xml)

#### verdict_refute_empty?

```ruby
verdict_refute_empty?(id, obj, msg = nil)
vr_empty?(id, obj, msg = nil)
```

Fails if ```obj``` is empty.

@[ruby](verdict_refute_empty.rb)

@[xml](verdict_refute_empty.xml)

#### verdict_refute_equal?

```ruby
verdict_refute_equal?(id, exp, act, msg = nil)
va_equal?(id, exp, act, msg = nil)
```
Fails if ```exp == act```.

For floats use verdict_refute_in_delta?.

@[ruby](verdict_refute_equal.rb)

@[xml](verdict_refute_equal.xml)

