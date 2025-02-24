;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 01:09:54>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/tests/test-elisp-test-find.el

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