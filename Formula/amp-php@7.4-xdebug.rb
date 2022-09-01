require File.expand_path("../../Abstract/abstract-php-extension", __FILE__)

class AmpPhpAT74Xdebug < AbstractPhp74Extension
  init
  desc "Provides debugging and profiling capabilities."
  homepage "https://xdebug.org"
  url "https://xdebug.org/files/xdebug-3.1.4.tgz"
  mirror "https://github.com/AmpersandHQ/homebrew-php/raw/master/files/xdebug-3.1.4.tgz"
  sha256 "4195926f9f6c4e802ff749bb2ca85ac50636719a72e5389e372e35ef523505f9"
  head "https://github.com/xdebug/xdebug.git"

  def extension_type
    "zend_extension"
  end

  def config_file
    <<~EOS
      [#{extension}]
      #{extension_type}="#{module_path}"
      xdebug.mode=debug
      xdebug.client_port=9010
      xdebug.idekey=PHPSTORM
      EOS
  rescue StandardError
    nil
  end

  def install
    system "pwd"
    system "ls -lasth"

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
