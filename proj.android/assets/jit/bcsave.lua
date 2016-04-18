LJ @./jit/bcsave.lua®    4   7    7  % > 4  7  ' > G  	exitos×Save LuaJIT bytecode: luajit -b[options] input output
  -l        Only list bytecode.
  -s        Strip debug info (default).
  -g        Keep debug info.
  -n name   Set module name (default: auto-detect from input name).
  -t type   Set output file type (default: auto-detect from output name).
  -a arch   Override architecture for object files (default: native).
  -o os     Override OS for object files (default: native).
  -e chunk  Use chunk string as input.
  --        Stop handling options.
  -         Use stdin as input and/or stdout as output.

File types: c h obj o raw (default)

writestderrio ¦  )   T  C E 4  7 7% C =4  7 7% >4 7' >G  	exitos
luajit: 
writestderriook   z  04    > TH    T)   +  4   > ?  Àloadfile-function	typecheck input   n  !6   T4 7H +  4 7   > ?  À	openstdoutio-check name  mode     -K4  7  >  +  6 %  > T  T H Àunknown 
lowerstringcheck str  map  err  s    $Q4  74  7  >% >+  6  T% H Àraw%.(%a+)$
lower
matchstringmap_type str  ext 	   V+  4  7  % >% >4  7  % % @ À_[%.%-]	gsubbad module name^[%w_.%-]+$
matchstringcheck str   Ò 
 'B[4    > T4 7  % >  T  4 7  % >  T  4 7  % >  T)   +    % >4 7  % %	 @ À_[%.%-]	gsub+cannot derive module name, use -n name^[%w_.%-]+^(.*)%.[^.]*$[^/\]+$
matchstring	type



check str  (tail head 	 ¸  9k  7   >  T T  7 >  +   %  %	 
 >G  À: cannot write 
close-
writecheck fp  output  s  ok err   k  
2q+    %  >+     >G  ÀÀwbsavefile bcsave_tail output  s  fp  á Q¨v+   %  >7  T
 74 7% + 7	 > =T 74 7% + 7	 
 + 7 > =2  '  '  '  '	 I4	 4 7
 
 > =   'N  T 74 7 % '  >% >'      9Ká+  	 4
 7

 % '  >
% $

>G  ÀÀÀ	
};
,
,concat
table	bytetostring7#define %s%s_SIZE %d
static const char %s%s[] = {
modnamej#ifdef _cplusplus
extern "C"
#endif
#ifdef _WIN32
__declspec(dllexport)
#endif
const char %s%s[] = {
formatstring
writec	typewsavefile LJBC_PREFIX bcsave_tail ctx  Routput  Rs  Rfp Mt 1n  1m  1     i b      Ò H   x   K  Ö +  7 +  7  >' @  
bswaprshift        bit x  	 G  Ù +  7   >+  H  
À
bswap       bit two32 x   ­Dî¶7 % >+  7 $) ) 7  T) T
7  T7  T7  T) 1  	 7
	%
 >

 T
+
 7
