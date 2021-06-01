module dbey.simplemath;

auto sqrt (size_t i)
{
  size_t x = i;
  size_t y = (x + 1) >> 1;
  
  while (y < x)
  {
    x = y;
    y = (x + i / x) >> 1;
  }
  return x;
}

bool isOdd (int i)
{
  return i & 1;

}

bool isPrime (size_t xPrime)
{
  if (xPrime > 1)
  {
    for (size_t f = 2; f <= sqrt(xPrime); f++)
    {
      if (xPrime % f == 0)
      {
        return false;
      }
    }
  } else {
    return false;
  }
  return true;
}

unittest
{
  size_t test;
  foreach (n; 0..7920)
  {
    if (isPrime(n))
    {
      //n.writeln(" is a prime");
      test++;
    } else {
      //n.writeln();
    }
  }
  assert (test == 1000,
  "Because there are 1000 prime numbers up to 7920.");
  assert (isOdd(test) is false,
  "Because 1000 is not odd number.");
  assert (sqrt(test) == 31,
  "Because 31 squared is close to a thousand.");
}
