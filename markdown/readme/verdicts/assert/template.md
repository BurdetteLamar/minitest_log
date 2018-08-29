## Truth

This example shows how assert and refute truthiness.

@[ruby](example.rb)

In the call to method ```log.verdict_assert?```, the three arguments are:

- A ```Symbol``` verdict identifier.
- An truth value ```Object``` to be verified.
- An optional ```String``` message.

The method tests whether the valus is truthy, logs the verdict, and  returns a boolean, in this case ```true```.

The call to method ```log.verdict_assert?```, is similar, but tests whether the value is not truthy.

Here's the log showing the verdicts:

@[xml](log.xml)

