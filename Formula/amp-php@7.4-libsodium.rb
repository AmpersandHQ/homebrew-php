require File.expand_path("../../Abstract/abstract-php-extension", __FILE__)

class AmpPhpAT74Libsodium < AbstractPhp74Extension
  init
  desc "Modern and easy-to-use crypto library"
  homepage "https://github.com/jedisct1/libsodium-php"
  url "https://github.com/jedisct1/libsodium-php/archive/1.0.7.tar.gz"
  sha256 "b66c795fa39909eccbc4310e6e9700230e5ad9e8e9d7fcf79bb344dbf9d2f905"
  head "https://github.com/jedisct1/libsodium-php.git"

  depends_on "libsodium"

  def extension
    "libsodium"
  end

  def install
    safe_phpize
    system "./configure", "--prefix=#{prefix}", phpconfig
    system "make"
    prefix.install "modules/libsodium.so"
    write_config_file if build.with? "config-file"
  end
end
