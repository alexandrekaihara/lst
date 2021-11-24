#!/bin/bash

cat > /etc/dovecot/dovecot.conf <<EOF
auth_mechanisms = plain login
log_timestamp = "%Y-%m-%d %H:%M:%S "
passdb {
  args = /etc/dovecot/dovecot-mysql.conf
  driver = sql
}
namespace inbox {
  inbox = yes
  location =
  separator = .
  prefix =
  mailbox Drafts {
    auto = subscribe
    special_use = \Drafts
  }
  mailbox Sent {
    auto = subscribe
    special_use = \Sent
  }
  mailbox Trash {
    auto = subscribe
    special_use = \Trash
  }
  mailbox Junk {
    auto = subscribe
    special_use = \Junk
  }
}
protocols = imap pop3
service auth {
  unix_listener /var/spool/postfix/private/auth_dovecot {
    group = postfix
    mode = 0660
    user = postfix
  }
  unix_listener auth-master {
    mode = 0600
    user = vmail
  }
  user = root
}
listen = *
ssl_cert = </etc/postfix/sslcert/mailserver.crt
ssl_key = </etc/postfix/sslcert/mailserver.key
ssl_min_protocol = !SSLv3
ssl_cipher_list = EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:+CAMELLIA256:+AES256:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!ECDSA:CAMELLIA256-SHA:AES256-SHA:CAMELLIA128-SHA:AES128-SHA
userdb {
  args = /etc/dovecot/dovecot-mysql.conf
  driver = sql
}
protocol pop3 {
  pop3_uidl_format = %08Xu%08Xv
}
protocol lda {
  auth_socket_path = /var/run/dovecot/auth-master
  postmaster_address = postmaster@mailserver.com
}
EOF
