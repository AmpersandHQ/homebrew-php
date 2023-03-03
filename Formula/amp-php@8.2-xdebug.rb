require File.expand_path("../../Abstract/abstract-php-extension", __FILE__)

class AmpPhpAT82Xdebug < AbstractPhp82Extension
  init
  desc "Provides debugging and profiling capabilities."
  homepage "https://xdebug.org"
  url "https://xdebug.org/files/xdebug-3.2.0.tgz"
  mirror "https://github.com/AmpersandHQ/homebrew-php/raw/master/files/xdebug-3.2.0.tgz"
  sha256 "7769b20eecdadf5fbe9f582512c10b394fb575b6f7a8c3a3a82db6883e0032b7"
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
    unlink_config_file
    write_config_file if build.with? "config-file"
  end
end
