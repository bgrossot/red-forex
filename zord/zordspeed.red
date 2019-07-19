Red []

i: 0
loop 5000000
[
  i: i + 1
  if (mod i 3) = 0 [prin "Fizz" ]
  either (mod i 5) = 0 [prin "Buzz"] [
  if (mod i 3) <> 0 [prin i] ]
  prin " "
]
