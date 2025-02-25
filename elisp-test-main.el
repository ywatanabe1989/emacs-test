;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 14:36:25>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/elisp-test-main.el

;; Contains the main function to run tests.

(defun et-test
    (&rest root-paths)
  "Run tests from specified ROOT-PATHS, marked files in dired, or current directory."
  (interactive)
  (setq et-results-org-path-switched
        (if
            (eq major-mode 'dired-mode)
            (expand-file-name et-results-org-path-dired default-directory)
          et-results-org-path))
  (let*
      ((paths
        (cond
         ((eq major-mode 'dired-mode)
          (--et-find-list-marked-paths-dired))
         (root-paths
          (et-find-test-files-multiple root-paths))
         (t
          (list default-directory))))
       (tests
        (et--prepare-test-plan paths)))
    (when
        (and tests
             (yes-or-no-p "Proceed with running these tests? "))
      (let
          ((test-results
            (et--run-multiple-test tests)))
        (et--report-results
         (get-buffer-create "*elisp-test-results*")
         test-results)))))

;; ;; Key Binding
;; (global-set-key (kbd "C-c C-t") #'et-test)

(provide 'elisp-test-main)

(when
    (not load-file-name)
  (message "elisp-test-main.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))