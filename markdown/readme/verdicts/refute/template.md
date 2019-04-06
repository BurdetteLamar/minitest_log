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

