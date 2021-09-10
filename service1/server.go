package main

import (
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

func main() {
	fmt.Fprintf(os.Stdout, "Starting server\n")
	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
		w.Write([]byte("This is an example server.\n"))
		authHeader := req.Header.Get("Authorization")
		fmt.Fprintf(os.Stdout, "Received request:\n")
		fmt.Fprintf(os.Stdout, "Authorization: %s\n", authHeader)
		// In real code, if get a JWT, verify the signature of the JWT, then verify the Audience,
		// then extract SVID out of subject field, and parse for EdgeX service key.
		for _, certs := range req.TLS.VerifiedChains {
			for _, cert := range certs {
				fmt.Fprintf(os.Stdout, "Certificate: %s\n", cert.Subject.String())
				for _, uri := range cert.URIs {
					fmt.Fprintf(os.Stdout, "URI: %s\n", uri.String())
					// First certificate in verified chain has URI list,
					// one of which is the SVID containing the EdgeX service key
				}
			}
		}
		// This code should accept either a verified client certificate OR a verified JWT
		// and exchange it for a valid secret store token.
	})

	caPem, _ := ioutil.ReadFile("/tmp/bundle.0.pem")
	certPool := x509.NewCertPool()
	certPool.AppendCertsFromPEM(caPem)

	cfg := &tls.Config{
		MinVersion:               tls.VersionTLS13,
		ClientAuth:               tls.VerifyClientCertIfGiven, //tls.RequireAndVerifyClientCert, //tls.VerifyClientCertIfGiven,
		ClientCAs:                certPool,
		CurvePreferences:         []tls.CurveID{tls.CurveP521, tls.CurveP384, tls.CurveP256},
		PreferServerCipherSuites: true,
		RootCAs:                  certPool,
	}
	srv := &http.Server{
		Addr:         ":443",
		Handler:      mux,
		TLSConfig:    cfg,
		TLSNextProto: make(map[string]func(*http.Server, *tls.Conn, http.Handler), 0),
	}
	log.Fatal(srv.ListenAndServeTLS("/tmp/svid.0.pem", "/tmp/svid.0.key"))
}
