#!/usr/bin/sbcl --script
;;;; JAR Decompiler Tool in Common Lisp
;;;; Simple, practical implementation with minimal dependencies

;;; Utility functions for colored output
(defun format-color (stream color-code text)
  "Print colored text to stream"
  (format stream "~C[~Am~A~C[0m" #\Esc color-code text #\Esc))

(defun print-info (message)
  (format-color t 34 (format nil "[INFO] ~A" message))
  (terpri))

(defun print-success (message)
  (format-color t 32 (format nil "[SUCCESS] ~A" message))
  (terpri))

(defun print-error (message)
  (format-color t 31 (format nil "[ERROR] ~A" message))
  (terpri))

(defun print-warning (message)
  (format-color t 33 (format nil "[WARNING] ~A" message))
  (terpri))

;;; System command execution (safe, no shell interpretation)
(defun run-program-safe (program args &key directory ignore-errors (output t) (error-output t))
  "Run a program with arguments safely (no shell interpretation)"
  (let* ((process (sb-ext:run-program program args
                    :directory directory
                    :output output
                    :error error-output
                    :search t
                    :wait t))
         (exit-code (sb-ext:process-exit-code process)))
    (unless (or ignore-errors (zerop exit-code))
      (error "Command failed: ~A ~A (exit code: ~A)" program args exit-code))
    exit-code))

(defun run-program-output (program args &key directory)
  "Run a program and capture its stdout as a string"
  (with-output-to-string (stream)
    (sb-ext:run-program program args
                       :directory directory
                       :output stream
                       :error nil
                       :search t
                       :wait t)))

(defun file-exists-p (path)
  "Check if file exists"
  (probe-file path))

(defun ensure-dir (path)
  "Ensure directory exists"
  (ensure-directories-exist (concatenate 'string path "/")))

;;; Configuration
(defparameter *decompiler-dir* (namestring (merge-pathnames "decompiler-tools/" (user-homedir-pathname))))
(defparameter *decompilers*
  '((:cfr         . ("cfr.jar"
                    "https://github.com/leibnitz27/cfr/releases/download/0.152/cfr-0.152.jar"))
    (:fernflower . ("fernflower.jar"
                    "https://github.com/fesh0r/fernflower/releases/download/v1.1.1/fernflower-1.1.1.jar"))
    (:procyon    . ("procyon.jar"
                    "https://github.com/mstrobel/procyon/releases/download/v0.6.0/procyon-decompiler-0.6.0.jar"))))

;;; Decompiler management
(defun get-decompiler-info (type)
  "Get decompiler JAR name and URL"
  (cdr (assoc type *decompilers*)))

(defun get-decompiler-jar-path (type)
  "Get full path to decompiler JAR"
  (let ((info (get-decompiler-info type)))
    (when info
      (concatenate 'string *decompiler-dir* (first info)))))

(defun download-decompiler (type)
  "Download decompiler if not present"
  (let* ((info (get-decompiler-info type))
         (jar-path (get-decompiler-jar-path type))
         (url (second info)))
    (when (and jar-path url (not (file-exists-p jar-path)))
      (print-warning (format nil "~A not found. Downloading..." type))
      (ensure-dir *decompiler-dir*)
      (run-program-safe "wget" (list "-q" url "-O" jar-path))
      (print-success (format nil "~A downloaded successfully" type)))))

;;; JAR operations
(defun extract-jar (jar-path output-dir)
  "Extract JAR file to output directory"
  (print-info (format nil "Extracting JAR file: ~A" jar-path))
  (ensure-dir output-dir)
  (let ((abs-jar (namestring (truename jar-path))))
    (let ((exit-code (run-program-safe "jar" (list "xf" abs-jar)
                                       :directory output-dir
                                       :ignore-errors t
                                       :error-output nil)))
      (unless (zerop exit-code)
        (run-program-safe "unzip" (list "-q" abs-jar)
                          :directory output-dir))))
  (print-success "JAR file extracted"))

(defun find-class-files (directory)
  "Find all .class files in directory"
  (let ((output (run-program-output "find" (list directory "-name" "*.class" "-type" "f"))))
    (with-input-from-string (s output)
      (loop for line = (read-line s nil nil)
            while line
            unless (string= line "")
            collect line))))

(defun count-files (directory extension)
  "Count files with given extension in directory"
  (let ((output (run-program-output "find"
                  (list directory "-name" (format nil "*.~A" extension) "-type" "f"))))
    (length (remove-if (lambda (line) (string= line ""))
                       (with-input-from-string (s output)
                         (loop for line = (read-line s nil nil)
                               while line collect line))))))

;;; Decompilation
(defun decompile-with-cfr (class-file java-file)
  "Decompile single class file with CFR"
  (let ((jar-path (get-decompiler-jar-path :cfr)))
    (with-open-file (out java-file :direction :output :if-exists :supersede)
      (sb-ext:run-program "java" (list "-jar" jar-path class-file)
                         :output out
                         :error nil
                         :search t
                         :wait t))))

(defun decompile-with-procyon (class-file java-file)
  "Decompile single class file with Procyon"
  (let ((jar-path (get-decompiler-jar-path :procyon)))
    (with-open-file (out java-file :direction :output :if-exists :supersede)
      (sb-ext:run-program "java" (list "-jar" jar-path class-file)
                         :output out
                         :error nil
                         :search t
                         :wait t))))

(defun decompile-with-fernflower (jar-file output-dir)
  "Decompile entire JAR with Fernflower"
  (let ((jar-path (get-decompiler-jar-path :fernflower))
        (temp-dir (concatenate 'string output-dir "/fernflower-temp")))
    (ensure-dir temp-dir)
    (run-program-safe "java" (list "-jar" jar-path "-dgs=1" jar-file temp-dir)
                      :ignore-errors t :error-output nil)
    ;; Extract the decompiled JAR
    (let ((decompiled-jar (format nil "~A/~A" temp-dir (file-namestring jar-file))))
      (when (file-exists-p decompiled-jar)
        (run-program-safe "jar" (list "xf" (namestring (truename decompiled-jar)))
                          :directory temp-dir :error-output nil :ignore-errors t)
        (delete-file decompiled-jar)
        ;; Move files to output dir
        (run-program-safe "cp" (list "-r" "-T" temp-dir output-dir)
                          :ignore-errors t)
        (run-program-safe "rm" (list "-rf" temp-dir))))))

(defun decompile-classes (output-dir decompiler-type jar-file &key verbose keep-class)
  "Decompile all class files in directory"
  (print-info (format nil "Finding .class files..."))
  (let ((class-files (find-class-files output-dir)))
    (print-info (format nil "Found ~A class files" (length class-files)))

    (print-info (format nil "Decompiling with ~A..." decompiler-type))

    (cond
      ;; Fernflower processes the whole JAR at once
      ((eq decompiler-type :fernflower)
       (decompile-with-fernflower jar-file output-dir))

      ;; CFR and Procyon process individual files
      (t
       (let ((count 0)
             (total (length class-files)))
         (dolist (class-file class-files)
           (incf count)
           (when verbose
             (format t "  Decompiling (~A/~A): ~A~%" count total class-file))

           (let ((java-file (concatenate 'string
                                        (subseq class-file 0 (- (length class-file) 6))
                                        ".java")))
             (case decompiler-type
               (:cfr (decompile-with-cfr class-file java-file))
               (:procyon (decompile-with-procyon class-file java-file))
               (t (error "Unknown decompiler: ~A" decompiler-type))))))))

    (print-success "Decompilation completed")

    ;; Remove class files if requested
    (unless keep-class
      (print-info "Removing .class files...")
      (run-program-safe "find" (list output-dir "-name" "*.class" "-type" "f" "-delete"))
      (print-success ".class files removed"))))

;;; Main function
(defun decompile-jar (jar-file &key output-dir decompiler verbose keep-class)
  "Main decompilation function"
  (handler-case
      (progn
        ;; Check JAR file exists
        (unless (file-exists-p jar-file)
          (print-error (format nil "JAR file not found: ~A" jar-file))
          (return-from decompile-jar nil))

        ;; Set default output directory
        (unless output-dir
          (setf output-dir (format nil "~A_src"
                                  (pathname-name (pathname jar-file)))))

        ;; Set default decompiler
        (unless decompiler
          (setf decompiler :cfr))

        ;; Download decompiler if needed
        (download-decompiler decompiler)

        ;; Extract and decompile
        (extract-jar jar-file output-dir)
        (decompile-classes output-dir decompiler jar-file
                          :verbose verbose :keep-class keep-class)

        ;; Summary
        (let ((java-count (count-files output-dir "java")))
          (terpri)
          (print-success "=== Decompilation Summary ===")
          (format t "  JAR file:        ~A~%" jar-file)
          (format t "  Output directory: ~A~%" output-dir)
          (format t "  Decompiler used: ~A~%" decompiler)
          (format t "  Java files created: ~A~%" java-count)
          (terpri)
          (print-info (format nil "You can browse the decompiled source in: ~A" output-dir))))
    (error (e)
      (print-error (format nil "Error: ~A" e))
      nil)))

;;; Command-line interface
(defun show-usage ()
  "Display usage information"
  (format t "Usage: jar-decompiler.lisp [OPTIONS] <jar_file>~%~%")
  (format t "JAR Decompiler Tool - Lisp Version~%~%")
  (format t "OPTIONS:~%")
  (format t "  -o <dir>      Output directory (default: <jar_name>_src)~%")
  (format t "  -d <type>     Decompiler: cfr, fernflower, procyon (default: cfr)~%")
  (format t "  -v            Verbose output~%")
  (format t "  -k            Keep .class files after decompilation~%")
  (format t "  -h            Show this help message~%~%")
  (format t "EXAMPLES:~%")
  (format t "  ./jar-decompiler.lisp myapp.jar~%")
  (format t "  ./jar-decompiler.lisp -o output -d procyon myapp.jar~%")
  (format t "  ./jar-decompiler.lisp -v -k library.jar~%~%"))

(defun parse-args (args)
  "Parse command-line arguments"
  (let ((options nil)
        (jar-file nil)
        (i 1))  ; Start from 1 to skip script name
    (loop while (< i (length args))
          do (let ((arg (nth i args)))
               (cond
                 ((string= arg "-o")
                  (incf i)
                  (when (< i (length args))
                    (setf (getf options :output-dir) (nth i args))))
                 ((string= arg "-d")
                  (incf i)
                  (when (< i (length args))
                    (setf (getf options :decompiler)
                          (intern (string-upcase (nth i args)) :keyword))))
                 ((string= arg "-v")
                  (setf (getf options :verbose) t))
                 ((string= arg "-k")
                  (setf (getf options :keep-class) t))
                 ((string= arg "-h")
                  (show-usage)
                  (sb-ext:exit :code 0))
                 ((not (char= (char arg 0) #\-))
                  (setf jar-file arg)))
               (incf i)))
    (values jar-file options)))

;;; Main entry point
(defun main ()
  "Main entry point for script"
  (handler-case
      (multiple-value-bind (jar-file options)
          (parse-args sb-ext:*posix-argv*)
        (if jar-file
            (apply #'decompile-jar jar-file options)
            (progn
              (print-error "No JAR file specified")
              (show-usage)
              (sb-ext:exit :code 1))))
    (error (e)
      (print-error (format nil "Fatal error: ~A" e))
      (sb-ext:exit :code 1)))
  (sb-ext:exit :code 0))

;;; Run main when executed as script
(main)