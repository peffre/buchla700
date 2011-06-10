/**
*
* This file contains macro definitions for use with the Atari specific
* functions gemdos,bios and xbios (see manual section 5.5)
*
**/

extern bios ();
extern xbios ();
extern gemdos ();

/* GEMDOS functions (trap #1) */

#define Pterm0()       gemdos(0x0)
#define Cconin()       gemdos(0x1)
#define Cconout(a)     gemdos(0x2,a)
#define Cauxin()       gemdos(0x3)
#define Cauxout(a)     gemdos(0x4,a)
#define Cprnout(a)     gemdos(0x5,a)
#define Crawio(a)      gemdos(0x6,a)
#define Crawcin()      gemdos(0x7)
#define Cnecin()       gemdos(0x8)
#define Cconws(a)      gemdos(0x9,a)
#define Cconrs(a)      gemdos(0x0a,a)
#define Cconis()       gemdos(0x0b)
#define Dsetdrv(a)     gemdos(0x0e,a)
#define Cconos()       gemdos(0x10)
#define Cprnos()       gemdos(0x11)
#define Cauxis()       gemdos(0x12)
#define Cauxos()       gemdos(0x13)
#define Dgetdrv()      gemdos(0x19)
#define Fsetdta(a)     gemdos(0x1a,a)
#define Super(a)       gemdos(0x20,a)
#define Tgetdate()     gemdos(0x2a)
#define Tsetdate(a)    gemdos(0x2b,a)
#define Tgettime()     gemdos(0x2c)
#define Tsettime(a)    gemdos(0x2d,a)
#define Fgetdta()      gemdos(0x2f)
#define Sversion()     gemdos(0x30)
#define Ptermres(a,b)  gemdos(0x31,a,b)
#define Dfree(a,b)     gemdos(0x36,a,b)
#define Dcreate(a)     gemdos(0x39,a)
#define Ddelete(a)     gemdos(0x3a,a)
#define Dsetpath(a)    gemdos(0x3b,a)
#define Fcreate(a,b)   gemdos(0x3c,a,b)
#define Fopen(a,b)     gemdos(0x3d,a,b)
#define Fclose(a)      gemdos(0x3e,a)
#define Fread(a,b,c)   gemdos(0x3f,a,b,c)
#define Fwrite(a,b,c)  gemdos(0x40,a,b,c)
#define Fdelete(a)     gemdos(0x41,a)
#define Fseek(a,b,c)   gemdos(0x42,a,b,c)
#define Fattrib(a,b,c) gemdos(0x43,a,b,c)
#define Fdup(a)        gemdos(0x45,a)
#define Fforce(a,b)    gemdos(0x46,a,b)
#define Dgetpath(a,b)  gemdos(0x47,a,b)
#define Malloc(a)      gemdos(0x48,a)
#define Mfree(a)       gemdos(0x49,a)
#define Mshrink(a,b)   gemdos(0x4a,0,a,b)	/* NOTE: Null parameter added */
#define Pexec(a,b,c,d) gemdos(0x4b,a,b,c,d)
#define Pterm(a)       gemdos(0x4c,a)
#define Fsfirst(a,b)   gemdos(0x4e,a,b)
#define Fsnext()       gemdos(0x4f)
#define Frename(a,b,c) gemdos(0x56,a,b,c)
#define Fdatime(a,b,c) gemdos(0x57,a,b,c)

/* BIOS functions (trap #13) */

#define Bconstat(a)      bios(1,a)
#define Bconin(a)        bios(2,a)
#define Bconout(a,b)     bios(3,a,b)
#define Rwabs(a,b,c,d,e) bios(4,a,b,c,d,e)
#define Setexc(a,b)      bios(5,a,b)
#define Bcostat(a)       bios(8,a)
#define Mediach(a)       bios(9,a)
#define Drvmap()         bios(10)
#define Getshift()       bios(11)

/* XBIOS functions (trap #14) */

#define Initmous(a,b,c)        xbios(0,a,b,c)
#define Physbase()             xbios(2)
#define Logbase()              xbios(3)
#define Getrez()               xbios(4)
#define Setscreen(a,b,c)       xbios(5,a,b,c)
#define Setpallete(a)          xbios(6,a)
#define Setcolor(a,b)          xbios(7,a,b)
#define Floprd(a,b,c,d,e,f,g)  xbios(8,a,b,c,d,e,f,g)
#define Flopwr(a,b,c,d,e,f,g)  xbios(9,a,b,c,d,e,f,g)
#define Midiws(a,b)            xbios(12,a,b)
#define Mfpint(a,b)            xbios(13,a,b)
#define Iorec(a)               xbios(14,a)
#define Rsconf(a,b,c,d,e,f)    xbios(15,a,b,c,d,e,f)
#define Keytbl(a,b,c)          xbios(16,a,b,c)
#define Random()               xbios(17)
#define Protobt(a,b,c,d)       xbios(18,a,b,c,d)
#define Flopver(a,b,c,d,e,f,g) xbios(19,a,b,c,d,e,f,g)
#define Prtblk()               xbios(20)
#define Cursconf(a,b)          xbios(21,a,b)
#define Settime(a)             xbios(22,a)
#define Gettime()              xbios(23)
#define Bioskeys()             xbios(24)
#define Ikbdws(a,b)            xbios(25,a,b)
#define Jdisint(a)             xbios(26,a)
#define Jenabint(a)            xbios(27,a)
#define Giaccess(a,b)          xbios(28,a,b)
#define Offgibit(a)            xbios(29,a)
#define Ongibit(a)             xbios(30,a)
#define Xbtimer(a,b,c,d)       xbios(31,a,b,c,d)
#define Dosound(a)             xbios(32,a)
#define Setprt(a)              xbios(33,a)
#define Kbdvbase()             xbios(34)
#define Kbrate(a,b)            xbios(35,a,b)
/* #define Prtblk()               xbios(36) */
#define Vsync()                xbios(37)
#define Supexec(a)             xbios(38,a)
