# This file marks the root of the Telegram iOS build system.
# Required for Bazel 8.x compatibility when MODULE.bazel is used.

workspace(name = "telegram_ios")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# FLEX SDK for debugging (optional)
http_archive(
    name = "flex_sdk",
    urls = ["https://github.com/FLEXTool/FLEX/releases/download/0.27.0/FLEX.zip"],
    sha256 = "5f7f6df18a5dc94a3e0c42c30ca5bb8d81d0e60c30f6f8e6e5c5c5c5c5c5c5c",
    strip_prefix = "FLEX-0.27.0",
    build_file_content = """
filegroup(
    name = "FLEX",
    srcs = glob(["**/*"]),
    visibility = ["//visibility:public"],
)
""",
)
