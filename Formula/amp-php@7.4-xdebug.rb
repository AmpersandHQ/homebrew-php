require File.expand_path("../../Abstract/abstract-php-extension", __FILE__)

class AmpPhpAT74Xdebug < AbstractPhp74Extension
  init
  desc "Provides debugging and profiling capabilities."
  homepage "https://xdebug.org"
  url "https://xdebug.org/files/xdebug-2.9.8.tgz"
  mirror "https://github.com/AmpersandHQ/homebrew-php/raw/master/files/xdebug-2.9.8.tgz"
  sha256 "f555b6cc58d96c9965af942d22e0f1818b7a477a410c76b1ab0eebe85a762f8a"
  head "https://github.com/xdebug/xdebug.git"

  def extension_type
    "zend_extension"
  end

  def config_file
    <<~EOS
      [#{extension}]
      #{extension_type}="#{module_path}"
      xdebug.remote_enable=1
      xdebug.remote_port=9010
      EOS
  rescue StandardError
    nil
  end

  def install
    Dir.chdir "xdebug-#{version}" unless build.head?

    safe_phpize
    system "./configure", "--prefix=#{prefix}",
                          phpconfig,
                          "--disable-debug",
                          "--disable-dependency-tracking",
                          "--enable-xdebug"
    system "make"
    prefix.install "modules/xdebug.so"
    write_config_file if build.with? "config-file"
  end
end
