Red []

i: 0
loop 100
[
  i: i + 1
  either (mod i 15) = 0 [prin "FizzBuzz"] [
    either (mod i 3) = 0 [prin "Fizz"] [
      either (mod i 5) = 0 [prin "Buzz"] [
        prin i
  ]]]
  prin " "
]
print " "
print "---------------------------------------------"
i: 0
loop 100
[
  i: i + 1
  if (mod i 3) = 0 [prin "Fizz" ]
  either (mod i 5) = 0 [prin "Buzz"] [
  if (mod i 3) <> 0 [prin i] ]
  prin " "
]