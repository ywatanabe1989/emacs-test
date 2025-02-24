;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 01:09:32>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/tests/test-elisp-test.el

(require 'ert)

(ert-deftest test-elisp-test-loadable
    ()
  (require 'elisp-test)
  (should
   (featurep 'elisp-test)))

(ert-deftest test-elisp-test-find-loadable
    ()
  (require 'elisp-test-find)
  (should
   (featurep 'elisp-test-find)))

(ert-deftest test-elisp-test-main-loadable
    ()
  (require 'elisp-test-main)
  (should
   (featurep 'elisp-test-main)))

(ert-deftest test-elisp-test-path-loadable
    ()
  (require 'elisp-test-path)
  (should
   (featurep 'elisp-test-path)))

(ert-deftest test-elisp-test-run-loadable
    ()
  (require 'elisp-test-run)
  (should
   (featurep 'elisp-test-run)))

(ert-deftest test-elisp-test-summarize-loadable
    ()
  (require 'elisp-test-summarize)
  (should
   (featurep 'elisp-test-summarize)))

(ert-deftest test-elisp-test-variables-loadable
    ()
  (require 'elisp-test-variables)
  (should
   (featurep 'elisp-test-variables)))

(provide 'test-elisp-test)

(when
    (not load-file-name)
  (message "test-elisp-test.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))