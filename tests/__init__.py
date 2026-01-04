import warnings

warnings.filterwarnings(
    "ignore",
    message="Monkey-patching ssl after ssl has already been imported.*",
)
warnings.filterwarnings(
    "ignore",
    message="TestResult has no addDuration method",
    category=RuntimeWarning,
)
