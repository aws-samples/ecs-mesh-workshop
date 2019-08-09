package main

import (
	"log"
	"net/http"
	"store/api"
)

func main() {
	// Initial local cache
	api.LocalCache = make(map[string]api.Todo)

	// Run internal queue
	api.ProcessMessage()

	router := api.NewRouter()
	addr :=":9080"
	log.Printf("store server is ready at - %s \n", addr)
	log.Fatal(http.ListenAndServe(addr, router))
}