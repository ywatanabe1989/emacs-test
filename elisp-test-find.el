;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 02:15:49>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/elisp-test-find.el

;; Contains functions to discover test files and extract test definitions.

;; Test Files Finder
;; ----------------------------------------

(defun et-find-test-files
    (file-or-directory &optional include-hidden-p)
  "Find all test files in FILE-OR-DIRECTORY matching `et-test-file-expressions`.

  If INCLUDE-HIDDEN-P is non-nil, include hidden files."
  (let*
      ((full-path
        (expand-file-name file-or-directory))
       (test-dir
        (if
            (file-directory-p full-path)
            (if
                (string-match-p "/tests/?$" full-path)
                full-path
              (expand-file-name "tests" full-path))
          full-path))
       (file-list
        '()))
    (if
        (file-directory-p test-dir)
        (dolist
            (pattern et-test-file-expressions)
          (setq file-list
                (append file-list
                        (directory-files-recursively test-dir pattern))))
      (when
          (cl-some
           (lambda
             (pattern)
             (string-match-p pattern full-path))
           et-test-file-expressions)
        (setq file-list
              (list full-path))))
    ;; Exclude files matching exclude patterns
    (when et-test-file-exclude-expressions
      (setq file-list
            (seq-remove
             (lambda
               (file)
               (cl-some
                (lambda
                  (pattern)
                  (string-match-p pattern file))
                et-test-file-exclude-expressions))
             file-list)))
    ;; Filter hidden files if required
    (unless include-hidden-p
      (setq file-list
            (seq-filter
             (lambda
               (file)
               (not
                (string-match-p "/\\.[^/]*\\'" file)))
             file-list)))
    file-list))

(defun et-dired-list-marked-paths
    ()
  "Get list of marked files/directories in dired."
  (interactive)
  (when
      (eq major-mode 'dired-mode)
    (let
        ((found
          (dired-get-marked-files)))
      found)))

(defun et-find-test-files-dired
    ()
  "Find test files based on selected paths"
  (interactive)
  (let*
      ((marked-paths
        (et-dired-list-marked-paths))
       (test-files
        (when marked-paths
          (mapcan #'et-find-test-files marked-paths))))
    (when test-files
      (with-current-buffer
          (get-buffer-create et-buffer-name)
        (erase-buffer)
        (insert
         (mapconcat 'identity test-files "\n"))
        (display-buffer(current-buffer)))
      test-files)))

;; Deftest Finder
;; ----------------------------------------

(defun --et-find-deftest-file
    (file)
  "Extract ert-deftest names from FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char
     (point-min))
    (let
        (tests)
      (while
          (re-search-forward "^(ert-deftest\\s-+\\([^[:space:]\n]+\\)" nil t)
        (push
         (cons file
               (match-string 1))
         tests))
      tests)))

(defun et-find-deftest
    (&optional file-or-directory)
  "Find all ert-deftest forms in FILE-OR-DIRECTORY."
  (let*
      ((test-files
        (et-find-test-files file-or-directory))
       (tests
        '()))
    (dolist
        (file test-files tests)
      (setq tests
            (append tests
                    (--et-find-deftest-file file))))))

(provide 'elisp-test-find)

(when
    (not load-file-name)
  (message "elisp-test-find.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))