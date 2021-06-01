/* DMD64 D Compiler v2.092.1-dirty
 * 
 * dmd -w -of"firstTest" "BooleanSieve.d" dbey\simplemath.d
 * 
 * Verification Source:
 * https://primes.utm.edu/lists/small/1000.txt
 * https://primes.utm.edu/lists/small/millions/primes1.zip
 */
  import std.stdio, std.format;
  import dbey.simplemath;
  
  class BooleanSieve
  {
    bool[] data;
    size_t[] list;
    size_t size;
//*/
    this(size_t limit)
    { // First prime number is 2 ~~~v
      this.data ~= [ false, false, true ];
      for (size_t l = 3; l <= limit; l += 2)
      { // Even numbers are false
        this.data ~= [ true, false ]; // odd/even
      }
      this.size = this.data.length;
    }
//*/    
    size_t length () @property
    {
      return this.list.length;
    }
//*/    
    auto factorSet (size_t f) @property
    {
      for (size_t s = f*2; s < this.size; s += f)
      {
        this.data[s] = false;
      }
    }
//*/
    auto primeList () @property
    {
      if (this.length < 1)
      {
        foreach (i, p; this.data)
        {
          if (p) this.list ~= i;
        }
      }                
      return this.list;
    }
//*/
    override string toString()
    {
      string result;
      uint xRow;
      
      foreach(p; this.primeList)
      {
        xRow++;
        if (xRow < 10)
        {
          result ~= format!"%9s"(p);
        } else {
          result ~= format!"%9s\n"(p);
          xRow = 0;
        }
      }
     return result;
   }
 }
// First one thousand prime number
   immutable test2 = 15_485_863;
// First 1.000.000 prime number
void main()
{
  immutable test1 = 7919; // First 1000 prime number
  auto ES = new BooleanSieve (test1);
  for (size_t i = 3; i < sqrt(test1); i += 2)
  {
    ES.factorSet(i);
  }
  auto first1000Prime = ES.primeList;
  //ES.writeln;/*/
  ES = new BooleanSieve (test2);
  foreach (f; first1000Prime)
  {
    ES.factorSet(f);
  }
  ES.writeln;
  "There are ".writeln(ES.length,
  " prime numbers up to ", test2,
  " because more can be eliminated" ~
  " with one thousand prime numbers.");
//*/
}
