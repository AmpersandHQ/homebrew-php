require File.expand_path("../../Abstract/abstract-php-extension", __FILE__)

class AmpPhpAT73Xdebug < AbstractPhp73Extension
  init
  desc "Provides debugging and profiling capabilities."
  homepage "https://xdebug.org"
  url "https://xdebug.org/files/xdebug-2.7.0beta1.tgz"
  sha256 "90a0ceaf95c7d936113ed0d7474f16978ec2277453be69239d92d0523e0910be"
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