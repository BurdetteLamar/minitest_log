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
vr_equal?(id, exp, act, msg = nil)
```
Fails if ```exp == act```.

For floats use verdict_refute_in_delta?.

@[ruby](verdict_refute_equal.rb)

@[xml](verdict_refute_equal.xml)

#### verdict_refute_in_delta?

```ruby
verdict_refute_in_delta?(id, exp, act, delta = 0.001, msg = nil)
vr_in_delta?(id, exp, act, delta = 0.001, msg = nil)
````

For comparing Floats. Fails if ```exp``` is within ```delta``` of ```act```.

@[ruby](verdict_refute_in_delta.rb)

@[xml](verdict_refute_in_delta.xml)

#### verdict_refute_in_epsilon?

```ruby
verdict_ refute_in_epsilon?(id, a, b, epsilon = 0.001, msg = nil) 
vr_in_epsilon?(id, a, b, epsilon = 0.001, msg = nil) 
```

For comparing Floats. Fails if ```exp``` and ```act``` have a relative error less than ```epsilon```.

@[ruby](verdict_refute_in_epsilon.rb)

@[xml](verdict_refute_in_epsilon.xml)

#### verdict_refute_includes?

```ruby
verdict_refute_includes?(id, collection, obj, msg = nil) 
vr_includes?(id, collection, obj, msg = nil) 
```

Fails if ```collection``` includes ```obj```.

@[ruby](verdict_refute_includes.rb)

@[xml](verdict_refute_includes.xml)

#### verdict_refute_instance_of?

```ruby
verdict_refute_instance_of?(id, cls, obj, msg = nil)
vr_instance_of?(id, cls, obj, msg = nil)
```

Fails if ```obj``` is an instance of ```cls```.

@[ruby](verdict_refute_instance_of.rb)

@[xml](verdict_refute_instance_of.xml)

#### verdict_refute_kind_of?

```ruby
verdict_refute_kind_of?(id, cls, obj, msg = nil)
vr_kind_of?(id, cls, obj, msg = nil)
```

Fails if ```obj``` is a kind of ```cls```.

@[ruby](verdict_refute_kind_of.rb)

@[xml](verdict_refute_kind_of.xml)

#### verdict_refute_match?

```ruby
verdict_refute_match?(id, matcher, obj, msg = nil)
vr_match?(id, matcher, obj, msg = nil)
```

Fails if ```matcher =~ obj```.

@[ruby](verdict_refute_match.rb)

@[xml](verdict_refute_match.xml)

#### verdict_refute_nil?

```ruby
verdict_refute_nil?(id, obj, msg = nil)
vr_nil?(id, obj, msg = nil)
```

Fails if ```obj``` is nil.

@[ruby](verdict_refute_nil.rb)

@[xml](verdict_refute_nil.xml)

#### verdict_refute_operator?

```ruby
verdict_refute_operator?(id, o1, op, o2 = UNDEFINED, msg = nil)
vr_operator?(id, o1, op, o2 = UNDEFINED, msg = nil)
````

Fails if ```o1``` is not ```op``` ```o2```.

@[ruby](verdict_refute_operator.rb)

@[xml](verdict_refute_operator.xml)

#### verdict_refute_predicate?

```ruby
verdict_refute_predicate?(id, o1, op, msg = nil)
vr_predicate?(id, o1, op, msg = nil)
```

For testing with predicates.

@[ruby](verdict_refute_predicate.rb)

@[xml](verdict_refute_predicate.xml)

#### verdict_refute_respond_to?

```ruby
verdict_refute_respond_to?(id, obj, meth, msg = nil)
vr_respond_to?(id, obj, meth, msg = nil)
```

Fails if ```obj``` responds to ```meth```.

@[ruby](verdict_refute_respond_to.rb)

@[xml](verdict_refute_respond_to.xml)