1   T
7
% (  >
1	 0
	 7
  T% T% >
7
7  T7  T4 4 7% % > =  7'	 > 7>7
  '	 >+ 78  T) T) %  >T	%! :3# 7 6  T'  :"  T' T' :$  T' T' :%' :& ' >:' 3) 7 6>:(7  T7 * T( :+ ' >:,	 7.
 %/ > = :- 71 > = :0 717/
8 > = :2 ' >:3 ' >:47.
 %5 >' 46 37 >T7/
6	 ' >:8  >:9775
 > ANì7/
8 ' >:'7/
8 ' >::7/
8 ' >:;7/
8	 ' >:87/
8	 7.
 %= > = :<7/
8	 717=
8 > = :>7/
8	 717=
> = :?7=
8 ' >:97=
8 ' >:@7=
8	  >:?7=
8' :;7/
8 ' >:'7/
8	  >:<7/
8	  >:?7/
8 ' >:'7/
8	 >:<7/
8	  >:?775
 > 7/
8 ' >:'7/
8	 ' >:+7/
8	 >:<7/
8	  >:?7/
8 ' >:'7/
8	  >:<+  %A > 7B7C
 71
 >> =+    >G  ÀÀÀÀÀstring
writewbsectidx	sizeentsizesymofs	info	link	name
align  .symtab.shstrtab.strtab.rodata.note.GNU-stackipairs
spaceshstridx
shnumshentsizesizeofehsize	sectoffsetof
shofsversion
flagsmipsel arm(ppc	mipsmipselx64>x86ppcspemachine	typeeversioneendianeclass freebsd	solarisopenbsdnetbsdeosabi	ELF/no support for writing native object filesemagic	copy
close	readrb/bin/ls	openioassert
otherbsdoshdrELF32objELF64objnew int64_t	cast 
bswapbeabi 	mipsppcspeppcx64	archmodnameï	typedef struct {
  uint8_t emagic[4], eclass, eendian, eversion, eosabi, eabiversion, epad[7];
  uint16_t type, machine;
  uint32_t version;
  uint32_t entry, phofs, shofs;
  uint32_t flags;
  uint16_t ehsize, phentsize, phnum, shentsize, shnum, shstridx;
} ELF32header;
typedef struct {
  uint8_t emagic[4], eclass, eendian, eversion, eosabi, eabiversion, epad[7];
  uint16_t type, machine;
  uint32_t version;
  uint64_t entry, phofs, shofs;
  uint32_t flags;
  uint16_t ehsize, phentsize, phnum, shentsize, shnum, shstridx;
} ELF64header;
typedef struct {
  uint32_t name, type, flags, addr, ofs, size, link, info, align, entsize;
} ELF32sectheader;
typedef struct {
  uint32_t name, type;
  uint64_t flags, addr, ofs, size;
  uint32_t link, info;
  uint64_t align, entsize;
} ELF64sectheader;
typedef struct {
  uint32_t name, value, size;
  uint8_t info, other;
  uint16_t sectidx;
} ELF32symbol;
typedef struct {
  uint32_t name;
  uint8_t info, other;
  uint16_t sectidx;
  uint64_t value, size;
} ELF64symbol;
typedef struct {
  ELF32header hdr;
  ELF32sectheader sect[6];
  ELF32symbol sym[2];
  uint8_t space[4096];
} ELF32obj;
typedef struct {
  ELF64header hdr;
  ELF64sectheader sect[6];
  ELF64symbol sym[2];
  uint8_t space[4096];
} ELF64obj;
	cdefÀþÀ
@2233344555667777777778<==>>>>>??@AABBBBCCEJJJJJJJKLLLLLLMMMMMMMNNNNOOOPPPPPQQQQQQQQQQQSSTTTTTTTVVVVVVWWWWWWXXYYYYZZZZZZ[[[[[[\\^^^^_______``````aaaaaaabbbbccccfffffgggijjkkkkllllmmmmmnnnggppppppqqqqqqrrrrrrsssssstttttttttuuuuuuuuuvvvvvvvvwwwwwwxxxxxxyyyyyyzzzz{{{{{{||||||}}}}}}~~~~~~LJBC_PREFIX bit check savefile bcsave_tail ctx  ïoutput  ïs  ïffi  ïsymname èis64 æisbe  æf32 Öf16 Ôfofs  Ôtwo32 o 
¼hdr »bf bs sofs aÉofs  É  i name  sect fp ²     Ü H   x   K  à +  7 +  7  >' @  
bswaprshift        bit x  	 í/×ß¦i7 % >+  7 $) 7  T%  $T7  T) %  % $1	  7	
%
 >	 	 T
+	 7	1 7	%
 >	7
	 3 7 6>:
 ' >:
 7	 % > = :
 ' >:
7	8 % :7	8   >:7	8  (  >:7	 ' >:7	' :7	% :7	' :7	  >:7	8% :7	8  >:7	8 ( >:7 	 ' >:7 	' :7 	% :7 	' :7!	  >:7"	 ' >:7"	' :7"	7# ' >;7$	 'ÿÿ>:7$	' :7$	 ' >:%7$	%& :7'7(	 >  >:)	7	8  7	 %( >>:*7'7(	 > 7	8 7	 %( >>:*+  %+ > 7,7-	 7.	 >> =+    >G  ÀÀÀÀsizeofstring
writewbofsstrtabsize
space	copy@feat.00
value	sym3nameref	sym2sym1aux	sym1.rdatasym0aux	nauxscl
flags	size.drectve	name	sect
nsyms	sym0offsetofsymtabofsnsects armÀppcò	mipsæmipselæx64äx86Ìhdr
PEobjnew 
bswapbeabi ,DATA    /EXPORT:x64_x86	archmodnameÛtypedef struct {
  uint16_t arch, nsects;
  uint32_t time, symtabofs, nsyms;
  uint16_t opthdrsz, flags;
} PEheader;
typedef struct {
  char name[8];
  uint32_t vsize, vaddr, size, ofs, relocofs, lineofs;
  uint16_t nreloc, nline;
  uint32_t flags;
} PEsection;
typedef struct __attribute((packed)) {
  union {
    char name[8];
    uint32_t nameref[2];
  };
  uint32_t value;
  int16_t sect;
  uint16_t type;
  uint8_t scl, naux;
} PEsym;
typedef struct __attribute((packed)) {
  uint32_t size;
  uint16_t nreloc, nline;
  uint32_t cksum;
  uint16_t assoc;
  uint8_t comdatsel, unused[3];
} PEsymaux;
typedef struct {
  PEheader hdr;
  PEsection sect[2];
  // Must be an even number of symbol structs.
  PEsym sym0;
  PEsymaux sym0aux;
  PEsym sym1;
  PEsymaux sym1aux;
  PEsym sym2;
  PEsym sym3;
  uint32_t strtabsize;
  uint8_t space[4096];
} PEobj;
	cdef¨@++,,,-...////00013333678888899:>>>?@@@@@@AAAABBBBBBBCCCCFFFFGGGGGGHHHHHHIIIIIJJJKKKLLLMMMMMNNNNOOOOOOPPPPPPQQQQQRRRSSSTTTUUUUUVVVVVWWWXXXXXXYYYYYZZZ[[[[[\\\]]]]^^____``````````aaaaabbccccccccccffffggggggggggghhhhhiLJBC_PREFIX bit savefile bcsave_tail ctx  Øoutput  Øs  Øffi  Øsymname Ñis64 Ðsymexport Áf32 Àf16 ¿o ´hdr ³ofs 4fp # > ô +  7    @  	band      bit v  a   ¬ Aî7 % >% +  7 $) ) ' % 7	 	 T	)	 '
 % 
 	 T	7	 	 T	)	 %	 	 T		+	 7
 

 T
)
 T)
 % >	1	 +
 7

7 >	 7 % >   >3 3 :
3 :3 :7 63 3 :
3 :3 :7 6  T
7
 ( >:7
  >:'   ' I'    T 76
 6>:
 6>:7 % >778 > 
  >: 
  >:!767"  T( T( :7"6:7"6:7"' :#7"' :$7"77&>77'>77(>:%7&  T' T' :)7&77&>77'>:*7& :+7&:,7& :-7&' :.7&' :/7&' :0717'72%3 >717'74%5 >7' :!7': 7(' :)7(77(>:*7(7 %7 >:67(' :87(7 %7 >777>:97(	    >::Kb77' :;77' :<77' :=717 >+  %> > 7?7@  > =+    >G  ÀÀÀÀÀstring
writewb	strx	sect	typestrsizestroff
nsymssym_entrysymoff__DATAsegname__datasectname	copynsectsinitprotmaxprotfilesizefileoffvmsizecmdsizecmdsymsecsegsizeofcmds
ncmdsfiletypehdr	sizeoffsetsizeofcpusubtypecputypefat_archnfat_arch
magicfat  	              
spaceoffsetofnew
bswap %unsupported architecture for OSXx86mach_fat_objarmmach_obj_64x64	archmach_objmodname_ñtypedef struct
{
  uint32_t magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds, flags;
} mach_header;
typedef struct
{
  mach_header; uint32_t reserved;
} mach_header_64;
typedef struct {
  uint32_t cmd, cmdsize;
  char segname[16];
  uint32_t vmaddr, vmsize, fileoff, filesize;
  uint32_t maxprot, initprot, nsects, flags;
} mach_segment_command;
typedef struct {
  uint32_t cmd, cmdsize;
  char segname[16];
  uint64_t vmaddr, vmsize, fileoff, filesize;
  uint32_t maxprot, initprot, nsects, flags;
} mach_segment_command_64;
typedef struct {
  char sectname[16], segname[16];
  uint32_t addr, size;
  uint32_t offset, align, reloff, nreloc, flags;
  uint32_t reserved1, reserved2;
} mach_section;
typedef struct {
  char sectname[16], segname[16];
  uint64_t addr, size;
  uint32_t offset, align, reloff, nreloc, flags;
  uint32_t reserved1, reserved2, reserved3;
} mach_section_64;
typedef struct {
  uint32_t cmd, cmdsize, symoff, nsyms, stroff, strsize;
} mach_symtab_command;
typedef struct {
  int32_t strx;
  uint8_t type, sect;
  int16_t desc;
  uint32_t value;
} mach_nlist;
typedef struct {
  uint32_t strx;
  uint8_t type, sect;
  uint16_t desc;
  uint64_t value;
} mach_nlist_64;
typedef struct
{
  uint32_t magic, nfat_arch;
} mach_fat_header;
typedef struct
{
  uint32_t cputype, cpusubtype, offset, size, align;
} mach_fat_arch;
typedef struct {
  struct {
    mach_header hdr;
    mach_segment_command seg;
    mach_section sec;
    mach_symtab_command sym;
  } arch[1];
  mach_nlist sym_entry;
  uint8_t space[4096];
} mach_obj;
typedef struct {
  struct {
    mach_header_64 hdr;
    mach_segment_command_64 seg;
    mach_section_64 sec;
    mach_symtab_command sym;
  } arch[1];
  mach_nlist_64 sym_entry;
  uint8_t space[4096];
} mach_obj_64;
typedef struct {
  mach_fat_header fat;
  mach_fat_arch fat_arch[4];
  struct {
    mach_header hdr;
    mach_segment_command seg;
    mach_section sec;
    mach_symtab_command sym;
  } arch[4];
  mach_nlist sym_entry;
  uint8_t space[4096];
} mach_fat_obj;
	cdefü
×¿¥¿»¿¿»¿YYZZZZ[[[[\\\]]]]]]^^^____aaaaaaaaacddggghhhhhhhhhhiiiiiiiiijjjjjjjjjkklllllmmmmmqqqqqrssttuuuuuvvvvvxxxxxxxxxxyyyyzzzzzz||}}}}}}}~~~~qLJBC_PREFIX check bit savefile bcsave_tail ctx  output  s  ffi  symname isfat is64  align  mobj  aligned ïbe32 ío êmach_size 
àcputype 	×cpusubtype 	Î  i ofs a a  xfp  ß 
 #r²
