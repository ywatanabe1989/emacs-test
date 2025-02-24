;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 07:17:55>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/tests/test-elisp-test-summarize.el

(require 'ert)
(require 'elisp-test-report)
(require 'elisp-test-variables)

(ert-deftest test-et--report-results-saves-file
    ()
  (let
      ((temp-buffer
        (generate-new-buffer "*test*"))
       (test-results
        '(("1" "test1" "PASSED")
          ("2" "test2" "FAILED: reason"))))
    (unwind-protect
        (progn
          (et--report-results temp-buffer test-results)
          (should
           (file-exists-p et-results-org-path-switched)))
      (kill-buffer temp-buffer)
      (when
          (file-exists-p et-results-org-path-switched)
        (delete-file et-results-org-path-switched)))))

(provide 'test-elisp-test-summarize)

(when
    (not load-file-name)
  (message "test-elisp-test-summarize.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))