;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 06:33:34>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/elisp-test-plan.el

(defun et--prepare-test-plan
    (paths)
  "Create test execution plan from PATHS and return list of tests."
  (let
      ((tests
        (mapcan #'--et-find-deftest paths)))
    (when tests
      (with-current-buffer
          (get-buffer-create "*elisp-test-plan*")
        (erase-buffer)
        (org-mode)
        (insert "* Found Tests\n\n")
        (dolist
            (test tests)
          (insert
           (format "- %s :: %s\n"
                   (file-name-nondirectory
                    (car test))
                   (cdr test))))
        (display-buffer
         (current-buffer)))
      tests)))

(provide 'elisp-test-plan)

(when
    (not load-file-name)
  (message "elisp-test-plan.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))