package main

import (
	"context"
	"crypto/tls"
	"flag"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"net/http/httptrace"
	"time"

	p "uptime/protos"

	"google.golang.org/grpc"
)

var (
	port = flag.Int("port", 50051, "The server port")
)

type server struct {
	p.UnimplementedUptimeServiceServer
}

func (s *server) Check(ctx context.Context, in *p.CheckRequest) (*p.CheckResponse, error) {
	response := p.CheckResponse{}

	start := time.Now()

	req, _ := http.NewRequest(in.GetMethod(), in.GetUrl(), nil)

	trace := &httptrace.ClientTrace{
		DNSDone: func(dnsInfo httptrace.DNSDoneInfo) {
			response.Dns = int32(time.Since(start).Milliseconds())
		},
		ConnectDone: func(network, addr string, err error) {
			response.Connect = int32(time.Since(start).Milliseconds())
		},
		TLSHandshakeDone: func(state tls.ConnectionState, err error) {
			response.Tls = int32(time.Since(start).Milliseconds())
		},
		GotFirstResponseByte: func() {
			response.FirstByte = int32(time.Since(start).Milliseconds())
		},
	}
	req = req.WithContext(httptrace.WithClientTrace(req.Context(), trace))

	transport := &http.Transport{
		DisableKeepAlives: true,
	}

	client := &http.Client{
		Transport: transport,
	}

	res, err := client.Do(req)

	if err != nil {
		log.Fatal(err)
	}

	bodyBytes, err := io.ReadAll(res.Body)

	if err != nil {
		log.Fatal(err)
	}

	defer res.Body.Close()

	response.Complete = int32(time.Since(start).Milliseconds())
	response.StatusCode = int32(res.StatusCode)
	response.ResponseBody = bodyBytes

	return &response, nil
}

func main() {
	flag.Parse()
	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", *port))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	s := grpc.NewServer()
	p.RegisterUptimeServiceServer(s, &server{})
	log.Printf("server listening at %v", lis.Addr())
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
