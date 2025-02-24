;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 07:03:59>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/elisp-test-run.el

;; Single Test Runner
;; ----------------------------------------

;; ;; Passed Tests are also listed as Failed Tests
;; (defun et--run-single-test
;;     (test &optional timeout)
;;   "Run a single TEST with TIMEOUT (defaults to 10 seconds)."
;;   (let
;;       ((file
;;         (car test))
;;        (testname
;;         (cdr test))
;;        (timeout-secs
;;         (or timeout 10)))
;;     (with-current-buffer
;;         (get-buffer-create "*ert*")
;;       (let
;;           ((inhibit-read-only t))
;;         (erase-buffer)))
;;     (condition-case err
;;         (progn
;;           (load file nil t)
;;           (let
;;               ((test-symbol
;;                 (intern testname)))
;;             (if
;;                 (ert-test-boundp test-symbol)
;;                 (with-timeout
;;                     (timeout-secs
;;                      (list file testname "TIMEOUT: Test exceeded time limit"))
;;                   (ert test-symbol)
;;                   (list file testname
;;                         (with-current-buffer "*ert*"
;;                           (let
;;                               ((output
;;                                 (buffer-substring-no-properties
;;                                  (point-min)
;;                                  (point-max))))
;;                             (cond
;;                              ((string-match "^\\* Test Results Summary\n- Passed: \\([0-9]+\\)\n- Failed: 0" output)
;;                               "PASSED")
;;                              ((string-match-p "- Failed: [1-9]" output)
;;                               (concat "FAILED: " output))
;;                              ((string-match-p "- Skipped: [1-9]" output)
;;                               (concat "SKIPPED: " output))
;;                              (t output))))))
;;               (list file testname "NOT-FOUND: Test not found"))))
;;       (error
;;        (list file testname
;;              (format "ERROR: %S" err))))))

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
                            (cond
                             ((string-match "Failed:\\s-*0\\b" output)
                              "PASSED")
                             ((string-match "Failed:\\s-*[1-9][0-9]*\\b" output)
                              (concat "FAILED: " output))
                             ((string-match "Skipped:\\s-*[1-9][0-9]*\\b" output)
                              (concat "SKIPPED: " output))
                             (t output))))))
              (list file testname "NOT-FOUND: Test not found"))))
      (error
       (list file testname
             (format "ERROR: %S" err))))))
;; (defun et--run-single-test
;;     (test &optional timeout)
;;   "Run a single TEST with TIMEOUT (defaults to 10 seconds)."
;;   (let
;;       ((file
;;         (car test))
;;        (testname
;;         (cdr test))
;;        (timeout-secs
;;         (or timeout 10)))
;;     (with-current-buffer
;;         (get-buffer-create "*ert*")
;;       (let
;;           ((inhibit-read-only t))
;;         (erase-buffer)))
;;     (condition-case err
;;         (progn
;;           (load file nil t)
;;           (let
;;               ((test-symbol
;;                 (intern testname)))
;;             (if
;;                 (ert-test-boundp test-symbol)
;;                 (with-timeout
;;                     (timeout-secs
;;                      (list file testname "TIMEOUT: Test exceeded time limit"))
;;                   (ert test-symbol)
;;                   (list file testname
;;                         (with-current-buffer "*ert*"
;;                           (let
;;                               ((output
;;                                 (buffer-substring-no-properties
;;                                  (point-min)
;;                                  (point-max))))
;;                             (if
;;                                 (string-match "Selector:.*\nPassed:\\s-*\\([0-9]+\\)\nFailed:\\s-*\\([0-9]+\\)" output)
;;                                 (if
;;                                     (string=
;;                                      (match-string 2 output)
;;                                      "0")
;;                                     "PASSED"
;;                                   (concat "FAILED: " output))
;;                               output)))))
;;               (list file testname "NOT-FOUND: Test not found"))))
;;       (error
;;        (list file testname
;;              (format "ERROR: %S" err))))))

;; Multiple Tests Runner
;; ----------------------------------------

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