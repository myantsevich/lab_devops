# groovyTests

## Task 1
`task1.groovy` - function `int sum(int, int)`, summ 2 numbers. Example - `sum(1,4) == 5` 

## Task 2
`task2.groovy` - function `[] mulEvenOdd([])`, return a list of input elements, where odd numbers are multiplied by 3 and even numbers by 2. Example - `mulEvenOdd([4,5,6]) == [8,15,12]` 

## Task 3
`task3.groovy` - function `boolean isSublist([], [])`, define, whether second list sublist of the first list. Example - `isSublist([1,2,3], [2,3]) == true` 

## Task 4
`task4.groovy` - function `int fib(int)`, return n-th element of [Fibonacci's sequence](https://en.wikipedia.org/wiki/Fibonacci_number). Example - `fib(4) == 3`

## Task 5
`task5.groovy` - function `boolean isIp(string)`, define, whether input string have a Ip format. Example - `isSublist(10.0.152.164) == true`

## Task 6
`task6.groovy` - function `[:] adults(string)`, find all adults in the input map and return them as map. Example - `adults([Kate: 24, Alan:16, Osvald: 18]) == [Kate: 24, Osvald: 18]`

## Task 7
`task7.groovy` - function `[:] encryptThis(string)`, You need to encrypt input string. Conditions:
- string is a space separated words
- you need to encrypt each word using following rules:
  * The first letter needs to be converted to its ASCII code
  * The second letter needs to be switched with the last letter
Example - `encryptThis("Hello") == "72olle", .encryptThis("hello world") == "104olle 119drlo"`

## Task 8
`task8.groovy` - function `string parseAndFilterJson(string)`, parse input json, find all entries, and return another json with values where sum of digits in value field equal to 9. Example - `parseAndFilterJson("{\"Kate\":18,\"Alan\":16,\"Osvald\":27}") == "{\"Kate\":18,\"Osvald\":27}"`

## Task 9
`task9.groovy` - function `string exec(string)`, execute input string as a system command and return output(**output must be trimmed using .trim() function**). Example - `exec("date") == "Mon Dec  3 22:40:34 +03 2018"`

## Task 10
`task10.groovy` - function `string urlText(string)`, perform a URL request to the address, specified in function and return text output. Example - `urlText("http://httpstat.us/200") == "200 OK"`

## Task 11
`task11.groovy` - function `string gstring(string, int)`, string to be used as default - "1() 2() 3()". You need to insert first input string inside the brackets, near the number, which equals to the second input parameter. Example - `gstring("test", 2) == "1() 2(test) 3()"`

## Calculator (optional)
`calculator.groovy` - function `int exec(string)`, calculate input expression. Example - `exec("6(3+1)") == 24, exec("1+9/3") == 4`
