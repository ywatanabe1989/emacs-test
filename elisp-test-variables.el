;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 01:04:43>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/elisp-test-variables.el

;; This module defines variables used across the framework.

(defgroup elisp-test
  nil
  "Emacs Lisp Testing Framework."
  :group 'tools)

;; Variables
;; ----------------------------------------

(defvar et-loadpath
  '()
  "List of load paths for tests.")

(defvar et-buffer-name
  "*elisp-test*"
  "Name of the buffer used for elisp test results.")

(defcustom et-timeout-sec
  10
  "Default timeout in seconds for running a single test."
  :type 'integer
  :group 'elisp-test)

(defcustom et-test-file-expressions
  '("^test-.*\\.el$")
  "List of regular expressions to match test files."
  :type
  '(repeat string)
  :group 'elisp-test)

(defcustom et-test-file-exclude-expressions
  '("/\\.[^/]+/"        ; Hidden directories
    "/\\.[^/]+$"        ; Hidden files
    "/_[^/]+/"          ; Underscore directories
    "/_[^/]+$")
                                        ; Underscore files
  "List of regular expressions to exclude test files."
  :type
  '(repeat string)
  :group 'elisp-test)

(defcustom et-results-file
  "~/elisp-test-results.org"
  "File path where test results will be saved.

This file will contain the Org-mode formatted test results."
  :type 'file
  :group 'elisp-test)

(provide 'elisp-test-variables)

(when
    (not load-file-name)
  (message "elisp-test-variables.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))