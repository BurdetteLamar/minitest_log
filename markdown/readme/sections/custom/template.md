### Custom Elements

Use method ```put_element(name, *args)``` to put custom elements onto the log.  The name must be text that can become a legal XML element name.

Method ```section``` just calls ```put_element``` with the name ```section```, so the remaining allowed ```*args``` are the same for both :

- A string becomes text.
- A hash-like object becomes attributes.
- An array-like object becomes a numbered list.

A call to ```put_element``` with no block generates a childless element -- one with no sub-elements (though it may still have text).

Create sub-elements for a custom element by calling ```put_element``` with a block.  Whatever elements are generated by the block become sub-elements of the custom element.

@[ruby](example.rb)

@[xml](log.xml)

