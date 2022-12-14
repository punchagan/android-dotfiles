;; Add melpa to package archives list
(require 'package)
(setq package-archives
      '(("gnu"       . "http://elpa.gnu.org/packages/")
        ("melpa"     . "http://melpa.org/packages/")))

;; Ensure the installed packages are on load-path
(package-initialize)

;; Backup to a single directory
(setq backup-directory-alist
      `(("." . ,(expand-file-name "backups" user-emacs-directory))))

;; No tool-bar, menu-bar and scroll-bar
(tool-bar-mode   -1)
(menu-bar-mode   -1)

;; More prominent window divider
(window-divider-mode 1)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(lua-mode prettier magit)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
