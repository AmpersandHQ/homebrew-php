class AmpPhpAT72 < Formula
  desc "General-purpose scripting language"
  homepage "https://www.php.net/"
  url "https://www.php.net/distributions/php-7.2.34.tar.xz"
  sha256 "409e11bc6a2c18707dfc44bc61c820ddfd81e17481470f3405ee7822d8379903"

  keg_only :versioned_formula

  depends_on "httpd" => [:build, :test]
  depends_on "pkg-config" => :build
  depends_on "xz" => :build
  depends_on "apr"
  depends_on "apr-util"
  depends_on "argon2"
  depends_on "aspell"
  depends_on "autoconf"
  depends_on "curl"
  depends_on "freetds"
  depends_on "freetype"
  depends_on "gd"
  depends_on "gettext"
  depends_on "glib"
  depends_on "gmp"
  depends_on "icu4c@75"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libpq"
  depends_on "libsodium"
  depends_on "libxpm"
  depends_on "libzip"
  depends_on "openldap"
  depends_on "openssl@1.1"
  depends_on "sqlite"
  depends_on "tidy-html5"
  depends_on "unixodbc"
  depends_on "webp"

  # PHP build system incorrectly links system libraries
  # see https://github.com/php/php-src/pull/3472
  # see https://github.com/php/php-src/pull/7596
  patch :DATA

  def install
    # Ensure that libxml2 will be detected correctly in older MacOS
    ENV["SDKROOT"] = MacOS.sdk_path if MacOS.version == :el_capitan || MacOS.version == :sierra

    # Work around for building with Xcode 15.3
    if DevelopmentTools.clang_build_version >= 1500
      ENV.append "CFLAGS", "-Wno-incompatible-function-pointer-types"
      ENV.append "LDFLAGS", "-lresolv"
      inreplace "main/reentrancy.c", "readdir_r(dirp, entry)", "readdir_r(dirp, entry, result)"
    end

    # Work around configure issues with Xcode 12
    # See https://bugs.php.net/bug.php?id=80171
    # See https://github.com/Homebrew/homebrew-core/pull/61828/
    ENV.append "CFLAGS", "-Wno-implicit-function-declaration  -DU_DEFINE_FALSE_AND_TRUE=1"
    ENV.append "CXXFLAGS", "-DU_DEFINE_FALSE_AND_TRUE=1"

    # Work around to support `icu4c` 75, which needs C++17.
    ENV.append "CXX", "-std=c++17"
    ENV.libcxx if ENV.compiler == :clang

    # buildconf required due to system library linking bug patch
    system "./buildconf", "--force"

    inreplace "configure" do |s|
      s.gsub! "APACHE_THREADED_MPM=`$APXS_HTTPD -V | grep 'threaded:.*yes'`",
              "APACHE_THREADED_MPM="
      s.gsub! "APXS_LIBEXECDIR='$(INSTALL_ROOT)'`$APXS -q LIBEXECDIR`",
              "APXS_LIBEXECDIR='$(INSTALL_ROOT)#{lib}/httpd/modules'"
      s.gsub! "-z `$APXS -q SYSCONFDIR`",
              "-z ''"
    end

    # Update error message in apache sapi to better explain the requirements
    # of using Apache http in combination with php if the non-compatible MPM
    # has been selected. Homebrew has chosen not to support being able to
    # compile a thread safe version of PHP and therefore it is not
    # possible to recompile as suggested in the original message
    inreplace "sapi/apache2handler/sapi_apache2.c",
              "You need to recompile PHP.",
              "Homebrew PHP does not support a thread-safe php binary. "\
              "To use the PHP apache sapi please change "\
              "your httpd config to use the prefork MPM"

    inreplace "sapi/fpm/php-fpm.conf.in", ";daemonize = yes", "daemonize = no"

    config_path = etc/"php/#{php_version}"
    # Prevent system pear config from inhibiting pear install
    (config_path/"pear.conf").delete if (config_path/"pear.conf").exist?

    # Prevent homebrew from harcoding path to sed shim in phpize script
    ENV["lt_cv_path_SED"] = "sed"

    # Each extension that is built on Mojave needs a direct reference to the
    # sdk path or it won't find the headers
    headers_path = "=#{MacOS.sdk_path_if_needed}/usr"

    args = %W[
      --prefix=#{prefix}
      --localstatedir=#{var}
      --sysconfdir=#{config_path}
      --with-config-file-path=#{config_path}
      --with-config-file-scan-dir=#{config_path}/conf.d
      --with-pear=#{pkgshare}/pear
      --enable-bcmath
      --enable-calendar
      --enable-dba
      --enable-dtrace
      --enable-exif
      --enable-ftp
      --enable-fpm
      --enable-gd
      --enable-intl
      --enable-mbregex
      --enable-mbstring
      --enable-mysqlnd
      --disable-opcache-file
      --enable-pcntl
      --enable-phpdbg
      --enable-phpdbg-readline
      --enable-phpdbg-webhelper
      --enable-shmop
      --enable-soap
      --enable-sockets
      --enable-sysvmsg
      --enable-sysvsem
      --enable-sysvshm
      --enable-wddx
      --enable-zip
      --with-bz2#{headers_path}
      --with-curl=#{Formula["curl"].opt_prefix}
      --with-fpm-user=_www
      --with-fpm-group=_www
      --with-freetype-dir=#{Formula["freetype"].opt_prefix}
      --with-gd=#{Formula["gd"].opt_prefix}
      --with-gettext=#{Formula["gettext"].opt_prefix}
      --with-gmp=#{Formula["gmp"].opt_prefix}
      --with-iconv#{headers_path}
      --with-icu-dir=#{Formula["icu4c@75"].opt_prefix}
      --with-jpeg-dir=#{Formula["jpeg"].opt_prefix}
      --with-kerberos#{headers_path}
      --with-layout=GNU
      --with-ldap=#{Formula["openldap"].opt_prefix}
      --with-ldap-sasl#{headers_path}
      --with-libxml-dir#{headers_path}
      --with-libedit#{headers_path}
      --with-libzip
      --with-mhash#{headers_path}
      --with-mysql-sock=/tmp/mysql.sock
      --with-mysqli=mysqlnd
      --with-ndbm#{headers_path}
      --with-openssl=#{Formula["openssl@1.1"].opt_prefix}
      --with-password-argon2=#{Formula["argon2"].opt_prefix}
      --with-pdo-dblib=#{Formula["freetds"].opt_prefix}
      --with-pdo-mysql=mysqlnd
      --with-pdo-odbc=unixODBC,#{Formula["unixodbc"].opt_prefix}
      --with-pdo-pgsql=#{Formula["libpq"].opt_prefix}
      --with-pdo-sqlite=#{Formula["sqlite"].opt_prefix}
      --with-pgsql=#{Formula["libpq"].opt_prefix}
      --with-pic
      --with-png-dir=#{Formula["libpng"].opt_prefix}
      --with-pspell=#{Formula["aspell"].opt_prefix}
      --with-sodium=#{Formula["libsodium"].opt_prefix}
      --with-sqlite3=#{Formula["sqlite"].opt_prefix}
      --with-tidy=#{Formula["tidy-html5"].opt_prefix}
      --with-unixODBC=#{Formula["unixodbc"].opt_prefix}
      --with-webp-dir=#{Formula["webp"].opt_prefix}
      --with-xmlrpc
      --with-xpm-dir=#{Formula["libxpm"].opt_prefix}
      --with-xsl#{headers_path}
      --with-zlib#{headers_path}
    ]

    system "./configure", *args
    system "make"
    system "make", "install"

    # Allow pecl to install outside of Cellar
    extension_dir = Utils.safe_popen_read("#{bin}/php-config", "--extension-dir").chomp
    orig_ext_dir = File.basename(extension_dir)
    inreplace bin/"php-config", lib/"php", prefix/"pecl"
    inreplace "php.ini-development", %r{; ?extension_dir = "\./"},
      "extension_dir = \"#{HOMEBREW_PREFIX}/lib/php/pecl/#{orig_ext_dir}\""

    # Use OpenSSL cert bundle
    openssl = Formula["openssl@1.1"]
    inreplace "php.ini-development", /; ?openssl\.cafile=/,
      "openssl.cafile = \"#{openssl.pkgetc}/cert.pem\""
    inreplace "php.ini-development", /; ?openssl\.capath=/,
      "openssl.capath = \"#{openssl.pkgetc}/certs\""

    config_files = {
      "php.ini-development"   => "php.ini",
      "sapi/fpm/php-fpm.conf" => "php-fpm.conf",
      "sapi/fpm/www.conf"     => "php-fpm.d/www.conf",
    }
    config_files.each_value do |dst|
      dst_default = config_path/"#{dst}.default"
      rm dst_default if dst_default.exist?
    end
    config_path.install config_files

    unless (var/"log/php-fpm.log").exist?
      (var/"log").mkpath
      touch var/"log/php-fpm.log"
    end
  end

  def post_install

    # Set a default date.timezone
    system "sed -i '' 's/;date.timezone =/date.timezone=\"Europe\\/London\"/' #{etc}/php/#{php_version}/php.ini"

    # Increase default memory limit
    system "sed -i '' 's/memory_limit = 128M/memory_limit = 1024M/' #{etc}/php/#{php_version}/php.ini"
    system "sed -i '' 's/memory_limit = 512M/memory_limit = 1024M/' #{etc}/php/#{php_version}/php.ini"

    # Increase default max_execution_time as magento in developer mode is slow
    system "sed -i '' 's/max_execution_time = 30/max_execution_time = 240/' #{etc}/php/#{php_version}/php.ini"
    system "sed -i '' 's/max_execution_time = 60/max_execution_time = 240/' #{etc}/php/#{php_version}/php.ini"

    # Set fpm to static mode with 10 processes
    system "sed -i '' 's/pm = dynamic/pm = static/' #{etc}/php/#{php_version}/php-fpm.d/www.conf"
    system "sed -i '' 's/pm.max_children = 5/pm.max_children = 10/' #{etc}/php/#{php_version}/php-fpm.d/www.conf"

    # Ensure opcache is disabled
    system "rm -f #{etc}/php/#{php_version}/conf.d/ext-opcache.ini"

    pear_prefix = pkgshare/"pear"
    pear_files = %W[
      #{pear_prefix}/.depdblock
      #{pear_prefix}/.filemap
      #{pear_prefix}/.depdb
      #{pear_prefix}/.lock
    ]

    %W[
      #{pear_prefix}/.channels
      #{pear_prefix}/.channels/.alias
    ].each do |f|
      chmod 0755, f
      pear_files.concat(Dir["#{f}/*"])
    end

    chmod 0644, pear_files

    # Custom location for extensions installed via pecl
    pecl_path = HOMEBREW_PREFIX/"lib/php/pecl"
    ln_s pecl_path, prefix/"pecl" unless (prefix/"pecl").exist?
    extension_dir = Utils.safe_popen_read("#{bin}/php-config", "--extension-dir").chomp
    php_basename = File.basename(extension_dir)
    php_ext_dir = opt_prefix/"lib/php"/php_basename

    # fix pear config to install outside cellar
    pear_path = HOMEBREW_PREFIX/"share/pear@#{php_version}"
    cp_r pkgshare/"pear/.", pear_path
    {
      "php_ini"  => etc/"php/#{php_version}/php.ini",
      "php_dir"  => pear_path,
      "doc_dir"  => pear_path/"doc",
      "ext_dir"  => pecl_path/php_basename,
      "bin_dir"  => opt_bin,
      "data_dir" => pear_path/"data",
      "cfg_dir"  => pear_path/"cfg",
      "www_dir"  => pear_path/"htdocs",
      "man_dir"  => HOMEBREW_PREFIX/"share/man",
      "test_dir" => pear_path/"test",
      "php_bin"  => opt_bin/"php",
    }.each do |key, value|
      value.mkpath if /(?<!bin|man)_dir$/.match?(key)
      system bin/"pear", "config-set", key, value, "system"
    end

    system bin/"pear", "update-channels"

  end

  def caveats
    <<~EOS
      To enable PHP in Apache add the following to httpd.conf and restart Apache:
          LoadModule php7_module #{opt_lib}/httpd/modules/libphp7.so

          <FilesMatch \\.php$>
              SetHandler application/x-httpd-php
          </FilesMatch>

      Finally, check DirectoryIndex includes index.php
          DirectoryIndex index.php index.html

      The php.ini and php-fpm.ini file can be found in:
          #{etc}/php/#{php_version}/
    EOS
  end

  def php_version
    version.to_s.split(".")[0..1].join(".")
  end

  service do
    run [opt_sbin/"php-fpm", "--nodaemonize"]
    keep_alive true
    working_dir var
    error_log_path var/"log/php-fpm.log"
  end
