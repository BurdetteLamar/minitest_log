### Assert Verdicts

#### verdict_assert?

```ruby
verdict_assert?(id, obj, msg = nil)
```

Fails unless obj is truthy.

@[ruby](verdict_assert.rb)

@[xml](verdict_assert.xml)

#### verdict_assert_empty?

```ruby
verdict_assert_empty?(id, obj, msg = nil)
```

Fails unless obj is empty.

@[ruby](verdict_assert_empty.rb)

@[xml](verdict_assert_empty.xml)

#### verdict_assert_equal?

```ruby
verdict_assert_equal?(id, exp, act, msg = nil)
```
Fails unless exp == act printing the difference between the two, if possible.

If there is no visible difference but the assertion fails, you should suspect that your #== is buggy, or your inspect output is missing crucial details.

For floats use verdict_assert_in_delta?.

@[ruby](verdict_assert_equal.rb)

@[xml](verdict_assert_equal.xml)

#### verdict_assert_in_delta?

```ruby
verdicct_assert_in_delta?(id, exp, act, delta = 0.001, msg = nil)
````

For comparing Floats. Fails unless exp and act are within delta of each other.

@[ruby](verdict_assert_in_delta.rb)

@[xml](verdict_assert_in_delta.xml)

#### verdict_assert_in_epsilon?

```ruby
verdict_assert_in_epsilon?(id, a, b, epsilon = 0.001, msg = nil)
```

For comparing Floats. Fails unless exp and act have a relative error less than epsilon.

@[ruby](verdict_assert_in_epsilon.rb)

@[xml](verdict_assert_in_epsilon.xml)

