### Assert Verdicts

#### verdict_assert?

```ruby
verdict_assert?(id, obj, msg = nil)
va?(id, obj, msg = nil)
```

Fails unless ```obj``` is truthy.

@[ruby](verdict_assert.rb)

@[xml](verdict_assert.xml)

#### verdict_assert_empty?

```ruby
verdict_assert_empty?(id, obj, msg = nil)
va_empty?(id, obj, msg = nil)
```

Fails unless ```obj``` is empty.

@[ruby](verdict_assert_empty.rb)

@[xml](verdict_assert_empty.xml)

#### verdict_assert_equal?

```ruby
verdict_assert_equal?(id, exp, act, msg = nil)
va_equal?(id, exp, act, msg = nil)
```
Fails unless ```exp == act```.

For floats use verdict_assert_in_delta?.

@[ruby](verdict_assert_equal.rb)

@[xml](verdict_assert_equal.xml)

#### verdict_assert_in_delta?

```ruby
verdict_assert_in_delta?(id, exp, act, delta = 0.001, msg = nil)
va_in_delta?(id, exp, act, delta = 0.001, msg = nil)
````

For comparing Floats. Fails unless ```exp``` and ```act``` are within ```delta``` of each other.

@[ruby](verdict_assert_in_delta.rb)

@[xml](verdict_assert_in_delta.xml)

#### verdict_assert_in_epsilon?

```ruby
verdict_assert_in_epsilon?(id, a, b, epsilon = 0.001, msg = nil)
va_in_epsilon?(id, a, b, epsilon = 0.001, msg = nil)
```

For comparing Floats. Fails unless ```exp``` and ```act``` have a relative error less than ```epsilon```.

@[ruby](verdict_assert_in_epsilon.rb)

@[xml](verdict_assert_in_epsilon.xml)

#### verdict_assert_includes?

```ruby
verdict_assert_includes?(id, collection, obj, msg = nil)
va_includes?(id, collection, obj, msg = nil)
```

Fails unless ```collection``` includes ```obj```.

@[ruby](verdict_assert_includes.rb)

@[xml](verdict_assert_includes.xml)

#### verdict_assert_instance_of?

```ruby
verdict_assert_instance_of?(id, cls, obj, msg = nil)
va_instance_of?(id, cls, obj, msg = nil)
```

Fails unless ```obj``` is an instance of ```cls```.

@[ruby](verdict_assert_instance_of.rb)

@[xml](verdict_assert_instance_of.xml)

#### verdict_assert_kind_of?

```ruby
verdict_assert_kind_of?(id, cls, obj, msg = nil)
va_kind_of?(id, cls, obj, msg = nil)
```

Fails unless ```obj``` is a kind of ```cls```.

@[ruby](verdict_assert_kind_of.rb)

@[xml](verdict_assert_kind_of.xml)

#### verdict_assert_match?

```ruby
verdict_assert_match?(id, cls, obj, msg = nil)
va_match?(id, cls, obj, msg = nil)
```

Fails unless ```matcher =~ obj```.

@[ruby](verdict_assert_match.rb)

@[xml](verdict_assert_match.xml)

#### verdict_assert_nil?

```ruby
verdict_assert_nil?(id, obj, msg = nil)
va_nil?(id, obj, msg = nil)
```

Fails unless ```obj``` is nil.

@[ruby](verdict_assert_nil.rb)

@[xml](verdict_assert_nil.xml)

#### verdict_assert_operator?

```ruby
verdict_assert_operator?(id, o1, op, o2 = UNDEFINED, msg = nil)
va_operator?(id, o1, op, o2 = UNDEFINED, msg = nil)
````

For testing with binary operators.

@[ruby](verdict_assert_operator.rb)

@[xml](verdict_assert_operator.xml)

#### verdict_assert_output?

```ruby
verdict_assert_output?(id, stdout = nil, stderr = nil) { || ... }
va_output?(id, stdout = nil, stderr = nil) { || ... }
```

Fails if stdout or stderr do not output the expected results. Pass in nil if you don't care about that streams output. Pass in '' if you require it to be silent. Pass in a regexp if you want to pattern match.

NOTE: this uses capture_io, not capture_subprocess_io.

@[ruby](verdict_assert_output.rb)

@[xml](verdict_assert_output.xml)

#### verdict_assert_predicate?

```ruby
verdict_assert_predicate?(id, o1, op, msg = nil)
va_predicate?(id, o1, op, msg = nil)
```

Fails if stdout or stderr do not output the expected results. Pass in nil if you don't care about For testing with predicates.

@[ruby](verdict_assert_predicate.rb)

@[xml](verdict_assert_predicate.xml)

