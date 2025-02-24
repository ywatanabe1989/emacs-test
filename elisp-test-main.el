;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 02:15:55>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/elisp-test-main.el

;; Contains the main function to run tests.

(defun et-test
    (path)
  (interactive)
  (let*
      ((tests
        (et-find-deftest path))
       (test-names
        (make-hash-table :test 'equal)))
    (when tests
      (with-current-buffer
          (get-buffer-create "*elisp-test-plan*")
        (erase-buffer)
        (org-mode)
        (insert "* Found Tests\n\n")
        (dolist
            (test tests)
          (let*
              ((fullpath
                (car test))
               (testname
                (cdr test))
               (count
                (1+
                 (gethash testname test-names 0))))
            (puthash testname count test-names)
            (insert
             (format "- [[file:%s::%s][%s]] %s\n"
                     fullpath
                     testname
                     testname
                     (if
                         (> count 1)
                         "[DUPLICATE]" "")))))
        (org-overview)
        (org-show-all)
        (display-buffer
         (current-buffer)))
      (when
          (yes-or-no-p "Proceed with running these tests? ")
        (setq --et-test-alist tests)
        (setq --et-single-test-results
              (et--run-single-test
               (car --et-test-alist)))
        (setq --et-multiple-test-results
              (et--run-multiple-test --et-test-alist))
        (setq --et-summarized-results
              (et--summarize-results --et-multiple-test-results))
        --et-summarized-results))))

;; Example
;; (require 'elisp-test)
;; (et-test "~/proj/llemacs/llemacs.el/tests")

(provide 'elisp-test-main)

(when
    (not load-file-name)
  (message "elisp-test-main.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))