end

__END__
diff --git a/acinclude.m4 b/acinclude.m4
index 168c465f8d..6c087d152f 100644
--- a/acinclude.m4
+++ b/acinclude.m4
@@ -441,7 +441,11 @@ dnl
 dnl Adds a path to linkpath/runpath (LDFLAGS)
 dnl
 AC_DEFUN([PHP_ADD_LIBPATH],[
-  if test "$1" != "/usr/$PHP_LIBDIR" && test "$1" != "/usr/lib"; then
+  case "$1" in
+  "/usr/$PHP_LIBDIR"|"/usr/lib"[)] ;;
+  /Library/Developer/CommandLineTools/SDKs/*/usr/lib[)] ;;
+  /Applications/Xcode*.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/*/usr/lib[)] ;;
+  *[)]
     PHP_EXPAND_PATH($1, ai_p)
     ifelse([$2],,[
       _PHP_ADD_LIBPATH_GLOBAL([$ai_p])
@@ -452,8 +456,8 @@ AC_DEFUN([PHP_ADD_LIBPATH],[
       else
         _PHP_ADD_LIBPATH_GLOBAL([$ai_p])
       fi
-    ])
-  fi
+    ]) ;;
+  esac
 ])

 dnl
@@ -487,7 +491,11 @@ dnl add an include path.
 dnl if before is 1, add in the beginning of INCLUDES.
 dnl
 AC_DEFUN([PHP_ADD_INCLUDE],[
-  if test "$1" != "/usr/include"; then
+  case "$1" in
+  "/usr/include"[)] ;;
+  /Library/Developer/CommandLineTools/SDKs/*/usr/include[)] ;;
+  /Applications/Xcode*.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/*/usr/include[)] ;;
+  *[)]
     PHP_EXPAND_PATH($1, ai_p)
     PHP_RUN_ONCE(INCLUDEPATH, $ai_p, [
       if test "$2"; then
@@ -495,8 +503,8 @@ AC_DEFUN([PHP_ADD_INCLUDE],[
       else
         INCLUDES="$INCLUDES -I$ai_p"
       fi
-    ])
-  fi
+    ]) ;;
+  esac
 ])

 dnl internal, don't use
