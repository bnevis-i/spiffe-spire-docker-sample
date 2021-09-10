package main

import (
	"crypto/tls"
	"crypto/x509"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
	"time"
)

func main() {
	log.SetFlags(log.Lshortfile)

	caPem, _ := ioutil.ReadFile("/tmp/bundle.0.pem")
	caCertPool := x509.NewCertPool()
	caCertPool.AppendCertsFromPEM(caPem)

	clientCert, err := tls.LoadX509KeyPair("/tmp/svid.0.pem", "/tmp/svid.0.key")
	if err != nil {
		log.Fatalf("loadcert failed : %v", err)
	}

	cfg := &tls.Config{
		MinVersion:       tls.VersionTLS13,
		Certificates:     []tls.Certificate{clientCert},
		CurvePreferences: []tls.CurveID{tls.CurveP521, tls.CurveP384, tls.CurveP256},
		RootCAs:          caCertPool,
	}

	c := http.Client{
		Timeout: 5 * time.Second,
		Transport: &http.Transport{
			IdleConnTimeout: 10 * time.Second,
			TLSClientConfig: cfg,
		},
	}

	r, err := http.NewRequest(http.MethodGet, "https://spiffe-service1/", nil)
	if err != nil {
		log.Fatalf("request failed : %v", err)
	}

	jwtBytes, _ := ioutil.ReadFile("/tmp/svid.0.jwt")
	jwt := strings.TrimSpace(string(jwtBytes))
	r.Header.Add("Authorization", "Bearer "+jwt)

	resp, err := c.Do(r)
	if err != nil {
		log.Fatalf("request failed : %v", err)
	}

	defer resp.Body.Close()
	body, _ := io.ReadAll(resp.Body)

	log.Println(string(body))
}
