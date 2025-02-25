<!-- ---
!-- Timestamp: 2025-02-25 15:27:42
!-- Author: ywatanabe
!-- File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/README.md
!-- --- -->

# Elisp Test

[![Build Status](https://github.com/ywatanabe1989/elisp-test/workflows/tests/badge.svg)](https://github.com/ywatanabe1989/elisp-test/actions)

A testing framework for Emacs Lisp projects that integrates with ERT (Emacs Lisp Regression Testing).

## Examples
- [`example-multiple.org`](./examples/elisp-test-results-with-error.org)
- [`example-multiple.pdf`](./examples/elisp-test-results-with-error.pdf)

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

#### Interactive Mode


```elisp
(et-test) ; Run tests on current directory
(et-test "~/projects/my-elisp-project/test-example.el") ; Run tests on specific path
(et-test "~/projects/my-elisp-project/tests/") ; Run tests on child paths
;; In dired
;; Mark test files/directories with `m` -> `M-x et-test`
```

#### Batch Mode

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

## Configurations

#### Example Key Bindings

``` elisp
(global-set-key (kbd "C-c C-t") #'et-test)
(global-set-key (kbd "C-M-t") #'elisp-test-buffer)
```

#### Customizable Variables

- `et-timeout-sec`: Test timeout (default: 10s)
- `et-test-file-expressions`: Test file patterns
- `et-test-file-exclude-expressions`: Exclusion patterns
- `et-results-org-path`: Results file location
- `et-results-org-path-dired`: Results file location
- `et-buffer-name`: Test buffer name

## License

Yusuke Watanabe (ywatanabe@alumni.u-tokyo.ac.jp)

<!-- EOF -->
