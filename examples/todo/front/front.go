package main

import (
	"api/api"
	"log"
	"net/http"
	"os"
)


var StoreServiceUrl = os.Getenv("STORE_SERVICE_URL")

func main() {

	if StoreServiceUrl=="" {
		log.Fatal("front server failed to lookup environment - STORE_SERVICE_URL and exited.")
	}
	router := api.NewRouter()
	addr :=":8080"
	log.Printf("front server is ready at - %s \n", addr)
	log.Fatal(http.ListenAndServe(addr, router))
}


