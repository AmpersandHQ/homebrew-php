class Icu4cAT621 < Formula
  homepage "http://site.icu-project.org/"
  head "https://ssl.icu-project.org/repos/icu/trunk/icu4c/", :using => :svn
  url "https://ssl.icu-project.org/files/icu4c/62.1/icu4c-62_1-src.tgz"
  version "62.1"
  sha256 "3dd9868d666350dda66a6e305eecde9d479fb70b30d5b55d78a1deffb97d5aa3"

  keg_only "This version should only be used as a dependency when building amp-php versions, it does not need linked as references by path"

  option :universal
  option :cxx11

  def install
    ENV.universal_binary if build.universal?
    ENV.cxx11 if build.cxx11?

    args = ["--prefix=#{prefix}", "--disable-samples", "--disable-tests", "--enable-static"]
    args << "--with-library-bits=64"

    cd "source" do
      system "./configure", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    system "#{bin}/gendict", "--uchars", "/usr/share/dict/words", "dict"
  end
end