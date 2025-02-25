;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-02-25 14:33:09>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-test/elisp-test-report.el

;; Reports test results.

;; Main
;; ----------------------------------------

(defun et--report-results
    (buffer test-results)
  "Save results from BUFFER using TEST-RESULTS to file if needed."
  (let
      ((test-names
        (make-hash-table :test 'equal)))
    (with-temp-buffer
      (org-mode)
      (let*
          ((totals
            (et--count-results test-results test-names))
           (duplicates
            (et--count-duplicates test-names)))
        (et--insert-summary
         (current-buffer)
         totals duplicates)
        (et--insert-test-section
         (current-buffer)
         test-results test-names
         (lambda
           (str)
           (string-match-p "PASSED" str))
         "Passed Tests")
        (et--insert-test-section
         (current-buffer)
         test-results test-names
         (lambda
           (str)
           (string-match-p "\\(ERROR\\|FAILED\\)" str))
         "Failed Tests")
        (et--insert-test-section
         (current-buffer)
         test-results test-names
         (lambda
           (str)
           (string-match-p "TIMEOUT:" str))
         "Timeout Tests")
        (et--insert-test-section
         (current-buffer)
         test-results test-names
         (lambda
           (str)
           (string-match-p "NOT-FOUND:" str))
         "Not Found Tests"))
      (write-region
       (point-min)
       (point-max)
       et-results-org-path-switched))
    (let
        ((latex-deps
          '("pdflatex" "latex")))
      (when
          (and
           (require 'ox-latex nil t)
           (cl-every #'executable-find latex-deps))
        (let
            ((buf
              (get-file-buffer et-results-org-path-switched)))
          (unless buf
            (setq buf
                  (find-file-noselect et-results-org-path-switched)))
          (when buf
            (display-buffer buf)
            (with-current-buffer buf
              (org-fold-show-all)
              (org-latex-export-to-pdf)
              (let
                  ((tex-file
                    (concat
                     (file-name-sans-extension et-results-org-path-switched)
                     ".tex")))
                (when
                    (file-exists-p tex-file)
                  (delete-file tex-file))))))))))

;; Helpers
;; ----------------------------------------

(defun et--count-results
    (results test-names)
  "Count totals from test RESULTS, updating TEST-NAMES hash table."
  (let
      ((total-passed 0)
       (total-failed 0)
       (total-skipped 0)
       (total-timeout 0))
    (dolist
        (result results)
      (let*
          ((test-name
            (cadr result))
           (output
            (nth 2 result)))
        (puthash test-name
                 (1+
                  (gethash test-name test-names 0))
                 test-names)
        (cond
         ((equal output "PASSED")
          (cl-incf total-passed))
         ((string-prefix-p "FAILED:" output)
          (cl-incf total-failed))
         ((string-prefix-p "SKIPPED:" output)
          (cl-incf total-skipped))
         ((string-prefix-p "TIMEOUT:" output)
          (cl-incf total-timeout))
         ((string-prefix-p "NOT-FOUND:" output)
          (cl-incf total-skipped))
         ((string-prefix-p "ERROR:" output)
          (cl-incf total-failed)))))
    (list total-passed total-failed total-skipped total-timeout)))

(defun et--count-duplicates
    (test-names)
  "Count duplicate test names in TEST-NAMES hash table."
  (let
      ((total-duplicates 0))
    (maphash
     (lambda
       (k v)
       (when
           (> v 1)
         (cl-incf total-duplicates)))
     test-names)
    total-duplicates))

(defun et--insert-summary
    (buffer totals duplicates)
  "Insert summary section into BUFFER using TOTALS and DUPLICATES count."
  (with-current-buffer buffer
    (let*
        ((total-passed
          (nth 0 totals))
         (total-failed
          (nth 1 totals))
         (total-skipped
          (nth 2 totals))
         (total-timeout
          (nth 3 totals))
         (total
          (+ total-passed total-failed total-skipped total-timeout))
         (success-rate
          (/
           (* 100.0 total-passed)
           total)))
      (insert "* Test Results Summary\n\n")
      (insert
       (format "- Passed: %d\n" total-passed))
      (insert
       (format "- Failed: %d\n" total-failed))
      (insert
       (format "- Skipped: %d\n" total-skipped))
      (insert
       (format "- Timeout: %d\n" total-timeout))
      (insert
       (format "- Duplicates: %d\n" duplicates))
      (insert
       (format "- Total: %d\n" total))
      (insert
       (format "- Success Rate: %.1f%%\n\n" success-rate)))))

;; (defun et--insert-test-section
;;     (buffer results test-names condition section-title)
;;   "Insert test section into BUFFER for tests matching CONDITION."
;;   (with-current-buffer buffer
;;     (insert
;;      (format "** %s\n" section-title))
;;     (dolist
;;         (result results)
;;       (let
;;           ((output
;;             (nth 2 result)))
;;         (when
;;             (and output
;;                  (funcall condition output))
;;           (let*
;;               ((test-name
;;                 (cadr result))
;;                (duplicate-tag
;;                 (if
;;                     (>
;;                      (gethash test-name test-names 0)
;;                      1)
;;                     " [DUPLICATE]" "")))
;;             (insert
;;              (format "- [[file:%s::%s][%s]] :: %s%s\n"
;;                      (car result)
;;                      test-name
;;                      (file-name-nondirectory
;;                       (car result))
;;                      test-name
;;                      duplicate-tag))))))))

(defun et--insert-test-section
    (buffer results test-names condition section-title)
  "Insert test section into BUFFER for tests matching CONDITION."
  (with-current-buffer buffer
    (insert
     (format "** %s\n" section-title))
    (dolist
        (result results)
      (let
          ((output
            (nth 2 result)))
        (when
            (and output
                 (funcall condition output))
          (let*
              ((test-name
                (cadr result))
               (duplicate-tag
                (if
                    (>
                     (gethash test-name test-names 0)
                     1)
                    " [DUPLICATE]" "")))
            (insert
             (format "- [[file:%s::%s][%s]] :: %s%s\n"
                     (car result)
                     test-name
                     (file-name-nondirectory
                      (car result))
                     test-name
                     duplicate-tag))
            ;; Add error details for failed tests
            (when
                (string-match-p "\\(ERROR\\|FAILED\\)" output)
              (if
                  (string-match "FAILED:\\s-*\\(.*\\)" output)
                  (let
                      ((error-details
                        (match-string 1 output)))
                    (insert "  + Error details:\n")
                    (insert
                     (format "    %s\n"
                             (string-trim error-details))))
                (when
                    (string-match "ERROR:\\s-*\\(.*\\)" output)
                  (let
                      ((error-details
                        (match-string 1 output)))
                    (insert "  + Error details:\n")
                    (insert
                     (format "    %s\n"
                             (string-trim error-details)))))))))))))

(provide 'elisp-test-report)

(when
    (not load-file-name)
  (message "elisp-test-report.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))