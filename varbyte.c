// from Standard MIDI File Format.pdf
//
#include <stdbool.h>
#include <stdio.h>
WriteVarLen(value)
register long value;
{
register long buffer;
buffer = value & 0x7f;
while((value >>= 7) > 0)
{
buffer <<= 8;
buffer |= 0x80;
buffer += (value &0x7f);
}
while (TRUE)
{
putc(buffer,outfile);
if(buffer & 0x80) buffer >>= 8;
else
break;
}
}
doubleword ReadVarLen()
{
register doubleword value;
register byte c;
if((value = getc(infile)) & 0x80)
{
value &= 0x7f;
do
{
value = (value << 7) + ((c = getc(infile)) & 0x7f);
} while (c & 0x80);
}
return(value);
}

