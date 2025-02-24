<!-- ---
!-- Timestamp: 2025-02-25 07:33:44
!-- Author: ywatanabe
!-- File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/README.md
!-- --- -->

# Emacs Test

A testing framework for Emacs Lisp projects that integrates with ERT (Emacs Lisp Regression Testing).

## Features

- Automated test discovery with customizable patterns
- Interactive test execution through Dired or function calls
- Detailed test results in [`Org-mode` format](./elisp-test-results.org) with [`PDF export`](elisp-test-results.pdf)
- Test timeout handling and error reporting
- Duplicate test detection
- Load path management
- Batch mode support for CI/CD

## Installation

1. Clone the repository:
```bash
git clone https://github.com/username/emacs-test.git ~/.emacs.d/lisp/emacs-test
```

2. Add to your init.el:
```elisp
(add-to-list 'load-path "~/.emacs.d/lisp/emacs-test")
(require 'elisp-test)
```

## Usage

### Interactive Mode

1. Run tests on current directory:
```elisp
(et-test)
```

2. Run tests on specific path:
```elisp
(et-test "~/projects/my-elisp-project/tests")
```

3. Using Dired:
   - Open directory in dired (`C-x d`)
   - Mark test files with `m`
   - Execute `M-x et-test`

### Configuration

Customize via `M-x customize-group RET elisp-test`:

- `et-timeout-sec`: Test timeout (default: 10s)
- `et-test-file-expressions`: Test file patterns
- `et-test-file-exclude-expressions`: Exclusion patterns
- `et-results-org-path`: Results file location
- `et-buffer-name`: Test buffer name

### Batch Mode

Create a `run-tests.el`:
```elisp
(setq ert-batch-print-level nil)
(setq ert-batch-print-length nil)
(load "~/.emacs.d/lisp/emacs-test/elisp-test.el")
(et-test "~/path/to/tests")
```

Run from command line:
```bash
emacs -Q --batch -l run-tests.el
```

## License

Yusuke Watanabe (ywatanabe@alumni.u-tokyo.ac.jp)

<!-- EOF -->