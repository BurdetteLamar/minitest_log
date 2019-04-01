## Data

Put data onto the log using method ```:put_data```.

Generally speaking, a collection will be explicated in the log.

### Strings

An object that is a ```kind_of?(String)``` is logged simply.

@[ruby](kind_of_string.rb)

@[xml](kind_of_string.xml)

### Hash-Like Objects

Otherwise, an object that ```respond_to?(:each_with_pair)``` is logged as name-value pairs.

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

