;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 07:14:33>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/tests/test-elisp-test-find.el

(require 'ert)
(require 'elisp-test-find)

(ert-deftest test-et-find-test-files-single-file
    ()
  (should
   (equal
    (et-find-test-files "test-elisp-test-find.el")
    (list
     (expand-file-name "test-elisp-test-find.el")))))

(ert-deftest test-et-find-test-files-directory
    ()
  (let
      ((test-dir default-directory))
    (should
     (member
      (expand-file-name "test-elisp-test-find.el")
      (et-find-test-files test-dir)))))

(ert-deftest test-et-find-test-files-exclude
    ()
  (let
      ((test-dir default-directory))
    (should-not
     (member ".test-hidden.el"
             (et-find-test-files test-dir)))))

(ert-deftest test--et-find-deftest-file
    ()
  (let
      ((tests
        (--et-find-deftest-file "test-elisp-test-find.el")))
    (should
     (member "test-et-find-test-files-single-file"
             (mapcar #'cdr tests)))))

(ert-deftest test--et-find-deftest
    ()
  (let
      ((tests
        (--et-find-deftest default-directory)))
    (should
     (member "test-et-find-test-files-single-file"
             (mapcar #'cdr tests)))))

(provide 'test-elisp-test-find)

(ert-deftest test--et-find-deftest-file
    ()
  (let
      ((temp-test-file
        (make-temp-file "elisp-test" nil ".el")))
    (unwind-protect
        (progn
          (with-temp-file temp-test-file
            (insert "(ert-deftest sample-test () t)"))
          (let
              ((results
                (--et-find-deftest-file temp-test-file)))
            (should
             (equal
              (cdr
               (car results))
              "sample-test"))))
      (delete-file temp-test-file))))

(provide 'test-elisp-test-find)

(when
    (not load-file-name)
  (message "test-elisp-test-find.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))