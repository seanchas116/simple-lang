simple-lang
===========

A very simple programming language written in Ruby.

Features:

* Floating-point and function literals
* Variables
* Arithmetic operations
* case-when statement

Using [Parslet](http://kschiess.github.io/parslet/) for constructing the parser.

Examples
----

Example (Closure):

    get_counter = () =>
      count = 0
      () =>
        count = count + 1
      end
    end

    counter = get_counter()

    print(counter())
    print(counter())

Result:

    1.0
    2.0

Example (Recursion):

    sum = (x, memo) =>
      case x
      when 0
        memo
      else
        sum(x-1, memo + x)
      end
    end

    print(sum(10, 0))

Result:

    55.0

Example (Object):

    Counter = () =>
      self = Object()
      count = 0
      self.get_count = () =>
        count
      end
      self.increment = () =>
        count = count + 1
      end
      self
    end

    c = Counter()
    print(c.get_count())
    c.increment()
    print(c.get_count())

Result:

    0.0
    1.0

License
----

The MIT License.
