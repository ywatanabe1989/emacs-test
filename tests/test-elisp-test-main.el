;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 01:11:05>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/tests/test-elisp-test-main.el

;;; test-elisp-test-main.el --- Tests for elisp-test-main.el -*- lexical-binding: t; -*-

(require 'ert)
(require 'elisp-test-main)

(ert-deftest test-et-test-function
    ()
  "Test the `et-test` function."
  ;; Since `et-test` is interactive and prompts the user, we'll need to simulate
  ;; user input. We can use `cl-letf` to override `yes-or-no-p`.
  (let
      ((test-dir
        (make-temp-file "et-test-dir" t))
       (test-file
        (make-temp-file "et-test-file" nil ".el"))
       (test-code "(ert-deftest sample-test () (should t))"))
    (unwind-protect
        (progn
          ;; Write test code to temp file
          (with-temp-file test-file
            (insert test-code))
          ;; Move test file to test directory
          (rename-file test-file
                       (expand-file-name
                        (file-name-nondirectory test-file)
                        test-dir))
          (cl-letf
              (((symbol-function 'yes-or-no-p)
                (lambda
                  (&rest args)
                  t)))
            (et-test test-dir)
            ;; We can check if the results buffer exists, or check other side effects.
            ))
      ;; Cleanup
      (delete-directory test-dir t))))

(provide 'test-elisp-test-main)

(when
    (not load-file-name)
  (message "test-elisp-test-main.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))