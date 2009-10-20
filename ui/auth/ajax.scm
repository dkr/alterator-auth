(define-module (ui auth ajax)
    :use-module (alterator woo)
    :use-module (alterator ajax)
    :use-module (alterator str)
    :use-module (alterator effect)

    :export (init))

(define (ui-init)
    (let ((data (woo-read-first "/auth")))
    (form-update-value-list '("current_domain" 
	    "auth_type" "ldap_host" 
	    "ldap_ssl" "ldap_basedn") data)
    (form-update-enum "domain" (woo-list "/auth/avail_domain")))
    )

(define (hide_areas)
    (form-update-visibility '("local_area"
    "ldap_area" "krb5_area" "multi_area" 
    "pkcs11_area"
    ) #f))

(define (local_selected)
    (hide_areas)
    (form-update-visibility '("local_area") #t))

(define (ldap_changed)
    (form-update-value "ldap_basedn" "")
    (form-update-enum "local_bases" 
       (woo-list "/auth/local_bases"  
	'ldap_host (form-value "ldap_host")
	'ldap_ssl (form-value "ldap_ssl")))
    (form-bind "local_bases" "change" set_basedn)
    (show_bases)
)

(define (ldap_selected)
    (hide_areas)
    (form-update-visibility '("ldap_area") #t)
    (form-update-value "domain" "local")
    (form-update-enum "local_bases" 
       (woo-list "/auth/local_bases"  
	'ldap_host (form-value "ldap_host")
	'ldap_ssl (form-value "ldap_ssl")
	)
    )
    (form-bind "local_bases" "change" set_basedn)
    (form-update-value "local_bases" (form-value "ldap_basedn"))
)

(define (show_bases)
    (form-update-visibility '("local_bases") #t)
)

(define (set_basedn)
    (form-update-value "ldap_basedn" (form-value "local_bases"))
    (form-update-visibility '("local_bases") #f)
)

(define (krb5_selected)
    (hide_areas)
    (form-update-visibility '("krb5_area") #t))

(define (multi_selected)
    (hide_areas)
    (form-update-visibility '("multi_area") #t))

(define (pkcs11_selected)
    (hide_areas)
    (form-update-visibility '("pkcs11_area") #t))

(define (select_area)
     (let ( (type (car (string-cut-repeated (or (form-value "auth_type") "local") #\,))) )
      (cond
       ((string-ci=? type "local")(local_selected))
       ((string-ci=? type "ldap")(ldap_selected))
       ((string-ci=? type "krb5")(krb5_selected))
       ((string-ci=? type "multi")(multi_selected))
       ((string-ci=? type "pkcs11")(pkcs11_selected))
       (else (local_selected)))))

(define (init)
    (ui-init)
    (select_area)
    (form-bind "auth_type" "change" select_area)
    (form-bind "local_bases" "change" set_basedn)
    (form-bind "ldap_host" "change" ldap_changed)
    (form-bind "show_bdn" "click" show_bases)
)
