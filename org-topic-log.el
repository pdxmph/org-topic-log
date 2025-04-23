;;; org-topic-log.el --- Capture logs into agenda-based topic org files -*- lexical-binding: t; -*-
;;
;; Author: Generated
;; Version: 0.4
;; Package-Requires: ((emacs "25.1") (org "9.0"))
;; Keywords: outlines, convenience, org
;; URL: https://example.com/org-topic-log
;;
;;; Commentary:
;; Simplified: capture log entries into one of your `org-agenda-files`
;; based on a file-level tag (#+FILETAGS: topic). Includes debug messages.
;;
;; Usage:
;;   (require 'org-topic-log)
;;   (org-topic-log-setup)
;;   M-x org-topic-log-capture
;;
;;; Code:

(require 'seq)

(defgroup org-topic-log nil
  "Capture logs into topic-tagged org files from `org-agenda-files`"
  :group 'org
  :prefix "org-topic-log-")

(defcustom org-topic-log-filetag "topic"
  "File-level tag (#+FILETAGS:) identifying agenda files to capture into."
  :type 'string
  :group 'org-topic-log)

(defun org-topic-log--scan-files ()
  "Return list of agenda .org files whose #+FILETAGS: contains `org-topic-log-filetag`.
Debugs `org-agenda-files` and shows filtered results."
  ;; Debug: show current agenda files
  (message "[org-topic-log] org-agenda-files = %S" org-agenda-files)
  (when (boundp 'org-agenda-files)
    (let ((results
           (seq-filter
            (lambda (file)
              (and (string-match-p "\\.org\\'" file)
                   (with-temp-buffer
                     (insert-file-contents file)
                     (goto-char (point-min))
                     (let ((case-fold-search t))
                       (re-search-forward
                        (format "^#\\+FILETAGS:.*\\<%s\\>" org-topic-log-filetag)
                        nil t)))))
            org-agenda-files)))
      ;; Debug: show filtered topic files
      (message "[org-topic-log] filtered files = %S" results)
      results)))

(defun org-topic-log--select-file ()
  "Prompt user to select one of the topic-tagged agenda files."
  (let* ((files (org-topic-log--scan-files))
         (choices (mapcar (lambda (f) (cons (file-name-nondirectory f) f)) files)))
    ;; Debug: show choices before prompt
    (message "[org-topic-log] select choices = %S" choices)
    (if (null choices)
        (user-error "No agenda .org files with #+FILETAGS: %s" org-topic-log-filetag)
      (cdr (assoc (completing-read "Select topic file: " choices nil t) choices)))))

;;;###autoload
(defun org-topic-log-capture ()
  "Capture a log entry into a selected topic agenda file."
  (interactive)
  (org-capture nil "L"))

;;;###autoload
(defun org-topic-log-setup ()
  "Install the org-capture template for topic log entries from agenda files."
  (with-eval-after-load 'org-capture
    (add-to-list 'org-capture-templates
                 '("L" "Topic log" entry
                   (file org-topic-log--select-file)
                   "* %U %^{Title} %^g\n%?\n"
                   :prepend t
                   :empty-lines 1)
                 t)))

(provide 'org-topic-log)
;;; org-topic-log.el ends here
