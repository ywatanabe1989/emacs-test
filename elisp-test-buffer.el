;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 07:16:43>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/elisp-test-buffer.el

(defun elisp-test-buffer
    (&optional file-path buffer-name)
  "Run all tests in FILE-PATH and store results in BUFFER-NAME."
  (interactive)
  (let*
      ((current-file
        (if file-path
            (expand-file-name file-path)
          (buffer-file-name)))
       (test-buffer
        (find-file-noselect current-file))
       (orig-buffer
        (current-buffer))
       (buffer
        (get-buffer-create
         (or buffer-name "*ert*"))))

    (with-current-buffer test-buffer
      (eval-buffer)
      (save-excursion
        (goto-char
         (point-min))
        (let
            ((tests
              '())
             (results
              '()))
          (while
              (re-search-forward "^(ert-deftest\\s-+\\(\\sw\\(?:\\sw\\|-\\)*\\)" nil t)
            (push
             (intern
              (match-string-no-properties 1))
             tests))

          (when tests
            (with-current-buffer buffer
              (let
                  ((inhibit-read-only t))
                (erase-buffer)
                (insert
                 (format "File: %s\n" current-file))
                (setq tests
                      (nreverse tests))
                (dolist
                    (test tests)
                  (condition-case err
                      (let*
                          ((test-obj
                            (ert-get-test test))
                           (result
                            (ert-run-test test-obj))
                           (status
                            (if
                                (ert-test-passed-p result)
                                "PASSED" "FAILED")))
                        (push
                         (cons test
                               (cons status result))
                         results)
                        (insert
                         (format "Test: %s\nStatus: %s\n" test status))
                        (when
                            (ert-test-failed-p result)
                          (insert
                           (format "Error: %S\n"
                                   (ert-test-result-with-condition-condition result))))
                        (insert "\n"))
                    (error
                     (push
                      (cons test
                            (cons "ABORTED" err))
                      results)
                     (insert
                      (format "Test: %s\nStatus: ABORTED\nError: %S\n\n"
                              test err)))))))))))
    (pop-to-buffer buffer)
    (pop-to-buffer orig-buffer)
    buffer))

(global-set-key
 (kbd "C-M-t")
 'elisp-test-buffer)

(provide 'elisp-test-buffer)

(when
    (not load-file-name)
  (message "elisp-test-buffer.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))