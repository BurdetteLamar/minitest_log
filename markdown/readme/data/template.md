## Data

Put data onto the log using method ```:put_data```.

A data object ```obj``` is treated as follows:

- If ```obj.kind_of?(String)```, it is treated as a [String](#strings)
- Otherwise if ```obj.respond_to?(:each_pair)```, it is treated as [Hash-like](#hash-like-objects).
- Otherwise, it ```obj.respond_to?(:each_with_index```, it is treated as [Array-like](#array-like-objects).
- Otherwise, it is treated as "[other](#other-objects)".

### Strings

An object that is a ```kind_of?(String)``` is logged simply.

@[ruby](kind_of_string.rb)

@[xml](kind_of_string.xml)

### Hash-Like Objects

Otherwise, an object that ```respond_to?(:each_pair)``` is logged as name-value pairs.

@[ruby](each_pair.rb)

@[xml](each_pair.xml)

### Array-Like Objects

Otherwise, an object that ```respond_to?(:each_with_index)``` is logged as a numbered list.

@[ruby](each_with_index.rb)

@[xml](each_with_index.xml)

### Other Objects

Otherwise, the logger tries, successively, to log the object using ```:to_s```,
```:inspect```, and ```:__id__```.

If all that fails, the logger raises an exception (which is not illustrated here).

@[ruby](to_s.rb)

@[xml](to_s.xml)

