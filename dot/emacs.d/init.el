;; unobtrusive backup files

(setq backup-directory-alist `(("." . "~/.emacs-backup")))

;; generic settings

(setq auto-save-default nil)
(setq column-number-mode t)
(setq-default indent-tabs-mode nil)
(put 'downcase-region 'disabled nil)

;; use package management

(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list 'package-archives
               '("melpa" . "https://melpa.org/packages/"))
  (package-initialize))

;; automatically wrap text in text-mode

(add-hook 'text-mode-hook 'turn-on-auto-fill)

(setq paragraph-start "\\*\\|$"
      paragraph-separate "$")

;; W3M setup

(setq browse-url-browser-function 'w3m-browse-url)

(autoload 'w3m-browse-url "w3m" "Ask a WWW browser to show a URL." t)

(defun w3m-new-buffer ()
  "Opens a new, empty w3m buffer."
  "creating new buffer faster than `w3m-copy-buffer'"
  (interactive)
  (w3m-goto-url-new-session "about://"))

;; use mail-mode for Mutt and Sylpheed buffers

(add-to-list 'auto-mode-alist '("/mutt-" . mail-mode))
(add-to-list 'auto-mode-alist '("/tmpmsg-" . mail-mode))

;; Linux-style C formatting

(add-hook
 'c-mode-common-hook
 '(lambda () (local-set-key (kbd "RET") 'newline-and-indent)))

(defun linux-c-mode ()
  "C mode with adjusted defaults for use with the Linux kernel."
  (interactive)
  (c-mode)
  (c-set-style "K&R")
  (setq tab-width 8)
  (setq indent-tabs-mode t)
  (setq c-basic-offset 8))

(add-to-list 'auto-mode-alist '("\\.[ch]\\'" . linux-c-mode))

;; markdown-mode

(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)

(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.txt\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))

;; deft note-taking mode

(setq deft-extension "txt")
(setq deft-directory "~/Notes")
(setq deft-text-mode 'markdown-mode)

;; Tuareg and friends

(autoload 'tuareg-mode "tuareg" "Major mode for editing Caml code" t)
(autoload 'ocp-setup-indent "ocp-indent" "Indent OCaml" t)
(autoload 'merlin-mode "merlin" "Merlin mode" t)
(autoload 'utop "utop" "Toplevel for OCaml" t)
(autoload 'camldebug "camldebug" "Run the Caml debugger" t)

(add-hook 'tuareg-mode-hook 'merlin-mode)
(add-hook 'tuareg-mode-hook 'ocp-setup-indent)

(setq auto-mode-alist
      (cons '("\\.ml\\w?" . tuareg-mode) auto-mode-alist))

(setq auto-mode-alist
      (cons '("\\.eliom\\w?" . tuareg-mode) auto-mode-alist))

(setq tuareg-in-indent 0)

(add-hook
 'tuareg-mode-hook
 '(lambda () (add-hook 'before-save-hook 'delete-trailing-whitespace)))

;; setup environment variables using opam

(if (executable-find "opam")
    (dolist (var
             (car
              (read-from-string
               (shell-command-to-string "opam config env --sexp"))))
      (setenv (car var) (cadr var))))

;; update the emacs path and load path for OPAM-installed stuff

(let ((op (getenv "OCAML_TOPLEVEL_PATH")))
  (when op
    (add-to-list 'load-path
                 (expand-file-name "../../share/emacs/site-lisp" op))
    (add-to-list 'exec-path
                 (expand-file-name "../../bin" op))))

;; server setup

(require 'server)

(setq server-name "std")

(defun shutdown ()
  "Save buffers, Quit, and Shutdown (kill) server"
  (interactive)
  (save-some-buffers)
  (kill-emacs))

;; compilation keybindings

(global-set-key (kbd "C-c c") 'compile)

(global-set-key (kbd "C-c r") 'recompile)