4  4 % >+   % >7  T+     	 @ T7  T+     	 @ T+     	 @ G  ÀÀÀÀosxwindowsos1FFI library required to write this file typeffirequire
pcall
check bcsave_peobj bcsave_machobj bcsave_elfobj ctx  $output  $s  $ok ffi     7À+    >4  % >7 +  % >) >G  ÀÀw	dumpjit.bcrequirereadfile savefile input  output  f   
 ,Å+   >4  7 7 >7   T+  > :  T+   >T7   T+  >:  T+    	 >T+    	 >G  ÀÀÀÀÀÀobjmodnameraw	type
strip	dumpstring					readfile detecttype bcsave_raw detectmodname bcsave_obj bcsave_c ctx  -input  -output  -f )s $t # ¡	 
®®Ù22  C  <  ' ) 3  +  7:4 7+  7>:   T~Q}6 4  > Tu4 7 ' ' > Tm Tk4 7	   >
 TTe'  ' I^4	 7		
   >		 T
) T
S	 T
)
 :
T
N	 T
)
 :
T
I6
 

  T

 
 T
+
 >
	 T
 T
+
 >
+
 4 8 > =
 ;
 T
4	 T
	+
 4 7	   > =
 :
T
)	 T
+
 4 7	   >+ % >
:
T
	 T
