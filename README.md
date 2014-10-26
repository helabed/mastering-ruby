mastering-ruby
==============

my attempt at mastering ruby motivated by Dave Thomas video tutorials https://pragprog.com/screencasts/v-dtrubyom/the-ruby-object-model-and-metaprogramming

<pre>
helabed@hani-elabeds-MacBook-Pro:~/mastering-ruby(master) $ rspec ./*_spec.rb -f doc

blocks, Procs and lambdas.
  many ways to define/create an object out of a block.
    can be created with a lambda
    can be created with Proc.new
    can be created when passed as a method parameter with an '&' prepended - internally same as Proc.new
    and a deprecated way to do it, is same as lambda in Ruby 1.8, and Proc.new in Ruby 1.9
      can be created with a with a call to the built in method 'proc' - so avoid it
  Proc.new is liberal in dealing with parameters passing - behaves like parallel assignemnt.
    runs fine when passed the exact number of arguments as it was defined
    runs fine when passed the exact number of string arguments as it was defined
    runs fine when passed a smaller number of arguments as it was defined
    runs fine when passed a larger number of arguments as it was defined
    runs fine when passed a larger number of arguments and when it is defined with a variable argument list
  lambda is restrictive in dealing with parameters passing - behaves like a method call.
    runs fine when passed the exact number of arguments as it was defined
    runs fine when passed the exact number of string arguments as it was defined
    raises an error when passed a smaller number of arguments as it was defined
    raises an error when passed a larger number of arguments as it was defined
    runs fine when passed a larger number of arguments and when it is defined with a variable argument list
  a 'return' statement from Proc.new exists the surrounding context - behaves like inline code.
    should exit surrounding method and should not reach bottom of method
    should exit the method as expected when code inside a block hits a return statement
  a 'return' statement from lambda exists the proc only - behaves like a method.
    should exit the block only and should reach bottom of method
  a 'binding' is the context in which code is executing.
    should provide access to all variables in this binding including all passed parameters, instance variables, and local variables
    should provide access to all associated block in this binding
    should provide access to 'self' in this binding
    Ruby provides a binding with every block it creates - with lambda
    Ruby provides a binding with every block it creates - with Proc.new
  a 'reference' to the block can be passed around with an '&'
    then the bloack can be called with the call method

children of Struct
  should display all its subclasses

class_eval or module_eval
  allows us to execute any code inside a block where the receiver is a class or a module
    should execte any code where the receiver is a class
    should execte any code where the receiver is a module
  allows us to define methods inside a block
    should allow us to define instance methods on the class itself
    everytime we call class_eval on a class, ruby places the newly defined methods(instance methods) inside it, and makes it the current class of the receiver of class_eval
    class_eval would declare instance methods, because class_eval can be called only on classes and modules in ruby - the name reflects the receiver
    instance_eval would declare class methods, because instance_eval can be called on every single object in ruby - the name reflects the receiver
    see file 'receiver_a_class__class_eval__creates_instance_methods.png' to find out what the 'def' method does inside class_eval
    see file 'receiver_a_class__instance_eval__creates_class_methods.png' to find out what the 'def' method does inside instance_eval
    see file 'receiver__xxx_eval__truth_table.png' to find out what the 'def' method does for all cases
  allows us to define methods or code inside a class given a class object
    should allow us to define instance methods on the class itself

Class Methods
  can be created with self
    should be called without an instance
  can be created with class << self
    should be called without an instance

Class Variables
  can be created with self
    should be called without an instance
  can be created with class << self
    should be called without an instance

color enumeration
  using different classes
    should define color enumeration classes on the fly
    should be distinct from other classes color enumeration schemes
  using Single Enum class
    should define color enumeration classes on the fly without conflicting with others and remember its name

count with increment method
  hanis solution
    should return start first time called
    should return start + inc when called after first time(2nd)
    should return start + inc when called after first time(3rd)
    should return start + inc when called after first time(4th)
  daves solution
    should return start first time called
    should return start + inc when called after first time(2nd)
    should return start + inc when called after first time(3rd)
    should return start + inc when called after first time(4th)

define_method
  is available only inside a class or a module
    should allow us to create a simple statically named method inside a class
    should allow us to create a dynamically named method inside a class
    should allow us to create many dynamically named methods(i.e many similar methods) inside a class
    it should allow us to create a simple statically named method inside a module
      can access the method when using the 'include' keyword
      can access the method when using the 'extend' keyword
  is NOT available inside a singleton object, but just for classes or modules
    should raise error when we attempt to use it inside an object
  can be made available inside a singleton object with the help of class_eval
    should allow us to create methods inside a class
  can be made available inside a singleton object's ghost subclass with the help of class_eval
    should allow us to create methods inside a class

Enumerable filters
  - find
    returns the first item in the collection for which the block evaluates to true
    returns nil if no such item was found
  - detect (same as find)
    returns the first item in the collection for which the block evaluates to true
    returns nil if no such item was found
  - find_all
    returns all items in the collection for which the block evaluates to true
    returns empty array if no such item was found
  - select (same as find_all)
    returns all items in the collection for which the block evaluates to true
    returns empty array if no such item was found
  - reject
    returns all items in the collection for which the block evaluates to false
    returns empty array if none of the items for which the block evaluates to false
  - grep(x)
    returns all items in the collection for which x === item

Enumerable predicates
  - all?
    returns true if the given block evaluates to true for all items in the collection
    returns false if the given block evaluates to false for at least one item in the collection
  - any?
    returns true if the given block evaluates to true for any item in the collection (at least one)
    returns false if the given block evaluates to false for all items in the collection (none of the items evaluates to true)
  - include?(x)
    returns true if x is a member of the collection
    returns false if x is NOT a member of the collection
  - member?(x) (same as include)
    returns true if x is a member of the collection
    returns false if x is NOT a member of the collection

Enumerable transformers
  - map
    returns the transformed collection for which the block is applied to each element of original collection
  - collect (same as map)
    returns the transformed collection for which the block is applied to each element of original collection
  - partition (same as [select(&block), reject(&block)])
    returns 2 arrays for which all items in the collection whose blocks evaluate to true and false, respectively
  - sort
    returns the transformed sorted collection by the given block or the elements own <=> operator
  - sort_by
    returns sorted collection using criteria in given block

ruby hook methods
  - method related hooks:
    method_missing
      should do method_missing
    method_added
      should do be triggered everytime we add a method to a class
    singleton_method_added
      should do singleton_method_added
    method_removed
      should do method_removed
    singleton_method_removed
      should do singleton_method_removed
    method_undefined
      should do method_undefined
    singleton_method_undefined
      should do singleton_method_undefined
  - for Classes and Modules:
    inherited
      should show us who inherited from us with help of a stack
      should show us who inherited from us with help of a queue
    append_features
      should do append_features
    included
      should do included
    extend_object
      should do extend_object
    extended
      should do extended
    initialize_copy
      should do initialize_copy
    const_missing
      should do const_missing by brute force overriding original
      should do const_missing by using method alias chain and delegating to original when needed
      should be restricted to a single class or module when defined inside this class or module
  - for Marshalling:
    marshal_dump
      should do marshal_dump
    marshal_load
      should do marshal_load
  - for Coercion:
    coerce
      should do coerce
    induced_from
      should do induced_from
    to_s
      should do to_s
    to_sym
      should do to_sym
    to_proc
      should do to_proc
    to_string
      should do to_string
  - example of including comparable
    should trigger the space-ship operator (<=>) method
    should trigger the Ruby built-in hook method included

instance_eval
  allows us to execute any code inside a block - unlike eval
    should execte any code
    should execte any code with a receiver - unlike eval which is a private method
    inside the block of the receiver 'self' is set to the receiver of instance_eval
    allow us to cheat and access instance variables without a getter or a setter
      without instance_eval we should not be able to access the instance variable
      with instance_eval we should be able to access the instance variable
      without instance_eval we should not be able to access private methods
      with instance_eval we should be able to access private methods - i.e methods without a receiver
      instance_eval with a block produces a closure but not as we expect in that inside the block self is changed to the receiver of instance_eval
  allows us to define methods inside a block
    should allow us to define methods on any instance of a class
    everytime we call instance_eval on an object, ruby creates an anonymous ghost class and places the newly defined methods inside it, and makes it the class of the receiver of instance_eval
    should allow us to define methods on the class itself (class methods) - because a class is also an object in ruby
    everytime we call instance_eval on a class, ruby creates an anonymous ghost class and places the newly defined methods(class methods) inside it, and makes it the current class of the receiver(which is a class) of instance_eval
    class_eval would declare instance methods, because class_eval can be called only on classes and modules in ruby - the name reflects the receiver
    instance_eval would declare class methods, because instance_eval can be called on every single object in ruby - the name reflects the receiver
    see file 'receiver_a_class__class_eval__creates_instance_methods.png' to find out what the 'def' method does inside class_eval
    see file 'receiver_a_class__instance_eval__creates_class_methods.png' to find out what the 'def' method does inside instance_eval
    see file 'receiver__xxx_eval__truth_table.png' to find out what the 'def' method does for all cases
  allows us to create a Domain Specific Language(DSL) in a block
    should allow us to define and use a DSL inside a block - though people are moving away from such implementation because of wrong assumption that we have a closure around the block

instance variables
  are private to the object that created them
    should not allow access from the outside without a getter
    should allow access from the outside only when a getter is defined
    should not allow modification from the outside without a setter
    should allow modification from the outside only when a setter is defined with help of class_eval and attr_writer
    should allow modification from the outside only when a setter is defined with help of class_eval and attr_accessor

memoization examples - many ways to do it - subclassing, method rewriting, delegation
  example without memoization
    should execute expensive calculation each time
  memoization with a hash
    should execute expensive calculation once
  memoization using a subclass
    should execute expensive calculation once
  memoization using a subclass with code generation
    should execute expensive calculation once
  memoization using a subclass with code generation and without adding instance variables(@memory) to the original class - thanks to closure around define_method
    should execute expensive calculation once
  memoization using a ghost class to intercept the call chain in lieu of subclassing whole class
    should execute expensive calculation once
  memoization using a ghost class with code generation to create a hidden singleton class
    should execute expensive calculation once - see 'create_a_ghost_class_from_an_object.png'
  memoization using intrusive method re-writing after opening class
    should execute expensive calculation once
  memoization using a module to generically do the method re-writing
    should execute expensive calculation once
  memoization using a module and bind to generically do the method re-writing
    should execute expensive calculation once
  memoization using a module and a DSL to generically do the method re-writing
    should execute expensive calculation once
  memoization using Delegation
    should execute expensive calculation once (PENDING: not done yet)

Modulization
  for namespacing constants and classes
    should provide access to the module's constant
    should provide access to the module's class
  for defining and finding module methods with namespaces
    should provide access to the module's methods
  for creating instance methods
    should provide access to the module's instance method
    should assert that to 'include' a module's instance method does not mean copying the method's body, but instead referencing the one and only copy of it
    should be available for use from more than one class
    should be available for use from an object with the 'extend' keyword
    should be available for use from an object by including the methods from the module into a singleton class using 'class < < object'
  for converting a module instance methods into class methods of the class that is mixing in the module
    should provide access to the module's instance method as a class method using a singleton class using 'class < < self'
    should provide access to the module's instance method as a class method using the 'extend' keyword
    should provide access to the module's instance method as a class method using the 'extend' keyword and from within the extending class at the class level
  for inheritance without subclassing
    with include and extend keywords
      must provide access to class methods and instance methods of the module
        should provide access to class methods
        should provide access to instance methods
    with include only keywords, and with help of self.included(the_class) ruby hook
      must provide access to class methods and instance methods of the module
        should provide access to class methods
        should provide access to instance methods
  using alias method chain to override a method in a class that includes a module
    without calling alias_method
      does not work as intended because any included modules are searched for methods after the class's own methods are searched, so you cannot directly overwrite a class's method by including a module
    with a call to alias_method
      works as intended in that they allow us to overwrite a class's method by including a module and using a different method name

my_attr_accessor
  provides an alternative implementation of attr_accessor with logging support
    should allow us to use it from any class
  a symbol is converted to string automatically when interpolated inside a string
    should produce a string class

my_attr_accessor_with_class_eval
  provides an alternative implementation of attr_accessor with class_eval instead of define_method because class_eval is more efficient in memory and speed
    should allow us to use it from any class

Object based inheritance or prototypal inheritance
  methods can be created from object instances
    methods can be called from the instance
    a cloned object inherits the instance methods
    a duplicated object does not inherit the instance methods
  cloned objects also inherit the state of the cloned object
    instance variables are cloned also

a Ruby method
  always return the last statement executed
    should return the last statememnt from if block when an if{...} statement is truthy
    should return the last statememnt from else block when an if{...} statement is falsy
    should return nil when we have if (nil) as the last statement and no else block
    should return last statement in else block when we have if (nil) as the last statement

inherited in practice using shipping example in one file
  should be able to Ship 16oz domestic
  should be able to Ship 90oz domestic
  should be able to Ship 16oz international

inherited in practice using shipping example in one file
  should be able to Ship 16oz domestic
  should be able to Ship 90oz domestic
  should be able to Ship 16oz international

trace method calls
  - first iteration
    should trace a simple method everytime it is called with the help of define_method with block in Ruby 1.9
  - second iteration
    should trace a simple method everytime it is called with the help of class_eval and without define_method so that it can work with Ruby 1.8
  - third iteration
    should trace simple and complex methods(<<,[], and variable=) everytime it is called with the help of instance_method and Ruby 1.9
  - sidenote - prove that a CONST is available from within both a Ruby class and its instance
    should have access to the CONST at the class level
    should have access to the CONST from any instance of the class
  - forth iteration
    should trace simple and complex methods(<<,[], and variable=) everytime it is called with the help of instance_method and Ruby 1.8 and METHOD_HASH
  - fifth iteration
    should trace any existing class in Ruby 1.8 - try it with Time class
  - sixth iteration
    should trace any existing class in Ruby 1.8 - try it with String class - turn tracing OFF for String class while doing the tracing
  - seventh iteration
    should trace any existing class in Ruby 1.8 - with nested classes
  - eighth iteration
    should trace any existing class in Ruby 1.8 - with nested classes and dealing with recursive Array#inspect
  - nineth iteration
    should trace any existing class in Ruby 1.9 - with nested classes and with method_define with block support

Pending:
  memoization examples - many ways to do it - subclassing, method rewriting, delegation memoization using Delegation should execute expensive calculation once
    # not done yet
    # ./memoization_example_spec.rb:564

Finished in 0.12168 seconds
188 examples, 0 failures, 1 pending 
</pre>
