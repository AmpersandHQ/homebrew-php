class AmpPhpLegacyTidy < Formula
  desc "Granddaddy of HTML tools, with support for modern standards (modified for api compatibility for older php installs)"
  homepage "https://www.html-tidy.org/"
  url "https://github.com/htacg/tidy-html5/archive/5.6.0.tar.gz"
  sha256 "08a63bba3d9e7618d1570b4ecd6a7daa83c8e18a41c82455b6308bc11fe34958"
  head "https://github.com/htacg/tidy-html5.git", :branch => "next"

  keg_only "This version should only be used as a dependency when building amp-php versions, it does not need linked as references by path"

  depends_on "cmake" => :build

  def install
    # API compatibility with tidy-html5 v5.0.0 - https://github.com/htacg/tidy-html5/issues/224
    inreplace "ext/#{extension}/tidy.c", "buffio.h", "tidybuffio.h"

    cd "build/cmake"
    system "cmake", "../..", *std_cmake_args
    system "make"
    system "make", "install"
  end

  test do
    output = pipe_output(bin/"tidy -q", "<!doctype html><title></title>")
    assert_match /^<!DOCTYPE html>/, output
    assert_match /HTML Tidy for HTML5/, output
  end
end
