;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 06:28:26>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/tests/test-elisp-test.el

(require 'ert)

(ert-deftest test-elisp-test-loadable
    ()
  (should
   (require 'elisp-test)))

(ert-deftest test-elisp-test-variables-loadable
    ()
  (should
   (require 'elisp-test-variables)))

(ert-deftest test-elisp-test-loadpath-loadable
    ()
  (should
   (require 'elisp-test-loadpath)))

(ert-deftest test-elisp-test-find-loadable
    ()
  (should
   (require 'elisp-test-find)))

(ert-deftest test-elisp-test-run-loadable
    ()
  (should
   (require 'elisp-test-run)))

(ert-deftest test-elisp-test-parse-loadable
    ()
  (should
   (require 'elisp-test-parse)))

(ert-deftest test-elisp-test-report-loadable
    ()
  (should
   (require 'elisp-test-report)))

(ert-deftest test-elisp-test-main-loadable
    ()
  (should
   (require 'elisp-test-main)))

(provide 'test-elisp-test)

(when
    (not load-file-name)
  (message "test-elisp-test.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))