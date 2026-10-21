#!/usr/bin/env bash

erlang_builds_url() {
  case "${STACK}" in
    "heroku-20")
      erlang_builds_url="https://builds.hex.pm/builds/otp/ubuntu-20.04"
      ;;
    "heroku-22")
      erlang_builds_url="https://builds.hex.pm/builds/otp/ubuntu-22.04"
      ;;
    "cflinuxfs4")
      erlang_builds_url="https://builds.hex.pm/builds/otp/ubuntu-22.04"
      ;;
    *)
      erlang_builds_url="https://builds.hex.pm/builds/otp/ubuntu-22.04"
      ;;
  esac
  echo $erlang_builds_url
}

fetch_elixir_versions() {
  url="https://builds.hex.pm/builds/elixir/builds.txt"
  # builds.txt lists names like "v1.20.4-otp-29" and "v1.20.4"; strip the
  # leading "v" and any "-otp-NN" suffix so bare versions (e.g. 1.20.4) match.
  curl -s "$url" | awk '/^v[0-9.]+[- ]/ { v=$1; sub(/^v/,"",v); sub(/-otp-[0-9]+$/,"",v); print v }' | sort -u
}

fetch_erlang_versions() {
  case "${STACK}" in
    "heroku-20")
      url="https://builds.hex.pm/builds/otp/ubuntu-20.04/builds.txt"
      curl -s "$url" | awk '/^OTP-([0-9.]+ )/ {print substr($1,5)}'
      ;;
    "heroku-22")
      url="https://builds.hex.pm/builds/otp/ubuntu-22.04/builds.txt"
      curl -s "$url" | awk '/^OTP-([0-9.]+ )/ {print substr($1,5)}'
      ;;
    "cflinuxfs4")
      url="https://builds.hex.pm/builds/otp/ubuntu-22.04/builds.txt"
      curl -s "$url" | awk '/^OTP-([0-9.]+ )/ {print substr($1,5)}'
      ;;
    *)
      url="https://builds.hex.pm/builds/otp/ubuntu-22.04/builds.txt"
      curl -s "$url" | awk '/^OTP-([0-9.]+ )/ {print substr($1,5)}'
      ;;
  esac
}

exact_erlang_version_available() {
  # TODO: fallback to hashnuke one if not ubuntu-20.04 and not found on hex
  version=$1
  available_versions=$2
  found=1
  while read -r line; do
    if [ "$line" = "$version" ]; then
      found=0
    fi
  done <<< "$available_versions"
  echo $found
}

exact_elixir_version_available() {
  version=$1
  available_versions=$2
  found=1
  while read -r line; do
    if [ "$line" = "$version" ]; then
      found=0
    fi
  done <<< "$available_versions"
  echo $found
}

check_erlang_version() {
  version=$1
  exists=$(exact_erlang_version_available "$version" "$(fetch_erlang_versions)")
  if [ $exists -ne 0 ]; then
    output_line "Sorry, Erlang '$version' isn't supported yet or isn't formatted correctly. For a list of supported versions, please see https://github.com/HashNuke/heroku-buildpack-elixir#version-support"
    exit 1
  fi
}

check_elixir_version() {
  version=$1
  exists=$(exact_elixir_version_available "$version" "$(fetch_elixir_versions)")
  if [ $exists -ne 0 ]; then
    output_line "Sorry, Elixir '$version' isn't supported yet or isn't formatted correctly. For a list of supported versions, please see https://github.com/HashNuke/heroku-buildpack-elixir#version-support"
    exit 1
  fi
}