+
 4 7	   >+ % >
:
T
	 T
+
 4 7	   >+ % >
:
T
+
 >
K¢TT  T   T  '  T+ >+ 8 8   T% >T
   T+ >+	  8 8 >G   ÀÀÀÀ
ÀÀÀ	ÀÀÀOS nameoarchitectureafile typetmodnamenloadstringeg
stripsl--remove
table-sub	typeos
lowerstring	arch modname
strip	typeÀ 	














  !!!!!!!!!!!##&()++,,,,,,,,,--------/////000002jit usage check checkmodname checkarg map_type map_arch map_os bclist bcsave arg «n ªlist ©ctx 
a {_ _ _m ]opt W    +ê 4   % > 4 7   T) T) % >4  % >% 1 1 1	 1
 3 3 3	 1
 1 1 1 1 1 1 1 1 1 1 1 1 1 4 C  = 5 0  G  
startmodule               netbsdsolarisopenbsdosxfreebsdwindows
linux armppc	mipsmipselx64x86ppcspe rawrawcchhobjobjoobj    luaJIT_BC_bit)LuaJIT core/library version mismatchversion_numassertjitrequireÆ¸                ' . 4 9 = A F O T Y g o t  $0<CWjit (bit LJBC_PREFIX usage check readfile savefile map_type map_arch map_os checkarg detecttype checkmodname detectmodname bcsave_tail bcsave_raw bcsave_c bcsave_elfobj bcsave_peobj bcsave_machobj 
bcsave_obj 	bclist bcsave docmd   