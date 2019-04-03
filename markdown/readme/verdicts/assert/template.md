### Assert Verdicts

#### verdict_assert?

```ruby
verdict_assert?(id, obj, msg = nil)
va?(id, obj, msg = nil)
```

Fails unless obj is truthy.

@[ruby](verdict_assert.rb)

@[xml](verdict_assert.xml)

#### verdict_assert_empty?

```ruby
verdict_assert_empty?(id, obj, msg = nil)
va_empty?(id, obj, msg = nil)
```

Fails unless obj is empty.

@[ruby](verdict_assert_empty.rb)

@[xml](verdict_assert_empty.xml)

#### verdict_assert_equal?

```ruby
verdict_assert_equal?(id, exp, act, msg = nil)
va_equal?(id, exp, act, msg = nil)
```
Fails unless exp == act printing the difference between the two, if possible.

If there is no visible difference but the assertion fails, you should suspect that your #== is buggy, or your inspect output is missing crucial details.

For floats use verdict_assert_in_delta?.

@[ruby](verdict_assert_equal.rb)

@[xml](verdict_assert_equal.xml)

#### verdict_assert_in_delta?

```ruby
verdict_assert_in_delta?(id, exp, act, delta = 0.001, msg = nil)
va_in_delta?(id, exp, act, delta = 0.001, msg = nil)
````

For comparing Floats. Fails unless exp and act are within delta of each other.

@[ruby](verdict_assert_in_delta.rb)

@[xml](verdict_assert_in_delta.xml)

#### verdict_assert_in_epsilon?

```ruby
verdict_assert_in_epsilon?(id, a, b, epsilon = 0.001, msg = nil)
va_in_epsilon?(id, a, b, epsilon = 0.001, msg = nil)
```

For comparing Floats. Fails unless exp and act have a relative error less than epsilon.

@[ruby](verdict_assert_in_epsilon.rb)

@[xml](verdict_assert_in_epsilon.xml)

#### verdict_assert_includes?

```ruby
verdict_assert_includes?(id, collection, obj, msg = nil)
va_includes?(id, collection, obj, msg = nil)
```

Fails unless collection includes obj.

@[ruby](verdict_assert_includes.rb)

@[xml](verdict_assert_includes.xml)

#### verdict_assert_instance_of?

```ruby
verdict_assert_instance_of?(id, cls, obj, msg = nil)
va_instance_of?(id, cls, obj, msg = nil)
```

Fails unless obj is an instance of cls.

@[ruby](verdict_assert_instance_of.rb)

@[xml](verdict_assert_instance_of.xml)

#### verdict_assert_kind_of?

```ruby
verdict_assert_kind_of?(id, cls, obj, msg = nil)
va_kind_of?(id, cls, obj, msg = nil)
```

Fails unless obj is a kind of cls.

@[ruby](verdict_assert_kind_of.rb)

@[xml](verdict_assert_kind_of.xml)

