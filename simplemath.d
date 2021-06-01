module simplemath;

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
