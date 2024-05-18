---
author: "Juan Carlos Martinez de la Torre"
date: 2024-05-01
linktitle: testing-tricks-in-elixir-4-table-tests
title: Testing tricks in Elixir - Table tests
intro: hello hello adfasdfasdf 
# toc: true
---


## Table tests in Elixir

One of the features I enjoyed when working with Go was the table tests. In Go, a table test is a common pattern that allows to write concise and expressive test cases, especially when testing multiple input-output combinations for a function. Here's an example of a table test in Go:

```go
func add(a, b int) int {
    return a + b
}

// Test table with two cases
var testCases = []struct {
    a, b, expected int
}{
    {2, 3, 5},
    {-2, -3, -5},
}

// Test function
func TestAdd(t *testing.T) {
    for _, tc := range testCases {
        t.Run("", func(t *testing.T) {
            result := add(tc.a, tc.b)
            if result != tc.expected {
                t.Errorf("%d + %d: expected %d, got %d", tc.a, tc.b, tc.expected, result)
            }
        })
    }
}
```

In Elixir it is not so straighforward having this kind of table test, though it is possible to have something similar. Let's say we have this repetitive test suite, where we are doing the same kind of checks over different sef of inputs:

```elixir
    defmodule Test do
      use ExUnit.Case
    
      test "1 plus 2 is 3" do
        assert 1 + 2 == 3
      end
    
      test "2 plus 3 is 5" do
        assert 2 + 3 == 5
      end
    
      test "4 plus 6 is 10" do
        assert 4 + 6 == 10
      end
    end
```

One way to generalize this test suite into one test that is applied for different inputs/ouputs could be introducing a `for` like:

```elixir
defmodule Test do
  use ExUnit.Case

  @test_cases [{{1, 2}, 3}, {{2, 3}, 5}, {{4, 6}, 10}]

  for {{input_1, input_2}, output} <- @test_cases  do
    test "#{input_1} plus #{input_2} is #{output}" do
      assert input_1 + input_2 == output
    end
  end
end
```

It is important to note that this `for` statement is executed at compile time. The compilation will run over this `for` block generating as many tests as elements in the `input_output_list`. However, with this approach we end up in this error:

```
== Compilation error in file test/phoenix_blog/test.exs ==
** (CompileError) test/phoenix_blog/test.exs:8: undefined function input_1/0 (expected Test to define
 such a function or for it to be imported, but none are available)

```

Basically, this error means that at runtime the variable `input_1` is not available. However, we have defined it at compile time, right? And we are also making use of it on the test description. Since we need now that variable at runtime, we have to use the [unquote()](https://hexdocs.pm/elixir/Kernel.SpecialForms.html#unquote/1) function, that is a way to inject the value of the variable at runtime. 

This would be the final version:

```elixir
defmodule Test do
  use ExUnit.Case

  @input_output_list [{{1, 2}, 3}, {{2, 3}, 5}, {{4, 6}, 10}]

  for {{input_1, input_2}, output} <- @input_output_list do
    test "#{input_1} plus #{input_2} is #{output}" do
      assert unquote(input_1) + unquote(input_2) ==  unquote(output)
    end
  end
end
```

