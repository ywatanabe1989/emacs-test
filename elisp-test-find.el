;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 06:58:03>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/elisp-test-find.el

;; Contains functions to discover test files and extract test definitions.

;; Test Files Finder
;; ----------------------------------------

(defun et-find-test-files
    (file-or-directory &optional include-hidden-p)
  "Find all test files in FILE-OR-DIRECTORY matching `et-test-file-expressions`."
  (interactive "fSelect file or directory: ")
  (let*
      ((file-or-directory-full-path
        (expand-file-name file-or-directory))
       (file-list
        '()))
    (if
        (file-directory-p file-or-directory-full-path)
        (dolist
            (pattern et-test-file-expressions)
          (setq file-list
                (append file-list
                        (directory-files-recursively file-or-directory-full-path pattern t))))
      (let
          ((filename
            (file-name-nondirectory file-or-directory-full-path)))
        (dolist
            (pattern et-test-file-expressions)
          (when
              (string-match-p pattern filename)
            (setq file-list
                  (list file-or-directory-full-path))))))

    (when et-test-file-exclude-expressions
      (setq file-list
            (seq-remove
             (lambda
               (file)
               (let
                   ((filename
                     (file-name-nondirectory file)))
                 (cl-some
                  (lambda
                    (pattern)
                    (string-match-p pattern filename))
                  et-test-file-exclude-expressions)))
             file-list)))

    (unless include-hidden-p
      (setq file-list
            (seq-filter
             (lambda
               (file)
               (not
                (string-match-p "^\\."
                                (file-name-nondirectory file))))
             file-list)))

    file-list))

(defun et-find-test-files-dired
    (&optional include-hidden-p)
  "Find test files based on selected paths"
  (interactive)
  (when
      (eq major-mode 'dired-mode)
    (let*
        ((marked-paths
          (--et-find-list-marked-paths-dired))
         (test-files
          (when marked-paths
            (mapcan
             (lambda
               (path)
               (et-find-test-files path include-hidden-p))
             marked-paths))))
      ;; nil
      (when test-files
        (with-current-buffer
            (get-buffer-create et-buffer-name)
          (erase-buffer)
          (insert
           (mapconcat 'identity test-files "\n"))
          (display-buffer
           (current-buffer)))
        (progn
          (message "Found test files: %S" test-files)
          test-files)))))

;; (defun et-find-test-files-dired
;;     (&optional include-hidden-p)
;;   "Find test files based on selected paths"
;;   (interactive)
;;   (when
;;       (eq major-mode 'dired-mode)
;;     (let*
;;         ((marked-paths
;;           (--et-find-list-marked-paths-dired))
;;          (test-files
;;           (when marked-paths
;;             (mapcan
;;              (lambda
;;                (path)
;;                (if
;;                    (file-directory-p path)
;;                    (et-find-test-files path include-hidden-p)
;;                  (when
;;                      (cl-some
;;                       (lambda
;;                         (pattern)
;;                         (string-match-p pattern
;;                                         (file-name-nondirectory path)))
;;                       et-test-file-expressions)
;;                    (list path))))
;;              marked-paths))))
;;       (when test-files
;;         (with-current-buffer
;;             (get-buffer-create et-buffer-name)
;;           (erase-buffer)
;;           (insert
;;            (mapconcat 'identity test-files "\n"))
;;           (display-buffer
;;            (current-buffer)))
;;         (progn
;;           (message "Found test files: %S" test-files)
;;           test-files)))))

;; Helper
;; ----------------------------------------

;; This works
(defun --et-find-list-marked-paths-dired
    ()
  "Get list of marked files/directories in dired."
  (interactive)
  (when
      (eq major-mode 'dired-mode)
    (let
        ((found
          (dired-get-marked-files)))
      (progn
        ;; (message "Marked Files: %S" found)
        found))))

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

(defun --et-find-deftest
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