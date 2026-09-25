#!/usr/bin/env ruby
# frozen_string_literal: true

# bump.rb — refill Formula/tebako.rb for a tebako release:
#
#   ruby tools/bump.rb 2.8.17
#
# Fetches the release's SHA256SUMS (the release asset naming is the
# contract: <binary>-<version>-<platform>) and rewrites the formula's
# version line and every sha256 in place. The formula covers five
# binaries × four platforms (macos-arm64, macos-x86_64,
# linux-gnu-arm64, linux-gnu-x86_64); every one of the twenty must be
# present in SHA256SUMS or the run aborts naming what is missing.

require "net/http"
require "uri"

VERSION = ARGV.first or abort "usage: ruby tools/bump.rb <version>   (e.g. 2.8.17)"
ROOT = File.expand_path("..", __dir__)
FORMULA = File.join(ROOT, "Formula", "tebako.rb")
BINARIES = %w[tebako tebako-pkg tfs tebako-shim tebako-bootstrap].freeze
PLATFORMS = %w[macos-arm64 macos-x86_64 linux-gnu-arm64 linux-gnu-x86_64].freeze

def get(url, redirects = 3)
  uri = URI(url)
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.get(uri.request_uri) }
  return res.body if res.is_a?(Net::HTTPSuccess)
  return get(res["location"], redirects - 1) if res.is_a?(Net::HTTPRedirection) && redirects.positive? && res["location"]

  abort "GET #{url} → #{res.code} (is the release published?)"
end

sums_url = "https://github.com/tamatebako/tebako/releases/download/v#{VERSION}/SHA256SUMS"
body = get(sums_url)

sums = {}
body.each_line do |line|
  sha, file = line.strip.split(/\s+/, 2)
  sums[file] = sha
end

missing = BINARIES.product(PLATFORMS).reject { |b, p| sums.key?("#{b}-#{VERSION}-#{p}") }
abort "SHA256SUMS is missing: #{missing.map { |b, p| "#{b}-#{VERSION}-#{p}" }.join(', ')}" unless missing.empty?

text = File.read(FORMULA)
replaced = 0
BINARIES.product(PLATFORMS).each do |binary, platform|
  want = sums.fetch("#{binary}-#{VERSION}-#{platform}")
  # The asset name appears in the url; its sha256 sits on the same line
  # (the resource one-liners, which interpolate the `ver` local) or on
  # the immediately following line (the bare url + sha256 pair, which
  # interpolates `version` at formula scope). Each (binary, platform)
  # pair occurs exactly once in the formula.
  pattern = /(#{Regexp.escape(binary)}-\#\{ver(?:sion)?\}-#{Regexp.escape(platform)}[^\n]*(?:\n\s*)?sha256 ")[0-9a-f]{64}"/
  if text.sub!(pattern) { "#{Regexp.last_match(1)}#{want}\"" }
    replaced += 1
  else
    abort "no sha256 slot found for #{binary}-#{platform} in the formula"
  end
end

abort "expected 20 sha256 replacements, made #{replaced}" unless replaced == 20

text = text.sub(/version "[0-9.]+"/, %(version "#{VERSION}"))
  .sub(/sha256s are the release SHA256SUMS of v[0-9.]+/, "sha256s are the release SHA256SUMS of v#{VERSION}")
File.write(FORMULA, text)
puts "Formula/tebako.rb → v#{VERSION} (#{replaced} sha256s refilled)"
