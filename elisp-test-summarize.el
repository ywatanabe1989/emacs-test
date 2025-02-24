;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 02:16:26>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/elisp-test-summarize.el

;; Handles parsing and summarizing test results.

;; Parser
;; ----------------------------------------

(defun et--parse-test-result
    (result-str)
  "Parse test result string to extract pass/fail counts."
  (let
      ((passed 0)
       (failed 0)
       (skipped 0)
       (timeout 0))
    (cond
     ((string-prefix-p "TIMEOUT:" result-str)
      (cl-incf timeout))
     ((string-prefix-p "ERROR:" result-str)
      (cl-incf failed))
     ((string-prefix-p "NOT-FOUND:" result-str)
      (cl-incf skipped))
     (t
      (when
          (string-match "Passed:\\s-*\\([0-9]+\\)" result-str)
        (setq passed
              (string-to-number
               (match-string 1 result-str))))
      (when
          (string-match "Failed:\\s-*\\([0-9]+\\)" result-str)
        (setq failed
              (+ failed
                 (string-to-number
                  (match-string 1 result-str)))))
      (when
          (string-match "Skipped:\\s-*\\([0-9]+\\)" result-str)
        (setq skipped
              (string-to-number
               (match-string 1 result-str))))))
    (list passed failed skipped timeout)))

;; Summarizer
;; ----------------------------------------

(defun et--summarize-results
    (results)
  "Summarize test results with visualization and create org buffer."
  (let
      ((total-passed 0)
       (total-failed 0)
       (total-skipped 0)
       (total-timeout 0)
       (total-duplicates 0)
       (org-buffer
        (get-buffer-create "*elisp-test-results*"))
       (test-names
        (make-hash-table :test 'equal)))

    (dolist
        (result results)
      (let*
          ((test-name
            (cadr result))
           (output
            (nth 2 result))
           (counts
            (et--parse-test-result output)))
        (cl-incf total-passed
                 (nth 0 counts))
        (cl-incf total-failed
                 (nth 1 counts))
        (cl-incf total-skipped
                 (nth 2 counts))
        (cl-incf total-timeout
                 (nth 3 counts))
        (puthash test-name
                 (1+
                  (gethash test-name test-names 0))
                 test-names)))

    (maphash
     (lambda
       (k v)
       (when
           (> v 1)
         (cl-incf total-duplicates)))
     test-names)

    (with-current-buffer org-buffer
      (erase-buffer)
      (org-mode)
      (insert "* Test Results Summary\n\n")
      (let*
          ((total
            (+ total-passed total-failed total-skipped total-timeout))
           (success-rate
            (/
             (* 100.0 total-passed)
             total)))
        (insert
         (format "- Passed: %d\n" total-passed))
        (insert
         (format "- Failed: %d\n" total-failed))
        (insert
         (format "- Skipped: %d\n" total-skipped))
        (insert
         (format "- Timeout: %d\n" total-timeout))
        (insert
         (format "- Duplicates: %d\n" total-duplicates))
        (insert
         (format "- Total: %d\n" total))
        (insert
         (format "- Success Rate: %.1f%%\n\n" success-rate)))

      (insert "* Individual Test Results\n\n")
      (insert "** Passed Tests\n")
      (dolist
          (result results)
        (when
            (string-match "Passed:\\s-*1"
                          (nth 2 result))
          (let
              ((test-name
                (cadr result))
               (duplicate-tag
                (if
                    (>
                     (gethash
                      (cadr result)
                      test-names 0)
                     1)
                    " [DUPLICATE]" "")))
            (insert
             (format "- [[file:%s::%s][%s]] :: %s%s\n"
                     (car result)
                     test-name
                     (file-name-nondirectory
                      (car result))
                     test-name
                     duplicate-tag)))))

      (insert "\n** Failed Tests\n")
      (dolist
          (result results)
        (when
            (or
             (string-prefix-p "ERROR:"
                              (nth 2 result))
             (string-match "Failed:\\s-*1"
                           (nth 2 result)))
          (let
              ((test-name
                (cadr result))
               (duplicate-tag
                (if
                    (>
                     (gethash
                      (cadr result)
                      test-names 0)
                     1)
                    " [DUPLICATE]" "")))
            (insert
             (format "- [[file:%s::%s][%s]] :: %s%s\n"
                     (car result)
                     test-name
                     (file-name-nondirectory
                      (car result))
                     test-name
                     duplicate-tag)))))

      (insert "\n** Skipped Tests\n")
      (dolist
          (result results)
        (when
            (string-prefix-p "NOT-FOUND:"
                             (nth 2 result))
          (let
              ((test-name
                (cadr result))
               (duplicate-tag
                (if
                    (>
                     (gethash
                      (cadr result)
                      test-names 0)
                     1)
                    " [DUPLICATE]" "")))
            (insert
             (format "- [[file:%s::%s][%s]] :: %s%s\n"
                     (car result)
                     test-name
                     (file-name-nondirectory
                      (car result))
                     test-name
                     duplicate-tag)))))

      (insert "\n** Timeout Tests\n")
      (dolist
          (result results)
        (when
            (string-prefix-p "TIMEOUT:"
                             (nth 2 result))
          (let
              ((test-name
                (cadr result))
               (duplicate-tag
                (if
                    (>
                     (gethash
                      (cadr result)
                      test-names 0)
                     1)
                    " [DUPLICATE]" "")))
            (insert
             (format "- [[file:%s::%s][%s]] :: %s%s\n"
                     (car result)
                     test-name
                     (file-name-nondirectory
                      (car result))
                     test-name
                     duplicate-tag)))))

      ;; Save the buffer to the specified file
      (when
          (and et-results-file
               (or
                (not
                 (file-exists-p et-results-file))
                (yes-or-no-p
                 (format "File %s exists. Overwrite? " et-results-file))))
        (write-region
         (point-min)
         (point-max)
         et-results-file)
        (message "Test results saved to %s" et-results-file))

      ;; Display the results buffer
      (goto-char
       (point-min))
      (org-overview)
      (org-content 2)
      (display-buffer org-buffer)

      ;; Return the buffer contents
      (buffer-string))))

(provide 'elisp-test-summarize)

(when
    (not load-file-name)
  (message "elisp-test-summarize.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))