@@ -2411,7 +2419,8 @@ AC_DEFUN([PHP_SETUP_ICONV], [
     fi

     if test -f $ICONV_DIR/$PHP_LIBDIR/lib$iconv_lib_name.a ||
-       test -f $ICONV_DIR/$PHP_LIBDIR/lib$iconv_lib_name.$SHLIB_SUFFIX_NAME
+       test -f $ICONV_DIR/$PHP_LIBDIR/lib$iconv_lib_name.$SHLIB_SUFFIX_NAME ||
+       test -f $ICONV_DIR/$PHP_LIBDIR/lib$iconv_lib_name.tbd
     then
       PHP_CHECK_LIBRARY($iconv_lib_name, libiconv, [
         found_iconv=yes
diff --git a/ext/intl/locale/locale_methods.c b/ext/intl/locale/locale_methods.c
index 3379916822..f35944283e 100644
--- a/ext/intl/locale/locale_methods.c
+++ b/ext/intl/locale/locale_methods.c
@@ -1333,7 +1333,7 @@ PHP_FUNCTION(locale_filter_matches)
 		if( token && (token==cur_lang_tag) ){
 			/* check if the char. after match is SEPARATOR */
 			chrcheck = token + (strlen(cur_loc_range));
-			if( isIDSeparator(*chrcheck) || isEndOfTag(*chrcheck) ){
+			if( isIDSeparator(*chrcheck) || isKeywordSeparator(*chrcheck) || isEndOfTag(*chrcheck) ){
 				if( cur_lang_tag){
 					efree( cur_lang_tag );
 				}
diff --git a/ext/intl/breakiterator/codepointiterator_internal.cpp b/ext/intl/breakiterator/codepointiterator_internal.cpp
index 71ba056994d0..3982a599af38 100644
--- a/ext/intl/breakiterator/codepointiterator_internal.cpp
+++ b/ext/intl/breakiterator/codepointiterator_internal.cpp
@@ -73,7 +73,11 @@ CodePointBreakIterator::~CodePointBreakIterator()
 	clearCurrentCharIter();
 }

+#if U_ICU_VERSION_MAJOR_NUM >= 70
+bool CodePointBreakIterator::operator==(const BreakIterator& that) const
+#else
 UBool CodePointBreakIterator::operator==(const BreakIterator& that) const
+#endif
 {
 	if (typeid(*this) != typeid(that)) {
 		return false;
diff --git a/ext/intl/breakiterator/codepointiterator_internal.h b/ext/intl/breakiterator/codepointiterator_internal.h
index 43ec79d0b776..93b903a20bb8 100644
--- a/ext/intl/breakiterator/codepointiterator_internal.h
+++ b/ext/intl/breakiterator/codepointiterator_internal.h
@@ -37,7 +37,11 @@ namespace PHP {

 		virtual ~CodePointBreakIterator();

+#if U_ICU_VERSION_MAJOR_NUM >= 70
+		virtual bool operator==(const BreakIterator& that) const;
+#else
 		virtual UBool operator==(const BreakIterator& that) const;
+#endif

 		virtual CodePointBreakIterator* clone(void) const;