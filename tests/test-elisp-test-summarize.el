;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 02:02:49>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/tests/test-elisp-test-summarize.el

(require 'ert)
(require 'elisp-test-summarize)
(require 'elisp-test-variables)

(ert-deftest test-et--summarize-results-saves-file
    ()
  (let*
      ((test-dir
        (make-temp-file "et-test-dir" t))
       (et-results-file
        (expand-file-name "test-results.org" test-dir)))
    (cl-letf
        (((symbol-function 'y-or-n-p)
          (lambda
            (&rest _)
            t)))
      (unwind-protect
          (progn
            (with-temp-file et-results-file
              (insert "Initial content\n"))
            (et--summarize-results
             '(("test-file.el" "test-name" "Passed: 1")))
            (should
             (file-exists-p et-results-file))
            (with-temp-buffer
              (insert-file-contents et-results-file)
              (should
               (>
                (buffer-size)
                0))))
        (delete-directory test-dir t)))))

(provide 'test-elisp-test-summarize)

(when
    (not load-file-name)
  (message "test-elisp-test-summarize.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))