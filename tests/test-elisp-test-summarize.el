;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 02:02:49>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/tests/test-elisp-test-report.el

(require 'ert)
(require 'elisp-test-report)
(require 'elisp-test-variables)

(ert-deftest test-et--report-results-saves-file
    ()
  (let*
      ((test-dir
        (make-temp-file "et-test-dir" t))
       (et-results-org-path
        (expand-file-name "test-results.org" test-dir)))
    (cl-letf
        (((symbol-function 'y-or-n-p)
          (lambda
            (&rest _)
            t)))
      (unwind-protect
          (progn
            (with-temp-file et-results-org-path
              (insert "Initial content\n"))
            (et--report-results
             '(("test-file.el" "test-name" "Passed: 1")))
            (should
             (file-exists-p et-results-org-path))
            (with-temp-buffer
              (insert-file-contents et-results-org-path)
              (should
               (>
                (buffer-size)
                0))))
        (delete-directory test-dir t)))))

(provide 'test-elisp-test-report)

(when
    (not load-file-name)
  (message "test-elisp-test-report.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))