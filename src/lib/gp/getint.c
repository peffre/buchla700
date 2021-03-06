/*
   =============================================================================
	getint.c -- convert a string to a 16 bit integer
	Version 2 -- 1988-09-21 -- D.N. Lynx Crowe
   =============================================================================
*/

#include "ctype.h"
#include "stddefs.h"

extern long atol ();

/*
   =============================================================================
	get_int(str, ap) -- convert 'str' to a 16 bit integer at 'ap'
   =============================================================================
*/

int
get_int (str, ap)
     register char *str;
     int *ap;
{
  register int i, sign, c;
  long arg;
  char *s;

  s = str;

  while (*str == ' ')
    ++str;

  while ('\0' != (c = 0x00FF & *str++))
    {

      if (c == '+')
	{

	  if (++sign > 1)
	    return (FAILURE);

	}
      else if (c == '-')
	{

	  if (++sign > 1)
	    return (FAILURE);

	}
      else
	{

	  if (! isascii (c))
	    return (FAILURE);

	  if (! isdigit (c))
	    return (FAILURE);
	}
    }

  if ((arg = atol (s)) > 65535L)
    return (FAILURE);

  *ap = arg;

  return (SUCCESS);
}
