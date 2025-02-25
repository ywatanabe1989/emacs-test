;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 14:21:45>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/elisp-test-find.el

;; Contains functions to discover test files and extract test definitions.

;; Test Files Finder
;; ----------------------------------------

(defun et-find-test-files-multiple
    (root-paths &optional include-hidden-p)
  "Find test files in multiple ROOT-PATHS."
  (when root-paths
    (mapcan
     (lambda
       (path)
       (--et-find-test-files-single path include-hidden-p))
     root-paths)))

(defun et-find-test-files-multiple-dired
    (&optional include-hidden-p)
  "Find test files based on selected paths"
  (interactive)
  (when
      (eq major-mode 'dired-mode)
    (let*
        ((root-paths
          (--et-find-list-marked-paths-dired))
         (test-files
          (when root-paths
            (mapcan
             (lambda
               (path)
               (--et-find-test-files-single path include-hidden-p))
             root-paths))))
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

;; From Single Root
;; ----------------------------------------

(defun --et-find-matching-files
    (root-path patterns)
  "Find files in ROOT-PATH matching any of the given PATTERNS."
  ;; (message "DEBUG: Finding matching files in %s with patterns %S" root-path patterns)
  (let
      ((file-list
        '()))
    (if
        (file-directory-p root-path)
        (dolist
            (pattern patterns)
          ;; (message "DEBUG: Searching with pattern: %s" pattern)
          (let
              ((matching-files
                (directory-files-recursively root-path pattern t)))
            ;; (message "DEBUG: Pattern %s found %d files" pattern
            ;;          (length matching-files))
            (setq file-list
                  (append file-list matching-files))))
      (let
          ((filename
            (file-name-nondirectory root-path)))
        ;; (message "DEBUG: Checking single file: %s" filename)
        (dolist
            (pattern patterns)
          (when
              (string-match-p pattern filename)
            ;; (message "DEBUG: File matches pattern %s" pattern)
            (setq file-list
                  (list root-path))))))
    ;; (message "DEBUG: Total files matched: %d"
    ;;          (length file-list))
    file-list))

(defun --et-find-test-files-single
    (root-path &optional include-hidden-p)
  "Find all test files in ROOT-PATH matching `et-test-file-expressions`.
ROOT-PATH is used for calculating relative paths for exclusion patterns."
  (interactive "fSelect file or directory: ")
  ;; (message "DEBUG: Starting --et-find-test-files-single with root-path: %s" root-path)
  (let*
      ((root-path-full-path
        (expand-file-name root-path))
       (file-list
        (--et-find-matching-files root-path-full-path et-test-file-expressions)))
    ;; (message "DEBUG: After matching: Found %d files"
    ;;          (length file-list))
    ;; (message "DEBUG: et-test-file-exclude-expressions: %S" et-test-file-exclude-expressions)
    (setq file-list
          (--et-filter-excluded-files file-list root-path-full-path et-test-file-exclude-expressions))
    ;; (message "DEBUG: After exclusion: %d files remaining"
    ;;          (length file-list))
    (setq file-list
          (--et-filter-hidden-files file-list root-path-full-path include-hidden-p))
    ;; (message "DEBUG: After hidden filtering: %d files remaining"
    ;;          (length file-list))
    ;; (message "DEBUG: Final file list: %S" file-list)
    file-list))

(defun --et-filter-excluded-files
    (file-list root-path exclude-patterns)
  "Filter FILE-LIST removing files matching EXCLUDE-PATTERNS relative to ROOT-PATH."
  ;; (message "DEBUG: Filtering excluded files, patterns: %S" exclude-patterns)
  (when exclude-patterns
    (let
        ((original-count
          (length file-list)))
      (setq file-list
            (seq-remove
             (lambda
               (file)
               (let*
                   ((rel-path
                     (file-relative-name file root-path)))
                 ;; (message "DEBUG: Checking if %s should be excluded" rel-path)
                 (let
                     ((should-exclude
                       (cl-some
                        (lambda
                          (pattern)
                          (let
                              ((match
                                (string-match-p pattern rel-path)))
                            (when match
                              ;; (message "DEBUG: Excluding %s - matches pattern %s" rel-path pattern)
                              )
                            match))
                        exclude-patterns)))
                   should-exclude)))
             file-list))
      ;; (message "DEBUG: Excluded %d files"
      ;;          (- original-count
      ;;             (length file-list)))
      ))
  file-list)

(defun --et-filter-hidden-files
    (file-list root-path include-hidden-p)
  "Filter FILE-LIST to exclude hidden files unless INCLUDE-HIDDEN-P is non-nil.
Only considers files with hidden components after ROOT-PATH."
  ;; (message "DEBUG: Filtering hidden files, include-hidden-p: %s" include-hidden-p)
  (unless include-hidden-p
    (let
        ((original-count
          (length file-list)))
      (setq file-list
            (seq-filter
             (lambda
               (file)
               (let*
                   ((rel-path
                     (file-relative-name file root-path))
                    (components
                     (split-string rel-path "/" t))
                    (has-hidden-component nil))
                 ;; Check if any path component starts with a dot
                 (dolist
                     (component components)
                   (when
                       (string-match-p "^\\." component)
                     (setq has-hidden-component t)
                     ;; (message "DEBUG: Found hidden component: %s in relative path %s"
                     ;;          component rel-path)
                     ))
                 (not has-hidden-component)))
             file-list))
      ;; (message "DEBUG: Excluded %d hidden files"
      ;;          (- original-count
      ;;             (length file-list)))
      ))
  file-list)

;; (defun --et-find-test-files-single
;;     (root-path &optional include-hidden-p)
;;   "Find all test files in ROOT-PATH matching `et-test-file-expressions`."
;;   (interactive "fSelect file or directory: ")
;;   (let*
;;       ((root-path-full-path
;;         (expand-file-name root-path))
;;        (file-list
;;         '()))
;;     (if
;;         (file-directory-p root-path-full-path)
;;         (dolist
;;             (pattern et-test-file-expressions)
;;           (setq file-list
;;                 (append file-list
;;                         (directory-files-recursively root-path-full-path pattern t))))
;;       (let
;;           ((filename
;;             (file-name-nondirectory root-path-full-path)))
;;         (dolist
;;             (pattern et-test-file-expressions)
;;           (when
;;               (string-match-p pattern filename)
;;             (setq file-list
;;                   (list root-path-full-path))))))

;;     ;; ;; exclusion patterns are only applied to file names, instead of the part after the root paths
;;     ;; (when et-test-file-exclude-expressions
;;     ;;   (setq file-list
;;     ;;         (seq-remove
;;     ;;          (lambda
;;     ;;            (file)
;;     ;;            (let
;;     ;;                ((filename
;;     ;;                  (file-name-nondirectory file)))
;;     ;;              (cl-some
;;     ;;               (lambda
;;     ;;                 (pattern)
;;     ;;                 (string-match-p pattern filename))
;;     ;;               et-test-file-exclude-expressions)))
;;     ;;          file-list)))

;;     (when et-test-file-exclude-expressions
;;       (setq file-list
;;             (seq-remove
;;              (lambda
;;                (file)
;;                (let*
;;                    ((root-path root-path-full-path)
;;                     (rel-path
;;                      (file-relative-name file root-path)))
;;                  (cl-some
;;                   (lambda
;;                     (pattern)
;;                     (string-match-p pattern rel-path))
;;                   et-test-file-exclude-expressions)))
;;              file-list)))

;;     (unless include-hidden-p
;;       (setq file-list
;;             (seq-filter
;;              (lambda
;;                (file)
;;                (not
;;                 (string-match-p "^\\."
;;                                 (file-name-nondirectory file))))
;;              file-list)))

;;     file-list))

;; (defun --et-find-test-files-single-dired
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
;;                    (--et-find-test-files-single path include-hidden-p)
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
    (&optional root-path)
  "Find all ert-deftest forms in ROOT-PATH."
  (let*
      ((test-files
        (--et-find-test-files-single root-path))
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