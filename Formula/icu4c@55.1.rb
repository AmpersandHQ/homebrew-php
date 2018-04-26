class Icu4cAT551 < Formula
  homepage "http://site.icu-project.org/"
  head "https://ssl.icu-project.org/repos/icu/icu/trunk/", :using => :svn
  url "https://ssl.icu-project.org/files/icu4c/55.1/icu4c-55_1-src.tgz"
  version "55.1"
  sha256 "e16b22cbefdd354bec114541f7849a12f8fc2015320ca5282ee4fd787571457b"

  option :universal
  option :cxx11

  def install
    ENV.universal_binary if build.universal?
    ENV.cxx11 if build.cxx11?

    args = ["--prefix=#{prefix}", "--disable-samples", "--disable-tests", "--enable-static"]
    args << "--with-library-bits=64" if MacOS.prefer_64_bit?
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