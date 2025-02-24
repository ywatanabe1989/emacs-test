<!-- ---
!-- Timestamp: 2025-02-25 03:23:13
!-- Author: ywatanabe
!-- File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/README.md
!-- --- -->

# Emacs Test

A testing framework for Emacs Lisp projects that integrates with ERT (Emacs Lisp Regression Testing).

## Features

- Test file discovery with customizable patterns
- Individual and batch test execution
- Detailed test result reporting in Org format
- Test timeout handling
- Duplicate test detection
- Integration with Dired for file selection
- Command-line execution support

## Installation

1. Clone this repository:
```bash
git clone https://github.com/ywatanabe/emacs-test.git ~/.emacs.d/lisp/emacs-test
```

2. Add to your init.el:
```elisp
(add-to-list 'load-path "~/.emacs.d/lisp/emacs-test")
(require 'elisp-test)
```

## Usage

### Interactive Use

1. Run tests on a directory:
```elisp
(et-test "~/path/to/project")
```

2. Select test files in Dired:
- Mark files with 'm'
- Run `M-x et-find-test-files-dired`

### Command-Line Use

Create batch-run-tests.el:
```elisp
(setq ert-batch-print-level nil)
(setq ert-batch-print-length nil)
(load "/path/to/emacs-test.el")
(et-test "/path/to/emacs-test")
(kill-emacs 0)
```

Run:
```bash
emacs -batch -l batch-run-tests.el
```

## Configuration

Customize through M-x customize-group RET elisp-test:

- `et-timeout-sec`: Test timeout (default: 10s)
- `et-test-file-expressions`: Test file patterns
- `et-test-file-exclude-expressions`: Exclusion patterns
- `et-results-org-path`: Results save location

## License

Yusuke Watanabe (ywatanabe@alumni.u-tokyo.ac.jp)

<!-- EOF -->