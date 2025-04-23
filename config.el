;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Antoine Sole")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-bluloco-dark)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;;======================================;;
;; BASICS ;;
;;======================================;;

(setq-default fill-column 80)
(setq-default text-scale-mode-amount 3)


;;======================================;;
;; DEFUN ;;
;;======================================;;

;; Persistent scrach buffer
(defun doom/toggle-scratch-buffer (&optional arg project-p same-window-p)
  "Toggle a persistent scratch buffer.

If passed the prefix ARG, do not restore the last scratch buffer.
If PROJECT-P is non-nil, open a persistent scratch buffer associated with the
  current project."
  (interactive "P")
  (let (projectile-enable-caching)
    (if (eq (+popup-buffer-p (get-buffer "*doom:scratch*")) nil)
        (funcall
     (if same-window-p
         #'switch-to-buffer
       #'pop-to-buffer)
     (doom-scratch-buffer
      arg
      (cond ((eq doom-scratch-initial-major-mode t)
             (unless (or buffer-read-only
                         (derived-mode-p 'special-mode)
                         (string-match-p "^ ?\\*" (buffer-name)))
               major-mode))
            ((null doom-scratch-initial-major-mode)
             nil)
            ((symbolp doom-scratch-initial-major-mode)
             doom-scratch-initial-major-mode))
      default-directory
      (when project-p
        (doom-project-name))))
      (quit-windows-on (get-buffer "*doom:scratch*") nil))))

;; Connect to ssh quickly
(defun ssh-connect ()
  (interactive))

;;======================================;;
;; MAPPING ;;
;;======================================;;

(map! :leader
      :desc "Open scratch pad" "x" #'doom/toggle-scratch-buffer)

(map! :after projectile
      :leader
      :prefix "s"
      :desc "Replace in project" "R" 'projectile-replace-regexp)

(map! :leader
      :prefix "o"
      :desc "Open ssh connection" "s" 'ssh-connect)

(map! :mode html-mode
      :leader
      :prefix "c"
      :desc "Format file" "F" 'sgml-pretty-print)

;;======================================;;
;; ORG ;;
;;======================================;;

;; Keep a daily note
(defun open-daily-note ()
  (interactive)
  (let* ((today (format-time-string "%Y-%m-%d"))
         (path (concat (getenv "HOME") "/org/daily/" today ".org")))
    (find-file path)))

(defun org/insert-heading-reference (heading description)
  "Insert an reference to a heading"

  (interactive "sHeading: \nsDescription: " )
  (insert
   (concat " [["
           heading
           "]"
           (if (string= "" description)
               ()
               (concat "[" description "]"))
           "]")))

(map! :after org
      :localleader
      (:prefix-map ("m" . "move")
       :desc "Move to parent heading" "u" 'outline-up-heading
       :desc "Move to next heading at same level" "j" 'org-forward-heading-same-level
       :desc "Move to prev heading at same level" "k" 'org-backward-heading-same-level))

(map! :after org
      :localleader
      (:prefix-map ("l" . "links")
       :desc "Insert an reference to a heading" "h" 'org/insert-heading-reference))

(map! :leader
      :prefix "n"
      :desc "Open daily note" "d" 'open-daily-note)
