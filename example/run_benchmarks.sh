# Prefer running these on mobile devices, as it seems like macOS and web don't support running integration tests
# in profile mode good enough.

flutter drive --profile --driver test_driver/perf_driver.dart --target integration_test/benchmarks/observer_widgets_bench.dart --no-dds