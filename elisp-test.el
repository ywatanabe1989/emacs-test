;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-24 23:47:45>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/elisp-test.el

;; Main entry point, requiring all other modules and providing the `elisp-test` feature.

;;; elisp-test.el --- Main entry point for the Emacs Lisp testing framework -*- lexical-binding: t; -*-

(require 'elisp-test-variables)
(require 'elisp-test-path)
(require 'elisp-test-find)
(require 'elisp-test-run)
(require 'elisp-test-summarize)
(require 'elisp-test-main)

(provide 'elisp-test)

(when
    (not load-file-name)
  (message "elisp-test.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))