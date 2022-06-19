Code.load_file("calculator.exs", ".")

calc = Calculator.start(10)
Calculator.add(calc, 10)
Calculator.sub(calc, 8)
Calculator.mult(calc, 2)
Calculator.div(calc, 3)
IO.puts(Calculator.value(calc))
