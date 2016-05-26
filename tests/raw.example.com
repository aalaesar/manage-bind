$ttl 3d
$ORIGIN example.com.
@           IN  SOA     srvdns01.example.com.     admin.example.com.  (
                2016052604    ; serial
                12h      ; refresh
                30m      ; retry
                3w      ; expire
                2h30m      ; negative
                )
@			IN	NS	srvdns01.example.com.

ftp.domain.tld.		IN	A	95.38.94.196
host1		IN	A	12.34.56.78
@		IN	A	127.0.0.1
srvdns01.example.com.		IN	A	127.0.0.1
mailsrv		IN	A	98.76.54.32

@		IN	AAAA	fe80:cafe:fa:1::1de
srvdns01.example.com.		IN	AAAA	fe80:cafe:fa:1::1de
mailsrv		IN	AAAA	fe80:cafe::bafe

@		3w IN	MX 10	mailsrv
@		 IN	MX 20	backup.fqdn.

_http._tcp.example.com.	IN	SRV	1 1 80	host1
_ftp._tcp	IN	SRV	1 1 21	ftp

ftp 			IN	CNAME	host1
www			IN	CNAME	@
webmail			IN	CNAME	@

@			IN	TXT	"v=spf1 mx -all"
mail._domainkey			IN	TXT	( "v=DKIM1; k=rsa; t=s; n=core; p=someverylongstringbecausethisisakeyformailsecurity" )  ; ----- DKIM key mail for example.com

