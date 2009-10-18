;;;
;;; TODO: fails if translated string contains \n
;;;


(defconst translation-yml-file "~/devel/medical-reservation-system/mrs/config/locales/en.yml")

(defconst what-is-in-string "-_A-Za-z0-9\n\t\b\s!@#$%^&*()-+=_")

(defun select-string ()
  "Select a string under cursor. “string” here is anything between “”. Returns_pair_(beginig-of-string-in-buffer, end-of-string-in-buffer)."
  (interactive)
  (let (b1 b2)
    (skip-chars-backward what-is-in-string)
    (setq b1 (point))
    (skip-chars-forward what-is-in-string)
    (setq b2 (point))
    (set-mark b1)
    (cons b1 b2)
    )
  )

(defun localize-selected-string ()
  "Repleces string under cursor to fit for rails translations e.g string \"Someone else\" will be converted to t(:someone_else). Returns translation list: key and translation "  
  (interactive)
  (let ((selected (select-string)))
    (let ((p1 (car selected))
          (p2 (cdr selected)))
      (let ((val (buffer-substring p1 p2)))
        (progn
          (downcase-region p1 p2)
          (replace-string " " "_" `() p1 p2)
          (replace-string "\"" "t(:" `()  (- p1 1) p1)
          (replace-string "\"" ")"   `()  (+ p2 2) (+ p2 3) )
          (cons (buffer-substring (+ p1 2) (+ p2 2)) val)
          )
        )
      )
    )
  )


(defun update-translation-file ()
  "Replaces string under cursor and updates translation file"
  (interactive)
  (let ((translated-pair (localize-selected-string)))
    (let ((key (car translated-pair))
          (value (cdr translated-pair))
          (buf-name (buffer-name)))
      (progn
        (message "This is %s %s" key value)
        (switch-to-buffer (find-file-noselect translation-yml-file))
        ;; find key in file, if there is no such key insert it
        (beginning-of-buffer)
        (if (search-forward key `() t)
            (message "Key %s exists in buffer %s" key (buffer-name))
          (progn
            (end-of-buffer)
            (insert "\n")
            (insert key)
            (insert ": \"")
            (insert value)
            (insert "\""))
          (indent-for-tab-command)
            
          )
        (switch-to-buffer buf-name)
        )
      )
    )
  )




