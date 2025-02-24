;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 02:16:03>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/elisp-test-run.el

;; Runners: Single
;; ----------------------------------------

(defun et--run-single-test
    (test &optional timeout)
  "Run a single TEST with TIMEOUT (defaults to 10 seconds)."
  (let
      ((file
        (car test))
       (testname
        (cdr test))
       (timeout-secs
        (or timeout 10)))
    (with-current-buffer
        (get-buffer-create "*ert*")
      (let
          ((inhibit-read-only t))
        (erase-buffer)))
    (condition-case err
        (progn
          (load file nil t)
          (let
              ((test-symbol
                (intern testname)))
            (if
                (ert-test-boundp test-symbol)
                (with-timeout
                    (timeout-secs
                     (list file testname "TIMEOUT: Test exceeded time limit"))
                  (ert test-symbol)
                  (list file testname
                        (with-current-buffer "*ert*"
                          (let
                              ((output
                                (buffer-substring-no-properties
                                 (point-min)
                                 (point-max))))
                            (if
                                (string-match-p "failed" output)
                                (concat "FAILED: " output)
                              output)))))
              (list file testname "NOT-FOUND: Test not found"))))
      (error
       (list file testname
             (format "ERROR: %S" err))))))

(defun et--run-multiple-test
    (test-alist)
  "Run multiple tests from TEST-ALIST and return ((path selector results) ...)."
  (mapcar #'et--run-single-test test-alist))

(provide 'elisp-test-run)

(when
    (not load-file-name)
  (message "elisp-test-run.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))