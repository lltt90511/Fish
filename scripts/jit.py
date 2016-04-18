import os,sys  
  
srcdir = './'  
destdir = '../build'  
  
def luabinaryDir(srcdir, dstdir):  
   if not os.path.exists( srcdir ):   
      os.system( 'mkdir ' + srcdir )  
  
   if not os.path.exists( dstdir ):   
      os.system( 'mkdir ' + dstdir )  
  
   flist = os.listdir(srcdir)  
   for item in flist:  
      filepath = os.path.join(srcdir, item)  
      # print item  
      # print filepath  
      if os.path.isdir(filepath):  
         luabinaryDir( os.path.join(srcdir, item), os.path.join(dstdir, item) )  
      elif os.path.splitext( item )[1] == '.lua':  
         # print 'Y'  
         srcfile = os.path.join(srcdir, item)  
         dstfile = os.path.join(dstdir, item)  
         cmd = '/usr/local/bin/luajit -bg %s %s' % (srcfile, dstfile)  
         #print cmd  
         os.system(cmd)
luabinaryDir(srcdir,destdir)  