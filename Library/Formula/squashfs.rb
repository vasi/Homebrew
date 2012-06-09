require 'formula'

class Squashfs < Formula
  homepage 'http://squashfs.sourceforge.net/'
  url 'http://sourceforge.net/projects/squashfs/files/squashfs/squashfs4.0/squashfs4.0.tar.gz'
  sha256 '18948edbe06bac2c4307eea99bfb962643e4b82e5b7edd541b4d743748e12e21'

  head 'https://git.kernel.org/pub/scm/fs/squashfs/squashfs-tools.git'

  if ARGV.include? '--extra-format-support' and ARGV.build_head?
    depends_on 'lzo'
    depends_on 'xz'
  end

  def options
    [
      ['--extra-format-support', "Enables support for LZO and XZ formats. Only when building from HEAD."]
    ]
  end

  fails_with :clang do
    build 318
  end

  def patches
    if ARGV.build_head?
      %w[
        https://github.com/vasi/squashfs-tools/commit/695811dd120634d21391086684405b6178f2a046.patch
        https://github.com/vasi/squashfs-tools/commit/a90339f9aa08702ff6640b7de8300527f6a1d5bc.patch
        https://github.com/vasi/squashfs-tools/commit/45c40c7d8fe6b8b61458fa33cc28c069173bd45f.patch
        https://github.com/vasi/squashfs-tools/commit/c43950771a0128b46684862831c709e117baef1b.patch
        https://github.com/vasi/squashfs-tools/commit/a357ed71967daba52220fe43481b93dd4af9334f.patch
        https://github.com/vasi/squashfs-tools/commit/89f28dea697ead3ce0d418feb85b398b66e62e1f.patch
      ]
    else
      { :p0 => DATA }
    end
  end

  def install
    cd 'squashfs-tools' do
      if ARGV.include? '--extra-format-support' and ARGV.build_head?
        system "make LZO_SUPPORT=1 LZO_DIR='#{HOMEBREW_PREFIX}' XZ_SUPPORT=1 XZ_DIR='#{HOMEBREW_PREFIX}'"
      else
        system "make"
      end
      bin.install %w{mksquashfs unsquashfs}
    end

    doc.install %w{ACKNOWLEDGEMENTS CHANGES COPYING INSTALL OLD-READMEs PERFORMANCE.README README README-4.0} unless ARGV.build_head?
  end
end

__END__

Originally from some internal notes:
  "cd squashfs-tools; sed -i.orig 's/\|FNM_EXTMATCH//' $(grep -l FNM_EXTMATCH *)"
  "cd squashfs-tools; sed -i.orig $'/#include \"unsquashfs.h\"/{i\\\n#include <sys/sysctl.h>\n}' unsquashfs.c"

diff -u squashfs-tools.orig/mksquashfs.c squashfs-tools/mksquashfs.c
--- squashfs-tools.orig/mksquashfs.c	2009-04-05 14:22:48.000000000 -0700
+++ squashfs-tools/mksquashfs.c	2011-11-17 17:51:31.000000000 -0800
@@ -3975,7 +3975,7 @@
 				regexec(path->name[i].preg, name, (size_t) 0,
 					NULL, 0) == 0 :
 				fnmatch(path->name[i].name, name,
-					FNM_PATHNAME|FNM_PERIOD|FNM_EXTMATCH) ==
+					FNM_PATHNAME|FNM_PERIOD) ==
 					 0;
 
 			if(match && path->name[i].paths == NULL) {
Only in squashfs-tools: mksquashfs.c.orig
diff -u squashfs-tools.orig/unsquashfs.c squashfs-tools/unsquashfs.c
--- squashfs-tools.orig/unsquashfs.c	2009-04-05 14:23:06.000000000 -0700
+++ squashfs-tools/unsquashfs.c	2011-11-17 17:51:44.000000000 -0800
@@ -21,6 +21,7 @@
  * unsquashfs.c
  */
 
+#include <sys/sysctl.h>
 #include "unsquashfs.h"
 #include "squashfs_swap.h"
 #include "squashfs_compat.h"
@@ -1195,7 +1196,7 @@
 			int match = use_regex ?
 				regexec(path->name[i].preg, name, (size_t) 0,
 				NULL, 0) == 0 : fnmatch(path->name[i].name,
-				name, FNM_PATHNAME|FNM_PERIOD|FNM_EXTMATCH) ==
+				name, FNM_PATHNAME|FNM_PERIOD) ==
 				0;
 			if(match && path->name[i].paths == NULL)
 				/*
