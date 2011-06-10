/*
   =============================================================================
	memset.c -- fill memory
	Version 1 -- 1987-06-12

	Set an array of n chars starting at sp to the character c.
	Return sp.
   =============================================================================
*/

char *
memset (sp, c, n)
     register char *sp, c;
     register int n;
{
  register char *sp0 = sp;

  while (--n >= 0)
    *sp++ = c;

  return (sp0);
}
