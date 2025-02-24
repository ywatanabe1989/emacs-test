;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 06:29:56>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/elisp-test-loadpath.el

;; This module handles load path management.

;; PATH
;; ----------------------------------------

(defun et-add-load-paths
    (paths)
  "Add PATHS to `et-loadpath` and `load-path`.
  PATHS should be a list of directory paths to include."
  (dolist
      (path paths)
    (let
        ((full-path
          (expand-file-name path)))
      (add-to-list 'et-loadpath full-path)
      (add-to-list 'load-path full-path))))

(provide 'elisp-test-loadpath)

(when
    (not load-file-name)
  (message "elisp-test-loadpath.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))